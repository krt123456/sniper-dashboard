#!/bin/bash
# Pull fresh data.json from VPS, commit+push to GitHub Pages. Run every minute via cron.
set -e
DASH=/home/krt/.ai-shared/sniper-dashboard
cd "$DASH"
# 1) VPS exports fresh json, 2) scp it here
ssh -o StrictHostKeyChecking=no -o ConnectTimeout=15 root@185.222.242.112 \
  'cd /root/listing-sniper && .venv/bin/python tools/export_dashboard.py >/dev/null 2>&1' || exit 0
scp -o StrictHostKeyChecking=no -o ConnectTimeout=15 \
  root@185.222.242.112:/root/listing-sniper/dashboard_export/data.json "$DASH/data.json" || exit 0
# 3) commit+push only if changed
if ! git diff --quiet data.json 2>/dev/null; then
  git add data.json
  git -c user.email=bot@local -c user.name=bot commit -q -m "data $(date -u +%H:%M)" >/dev/null 2>&1 || true
  git push -q origin master >/dev/null 2>&1 || true
fi
