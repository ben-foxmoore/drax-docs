FROM quay.io/oauth2-proxy/oauth2-proxy:v7.3.0

ENTRYPOINT [ "sh", "-c", "/bin/oauth2-proxy --upstream=http://${UPSTREAM}" ]
