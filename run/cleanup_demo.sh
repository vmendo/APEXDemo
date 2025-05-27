#!/bin/bash

# ===============================
# DEMO CLEAN-UP SCRIPT
# ===============================

# --- Config ---
DEV_PROJECT_DIR="/home/opc/APEXDemo/my_projects/demo"
GITHUB_USER="vmendo"
GITHUB_REPO="APEX_CICD_demo"
DEV_DB_ALIAS="apex_dev"
PROD_DB_ALIAS="apex_pro"

# --- Colors ---
RED='\033[31m'
GREEN='\033[32m'
BLUE='\033[34m'
NC='\033[0m'

# --- Header ---
echo -e "${BLUE}🧹 Starting full demo cleanup...${NC}"
echo -e "${BLUE}THIS WILL CLEAN DEV1 and PRO...${NC}"
echo ""
read -p "Press any key to confirm..." -n 1 -s
echo ""


# --- Remove project directory ---
echo -e "${BLUE}Deleting local project directory: $DEV_PROJECT_DIR${NC}"
rm -rf "$DEV_PROJECT_DIR"
echo -e "${GREEN}✔ Local project directory removed.${NC}"

# --- Drop only custom dev objects ---
export TNS_ADMIN=/home/opc/APEXDemo/wallet/dev
echo -e "${BLUE}Cleaning up DEV database objects (custom only)...${NC}"
sql -name "$DEV_DB_ALIAS" @../scripts/clean_sql/origen-clean.sql

echo -e "${GREEN}✔ Dev database cleanup complete.${NC}"

# --- Drop ALL objects in production schema ---
export TNS_ADMIN=/home/opc/APEXDemo/wallet/pro
echo -e "${RED}⚠ Dropping ALL objects in the production...${NC}"
sql -name "$PROD_DB_ALIAS" @../scripts/clean_sql/destination-clean.sql

echo -e "${GREEN}✔ Production schema fully cleaned.${NC}"

# --- Reset GitHub repository ---
echo -e "${RED}⚙️  Resetting GitHub repository to empty state...${NC}"

# Delete all remote branches except main
for branch in $(gh api repos/$GITHUB_USER/$GITHUB_REPO/branches --jq '.[].name'); do
  if [[ "$branch" != "main" ]]; then
    echo "🧹 Deleting remote branch: $branch"
    gh api -X DELETE repos/$GITHUB_USER/$GITHUB_REPO/git/refs/heads/$branch
  fi
  sleep 1
done

# Delete all tags
for tag in $(gh api repos/$GITHUB_USER/$GITHUB_REPO/tags --jq '.[].name'); do
  echo "🏷️  Deleting tag: $tag"
  gh api -X DELETE repos/$GITHUB_USER/$GITHUB_REPO/git/refs/tags/$tag
  sleep 1
done

# Reinitialize main branch to empty state
echo "⚙️  Reinitializing main branch with empty commit"
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"
git init --initial-branch=main
git checkout -b main
echo "# Empty reset on $(date)" > README.md
git add README.md
git commit -m "chore: reset repository to empty state"
git remote add origin https://github.com/$GITHUB_USER/$GITHUB_REPO.git
git push -f origin main

cd ~
echo -e "${GREEN}✔ GitHub repo is now clean and reset (only main branch, one README.md).${NC}"

echo -e "${BLUE}✅ DEMO CLEANUP COMPLETE${NC}"
