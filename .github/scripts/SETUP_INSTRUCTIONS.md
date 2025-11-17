# GitHub Settings Setup - Quick Instructions

## ✅ GitHub CLI has been installed!

You just need to restart your terminal and then follow these steps:

---

## Step 1: Restart Your Terminal

**Close and reopen:**
- VSCode (completely close and reopen), OR
- Your PowerShell/Terminal window

This ensures `gh` command is available in your PATH.

---

## Step 2: Verify Installation

Open a new terminal and run:

```powershell
gh --version
```

You should see something like: `gh version 2.83.0`

---

## Step 3: Authenticate with GitHub

```powershell
gh auth login
```

**Follow the prompts:**

1. **What account do you want to log into?**
   - Select: `GitHub.com`

2. **What is your preferred protocol for Git operations?**
   - Select: `HTTPS` (recommended) or `SSH`

3. **How would you like to authenticate GitHub CLI?**
   - Select: `Login with a web browser`

4. **Copy the one-time code** displayed (e.g., `XXXX-XXXX`)

5. **Press Enter** - Your browser will open

6. **Paste the code** in the browser and authorize

7. **Done!** You should see: `✓ Logged in as yourusername`

---

## Step 4: Verify Authentication

```powershell
gh auth status
```

You should see your username and authentication status.

---

## Step 5: Run the Settings Script

```powershell
cd g:\Commander\archon\.github\scripts
.\apply-github-settings.ps1
```

### What will happen:

1. Script will show you're logged in as your GitHub username
2. You'll be asked to choose an option:
   - **Option 1:** Apply to ALL your personal repositories (recommended)
   - **Option 2:** Apply to a specific repository
   - **Option 3:** Test on current repository only

3. **For Option 1:** The script will:
   - Fetch all your repositories
   - Show you the list
   - Ask for confirmation (type `yes`)
   - Apply all settings to each repo
   - Show progress in real-time
   - Display a summary at the end

---

## Step 6: Review Results

After the script completes, you'll see:

```
╔════════════════════════════════════════════════════════╗
║   ✅ Configuration Complete!                          ║
╚════════════════════════════════════════════════════════╝

📊 Summary:
  Total repositories: X
  ✓ Fully configured: X
  ⚠ Partially configured: X
  ✗ Failed: 0
```

---

## What Gets Applied to Your Repos

### ✅ General Settings
- Enable Issues
- Enable Discussions
- Disable Wiki
- Enable Projects
- Auto-delete head branches after merge
- Allow all merge strategies (squash, merge commit, rebase)
- Set default branch to `main`

### 🔐 Security Features
- Dependabot alerts
- Automated security fixes
- Secret scanning (for public repos)
- Secret scanning push protection
- Private vulnerability reporting

### 🛡️ Branch Protection (main branch)
- Require pull request approvals (1 minimum)
- Dismiss stale reviews when new commits pushed
- Require code owner reviews
- Require conversation resolution
- Require status checks: frontend-tests, backend-tests, docker-build-test
- Prevent force pushes and deletions

### 🤖 GitHub Actions
- Read and write permissions
- Allow Actions to create/approve PRs

---

## Troubleshooting

### "gh: command not found"
**Solution:** Make sure you restarted your terminal after installation.

### Execution Policy Error
If you see an execution policy error when running the PowerShell script:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Then try running the script again.

### "Requires admin access" warnings
**Solution:** You should have admin access to your personal repos. If you see this, verify you're the owner of the repository.

### "Status checks not found"
**This is normal!** The status checks (frontend-tests, backend-tests, etc.) will be configured but won't fail builds until you actually add those GitHub Actions workflows to your repository.

---

## Verification

After running the script, verify settings on one or two repos:

1. Go to GitHub.com
2. Navigate to one of your repositories
3. Click **Settings**
4. Check:
   - **General** → Issues, Discussions, Projects enabled, Wiki disabled
   - **Branches** → Branch protection rules for `main`
   - **Actions** → Workflow permissions set to "Read and write"
   - **Security** → Dependabot, secret scanning enabled

---

## Quick Commands Reference

```powershell
# Check if gh is installed
gh --version

# Authenticate
gh auth login

# Check auth status
gh auth status

# Run the settings script
cd g:\Commander\archon\.github\scripts
.\apply-github-settings.ps1

# Apply to all repos (non-interactive)
.\apply-github-settings.ps1 -Mode all

# Apply to specific repo
.\apply-github-settings.ps1 -Mode specific -RepositoryName "username/repo-name"

# Test on current repo
.\apply-github-settings.ps1 -Mode current
```

---

## Additional Resources

- 📖 [Quick Start Guide](QUICK_START.md)
- 📚 [Full Documentation](APPLY_GLOBALLY.md)
- ⚙️ [GitHub Settings Reference](../GITHUB_SETTINGS.md)

---

## Summary: What to Do Now

1. ✅ **Restart your terminal** (close and reopen VSCode or PowerShell)
2. ✅ **Run:** `gh auth login`
3. ✅ **Authenticate in browser**
4. ✅ **Run:** `.\apply-github-settings.ps1` (from the scripts folder)
5. ✅ **Choose Option 1** to apply to all repos
6. ✅ **Type `yes`** to confirm
7. ✅ **Wait for completion** and review the summary

---

**That's it! Your repositories will have consistent, professional settings.** 🎉

---

Created: 2025-11-16
