This repo uses traefik to setup a reverse proxy on localhost:80 & localhost:443 that proxies traffic to your docker contains. By default every container will be available at `http://containerName.test` and you can enable TLS or a custom HOST for your container with a simple set of labels.

### Requirements
- Mac OS
- Docker
- Homebrew

### Clone the repository
To start, clone this repository. I cloned it into `$HOME/.config/traefik`

### Create a proxy docker network
```
docker networks create proxy
```

### Install dnsmasq to route `.test` domains to localhost
``` bash
brew install dnsmasq
```

### Add `.test` domain to dnsmasq configuration
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

### Start dnsmasq through homebrew
``` bash
brew services stop dnsmasq && brew services start dnsmasq
```

### Generate certificates for .test domain
``` bash
(cd certs && bash test-cert.bash)
```

### Run traefik as a container on the proxy network
``` bash
docker-compose up -d
```

### Test that everything works
Visit the dashboard: `http://traefik.proxy.test`

All docker containers that exist within the `proxy` network are proxied by traefik.

Docker-compose containers are hosted at `http://(projectName).(serviceName).test` or docker containers with a custom name are hosted at `http://(containerName).test`

To add a container to the proxy network in a docker-compose file, you can add the following:
```
version: "3.3"
services
  serviceName
    networks:
      - proxy

networks:
  proxy:
    external: true
```

### Enable TLS Support
Within your docker compose file, add the following labels to enable TLS:
```
version: "3.3"
services
  serviceName
    labels:
      # Enables redirect to https, replace `containerName`
      - "traefik.http.routers.containerName-insecure.entrypoints=web"
      - "traefik.http.routers.containerName-insecure.middlewares=redirect-to-https"

      # Enables TLS with a self-signed .test certificate
      - "traefik.http.routers.containerName.tls=true"
```