#!/bin/bash

echo "📁 Iniciando preparação das pastas do ambiente..."

# Diretório onde o script está
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Dois níveis acima do script
BASE_DIR="$(realpath "$SCRIPT_DIR/../..")"

# Diretórios
GLPI_CRON_DIR="$BASE_DIR/data/glpi/cron"
GLPI_CRON_FILE="$GLPI_CRON_DIR/glpi_cron"

# Pastas de dados (volumes persistentes)
DATA_DIRS=(
  "$GLPI_CRON_DIR"
)

# Criando diretórios
for DIR in "${DATA_DIRS[@]}"; do
  if [ ! -d "$DIR" ]; then
    echo "📂 Criando $DIR"
    mkdir -p "$DIR"
  else
    echo "✔️ Já existe: $DIR"
  fi
done

# Criando arquivo de cron do GLPI (antes das permissões)
if [ ! -f "$GLPI_CRON_FILE" ]; then
  echo "🕒 Criando arquivo de cron: $GLPI_CRON_FILE"
  cat << 'EOF' > "$GLPI_CRON_FILE"
*/3 * * * * /usr/bin/php8.3 /var/www/html/glpi/scripts/ldap_mass_sync.php
*/5 * * * * /var/www/html/glpi/scripts/importuser-all.sh
*/1 * * * * /usr/bin/php8.3 /var/www/html/glpi/front/cron.php --force mailgate >/dev/null
*/1 * * * * /usr/bin/php8.3 /var/www/html/glpi/front/cron.php --force queuedmail >/dev/null
*/1 * * * * /usr/local/bin/teste_cron.sh
* * * * * echo "Cron is running $(date)" >> /tmp/teste_cron.log
EOF
else
  echo "✔️ Arquivo de cron já existe: $GLPI_CRON_FILE"
fi

echo "🔧 Ajustando permissões..."
chown -R 33:33 "$BASE_DIR/data/glpi"
chmod -R 775 "$BASE_DIR/data/glpi"

# Configurando rede Docker personalizada
if ! docker network ls | grep -q "network-share"; then
  echo "🌐 Criando rede network-share..."
  docker network create \
    --driver=bridge \
    --subnet=172.18.0.0/16 \
    network-share
fi

echo "✅ Preparação concluída!"
