#!/bin/bash

# Configuration
APP_DIR="/home/pytomotion"
SERVICE_NAME="switches.service"
DEPLOY_KEY="/home/pytomotion/.ssh/deploy_key"
LOG_FILE="/home/pytomotion/logs/updater.log"

# Ensure logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting auto-update check..."

# Move to app directory
if ! cd "$APP_DIR"; then
    log "ERROR: Cannot change directory to $APP_DIR. Aborting."
    exit 1
fi

# Check if directory is a git repository
if [ ! -d ".git" ]; then
    log "ERROR: $APP_DIR is not a git repository. Aborting."
    exit 1
fi

# Configure GIT_SSH_COMMAND if deploy key exists
if [ -f "$DEPLOY_KEY" ]; then
    export GIT_SSH_COMMAND="ssh -i $DEPLOY_KEY -o StrictHostKeyChecking=accept-new"
    log "Using deploy key: $DEPLOY_KEY"
else
    log "No specific deploy key found at $DEPLOY_KEY, using default SSH keys."
fi

# Fetch latest changes from origin
log "Fetching latest changes from origin..."
if ! git fetch origin main; then
    log "ERROR: git fetch failed. Check network connection or deploy key permissions."
    exit 1
fi

# Get local and remote commit hashes
LOCAL_COMMIT=$(git rev-parse HEAD)
REMOTE_COMMIT=$(git rev-parse origin/main)

if [ "$LOCAL_COMMIT" = "$REMOTE_COMMIT" ]; then
    log "System is up to date (Commit: $LOCAL_COMMIT)."
    exit 0
fi

log "New update found! Local: $LOCAL_COMMIT, Remote: $REMOTE_COMMIT"

# Extract remote app.py to verify python syntax before deploying
log "Verifying Python syntax of backend/app.py in remote branch..."
TMP_APP="/tmp/app_new.py"
if git show origin/main:backend/app.py > "$TMP_APP" 2>/dev/null; then
    # Run syntax compilation check
    if ! python3 -m py_compile "$TMP_APP" >/dev/null 2>&1; then
        log "ERROR: Syntax verification failed on remote backend/app.py! Aborting update to prevent bricking."
        rm -f "$TMP_APP"
        exit 1
    fi
    log "Syntax verification passed."
    rm -f "$TMP_APP"
else
    log "WARNING: Could not retrieve remote backend/app.py for syntax checking. Proceeding with caution."
fi

# Perform update deployment via hard reset to origin/main
log "Deploying update (git reset --hard origin/main)..."
if ! git reset --hard origin/main; then
    log "ERROR: git reset --hard failed. Attempting to restore to previous commit."
    git reset --hard "$LOCAL_COMMIT"
    exit 1
fi

# Clean untracked files, excluding data directory containing state, devices, and schedules
log "Cleaning untracked files..."
git clean -fd --exclude="data/"

# Restart the application service
log "Restarting $SERVICE_NAME..."
if ! sudo systemctl restart "$SERVICE_NAME"; then
    log "ERROR: Failed to trigger systemctl restart. Rolling back..."
    git reset --hard "$LOCAL_COMMIT"
    sudo systemctl restart "$SERVICE_NAME"
    exit 1
fi

# Post-update health check: Wait 10 seconds and check if service is running
log "Waiting 10 seconds for service health check..."
sleep 10

SERVICE_STATUS=$(systemctl is-active "$SERVICE_NAME")
if [ "$SERVICE_STATUS" != "active" ]; then
    log "ERROR: Service failed to start post-update (status: $SERVICE_STATUS). Initiating rollback..."
    git reset --hard "$LOCAL_COMMIT"
    sudo systemctl restart "$SERVICE_NAME"
    log "Rollback completed. Service restored to commit: $LOCAL_COMMIT"
    exit 1
fi

log "Update successfully applied! New commit: $REMOTE_COMMIT"
exit 0
