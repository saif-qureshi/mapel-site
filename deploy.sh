#!/bin/bash

# Deploy the Maple Leaf marketing site (Astro static build) to production.
# Usage: ./deploy.sh
#
# Builds on the server and outputs static files to dist/, which nginx serves.
# One-time server setup required before the first run — see DEPLOY.md
# (point the nginx root at .../dist and add the .html -> clean-URL redirects).

set -e

SERVER="forge@159.65.13.183"
PROJECT_PATH="/home/forge/mapleleafcorporation.com/"
BRANCH="main"

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}Deploying marketing site (branch=$BRANCH)...${NC}"

ssh "$SERVER" "bash -s" <<ENDSSH
  set -e
  cd "$PROJECT_PATH"
  echo "Pulling latest code..."
  git pull origin $BRANCH
  echo "Installing dependencies..."
  npm ci
  echo "Building static site..."
  npm run build
  echo "Build output ready at ${PROJECT_PATH}dist"
ENDSSH

echo -e "${GREEN}✓ Deployment finished. nginx serves ${PROJECT_PATH}dist${NC}"
