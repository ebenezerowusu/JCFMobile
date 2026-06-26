#!/bin/bash
# SessionStart hook — ensures the Flutter SDK is available for web sessions
# so the monorepo can be analyzed, tested, and built.
#
# Runs in async mode because the first install downloads ~1.5 GB; subsequent
# sessions reuse the cached container state and the install step is skipped.
set -euo pipefail

echo '{"async": true, "asyncTimeout": 600000}'

# Only run in Claude Code on the web (remote) sessions.
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FLUTTER_DIR="${FLUTTER_DIR:-$HOME/flutter}"
FLUTTER_BIN="$FLUTTER_DIR/bin"

install_flutter() {
  echo "[session-start] Installing Flutter stable to $FLUTTER_DIR ..."
  local json url tmp
  json="$(curl -fsSL --max-time 60 \
    'https://storage.googleapis.com/flutter_infra_release/releases/releases_linux.json')"
  url="$(printf '%s' "$json" | python3 -c "import sys,json; d=json.load(sys.stdin); h=d['current_release']['stable']; r=[x for x in d['releases'] if x['hash']==h and x['channel']=='stable'][0]; print(d['base_url']+'/'+r['archive'])")"
  tmp="$(mktemp -d)"
  curl -fsSL --max-time 580 -o "$tmp/flutter.tar.xz" "$url"
  mkdir -p "$(dirname "$FLUTTER_DIR")"
  tar -xf "$tmp/flutter.tar.xz" -C "$(dirname "$FLUTTER_DIR")"
  rm -rf "$tmp"
}

# Idempotent: only install if the SDK is missing.
if [ ! -x "$FLUTTER_BIN/flutter" ]; then
  install_flutter
else
  echo "[session-start] Flutter already present at $FLUTTER_DIR"
fi

export PATH="$FLUTTER_BIN:$PATH"
git config --global --add safe.directory "$FLUTTER_DIR" 2>/dev/null || true

# Configure non-interactively (idempotent).
flutter config --no-analytics >/dev/null 2>&1 || true
flutter --version || true

# Persist PATH (and a shared pub cache) for the rest of the session.
if [ -n "${CLAUDE_ENV_FILE:-}" ]; then
  {
    echo "export PATH=\"$FLUTTER_BIN:\$PATH\""
    echo "export PUB_CACHE=\"$HOME/.pub-cache\""
  } >> "$CLAUDE_ENV_FILE"
fi

echo "[session-start] Flutter ready."
