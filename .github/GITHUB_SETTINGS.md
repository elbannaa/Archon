# GitHub Settings Configuration for Archon V2 Beta

This document describes the recommended GitHub repository settings for optimal workflow.

## ✅ Configured Automatically (via files)

The following features are configured via the files in `.github/`:

### Automation
- ✅ **Dependabot** - Automatic dependency updates (weekly)
- ✅ **Auto-labeling** - PRs automatically labeled based on files changed
- ✅ **Auto-assign reviewers** - Based on CODEOWNERS
- ✅ **Stale issue/PR management** - Closes inactive issues/PRs
- ✅ **First-time contributor greeting** - Welcome messages
- ✅ **PR quality checks** - Validates PR descriptions and titles
- ✅ **Merge conflict detection** - Alerts on conflicts

### Code Review
- ✅ **Claude Code Review** - AI code review with `@claude-review`
- ✅ **Claude Code Fix** - AI-assisted fixes with `@claude-fix`
- ✅ **CODEOWNERS** - Automatic reviewer assignment
- ✅ **PR Templates** - Structured pull request descriptions

### CI/CD
- ✅ **Continuous Integration** - Tests on every PR
- ✅ **Docker Build Tests** - Validates all services build
- ✅ **Release Notes Generator** - AI-generated release notes

## ⚙️ Manual Configuration Required

The following settings should be configured manually in GitHub repository settings:

### General Settings

Navigate to: `Settings > General`

#### Default Branch
- [x] Set to `main`

#### Pull Requests
- [x] ✅ Allow squash merging
- [x] ✅ Allow merge commits
- [x] ✅ Allow rebase merging
- [x] ✅ Automatically delete head branches

#### Issues
- [x] ✅ Enable issues

#### Projects
- [x] ⚠️ Enable projects (optional)

#### Wiki
- [ ] ❌ Disable wiki (use docs/ instead)

#### Discussions
- [x] ✅ Enable discussions (for Q&A)

---

### Branch Protection Rules

Navigate to: `Settings > Branches > Add rule`

#### Rule for `main` branch:

**Branch name pattern:** `main`

**Protect matching branches:**
- [x] ✅ Require a pull request before merging
  - [x] ✅ Require approvals: **1** (adjustable)
  - [x] ✅ Dismiss stale pull request approvals when new commits are pushed
  - [x] ⚠️ Require review from Code Owners (recommended)
  - [x] ❌ Restrict who can dismiss pull request reviews (not needed for small team)
  - [ ] ❌ Allow specified actors to bypass required pull requests (not recommended)
  
- [x] ✅ Require status checks to pass before merging
  - [x] ✅ Require branches to be up to date before merging
  - Status checks to require:
    - `frontend-tests`
    - `backend-tests`
    - `docker-build-test`
  
- [x] ✅ Require conversation resolution before merging

- [ ] ⚠️ Require signed commits (optional, for security)

- [ ] ❌ Require linear history (not needed for beta)

- [x] ⚠️ Require deployments to succeed before merging (if you have deployment workflows)

- [ ] ❌ Lock branch (not recommended)

- [ ] ❌ Do not allow bypassing the above settings (for emergency fixes by maintainers)

**Rules applied to administrators:**
- [ ] ⚠️ Include administrators (recommended for production, optional for beta)

---

### Secrets and Variables

Navigate to: `Settings > Secrets and variables > Actions`

#### Required Secrets:

- [x] `CLAUDE_CODE_OAUTH_TOKEN` - For Claude Code Action workflows
- [x] `SUPABASE_URL` - For CI tests (or use fake values in workflow)
- [x] `SUPABASE_SERVICE_KEY` - For CI tests (or use fake values in workflow)
- [x] `CODECOV_TOKEN` - For code coverage reports (optional)
- [x] `N8N_BASIC_AUTH_USER` - For n8n deployment (if applicable)
- [x] `N8N_BASIC_AUTH_PASSWORD` - For n8n deployment
- [x] `TUNNEL_TOKEN` - For Cloudflare tunnel (if applicable)

#### Variables (optional):

- `NODE_VERSION`: 18
- `PYTHON_VERSION`: 3.12

---

### Collaborators & Teams

Navigate to: `Settings > Collaborators and teams`

**Maintainers** (Admin access):
- @coleam00
- @Wirasm
- @sean-eskerium

**Contributors** (Write access):
- Add trusted contributors here

---

### Actions Permissions

Navigate to: `Settings > Actions > General`

#### Actions permissions:
- [x] ✅ Allow all actions and reusable workflows

#### Workflow permissions:
- [x] ✅ Read and write permissions
- [x] ✅ Allow GitHub Actions to create and approve pull requests

#### Fork pull request workflows:
- [x] ⚠️ Require approval for first-time contributors (recommended)
- [x] ❌ Require approval for all outside collaborators

---

### Security

Navigate to: `Settings > Security`

#### Code security and analysis:
- [x] ✅ Dependency graph (enabled by default)
- [x] ✅ Dependabot alerts (auto-enabled)
- [x] ✅ Dependabot security updates
- [x] ✅ Grouped security updates
- [x] ✅ Code scanning - CodeQL analysis (recommended)
- [x] ✅ Secret scanning (for public repos)
- [x] ✅ Secret scanning push protection (prevent committing secrets)

#### Private vulnerability reporting:
- [x] ✅ Enable private vulnerability reporting

---

### Webhooks & Services

Navigate to: `Settings > Webhooks`

Optional integrations:
- [x] Slack notifications
- [x] Discord webhooks
- [x] Email notifications

---

### GitHub Apps

Navigate to: `Settings > Installed GitHub Apps`

Recommended apps:
- [x] **Codecov** - Code coverage visualization
- [x] **Sentry** - Error tracking
- [x] **Renovate** - Alternative to Dependabot with more features
- [x] **Snyk** - Security vulnerability scanning

---

## 🔐 Security Checklist

- [x] ✅ SECURITY.md file created
- [x] ✅ Security issue template created
- [x] ✅ Private vulnerability reporting enabled
- [x] ✅ Secret scanning enabled
- [x] ✅ Dependabot alerts enabled
- [x] ⚠️ Add security email contact to SECURITY.md
- [x] ⚠️ Configure 2FA for all maintainers

---

## 📊 Recommended Labels

Navigate to: `Issues > Labels`

### Standard Labels (Auto-created by workflows):

**Type:**
- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `dependencies` - Dependency updates

**Component:**
- `frontend` - React/TypeScript UI
- `backend` - Python/FastAPI server
- `mcp` - MCP Server
- `agents` - PydanticAI agents
- `database` - Database/migrations
- `ci-cd` - CI/CD workflows
- `docker` - Docker/infrastructure

**Status:**
- `needs-triage` - Needs initial review
- `stale` - Inactive issue/PR
- `good-first-issue` - Good for newcomers
- `help-wanted` - Extra attention needed
- `work-in-progress` - Currently being worked on

**Priority:**
- `priority: critical` - Blocking production
- `priority: high` - Important feature/fix
- `priority: medium` - Should be addressed
- `priority: low` - Nice to have

**Size:**
- `size/xs` - < 10 lines changed
- `size/s` - 10-100 lines
- `size/m` - 100-500 lines
- `size/l` - 500-1000 lines
- `size/xl` - > 1000 lines

**Special:**
- `breaking-change` - Breaking changes
- `security` - Security-related
- `pinned` - Never mark as stale
- `merge-conflict` - Has merge conflicts

---

## 🤖 Automated Global Application

**NEW: Apply these settings to ALL your repositories automatically!**

We've created automation scripts to apply all these settings across all your personal repositories at once:

### Quick Start

**Windows (PowerShell):**
```powershell
cd g:\Commander\archon\.github\scripts
.\apply-github-settings.ps1
```

**Linux/Mac (Bash):**
```bash
cd /g/Commander/archon/.github/scripts
chmod +x apply-github-settings.sh
./apply-github-settings.sh
```

### Documentation

- 📖 **[Quick Start Guide](QUICK_START.md)** - Get started in 2 minutes
- 📚 **[Full Documentation](APPLY_GLOBALLY.md)** - Complete guide with troubleshooting
- 📁 **Scripts Location:** `.github/scripts/`

### Features

✅ Applies settings to all your personal repositories
✅ Interactive mode with confirmation
✅ Real-time progress feedback
✅ Detailed summary report
✅ Safe and idempotent (can run multiple times)

---

## 🚀 Manual Setup Commands (Alternative)

For single repository configuration or if you prefer manual setup:

```bash
# Enable all GitHub features via API (requires GitHub CLI)
gh repo edit --enable-issues --enable-projects --enable-wiki=false
gh repo edit --enable-discussions
gh repo edit --delete-branch-on-merge

# Add branch protection
gh api repos/:owner/:repo/branches/main/protection \
  --method PUT \
  --field required_pull_request_reviews[required_approving_review_count]=1 \
  --field required_status_checks[strict]=true \
  --field enforce_admins=false

# Enable security features
gh api repos/:owner/:repo/vulnerability-alerts --method PUT
gh api repos/:owner/:repo/automated-security-fixes --method PUT
```

---

## 📝 Notes

- This is a **beta project**, so some restrictions are intentionally relaxed
- Settings can be adjusted as the project matures
- Regular review of settings is recommended as the team grows

---

## ✅ Configuration Status

Last Updated: 2025-11-16

- [x] CODEOWNERS configured
- [x] Dependabot configured
- [x] Auto-labeling configured
- [x] Auto-assign configured
- [x] PR templates configured
- [x] Issue templates configured
- [x] CI/CD workflows configured
- [x] Security policy configured
- [x] Stale bot configured
- [x] Greetings workflow configured
- [x] **Automation scripts created** (apply-github-settings.sh & .ps1)
- [x] **Global application documentation created** (APPLY_GLOBALLY.md)
- [ ] Manual settings in GitHub UI (can now be automated via scripts)

---

For questions about these settings, contact:
- @coleam00
- @Wirasm
