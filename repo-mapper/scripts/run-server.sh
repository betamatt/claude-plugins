#!/bin/bash
# RepoMapper MCP Server launcher
# Finds and runs the RepoMapper server from the project's .repo-mapper directory

PROJECT_ROOT="$(pwd)"
REPO_MAPPER_DIR="$PROJECT_ROOT/.repo-mapper"

if [ ! -d "$REPO_MAPPER_DIR/RepoMapper" ]; then
    echo "Error: RepoMapper not installed. Run /repo-mapper:setup first." >&2
    exit 1
fi

# Use virtual environment if available, otherwise system Python
if [ -d "$REPO_MAPPER_DIR/venv" ]; then
    PYTHON="$REPO_MAPPER_DIR/venv/bin/python"
else
    PYTHON="python3"
fi

# Set PYTHONPATH for imports
export PYTHONPATH="$REPO_MAPPER_DIR/RepoMapper:$PYTHONPATH"

exec "$PYTHON" "$REPO_MAPPER_DIR/RepoMapper/repomap_server.py"
