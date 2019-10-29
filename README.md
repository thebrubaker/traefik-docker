A traefik setup on localhost 80 & 443 that proxies traffic to your docker contains.

### Requirements
- Mac OS
- Docker
- Homebrew

### Create a proxy docker network
```
docker networks create proxy
```

### Install dnsmasq to route .test domains to localhost
``` bash
brew install dnsmasq
```

### Add .test domain to dnsmasq configuration
``` bash
echo $(brew --prefix)/etc/dnsmasq.conf >> address=/.test/127.0.0.1
```

### Add .test domain to resolvers
``` bash
cat > /etc/resolvers/test <<EOF
nameserver 127.0.0.1
domain test
search_order 1
EOF
```

### Generate certificates for .test domain
``` bash
(cd certs && bash test-cert.bash)
```

### Run traefik
``` bash
docker-compose up -d
```

### Test that everything works
Visit the dashboard: `http://traefik.proxy.test`

All docker containers that are part of the `proxy` network are proxied by traefik.

Docker-compose containers are hosted at `http://(projectName).(serviceName).test`
Docker containers are hosted at `http://(containerName).test`

### Enable TLS Support
Within your docker compose file, add the following labels:
```
    networks:
      - proxy
    labels:
      # Enables redirect to https, replace `containerName`
      - "traefik.http.routers.containerName-insecure.entrypoints=web"
      - "traefik.http.routers.containerName-insecure.middlewares=redirect-to-https"

      # Enables TLS with a self-signed .test certificate
      - "traefik.http.routers.containerName.tls=true"

networks:
  proxy:
    external: true
```