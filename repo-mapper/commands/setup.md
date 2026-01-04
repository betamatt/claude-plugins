---
name: setup
description: Install RepoMapper to the current project for AI-optimized repository mapping
allowed-tools: ["Bash", "Read", "Write", "Glob"]
---

# RepoMapper Setup

Install RepoMapper to `.repo-mapper/` in the current project directory.

## Process

### 1. Pre-flight Checks

First, verify the environment:

```bash
# Check Python version (3.8+ required)
python3 --version
```

If Python is not available or version is below 3.8, inform the user and stop.

Check if already installed:
```bash
ls -la .repo-mapper/RepoMapper 2>/dev/null
```

If already installed, ask the user if they want to reinstall or abort.

### 2. Installation

Create the installation directory and clone RepoMapper:

```bash
# Create directory
mkdir -p .repo-mapper

# Clone RepoMapper (shallow clone for speed)
git clone --depth 1 https://github.com/pdavis68/RepoMapper.git .repo-mapper/RepoMapper
```

If git clone fails (no git or network issues), provide manual installation instructions:
- Download from: https://github.com/pdavis68/RepoMapper/archive/refs/heads/main.zip
- Extract to `.repo-mapper/RepoMapper/`

### 3. Create Virtual Environment and Install Dependencies

```bash
# Create virtual environment
python3 -m venv .repo-mapper/venv

# Install dependencies
.repo-mapper/venv/bin/pip install -r .repo-mapper/RepoMapper/requirements.txt
```

If venv creation fails, fall back to system Python:
```bash
pip3 install --user -r .repo-mapper/RepoMapper/requirements.txt
```

### 4. Post-Installation Setup

Add `.repo-mapper/` to `.gitignore` if not already present:

```bash
# Check if .gitignore exists and contains .repo-mapper
grep -q "^\.repo-mapper" .gitignore 2>/dev/null || echo ".repo-mapper/" >> .gitignore
```

Create default configuration file at `.claude/repo-mapper.local.md`:

```yaml
---
token_limit: 8192
auto_map: true
exclude_unranked: false
exclude_patterns:
  - "node_modules/**"
  - "vendor/**"
  - ".git/**"
  - "*.min.js"
  - "dist/**"
  - "build/**"
---

# RepoMapper Configuration

Project-specific settings for RepoMapper integration.

## Settings

- **token_limit**: Maximum tokens for generated maps (default: 8192)
- **auto_map**: Generate map on session start (default: true)
- **exclude_unranked**: Skip files with zero PageRank (default: false)
- **exclude_patterns**: Glob patterns to exclude from mapping
```

### 5. Verify Installation

```bash
# Test that RepoMapper can be imported
.repo-mapper/venv/bin/python -c "import sys; sys.path.insert(0, '.repo-mapper/RepoMapper'); from repomap import RepoMap; print('RepoMapper installed successfully')"
```

### 6. Report Success

Display:
- Installation location: `.repo-mapper/RepoMapper/`
- Python environment: `.repo-mapper/venv/`
- Config file: `.claude/repo-mapper.local.md`
- Next steps: Run `/repo-mapper:map` to generate your first repository map
