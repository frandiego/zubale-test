#!/bin/bash
set -e

log_and_run() {
  echo "[Entrypoint] Running: $*"
  "$@"
}

# Set currency and base currency from environment variables, with defaults
CURRENCY="${CURRENCY:-USD}"
BASE_CURRENCY="${BASE_CURRENCY:-BRL}"
OUTPUT_SCHEMA="${OUTPUT_SCHEMA:-dbt}"
OUTPUT_TABLE="${OUTPUT_TABLE:-currency_rates}"
INTERVAL_HOURS="${INTERVAL_HOURS:-1}"


log_and_run python hourly_currency_rate.py  \
              --currency "$CURRENCY" \
              --base-currency "$BASE_CURRENCY" \
              --output-schema "$OUTPUT_SCHEMA" \
              --output-table "$OUTPUT_TABLE" \
              --run-once
# Seed the database
log_and_run dbt seed

# Run dbt models
log_and_run dbt run

# Fetch currency rate each hour
log_and_run python hourly_currency_rate.py  \
              --currency "$CURRENCY" \
              --base-currency "$BASE_CURRENCY" \
              --output-schema "$OUTPUT_SCHEMA" \
              --output-table "$OUTPUT_TABLE" \
              --interval "$INTERVAL_HOURS"
