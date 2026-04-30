#!/bin/bash
# ============================================================
# Smivo — SQL Migration Runner
# ============================================================
# Usage:
#   ./supabase/scripts/run_migration.sh <migration_file>
#   ./supabase/scripts/run_migration.sh supabase/migrations/00047_order_placed_listing_id.sql
#
# Reads DATABASE_URL from .env.db at repo root.
# ============================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
ENV_FILE="$REPO_ROOT/.env.db"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check argument
if [ $# -eq 0 ]; then
  echo -e "${YELLOW}Usage: $0 <sql_file_or_migration_number>${NC}"
  echo ""
  echo "Examples:"
  echo "  $0 supabase/migrations/00047_order_placed_listing_id.sql"
  echo "  $0 00047   # auto-finds migration by number prefix"
  echo ""
  echo "Available migrations:"
  ls "$REPO_ROOT/supabase/migrations/"*.sql 2>/dev/null | while read f; do
    echo "  $(basename "$f")"
  done
  exit 1
fi

# Load DATABASE_URL
if [ ! -f "$ENV_FILE" ]; then
  echo -e "${RED}Error: $ENV_FILE not found${NC}"
  exit 1
fi

DATABASE_URL=$(grep '^DATABASE_URL=' "$ENV_FILE" | cut -d'=' -f2-)
if [ -z "$DATABASE_URL" ]; then
  echo -e "${RED}Error: DATABASE_URL not set in $ENV_FILE${NC}"
  exit 1
fi

# Resolve SQL file path
INPUT="$1"
SQL_FILE=""

if [ -f "$INPUT" ]; then
  # Direct file path
  SQL_FILE="$INPUT"
elif [ -f "$REPO_ROOT/$INPUT" ]; then
  # Relative to repo root
  SQL_FILE="$REPO_ROOT/$INPUT"
else
  # Try matching by migration number prefix
  MATCH=$(find "$REPO_ROOT/supabase/migrations" -name "${INPUT}*.sql" 2>/dev/null | head -1)
  if [ -n "$MATCH" ]; then
    SQL_FILE="$MATCH"
  fi
fi

if [ -z "$SQL_FILE" ] || [ ! -f "$SQL_FILE" ]; then
  echo -e "${RED}Error: Cannot find SQL file: $INPUT${NC}"
  exit 1
fi

FILENAME=$(basename "$SQL_FILE")

# Confirmation
echo -e "${YELLOW}╔══════════════════════════════════════════════╗${NC}"
echo -e "${YELLOW}║  Smivo Migration Runner                      ║${NC}"
echo -e "${YELLOW}╠══════════════════════════════════════════════╣${NC}"
echo -e "${YELLOW}║  File: ${NC}$FILENAME"
echo -e "${YELLOW}║  DB:   ${NC}$(echo "$DATABASE_URL" | sed 's/:[^:@]*@/:***@/')"
echo -e "${YELLOW}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "SQL content preview (first 10 lines):"
echo "────────────────────────────────────────"
head -10 "$SQL_FILE"
echo "────────────────────────────────────────"
echo ""
read -p "Execute this migration? (y/N) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${YELLOW}Cancelled.${NC}"
  exit 0
fi

# Execute
echo -e "\n${YELLOW}Executing migration...${NC}\n"

if psql "$DATABASE_URL" -f "$SQL_FILE" 2>&1; then
  echo -e "\n${GREEN}✅ Migration executed successfully: $FILENAME${NC}"
else
  echo -e "\n${RED}❌ Migration failed. Check errors above.${NC}"
  exit 1
fi
