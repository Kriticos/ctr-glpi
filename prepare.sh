#!/bin/bash
set -e

echo "📁 Iniciando preparação das pastas do ambiente..."

# Diretório onde o script está
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Dois níveis acima do script
BASE_DIR="$(realpath "$SCRIPT_DIR/../..")"

# Diretórios GLPI
GLPI_BASE_DIR="$BASE_DIR/data/glpi"
GLPI_APP_DIR="$GLPI_BASE_DIR/app"
GLPI_CRON_DIR="$GLPI_BASE_DIR/cron"
GLPI_CRON_FILE="$GLPI_CRON_DIR/glpi_cron"

# ----------------------------
# Criação de diretórios
# ----------------------------
DATA_DIRS=(
  "$GLPI_APP_DIR"
  "$GLPI_CRON_DIR"
)

for DIR in "${DATA_DIRS[@]}"; do
  if [ ! -d "$DIR" ]; then
    echo "📂 Criando $DIR"
    mkdir -p "$DIR"
  else
    echo "✔️ Já existe: $DIR"
  fi
done

# ----------------------------
# Criação do arquivo de cron
# ----------------------------
if [ ! -f "$GLPI_CRON_FILE" ]; then
  echo "🕒 Criando arquivo de cron: $GLPI_CRON_FILE"
  cat << 'EOF' > "$GLPI_CRON_FILE"
*/3 * * * * /usr/bin/php8.3 /var/glpi/scripts/ldap_mass_sync.php
*/5 * * * * /var/glpi/scripts/importuser-all.sh
*/1 * * * * /usr/bin/php8.3 /var/glpi/front/cron.php --force mailgate >/dev/null
*/1 * * * * /usr/bin/php8.3 /var/glpi/front/cron.php --force queuedmail >/dev/null
* * * * * echo "Cron is running $(date)" >> /tmp/teste_cron.log
EOF
else
  echo "✔️ Arquivo de cron já existe: $GLPI_CRON_FILE"
fi

# ----------------------------
# Permissões
# ----------------------------

echo "🔧 Ajustando permissões..."

# Dados do GLPI (www-data)
chown -R 33:33 "$GLPI_APP_DIR"
chmod -R 775 "$GLPI_APP_DIR"

# Cron do root (exigência do crontab)
chown root:root "$GLPI_CRON_FILE"
chmod 600 "$GLPI_CRON_FILE"

# ----------------------------
# Rede Docker
# ----------------------------
if ! docker network ls | grep -q "network-share"; then
  echo "🌐 Criando rede network-share..."
  docker network create \
    --driver=bridge \
    --subnet=172.18.0.0/16 \
    network-share
else
  echo "✔️ Rede network-share já existe"
fi

echo "✅ Preparação concluída!"
