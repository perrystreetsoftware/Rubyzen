# Dev Container Setup

Rubyzen's dev container allows you to lint a project without manually setting `RUBYZEN_PROJECT_PATHS`. It mounts a sibling directory as the target directory and configures the environment automatically.

## Directory Structure

Rubyzen and the project you want to lint must live in the same parent directory:

```
~/parent-folder/
├── Rubyzen/               (this project)
├── YourProject/           (the project you want to lint)
```

## Quick Start

From your host machine, inside the Rubyzen directory:

```bash
cd path/to/Rubyzen
export RUBYZEN_TARGET_PROJECT=YourProject
devcontainer open .
```

As a result, the dev container will automatically mount `../YourProject` into `/workspaces/target_project` and set `RUBYZEN_PROJECT_PATHS` to `/workspaces/target_project/src,/workspaces/target_project/spec`.

## Troubleshooting

| Issue | Solution |
|-------|----------|
| "Environment variable not set" error | `export RUBYZEN_TARGET_PROJECT=YourProject` before `code .` |
| "Target project not found" | Verify `../$RUBYZEN_TARGET_PROJECT` exists and rebuild container |
| Mount errors on startup | Check env var is set, target exists, then rebuild container |
| Changed env var but still seeing old project | Rebuild dev container to update mount path |
