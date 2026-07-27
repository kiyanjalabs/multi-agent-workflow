#!/bin/bash
MAX_JOBS=16
AGENT_NUM=0

while true; do
    # Wait if max jobs are running
    while (( $(jobs -rp | wc -l) >= MAX_JOBS )); do
        sleep 1
    done

    # Sync with remote
    git pull --rebase origin main 2>/dev/null

    # Check if there are any TODO tasks left
    if ! grep -q "^\* TODO" TODO.org; then
        wait
        break
    fi

    # Launch a new agent
    COMMIT=$(git rev-parse --short=6 HEAD)
    AGENT_NUM=$((AGENT_NUM + 1))
    LOGFILE="agent_logs/agent_${COMMIT}_${AGENT_NUM}.log"
    
    # Use your preferred CLI client (e.g., Claude, GPT)
    # --dangerously-skip-permissions allows autonomous action
    claude --dangerously-skip-permissions -p "$(cat AGENT_PROMPT.md | sed "s/YOUR_AGENT_NUMBER/$AGENT_NUM/g")" &> "$LOGFILE" &
done   
