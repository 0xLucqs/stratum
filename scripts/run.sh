#!/bin/bash

set -euo pipefail

# === Paths ===
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SESSION_NAME="sv2lab"
BITCOIN_ARCHIVE_NAME="bitcoin-sv2-tp-0.1.15-arm64-apple-darwin-unsigned.tar.gz"
BITCOIN_URL="https://github.com/0xLucqs/bitcoin/releases/download/sv2-tp-0.1.15/$BITCOIN_ARCHIVE_NAME"
BITCOIN_DIR="$REPO_ROOT/bitcoin-sv2-tp-0.1.15"
BITCOIN_BIN="$BITCOIN_DIR/bin/bitcoind"
BITCOIN_CONF="$BITCOIN_DIR/bitcoin.conf"
BITCOIN_ARCHIVE="$REPO_ROOT/$BITCOIN_ARCHIVE_NAME"
CPUMINER_BIN="$REPO_ROOT/cpuminer/minerd"

# === Download and unpack bitcoind if missing ===
if [ ! -x "$BITCOIN_BIN" ]; then
  echo "📦 bitcoind not found. Downloading from GitHub..."
  curl -L "$BITCOIN_URL" -o "$BITCOIN_ARCHIVE"
  tar -xvf "$BITCOIN_ARCHIVE" -C "$REPO_ROOT"
  rm "$BITCOIN_ARCHIVE"
  echo "✅ bitcoind extracted to $BITCOIN_DIR"
fi

# === Write bitcoin.conf if missing ===
if ! grep -q "rpcuser=username" "$BITCOIN_CONF" 2>/dev/null; then
  cat <<EOF > "$BITCOIN_CONF"
[testnet4]
server=1
rpcuser=username
rpcpassword=password
EOF
fi


# === Kill any existing session ===
tmux kill-session -t "$SESSION_NAME" 2>/dev/null || true

# === Start bitcoind in a new tmux session ===
tmux new-session -d -s "$SESSION_NAME" -n sv2
tmux send-keys -t "$SESSION_NAME":0 "$BITCOIN_BIN -testnet4 -sv2 -sv2port=8442 -sv2interval=20 -sv2feedelta=1000 -debug=sv2 -loglevel=sv2:trace -conf=$BITCOIN_CONF" C-m

until curl -s --user username:password http://127.0.0.1:48332/ -d '{"jsonrpc":"2.0","id":0,"method":"uptime"}' -H "Content-Type: application/json" | grep -q '"result"'; do
  echo "⏳ Waiting for bitcoind RPC to become ready..."
  sleep 1
done

# === Component commands (all relative to $REPO_ROOT) ===
declare -a COMPONENTS=(
  "cd roles/pool/config-examples && cargo run --release -- -c pool-config-local-tp-example.toml"
  "cd roles/jd-server/config-examples && cargo run --release -- -c jds-config-local-example.toml"
  "cd roles/jd-client/config-examples && cargo run --release -- -c jdc-config-local-example.toml"
  "cd roles/translator/config-examples && cargo run --release -- -c tproxy-config-local-jdc-example.toml"
)

# === Optionally add cpuminer ===
if [ -x "$CPUMINER_BIN" ]; then
  COMPONENTS+=("cd cpuminer && ./minerd -a sha256d -o stratum+tcp://localhost:34255 -q -D -P")
fi

# === Start components in new panes ===
for cmd in "${COMPONENTS[@]}"; do
  tmux split-window -t "$SESSION_NAME" -v
  tmux select-layout -t "$SESSION_NAME" tiled
  tmux send-keys -t "$SESSION_NAME" "cd $REPO_ROOT && $cmd" C-m
done

# === Layout and attach ===
tmux select-layout -t "$SESSION_NAME" tiled
tmux attach -t "$SESSION_NAME"

