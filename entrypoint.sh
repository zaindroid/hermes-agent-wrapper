#!/bin/sh
set -e

if [ ! -f /opt/data/config.yaml ]; then
  echo "[bootstrap] seeding config.yaml (first boot)"
  envsubst '${HERMES4_BASE_URL} ${HERMES4_MODEL_NAME}' < /opt/seed/config.yaml.tmpl > /opt/data/config.yaml
fi

nginx -g "daemon off;" &

# HERMES_DASHBOARD=1 alone does NOT start the dashboard as part of
# `gateway run` -- real bug found live: port 9119 never opened, `gateway
# run` only starts messaging/cron. The dashboard is its own process;
# HERMES_DASHBOARD_HOST/PORT (set in the Dockerfile) configure it once it
# is actually launched.
hermes dashboard --host 0.0.0.0 --port 9119 --no-open &

exec hermes gateway run
