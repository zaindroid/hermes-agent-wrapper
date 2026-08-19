FROM nousresearch/hermes-agent:latest

# nginx: single point on the fleet's standard port 8080 that (a) answers
# Coolify's hardcoded GET /health with a static 200 -- Hermes' own /health
# lives on the API-server port, which is intentionally left disabled here
# -- and (b) proxies everything else to the dashboard on 9119, with proper
# websocket-upgrade headers for its embedded Chat tab (/api/ws, /api/pty).
# gettext-base: envsubst, for templating config.yaml on first boot only.
RUN apt-get update && apt-get install -y --no-install-recommends nginx gettext-base \
    && rm -rf /var/lib/apt/lists/*

# Bound non-loopback deliberately -- Hermes' own auth gate only engages
# for a non-loopback bind. nginx sits in front too, but the point is
# Hermes enforces its own basic-auth regardless of the proxy layer.
ENV HERMES_DASHBOARD=1
ENV HERMES_DASHBOARD_HOST=0.0.0.0
ENV HERMES_DASHBOARD_PORT=9119

# API server: loopback-ONLY (127.0.0.1), never exposed via nginx/tunnel --
# its sole purpose is letting `hermes peer dm local/<bot>` deliver into
# another local bot's canonical Bot Chat (see entrypoint.sh's peer
# registration). API_SERVER_KEY is generate:hex in app.yaml -- the
# entrypoint reads it from its own process env to register the peer, no
# human ever needs to see or type it.
ENV API_SERVER_ENABLED=true
ENV API_SERVER_HOST=127.0.0.1
ENV API_SERVER_PORT=8642

COPY nginx.conf /etc/nginx/conf.d/hermes.conf
COPY config.yaml.tmpl /opt/seed/config.yaml.tmpl
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
