# RubyZen Development Setup

## Quick Start

1. **Set target project environment variable** (REQUIRED):
   ```bash
   export RUBYZEN_TARGET_PROJECT=YourProjectName
   ```

   **Note**: This environment variable is required. No default fallback is provided to ensure explicit project selection.

2. **Open in dev container**:
   ```bash
   code .
   ```

3. **Open the workspace file** in VS Code:
   - File → Open Workspace from File
   - Select `.vscode/rubyzen.code-workspace`

## How It Works

### Purely Environment-Driven Architecture

- **Environment Variable**: `RUBYZEN_TARGET_PROJECT` specifies which sibling project to lint (REQUIRED)
- **Fixed Mount**: Target project is always mounted to `/workspaces/target_project`
- **Static Configuration**: All config files use the same fixed path
- **No Hardcoded Fallbacks**: Explicit environment variable required

### Project Structure in Container

```
/workspaces/
├── Rubyzen/           (this linter project)
└── target_project/    (mounted external project)
    └── src/           (source code to lint)
```

### Configuration Files

All configuration is **static** - no generation needed:

- **`.rubyzen.yaml`**: Always points to `/workspaces/target_project/src`
- **`rubyzen.code-workspace`**: Always shows "Target Project" folder
- **`devcontainer.json`**: Mounts `$RUBYZEN_TARGET_PROJECT` to fixed location

## Usage Examples

### Required Environment Variable

```bash
# MUST set environment variable - no fallbacks
export RUBYZEN_TARGET_PROJECT=Husband-Redis
code .

# Or inline
RUBYZEN_TARGET_PROJECT=MyClientApp code .

# Different project
RUBYZEN_TARGET_PROJECT=SomeOtherProject code .
```

### Team Setup

Create a `.env` file for consistent team configuration:

```bash
# .env
RUBYZEN_TARGET_PROJECT=OurMainProject
```

### Requirements

- **Environment Variable**: `RUBYZEN_TARGET_PROJECT` must be set
- Target project must be a **sibling directory** to RubyZen
- Target project should have a `src/` subdirectory with Ruby files
- Directory structure example:
  ```
  parent-folder/
  ├── Rubyzen/           (this project)
  ├── Husband-Redis/     (target project)
  └── MyOtherProject/    (another target project)
  ```

## Troubleshooting

### "RUBYZEN_TARGET_PROJECT environment variable not set" Error

Set the environment variable before opening the dev container:

```bash
export RUBYZEN_TARGET_PROJECT=YourProjectName
code .
```

### "Target project not found" Warning

This means the project isn't mounted. Check:

1. **Environment variable**: Is `RUBYZEN_TARGET_PROJECT` set correctly?
2. **Directory exists**: Does `../$RUBYZEN_TARGET_PROJECT` exist on your host?
3. **Container rebuild**: Rebuild the dev container after setting the environment variable

### VS Code Shows Only One Project

You need to open the **workspace file**, not the folder:

1. File → Open Workspace from File
2. Select `.vscode/rubyzen.code-workspace`

This will show both "Rubyzen (Linter)" and "Target Project" in the sidebar.

### Mount Errors

If the dev container fails to start with mount errors:

1. Ensure `RUBYZEN_TARGET_PROJECT` is set in your shell
2. Verify the target project directory exists: `ls ../$RUBYZEN_TARGET_PROJECT`
3. Rebuild the dev container: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"
