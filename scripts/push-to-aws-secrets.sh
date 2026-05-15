#!/usr/bin/env bash
# ============================================================
# push-to-aws-secrets.sh
# Reads your .env file and pushes every secret to
# AWS Secrets Manager under /velura/<KEY>.
#
# Prerequisites:
#   - AWS CLI configured (aws configure)
#   - .env file exists in the project root
#
# Usage:
#   AWS_REGION=eu-west-1 bash scripts/push-to-aws-secrets.sh
# ============================================================

set -euo pipefail

REGION="${AWS_REGION:-us-east-1}"
ENV_FILE="${1:-.env}"
PREFIX="/velura"

# List of keys that are actual secrets (not plain config)
SECRETS=(
  MYSQL_ROOT_PASSWORD
  MYSQL_PASSWORD
  JWT_SECRET_KEY
  ELASTIC_PASSWORD
  KIBANA_PASSWORD
  KIBANA_ENCRYPTION_KEY
)

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: $ENV_FILE not found. Run: bash scripts/generate-secrets.sh > .env"
  exit 1
fi

# Load env file
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

for KEY in "${SECRETS[@]}"; do
  VALUE="${!KEY:-}"
  if [[ -z "$VALUE" ]]; then
    echo "SKIP  $KEY (not set in $ENV_FILE)"
    continue
  fi

  SECRET_NAME="${PREFIX}/${KEY}"
  echo -n "Pushing $SECRET_NAME ... "

  # Create or update
  if aws secretsmanager describe-secret \
       --secret-id "$SECRET_NAME" \
       --region "$REGION" &>/dev/null; then
    aws secretsmanager put-secret-value \
      --secret-id "$SECRET_NAME" \
      --secret-string "$VALUE" \
      --region "$REGION" > /dev/null
    echo "updated"
  else
    aws secretsmanager create-secret \
      --name "$SECRET_NAME" \
      --secret-string "$VALUE" \
      --region "$REGION" > /dev/null
    echo "created"
  fi
done

echo ""
echo "Done. Reference secrets in ECS task definitions as:"
echo "  valueFrom: arn:aws:secretsmanager:${REGION}:ACCOUNT_ID:secret:${PREFIX}/KEY"
