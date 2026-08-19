#!/bin/sh
set -e

if [ ! -f /opt/data/config.yaml ]; then
  echo "[bootstrap] seeding config.yaml (first boot)"
  envsubst '${HERMES4_BASE_URL} ${HERMES4_MODEL_NAME}' < /opt/seed/config.yaml.tmpl > /opt/data/config.yaml
fi

# Real bug found live: a hand-written minimal config.yaml (no
# _config_version, none of the other scaffold fields a real `hermes
# setup` run would add) resolves fine through `hermes config get` but
# silently sends an EMPTY model field on real chat requests (HTTP 400
# "model is required") -- config migrate fills in the missing schema and
# fixes it. Safe to run every boot: no-ops (exits 0, no prompt hang) once
# already migrated.
hermes config migrate

nginx -g "daemon off;" &

# HERMES_DASHBOARD=1 alone does NOT start the dashboard as part of
# `gateway run` -- real bug found live: port 9119 never opened, `gateway
# run` only starts messaging/cron. The dashboard is its own process;
# HERMES_DASHBOARD_HOST/PORT (set in the Dockerfile) configure it once it
# is actually launched.
hermes dashboard --host 0.0.0.0 --port 9119 --no-open &

exec hermes gateway run
