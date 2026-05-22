#!/usr/bin/env bash
set -euo pipefail

ROOT_ENV="../velura-project-AWS-/.env"
TARGET="terraform.tfvars"

if [ ! -f "$ROOT_ENV" ]; then
  echo "ERROR: root .env file not found at $ROOT_ENV"
  exit 1
fi

get_value() {
  local key="$1"
  grep -E "^${key}=" "$ROOT_ENV" | head -n1 | cut -d'=' -f2- || true
}

cat > "$TARGET" <<EOF
# Generated from $ROOT_ENV
aws_account_id = "${AWS_ACCOUNT_ID:-536697232354}"

# Database
# Local .env mapping: MYSQL_USER -> db_username
# Local .env mapping: MYSQL_PASSWORD -> db_password
# Local .env mapping: MYSQL_DATABASE -> db_name

db_username = "$(get_value MYSQL_USER || echo rental_user)"
db_password = "$(get_value MYSQL_PASSWORD || echo change_me_strong_app_password)"
db_name     = "$(get_value MYSQL_DATABASE || echo clothes_rental)"

# Secrets
# Local .env mapping: JWT_SECRET_KEY -> jwt_secret_key
# Local .env mapping: ELASTIC_PASSWORD -> elastic_password
# Local .env mapping: KIBANA_PASSWORD -> kibana_password
# Local .env mapping: KIBANA_ENCRYPTION_KEY -> kibana_encryption_key
jwt_secret_key        = "$(get_value JWT_SECRET_KEY || echo change_me_generate_with_openssl_rand_hex_32)"
elastic_password      = "$(get_value ELASTIC_PASSWORD || echo change_me_strong_elastic_password)"
kibana_password       = "$(get_value KIBANA_PASSWORD || echo change_me_strong_kibana_password)"
kibana_encryption_key = "$(get_value KIBANA_ENCRYPTION_KEY || echo change_me_exactly_32_chars_key!!)"

# Image URIs
image_auth     = ""
image_catalog  = ""
image_rental   = ""
image_admin    = ""
image_frontend = ""
image_filebeat = ""
EOF

echo "Created $TARGET from $ROOT_ENV. Update aws_account_id and image_* values before apply."
