#!/bin/bash

##
# Load Config Based on Argument
#
if [ -z "$1" ]; then
  echo "❌ Error: Please provide a config name (e.g. graylana)"
  echo "Usage: ./backup-mysql.sh graylana"
  exit 1
fi

CONFIG_NAME="$1"
CONFIG_PATH="./configs/${CONFIG_NAME}.sh"

if [ ! -f "$CONFIG_PATH" ]; then
  echo "❌ Error: Config '$CONFIG_NAME' not found at $CONFIG_PATH"
  exit 1
fi

# Load the config
source "$CONFIG_PATH"

# Fallback if MYSQL_SSL_DISABLE isn't set
MYSQL_SSL_DISABLE="${MYSQL_SSL_DISABLE:-"--ssl-mode=DISABLED"}"

##
# Date-based folder/filename
#
DATE_TAG=$(date +%F_%H-%M-%S)
ARCHIVE_NAME="$DB_NAME-$DATE_TAG.tar.gz"
LOCAL_SAVE_DIR="./archive/$CONFIG_NAME"
REMOTE_DUMP_DIR="/tmp/mysql_dump_$DATE_TAG"
REMOTE_ARCHIVE_PATH="/tmp/$ARCHIVE_NAME"

mkdir -p "$LOCAL_SAVE_DIR"

##
# Step 1: SSH in and dump each table
#
echo "🔄 Dumping MySQL tables remotely on $BASTION_HOST..."
ssh -i "$SSH_KEY" "${BASTION_USER}@${BASTION_HOST}" bash -s <<EOF
  set -e
  mkdir -p "$REMOTE_DUMP_DIR"
  TABLES=\$(mysql $MYSQL_SSL_DISABLE -h "$REMOTE_DB_HOST" -P "$REMOTE_DB_PORT" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -e "SHOW TABLES;" -s --skip-column-names)
  for TABLE in \$TABLES; do
    echo "Exporting \$TABLE..."
    mysqldump $MYSQL_SSL_DISABLE -h "$REMOTE_DB_HOST" -P "$REMOTE_DB_PORT" -u "$DB_USER" -p"$DB_PASS" --single-transaction --quick "$DB_NAME" "\$TABLE" > "$REMOTE_DUMP_DIR/\$TABLE.sql"
  done
  tar -czf "$REMOTE_ARCHIVE_PATH" -C "$REMOTE_DUMP_DIR" .
  rm -rf "$REMOTE_DUMP_DIR"
EOF

##
# Step 2: Download the archive
#
echo "⬇️  Downloading archive to $LOCAL_SAVE_DIR..."
scp -i "$SSH_KEY" "${BASTION_USER}@${BASTION_HOST}:${REMOTE_ARCHIVE_PATH}" "$LOCAL_SAVE_DIR/"

##
# Step 3: Cleanup
#
echo "🧹 Cleaning up remote archive..."
ssh -i "$SSH_KEY" "${BASTION_USER}@${BASTION_HOST}" "rm -f ${REMOTE_ARCHIVE_PATH}"

##
# Step 4: Clean up any macOS .DS_Store junk and old backups
#
find "$LOCAL_SAVE_DIR" -name .DS_Store -delete
find "$LOCAL_SAVE_DIR" -name "*.tar.gz" -mtime +7 -delete

echo "✅ Backup complete. Files saved in $LOCAL_SAVE_DIR/${ARCHIVE_NAME}"
