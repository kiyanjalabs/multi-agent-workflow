# BUILDiNG A LIGHTWAY MULTI-AGENT WORKFLOw

This multi-agent workflow in shell scripting, uses a lightweight, code-based approach.
The approach relies on Git for synchronization and a TODO.org file for task coordination.
This method allows multiple autonomous agents to run in parallel without complex frameworks


 
## 1. Define the Task List

Create a TODO.org file to serve as the single source of truth. Each task must have an ID, 
a status (TODO, IN-PROGRESS, DONE), and optional dependencies (:BLOCKER:).

...
* TODO Task 1
:PROPERTIES:
:ID: task-1
:END:
Description of the first task.

* TODO Task 2
:PROPERTIES:
:ID: task-2
:BLOCKER: task-1
:END:
Description of the second task, which waits for task-1.   
... 

## 2. Create the Agent Prompt

Define an AGENT_PROMPT.md file that instructs the AI model on how to operate. The prompt must include instructions to:

Synchronize: Run git pull --rebase before checking for tasks.
Select: Pick a TODO task with no active blockers.
Update: Mark the task IN-PROGRESS, commit, and push.
Execute: Perform the task logic.
Complete: Mark the task DONE, commit, and push.
Exit: Run exit 0 if no tasks remain.

...

Synchronize: Run git pull --rebase before checking for tasks.
Select: Pick a TODO task with no active blockers.
Update: Mark the task IN-PROGRESS, commit, and push.
Execute: Perform the task logic.
Complete: Mark the task DONE, commit, and push.
Exit: Run exit 0 if no tasks remain. 

...


## 3. Build the Orchestrator Script

Create a run_agents.sh script to manage parallel execution. 
It limits the number of concurrent agents and handles Git synchronization.

...
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
...
 

## 4. Run the System

Make the script executable and run it from the root of your Git repository. 
Each agent will operate in its own isolated environment (e.g., Docker container) and 
communicate solely through the shared Git repository. 


