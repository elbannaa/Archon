# Quick Start: Apply GitHub Settings Globally

## 🚀 Fast Track (Windows)

```powershell
# 1. Install GitHub CLI (if not already installed)
winget install --id GitHub.cli

# 2. Authenticate
gh auth login

# 3. Navigate to scripts folder
cd g:\Commander\archon\.github\scripts

# 4. Run the PowerShell script
.\apply-github-settings.ps1

# 5. Select option 1 to apply to all your repos
# Then type "yes" to confirm
```

## 🚀 Fast Track (Linux/Mac)

```bash
# 1. Install GitHub CLI
# macOS: brew install gh
# Linux: See APPLY_GLOBALLY.md for instructions

# 2. Authenticate
gh auth login

# 3. Navigate to scripts folder and make executable
cd /g/Commander/archon/.github/scripts
chmod +x apply-github-settings.sh

# 4. Run the bash script
./apply-github-settings.sh

# 5. Select option 1 to apply to all your repos
# Then type "yes" to confirm
```

---

## 📋 Quick Command Reference

### Apply to All Repositories

**PowerShell:**
```powershell
g:\Commander\archon\.github\scripts\apply-github-settings.ps1 -Mode all
```

**Bash:**
```bash
/g/Commander/archon/.github/scripts/apply-github-settings.sh
# Select option 1
```

### Apply to Specific Repository

**PowerShell:**
```powershell
.\apply-github-settings.ps1 -Mode specific -RepositoryName "username/repo"
```

**Bash:**
```bash
./apply-github-settings.sh
# Select option 2, then enter: username/repo
```

### Test on Current Repository

**PowerShell:**
```powershell
cd g:\path\to\your\repo
g:\Commander\archon\.github\scripts\apply-github-settings.ps1 -Mode current
```

**Bash:**
```bash
cd /path/to/your/repo
/g/Commander/archon/.github/scripts/apply-github-settings.sh
# Select option 3
```

---

## ✅ What Gets Configured

| Category | Settings |
|----------|----------|
| **General** | Issues ✓, Discussions ✓, Wiki ✗, Projects ✓, Auto-delete branches ✓ |
| **Merging** | Squash ✓, Merge commit ✓, Rebase ✓ |
| **Security** | Dependabot ✓, Secret scanning ✓, Vulnerability alerts ✓ |
| **Branch Protection** | Require PR approval (1), Status checks, Code owners review |
| **Actions** | Read/write permissions, Can create PRs |

---

## ⚠️ Common Issues

| Issue | Solution |
|-------|----------|
| `gh: command not found` | Install GitHub CLI: `winget install GitHub.cli` |
| `Not authenticated` | Run: `gh auth login` |
| `Requires admin access` | Verify you have admin rights to the repo |
| Execution policy error (PS) | Run: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |

---

## 📖 Full Documentation

For detailed information, see [APPLY_GLOBALLY.md](APPLY_GLOBALLY.md)

---

## 🔗 Useful Links

- [GitHub CLI Installation](https://cli.github.com/)
- [Full Settings Documentation](GITHUB_SETTINGS.md)
- [Detailed Usage Guide](APPLY_GLOBALLY.md)

---

**Last Updated:** 2025-11-16
