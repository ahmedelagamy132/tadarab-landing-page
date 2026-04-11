import json
import os
import hashlib
import secrets
import time
from flask import Flask, request, jsonify

app = Flask(__name__)

# ── Config ──────────────────────────────────────────────
BASE_DIR      = os.path.dirname(__file__)
PRICE_FILE    = os.path.join(BASE_DIR, 'price_data.json')
TOKENS_FILE   = os.path.join(BASE_DIR, 'tokens.json')
SALT          = 'miduva-price-salt-2024'
ITERATIONS    = 250_000
TOKEN_TTL     = 8 * 60 * 60   # 8-hour session tokens (survive normal work sessions)
MAX_ATTEMPTS  = 5
LOCKOUT_SEC   = 15 * 60        # 15-minute lockout

# PBKDF2-SHA256 of "M0hamed@Askar#2026" with the salt above
PASSWORD_HASH = '9e1d17e7123c33525e0f4f6fb4a0a80565064ef73a5fe0754cbd2c6980d04f66'

# In-memory rate-limit store (OK to reset on restart — security feature)
_attempts = {}   # ip -> [timestamp, ...]

DEFAULT_PRICE = {
    'price': '3310',
    'currency': 'ج.م',
    'origPrice': '10345',
    'discount': '68%'
}

# ── Token persistence ────────────────────────────────────
# Tokens are saved to disk so they survive server restarts and work
# correctly across multiple gunicorn workers.

def _load_tokens() -> dict:
    """Read tokens from disk, dropping any that have already expired."""
    if not os.path.exists(TOKENS_FILE):
        return {}
    try:
        with open(TOKENS_FILE) as f:
            raw = json.load(f)
        now = time.time()
        return {k: v for k, v in raw.items() if v > now}
    except Exception:
        return {}

def _save_tokens(tokens: dict):
    """Write only non-expired tokens to disk (atomic write via temp file)."""
    now = time.time()
    valid = {k: v for k, v in tokens.items() if v > now}
    tmp = TOKENS_FILE + '.tmp'
    with open(tmp, 'w') as f:
        json.dump(valid, f)
    os.replace(tmp, TOKENS_FILE)   # atomic on POSIX

def make_token() -> str:
    tokens = _load_tokens()
    token  = secrets.token_hex(32)
    tokens[token] = time.time() + TOKEN_TTL
    _save_tokens(tokens)
    return token

def is_valid_token(token: str) -> bool:
    tokens = _load_tokens()
    exp = tokens.get(token)
    if not exp:
        return False
    if time.time() > exp:
        tokens.pop(token, None)
        _save_tokens(tokens)
        return False
    # Sliding expiry — each use extends the session
    tokens[token] = time.time() + TOKEN_TTL
    _save_tokens(tokens)
    return True

def revoke_token(token: str):
    tokens = _load_tokens()
    tokens.pop(token, None)
    _save_tokens(tokens)

# ── Helpers ─────────────────────────────────────────────
def verify_password(pw: str) -> bool:
    dk = hashlib.pbkdf2_hmac('sha256', pw.encode(), SALT.encode(), ITERATIONS)
    return dk.hex() == PASSWORD_HASH

def check_rate_limit(ip: str) -> tuple[bool, int]:
    """Returns (is_locked, seconds_remaining)"""
    now = time.time()
    window = now - LOCKOUT_SEC
    times = [t for t in _attempts.get(ip, []) if t > window]
    _attempts[ip] = times
    if len(times) >= MAX_ATTEMPTS:
        remaining = int(times[0] + LOCKOUT_SEC - now) + 1
        return True, remaining
    return False, 0

def record_attempt(ip: str):
    _attempts.setdefault(ip, []).append(time.time())

def get_client_ip() -> str:
    return request.headers.get('X-Real-IP') or \
           request.headers.get('X-Forwarded-For', '').split(',')[0].strip() or \
           request.remote_addr or '0.0.0.0'

def load_price() -> dict:
    if os.path.exists(PRICE_FILE):
        try:
            with open(PRICE_FILE) as f:
                return json.load(f)
        except Exception:
            pass
    return DEFAULT_PRICE

def save_price(data: dict):
    safe = {
        'price':     str(data.get('price', '')),
        'currency':  str(data.get('currency', '')),
        'origPrice': str(data.get('origPrice', '')),
        'discount':  str(data.get('discount', '')),
    }
    tmp = PRICE_FILE + '.tmp'
    with open(tmp, 'w') as f:
        json.dump(safe, f)
    os.replace(tmp, PRICE_FILE)    # atomic write — no partial reads

def cors(resp):
    resp.headers['Access-Control-Allow-Origin']  = '*'
    resp.headers['Access-Control-Allow-Headers'] = 'Content-Type, Authorization'
    resp.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
    return resp

# ── Routes ──────────────────────────────────────────────
@app.after_request
def add_cors(resp):
    return cors(resp)

@app.route('/api/verify', methods=['GET', 'OPTIONS'])
def verify_token():
    if request.method == 'OPTIONS':
        return jsonify({}), 200
    auth  = request.headers.get('Authorization', '')
    token = auth.removeprefix('Bearer ').strip()
    if not is_valid_token(token):
        return jsonify({'error': 'غير مصرح'}), 401
    return jsonify({'ok': True})

@app.route('/api/price', methods=['GET', 'OPTIONS'])
def get_price():
    if request.method == 'OPTIONS':
        return jsonify({}), 200
    return jsonify(load_price())

@app.route('/api/login', methods=['POST', 'OPTIONS'])
def login():
    if request.method == 'OPTIONS':
        return jsonify({}), 200

    ip = get_client_ip()
    locked, remaining = check_rate_limit(ip)
    if locked:
        mins = (remaining // 60) + 1
        return jsonify({'error': f'محظور — انتظر {mins} دقيقة'}), 429

    data = request.get_json(silent=True) or {}
    pw   = data.get('password', '')

    # Constant-time delay to resist timing attacks
    time.sleep(0.6)

    if not pw or not verify_password(pw):
        record_attempt(ip)
        attempts_left = MAX_ATTEMPTS - len(_attempts.get(ip, []))
        return jsonify({'error': f'كلمة المرور غير صحيحة — متبقي {max(0,attempts_left)} محاولة'}), 401

    _attempts.pop(ip, None)
    return jsonify({'token': make_token()})

@app.route('/api/price', methods=['POST', 'OPTIONS'])
def set_price():
    if request.method == 'OPTIONS':
        return jsonify({}), 200

    auth  = request.headers.get('Authorization', '')
    token = auth.removeprefix('Bearer ').strip()
    if not is_valid_token(token):
        return jsonify({'error': 'غير مصرح'}), 401

    data = request.get_json(silent=True)
    if not data or not data.get('price'):
        return jsonify({'error': 'بيانات غير صالحة'}), 400

    save_price(data)
    return jsonify({'ok': True})

@app.route('/api/logout', methods=['POST', 'OPTIONS'])
def logout():
    if request.method == 'OPTIONS':
        return jsonify({}), 200
    auth  = request.headers.get('Authorization', '')
    token = auth.removeprefix('Bearer ').strip()
    revoke_token(token)
    return jsonify({'ok': True})

if __name__ == '__main__':
    app.run(host='127.0.0.1', port=5001)
