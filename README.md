# MySQL Backup Helper

This script helps automate MySQL database backups from remote servers through a bastion host. It dumps each table individually and creates a compressed archive.

## Features

- Dumps each table separately to prevent timeout issues with large databases
- Creates date-stamped backups
- Automatically cleans up old backups (older than 7 days)
- Supports multiple database configurations
- Handles SSL configuration
- Cleans up temporary files automatically

## Setup

1. Create a config file in the `configs/` directory (e.g. `configs/mysite.sh`)
2. Add the required environment variables to your config

### Config Variables

Create a new config file in the `configs/` directory with a `.sh` extension. For example `configs/mysite.sh`:

```bash
# Required Environment Variables
BASTION_HOST="your-bastion-host.example.com"    # Hostname of the bastion/jump server
BASTION_USER="your-ssh-user"                    # SSH username for the bastion host
SSH_KEY="/path/to/your/ssh/key"                 # Path to your SSH private key
REMOTE_DB_HOST="your-db-host.internal"          # Internal hostname/IP of the MySQL server
REMOTE_DB_PORT="3306"                           # MySQL port number
DB_USER="your-mysql-user"                       # MySQL username
DB_PASS="your-mysql-password"                   # MySQL password
DB_NAME="your-database-name"                    # Name of the database to backup

# Optional Environment Variables
MYSQL_SSL_DISABLE="--ssl-mode=DISABLED"         # MySQL SSL mode (defaults to disabled)
```

## Configuration Variables Explained

### Required Variables

- `BASTION_HOST`: The hostname or IP address of your bastion/jump server that has access to the database server
- `BASTION_USER`: Your SSH username for logging into the bastion host
- `SSH_KEY`: Full path to the SSH private key used for authentication with the bastion host
- `REMOTE_DB_HOST`: The internal hostname or IP address of your MySQL server (as accessible from the bastion host)
- `REMOTE_DB_PORT`: The port number your MySQL server is listening on (typically 3306)
- `DB_USER`: MySQL username with sufficient privileges to perform backups
- `DB_PASS`: Password for the MySQL user
- `DB_NAME`: Name of the database you want to backup

### Optional Variables

- `MYSQL_SSL_DISABLE`: MySQL SSL connection mode. Defaults to `--ssl-mode=DISABLED`. Set to empty string or modify if you need SSL enabled.

## Example Config

Create a file in `configs/mysite.sh` with your configuration:

```bash
#!/bin/bash

# Connection Details
BASTION_HOST="bastion.mysite.com"
BASTION_USER="deploy"
SSH_KEY="/Users/username/.ssh/mysite_key"

# Database Details
REMOTE_DB_HOST="db-internal.mysite.local"
REMOTE_DB_PORT="3306"
DB_USER="backup_user"
DB_PASS="your_secure_password"
DB_NAME="mysite_production"

# Optional: Enable SSL if needed
# MYSQL_SSL_DISABLE=""
```

## Security Notes

1. Make sure your config files are stored securely with restricted permissions (chmod 600)
2. Never commit config files containing sensitive information to version control
3. Use a dedicated MySQL user with minimal required privileges for backups
4. Store SSH keys securely and protect them with passphrases when possible


