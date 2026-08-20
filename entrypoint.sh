#!/bin/sh
set -e

if [ ! -f /opt/data/config.yaml ]; then
  echo "[bootstrap] seeding config.yaml (first boot)"
  envsubst '${HERMES4_BASE_URL} ${HERMES4_MODEL_NAME}' < /opt/seed/config.yaml.tmpl > /opt/data/config.yaml
fi

if [ ! -f /opt/data/honcho.json ] && [ -n "${HONCHO_BASE_URL:-}" ]; then
  echo "[bootstrap] seeding honcho.json (first boot)"
  printf '{"baseUrl": "%s"}' "$HONCHO_BASE_URL" > /opt/data/honcho.json
fi

# Custom dashboard themes are static definitions, not user-mutable state
# like config.yaml -- sync them from the image every boot so a theme
# tweak shipped in a new image actually lands on redeploy. The active
# theme SELECTION lives in config.yaml (dashboard.theme), untouched here.
mkdir -p /opt/data/dashboard-themes
cp -f /opt/seed/dashboard-themes/*.yaml /opt/data/dashboard-themes/ 2>/dev/null || true

# Real bug found live: a hand-written minimal config.yaml (no
# _config_version, none of the other scaffold fields a real `hermes
# setup` run would add) resolves fine through `hermes config get` but
# silently sends an EMPTY model field on real chat requests (HTTP 400
# "model is required") -- config migrate fills in the missing schema and
# fixes it. Safe to run every boot: no-ops (exits 0, no prompt hang) once
# already migrated.
hermes config migrate

nginx -g "daemon off;" &

# Register this gateway as its own "peer" over the loopback-only API
# server, so `hermes peer dm local/<bot>` can deliver a message into any
# local bot's canonical Bot Chat -- the supported mechanism for bot-to-bot
# messaging (peer dm works identically same-host or cross-host; there is
# no separate "local" verb). `peer add` is an upsert (aliased `set`), so
# safe to run unconditionally on every boot -- but the API server needs a
# few seconds to actually start listening first.
(
  for _ in $(seq 1 15); do
    curl -s -o /dev/null -m 2 "http://127.0.0.1:${API_SERVER_PORT:-8642}/health" && break
    sleep 2
  done
  hermes peer add local --url "http://127.0.0.1:${API_SERVER_PORT:-8642}" --key "$API_SERVER_KEY" \
    --note "self -- same-gateway bot-to-bot delivery" || true
) &

# HERMES_DASHBOARD=1 alone does NOT start the dashboard as part of
# `gateway run` -- real bug found live: port 9119 never opened, `gateway
# run` only starts messaging/cron. The dashboard is its own process;
# HERMES_DASHBOARD_HOST/PORT (set in the Dockerfile) configure it once it
# is actually launched.
hermes dashboard --host 0.0.0.0 --port 9119 --no-open &

exec hermes gateway run
