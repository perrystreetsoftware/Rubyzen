# RubyZen GitHub Action

A GitHub Action that runs RubyZen architectural linting on Ruby projects to enforce coding standards and architectural patterns.

## Usage

### Public Repository Usage

If this repository is public, you can use the action directly in your workflow:

```yaml
name: RubyZen Analysis

  pull_request:
    branches: [ main, master, develop ]


  analyze:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Run RubyZen Analysis
        uses: perrystreetsoftware/Rubyzen@main
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Private Repository Usage (Manual Checkout Required)

If this repository is private, you must manually check out the action using a Personal Access Token (PAT) and run it from a local path. Example:

```yaml
name: RubyZen Analysis

---
  pull_request:
    branches: [ main, master, develop ]
  workflow_dispatch:

*Analysis completed at 2025-01-15T10:30:00.000Z*
  analyze:
    runs-on: ubuntu-latest

    steps:
      - name: Show environment info
        run: |
          echo "Event: $GITHUB_EVENT_NAME | Repository: ${{ github.repository }}"
          echo "Ruby: $(ruby --version || echo 'Not installed')"

      - name: Checkout PR code
        uses: actions/checkout@v4

      # This GitHub Actions workflow configuration is intended for RubyZen analysis.
      # Note: Since the repository for the GitHub Action is private, you need to
      # manually check out the repository and run the action as part of your workflow steps.
      #
      - name: Checkout RubyZen action
        uses: actions/checkout@v4
        with:
          repository: perrystreetsoftware/Rubyzen
          token: ${{ secrets.RUBYZEN_ACCESS_TOKEN }}
          path: ./.github/actions/rubyzen

      - name: Run RubyZen Analysis
        uses: ./.github/actions/rubyzen
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          ruby-version: '3.3'
          target-directories: 'src:spec'
```

**Note:** `RUBYZEN_ACCESS_TOKEN` must be a Personal Access Token with access to this repository.

### Advanced Configuration

You can override the Ruby version and target directories:

```yaml
      - name: Run RubyZen Analysis
        uses: ./.github/actions/rubyzen
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          ruby-version: '3.2'
          target-directories: 'src:spec:lib'
```

**Multi-directory support:**
- Use `target-directories` for analyzing multiple directories (colon-separated, e.g., "src:spec")
- Directories are analyzed together, allowing cross-directory lint rules

## Development

This action is built as a composite action and maintained in the [RubyZen repository](https://github.com/perrystreetsoftware/Rubyzen).

### Local Testing

The RubyZen repository includes a self-testing workflow that demonstrates the action's functionality using sample project files.

## Support

For issues, feature requests, or questions about RubyZen rules, please visit the [RubyZen repository](https://github.com/perrystreetsoftware/Rubyzen/issues).
