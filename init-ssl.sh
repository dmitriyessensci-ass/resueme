#!/bin/bash
# Первый запуск: получает сертификат и поднимает всё на 443.
# Повторный запуск: просто стартует, если сертификат уже есть.
#
# Использование:
#   DOMAIN=resume.example.com EMAIL=you@example.com ./init-ssl.sh

set -euo pipefail

DOMAIN="${DOMAIN:?Укажи DOMAIN=your-domain.com}"
EMAIL="${EMAIL:?Укажи EMAIL=your@email.com}"
CERT_DIR="./nginx/certbot/conf/live/$DOMAIN"

echo "[init] Domain: $DOMAIN"

# Создаём нужные директории
mkdir -p nginx/logs nginx/certbot/conf nginx/certbot/www

if [ -f "$CERT_DIR/fullchain.pem" ]; then
    echo "[init] Сертификат уже есть, запускаем всё..."
    DOMAIN="$DOMAIN" podman-compose up -d
    echo "[init] Готово → https://$DOMAIN"
    exit 0
fi

# --- Первый запуск ---

echo "[init] Сертификата нет. Создаём временный self-signed для старта nginx..."
mkdir -p "$CERT_DIR"
openssl req -x509 -nodes -newkey rsa:2048 \
    -keyout "$CERT_DIR/privkey.pem" \
    -out    "$CERT_DIR/fullchain.pem" \
    -days 1 \
    -subj "/CN=$DOMAIN" 2>/dev/null

echo "[init] Поднимаем resume + nginx на временном сертификате..."
DOMAIN="$DOMAIN" podman-compose up -d resume nginx-proxy

echo "[init] Ждём готовности nginx (5 сек)..."
sleep 5

echo "[init] Запрашиваем сертификат у Let's Encrypt..."
podman run --rm \
    -v "$(pwd)/nginx/certbot/conf:/etc/letsencrypt" \
    -v "$(pwd)/nginx/certbot/www:/var/www/certbot" \
    certbot/certbot certonly \
    --webroot \
    --webroot-path=/var/www/certbot \
    --email "$EMAIL" \
    --agree-tos \
    --no-eff-email \
    --force-renewal \
    -d "$DOMAIN"

echo "[init] Перезагружаем nginx с настоящим сертификатом..."
podman-compose exec nginx-proxy nginx -s reload

echo "[init] Поднимаем certbot-renew для автообновления..."
DOMAIN="$DOMAIN" podman-compose up -d certbot-renew

echo ""
echo "[init] ✓ Готово! Сайт доступен: https://$DOMAIN"
