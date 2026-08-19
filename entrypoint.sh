#!/bin/sh
set -e

if [ ! -f /opt/data/config.yaml ]; then
  echo "[bootstrap] seeding config.yaml (first boot)"
  envsubst '${HERMES4_BASE_URL} ${HERMES4_MODEL_NAME}' < /opt/seed/config.yaml.tmpl > /opt/data/config.yaml
fi

nginx -g "daemon off;" &

exec hermes gateway run
