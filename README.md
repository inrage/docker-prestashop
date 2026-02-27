# Docker PrestaShop

[![Docker Pulls](https://img.shields.io/docker/pulls/inrage/docker-prestashop.svg)](https://hub.docker.com/r/inrage/docker-prestashop)
[![Docker Stars](https://img.shields.io/docker/stars/inrage/docker-prestashop.svg)](https://hub.docker.com/r/inrage/docker-prestashop)
[![Docker Image Size](https://img.shields.io/docker/image-size/inrage/docker-prestashop.svg)](https://hub.docker.com/r/inrage/docker-prestashop)

Production-ready Docker image for PrestaShop 1.7 websites. Based on Debian Bookworm with Apache 2.4 and PHP via [Sury](https://packages.sury.org/php/) repository.

Key features:

- [Docker Hub](https://hub.docker.com/r/inrage/docker-prestashop)
- Modern Apache 2.4.66 across all PHP versions
- Production-optimized PHP configuration (OPcache, realpath cache, memory limits)
- Security hardening (ServerTokens, security headers, expose_php off)
- GZIP compression and browser caching for static assets
- Real client IP support behind reverse proxy (Traefik)
- Memcached extension included

## Supported Tags

| Tag | PHP | Apache | Base |
|-----|-----|--------|------|
| `8.0` | PHP 8.0.30 | Apache 2.4.66 | Debian Bookworm |
| `7.4`, `latest` | PHP 7.4.33 | Apache 2.4.66 | Debian Bookworm |
| `7.2` | PHP 7.2.34 | Apache 2.4.66 | Debian Bookworm |

## Quick Start

```bash
docker run -d -p 80:80 -v $(pwd):/var/www/html inrage/docker-prestashop:7.4
```

## Installation

Mount your PrestaShop source code into `/var/www/html`. The image is a runtime only — it does not include PrestaShop source code.

### Docker Compose

```yaml
services:
  prestashop:
    image: inrage/docker-prestashop:7.4
    volumes:
      - ./src:/var/www/html
    ports:
      - "8080:80"
```

### Docker Swarm with Traefik

```yaml
version: "3.8"

services:
  web:
    image: inrage/docker-prestashop:7.4
    networks:
      database:
      traefik-public:
    volumes:
      - /host/website/myshop:/var/www/html
    deploy:
      replicas: 1
      labels:
        - traefik.enable=true
        - traefik.docker.network=traefik-public
        - traefik.constraint-label=traefik-public
        - traefik.http.routers.myshop-http.rule=Host(`shop.example.com`)
        - traefik.http.routers.myshop-http.entrypoints=http
        - traefik.http.routers.myshop-http.middlewares=https-redirect
        - traefik.http.routers.myshop-https.rule=Host(`shop.example.com`)
        - traefik.http.routers.myshop-https.entrypoints=https
        - traefik.http.routers.myshop-https.tls=true
        - traefik.http.routers.myshop-https.tls.certresolver=le
        - traefik.http.services.myshop.loadbalancer.server.port=80

networks:
  database:
    external: true
  traefik-public:
    external: true
```

## PHP Extensions

bcmath, curl, dom, fileinfo, gd, iconv, intl, json, mbstring, mysql, opcache, simplexml, xml, zip, memcached

## PHP Configuration

| Setting | Value |
|---------|-------|
| `memory_limit` | `512M` |
| `max_execution_time` | `300` |
| `max_input_time` | `300` |
| `max_input_vars` | `10000` |
| `upload_max_filesize` | `64M` |
| `post_max_size` | `64M` |
| `opcache.memory_consumption` | `256M` |
| `opcache.revalidate_freq` | `60` |
| `realpath_cache_size` | `4096K` |
| `session.cookie_httponly` | `1` |
| `session.cookie_secure` | `1` |
| `expose_php` | `Off` |

## Apache Modules

| Module | Purpose |
|--------|---------|
| `rewrite` | Friendly URLs |
| `headers` | Security headers |
| `deflate` | GZIP compression |
| `expires` | Browser caching |
| `ssl` | HTTPS support |
| `remoteip` | Real IP behind reverse proxy |

## Security Headers

The image sets the following headers by default:

- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: SAMEORIGIN`
- `X-XSS-Protection: 1; mode=block`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `ServerTokens Prod` (no version disclosure)

## Build Locally

```bash
docker build --build-arg PHP_VERSION=7.4 -t inrage/docker-prestashop:7.4 .
docker build --build-arg PHP_VERSION=7.2 -t inrage/docker-prestashop:7.2 .
docker build --build-arg PHP_VERSION=8.0 -t inrage/docker-prestashop:8.0 .
```

## License

MIT
