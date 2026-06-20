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
  REPO=\$(git remote get-url origin)

  # Build in an isolated clone so the live dist/ keeps serving until the
  # atomic swap below — zero downtime.
  echo "Building in isolated clone..."
  rm -rf /tmp/ml-deploy-build
  git clone -q --branch $BRANCH --depth 1 "\$REPO" /tmp/ml-deploy-build
  cd /tmp/ml-deploy-build
  npm ci --no-audit --no-fund
  npm run build

  echo "Swapping new build into place..."
  cd "$PROJECT_PATH"
  rm -rf dist.old dist.new
  cp -r /tmp/ml-deploy-build/dist dist.new
  mv dist dist.old && mv dist.new dist
  rm -rf dist.old /tmp/ml-deploy-build
  echo "Build output ready at ${PROJECT_PATH}dist"
ENDSSH

echo -e "${GREEN}✓ Deployment finished. nginx serves ${PROJECT_PATH}dist${NC}"
