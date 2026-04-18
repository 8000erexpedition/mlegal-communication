#!/usr/bin/env bash
# Deploy zur Subdomain demo.before-7.com via SSH/SFTP.
# Ersetzt nur die Website-Dateien — .htaccess und .htpasswd bleiben unberuehrt.
#
# Nutzung:
#   ./deploy.sh           # deployt v5-linen.html als index.html
#   ./deploy.sh v5b       # deployt v5b-linen-blue.html als index.html
#
# Voraussetzung: einmalig SSH-Key in Hostinger hinterlegen, sonst wird bei jeder
# Datei das Passwort abgefragt. Alternativ "brew install hudochenkov/sshpass/sshpass"
# und SSH-Passwort in ~/.mlegal-ssh-pass ablegen.

set -euo pipefail

SSH_HOST="hostinger-mlegal"  # siehe ~/.ssh/config
REMOTE_DIR="/home/u477290815/domains/before-7.com/public_html/demo"

VARIANT="${1:-v5}"
case "$VARIANT" in
  v5)  SOURCE="v5-linen.html" ;;
  v5b) SOURCE="v5b-linen-blue.html" ;;
  *)   echo "Unbekannte Variante: $VARIANT (erlaubt: v5, v5b)"; exit 1 ;;
esac

cd "$(dirname "$0")"

STAGING="$(mktemp -d)"
trap 'rm -rf "$STAGING"' EXIT

cp "$SOURCE"               "$STAGING/index.html"
cp briefpapier.html        "$STAGING/"
cp briefpapier-rechnung.html "$STAGING/"
cp businessplan.html       "$STAGING/"
cp impressum.html          "$STAGING/"
cp datenschutz.html        "$STAGING/"
cp iris-meinking.jpeg      "$STAGING/"
cp logo-globe-2d.png       "$STAGING/"
printf "User-agent: *\nDisallow: /\n" > "$STAGING/robots.txt"

echo "Staging-Inhalt ($STAGING):"
ls -la "$STAGING"

echo ""
echo "Deploye nach $SSH_HOST:$REMOTE_DIR ..."

rsync -avz \
  --exclude='.htaccess' \
  --exclude='.htpasswd' \
  "$STAGING/" \
  "$SSH_HOST:$REMOTE_DIR/"

echo ""
echo "Fertig. Teste: https://demo.before-7.com/"
