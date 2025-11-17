# Apply GitHub Settings Globally to All Your Repositories

This guide will help you apply the standardized GitHub settings from [GITHUB_SETTINGS.md](GITHUB_SETTINGS.md) to all your personal repositories automatically.

## 🎯 What Gets Applied

The automation scripts will configure:

### ✅ General Settings
- Enable Issues
- Enable Discussions
- Disable Wiki (use docs/ instead)
- Enable Projects
- Enable all merge strategies (squash, merge commit, rebase)
- Auto-delete head branches after merge
- Set default branch to `main`

### 🔐 Security Features
- Dependabot vulnerability alerts
- Automated security fixes
- Secret scanning (for public repos)
- Secret scanning push protection
- Private vulnerability reporting
- Dependency graph

### 🛡️ Branch Protection (main branch)
- Require pull request approvals (1 minimum)
- Require status checks to pass:
  - `frontend-tests`
  - `backend-tests`
  - `docker-build-test`
- Dismiss stale reviews when new commits are pushed
- Require code owner reviews
- Require conversation resolution before merging
- Prevent force pushes and deletions
- Keep branches up to date before merging

### 🤖 GitHub Actions Permissions
- Enable all actions and reusable workflows
- Read and write permissions for workflows
- Allow GitHub Actions to create and approve pull requests

---

## 📋 Prerequisites

### 1. Install GitHub CLI

**Windows (PowerShell):**
```powershell
winget install --id GitHub.cli
```

**macOS:**
```bash
brew install gh
```

**Linux (Debian/Ubuntu):**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

### 2. Authenticate with GitHub

```bash
gh auth login
```

Follow the prompts to authenticate with your GitHub account.

### 3. Verify Authentication

```bash
gh auth status
```

You should see your username and authentication status.

---

## 🚀 Usage

### Option 1: PowerShell Script (Windows - Recommended)

#### Apply to ALL Your Repositories

```powershell
cd g:\Commander\archon\.github\scripts
.\apply-github-settings.ps1
```

Then select option `1` when prompted.

#### Apply to a Specific Repository

```powershell
.\apply-github-settings.ps1 -Mode specific -RepositoryName "yourusername/repo-name"
```

#### Test on Current Repository

```powershell
# Navigate to your repository first
cd g:\path\to\your\repo

# Run the script
g:\Commander\archon\.github\scripts\apply-github-settings.ps1 -Mode current
```

---

### Option 2: Bash Script (Linux/Mac/Git Bash)

#### Apply to ALL Your Repositories

```bash
cd /g/Commander/archon/.github/scripts
chmod +x apply-github-settings.sh
./apply-github-settings.sh
```

Then select option `1` when prompted.

#### Apply to a Specific Repository

```bash
./apply-github-settings.sh
# Select option 2 and enter your repository name
```

#### Test on Current Repository

```bash
# Navigate to your repository first
cd /path/to/your/repo

# Run the script
/g/Commander/archon/.github/scripts/apply-github-settings.sh
# Select option 3
```

---

## 📊 What to Expect

### During Execution

The script will:
1. ✅ Verify GitHub CLI is installed and authenticated
2. 📋 Fetch your repositories (if applying to all)
3. 🔄 Apply settings to each repository one by one
4. 📊 Show real-time progress for each repo
5. ✅ Display a summary at the end

### Output Example

```
╔════════════════════════════════════════════════════════╗
║   GitHub Repository Settings Global Applier          ║
║   For Your Personal Repositories                      ║
╚════════════════════════════════════════════════════════╝

✓ GitHub CLI is installed and authenticated
👤 Logged in as: yourusername

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Configuring: yourusername/my-project
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚙️  Applying general settings...
  ✓ General settings applied
🔐 Enabling security features...
  ✓ Vulnerability alerts enabled
  ✓ Automated security fixes enabled
  ✓ Secret scanning enabled
🛡️  Setting up branch protection for 'main'...
  ✓ Branch protection applied to 'main'
🤖 Configuring GitHub Actions permissions...
  ✓ Actions permissions set
  ✓ Workflow permissions configured

✅ Repository fully configured: yourusername/my-project
```

### Summary Report

```
╔════════════════════════════════════════════════════════╗
║   ✅ Configuration Complete!                          ║
╚════════════════════════════════════════════════════════╝

📊 Summary:
  Total repositories: 25
  ✓ Fully configured: 20
  ⚠ Partially configured: 5
  ✗ Failed: 0
```

---

## ⚠️ Important Notes

### Admin Access Required

Some settings require **admin access** to the repository:
- Branch protection rules
- Some workflow permissions

If you see warnings about admin access, verify you have admin rights to the repository.

### Status Checks

The branch protection includes required status checks:
- `frontend-tests`
- `backend-tests`
- `docker-build-test`

**If these don't exist in your repository**, GitHub will still accept the configuration, but you may need to manually adjust the required checks later.

### Private Repositories

Some security features are only available for:
- Public repositories
- Private repositories with GitHub Advanced Security enabled

You may see warnings for these features on private repos.

---

## 🔍 Verification

After running the script, verify the settings were applied:

### Via GitHub CLI

```bash
# View repository settings
gh repo view yourusername/repo-name --web

# Check branch protection
gh api repos/yourusername/repo-name/branches/main/protection
```

### Via GitHub Web UI

1. Go to your repository on GitHub
2. Navigate to **Settings**
3. Check the following sections:
   - **General** → Pull Requests, Issues, Discussions
   - **Branches** → Branch protection rules for `main`
   - **Actions** → General → Workflow permissions
   - **Security** → Code security and analysis

---

## 🛠️ Troubleshooting

### Error: "GitHub CLI not installed"

**Solution:** Install GitHub CLI using the instructions in the Prerequisites section.

### Error: "Not authenticated"

**Solution:** Run `gh auth login` and follow the prompts.

### Warning: "Requires admin access"

**Solution:** You need admin permissions on the repository. If it's your personal repo, you should have admin access by default. For organization repos, contact your organization admin.

### Warning: "Branch protection requires status checks"

**Solution:** The status checks (`frontend-tests`, `backend-tests`, `docker-build-test`) are configured but may not exist in your repository yet. You can:
1. Set up these workflows in your repository
2. Or manually edit the branch protection rules to remove/change the required checks

### Error: "main branch not found"

**Solution:** Your repository uses a different default branch (like `master`). Either:
1. Rename your branch to `main` using: `gh repo edit --default-branch main`
2. Or modify the script to use your current default branch

### Script Execution Policy (PowerShell)

If you get an execution policy error on Windows:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

---

## 🔄 Updating Settings Later

If you want to update settings after initial configuration:

1. Edit [GITHUB_SETTINGS.md](GITHUB_SETTINGS.md) with your new preferences
2. Update the scripts if needed
3. Re-run the automation script

The scripts are **idempotent** - you can run them multiple times safely.

---

## 📝 Manual Configuration Still Required

Some settings cannot be automated and must be configured manually:

### Secrets and Variables

Navigate to: `Settings > Secrets and variables > Actions`

Add required secrets:
- `CLAUDE_CODE_OAUTH_TOKEN`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_KEY`
- Any other project-specific secrets

### Repository-Specific Files

These files should be added to each repository:

1. **`.github/CODEOWNERS`**
   ```
   # Default owners for everything
   * @yourusername

   # Frontend
   /frontend/ @frontend-team

   # Backend
   /backend/ @backend-team
   ```

2. **`.github/dependabot.yml`**
   ```yaml
   version: 2
   updates:
     - package-ecosystem: "npm"
       directory: "/frontend"
       schedule:
         interval: "weekly"

     - package-ecosystem: "pip"
       directory: "/backend"
       schedule:
         interval: "weekly"
   ```

---

## 🎯 Advanced Usage

### Apply to Multiple Repositories with Filtering

```powershell
# PowerShell: Filter repositories and apply
$repos = gh repo list --json nameWithOwner -q '.[].nameWithOwner' | ConvertFrom-Json
$filtered = $repos | Where-Object { $_ -like "*archon*" }

foreach ($repo in $filtered) {
    .\apply-github-settings.ps1 -Mode specific -RepositoryName $repo
}
```

```bash
# Bash: Filter repositories and apply
gh repo list --json nameWithOwner -q '.[].nameWithOwner' | grep "archon" | while read repo; do
    ./apply-github-settings.sh <<< "2
$repo"
done
```

### Dry Run (Test Mode)

Before applying to all repos, test on a single repository:

```powershell
.\apply-github-settings.ps1 -Mode current
```

Review the output and verify everything works as expected.

---

## 📚 Additional Resources

- [GitHub CLI Documentation](https://cli.github.com/manual/)
- [GitHub REST API - Repositories](https://docs.github.com/en/rest/repos)
- [GitHub Branch Protection](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches)
- [GitHub Actions Permissions](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository)

---

## 🤝 Support

If you encounter issues:

1. Check the troubleshooting section above
2. Review the [GITHUB_SETTINGS.md](GITHUB_SETTINGS.md) documentation
3. Verify your GitHub CLI version: `gh --version`
4. Check GitHub's status: https://www.githubstatus.com/

---

## ✅ Success Checklist

After running the scripts, verify:

- [ ] All repositories show as "Fully configured" or "Partially configured"
- [ ] Branch protection is enabled on `main` branch
- [ ] Issues and Discussions are enabled
- [ ] Wiki is disabled
- [ ] Auto-delete branches is enabled
- [ ] Security features are enabled (Dependabot, secret scanning)
- [ ] GitHub Actions permissions are configured
- [ ] Manual secrets have been added (if applicable)
- [ ] CODEOWNERS file exists (if you use it)
- [ ] Dependabot configuration exists

---

**Last Updated:** 2025-11-16

**Maintainer:** Your GitHub username

---

## 💡 Pro Tips

1. **Run on one repository first** to verify everything works before applying to all
2. **Keep a backup** of important repository settings before bulk changes
3. **Review the output carefully** - warnings may indicate settings that need manual attention
4. **Re-run periodically** to ensure new repositories get the same configuration
5. **Customize the scripts** to match your specific workflow needs

---

🎉 **You're all set!** Your repositories will now have consistent, production-ready settings across the board.
