# GitHub Settings Global Applier for Personal Repositories
# This script applies standardized GitHub repository settings across all YOUR repositories
# Requires: GitHub CLI (gh) to be installed and authenticated

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('all', 'specific', 'current')]
    [string]$Mode = 'prompt',

    [Parameter(Mandatory=$false)]
    [string]$RepositoryName
)

# Colors for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = 'White'
    )
    Write-Host $Message -ForegroundColor $Color
}

# Banner
Write-ColorOutput "╔════════════════════════════════════════════════════════╗" -Color Cyan
Write-ColorOutput "║   GitHub Repository Settings Global Applier          ║" -Color Cyan
Write-ColorOutput "║   For Your Personal Repositories                      ║" -Color Cyan
Write-ColorOutput "╚════════════════════════════════════════════════════════╝" -Color Cyan
Write-Host ""

# Check if gh CLI is installed
try {
    $null = Get-Command gh -ErrorAction Stop
    Write-ColorOutput "✓ GitHub CLI is installed" -Color Green
} catch {
    Write-ColorOutput "❌ GitHub CLI (gh) is not installed." -Color Red
    Write-Host "Install it from: https://cli.github.com/"
    exit 1
}

# Check if authenticated
try {
    gh auth status 2>$null
    if ($LASTEXITCODE -ne 0) {
        throw "Not authenticated"
    }
    Write-ColorOutput "✓ GitHub CLI is authenticated" -Color Green
} catch {
    Write-ColorOutput "⚠️  Not authenticated with GitHub CLI" -Color Yellow
    Write-Host "Run: gh auth login"
    exit 1
}

Write-Host ""

# Get current user
$GITHUB_USER = gh api user -q .login
Write-ColorOutput "👤 Logged in as: $GITHUB_USER" -Color Cyan
Write-Host ""

# Counters for summary
$script:TOTAL_REPOS = 0
$script:SUCCESS_COUNT = 0
$script:PARTIAL_COUNT = 0
$script:FAILED_COUNT = 0

# Function to apply settings to a single repository
function Apply-RepoSettings {
    param(
        [string]$Repo
    )

    $owner, $repo_name = $Repo -split '/'
    $settings_applied = 0
    $settings_failed = 0

    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color Cyan
    Write-ColorOutput "📦 Configuring: $Repo" -Color Green
    Write-ColorOutput "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -Color Cyan

    # 1. General Repository Settings
    Write-ColorOutput "⚙️  Applying general settings..." -Color Yellow
    try {
        gh repo edit $Repo `
            --enable-issues `
            --enable-discussions `
            --enable-wiki=false `
            --enable-projects `
            --delete-branch-on-merge `
            --allow-squash-merge `
            --allow-merge-commit `
            --allow-rebase-merge `
            --default-branch main 2>$null

        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ General settings applied" -Color Green
            $settings_applied++
        } else {
            Write-ColorOutput "  ⚠️  Some general settings may require admin access" -Color Yellow
            $settings_failed++
        }
    } catch {
        Write-ColorOutput "  ⚠️  Error applying general settings" -Color Yellow
        $settings_failed++
    }

    # 2. Security Features
    Write-ColorOutput "🔐 Enabling security features..." -Color Yellow

    # Enable vulnerability alerts
    try {
        gh api -X PUT "repos/$owner/$repo_name/vulnerability-alerts" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ Vulnerability alerts enabled" -Color Green
            $settings_applied++
        }
    } catch {
        Write-ColorOutput "  ⚠️  Vulnerability alerts (may already be enabled)" -Color Yellow
    }

    # Enable automated security fixes
    try {
        gh api -X PUT "repos/$owner/$repo_name/automated-security-fixes" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ Automated security fixes enabled" -Color Green
            $settings_applied++
        }
    } catch {
        Write-ColorOutput "  ⚠️  Automated security fixes (may already be enabled)" -Color Yellow
    }

    # Enable secret scanning
    try {
        gh api -X PUT "repos/$owner/$repo_name/secret-scanning" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ Secret scanning enabled" -Color Green
            $settings_applied++
        }
    } catch {
        Write-ColorOutput "  ⚠️  Secret scanning (requires public repo or GitHub Advanced Security)" -Color Yellow
    }

    # Enable secret scanning push protection
    try {
        gh api -X PUT "repos/$owner/$repo_name/secret-scanning/push-protection" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ Secret scanning push protection enabled" -Color Green
            $settings_applied++
        }
    } catch {
        Write-ColorOutput "  ⚠️  Secret scanning push protection (requires public repo or GitHub Advanced Security)" -Color Yellow
    }

    # Enable private vulnerability reporting
    try {
        gh api -X PUT "repos/$owner/$repo_name/private-vulnerability-reporting" 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ Private vulnerability reporting enabled" -Color Green
            $settings_applied++
        }
    } catch {
        Write-ColorOutput "  ⚠️  Private vulnerability reporting (may require specific plan)" -Color Yellow
    }

    # 3. Branch Protection for main branch
    Write-ColorOutput "🛡️  Setting up branch protection for 'main'..." -Color Yellow

    # Check if main branch exists
    try {
        gh api "repos/$owner/$repo_name/branches/main" 2>$null | Out-Null
        if ($LASTEXITCODE -eq 0) {
            # Build branch protection payload
            $protection = @{
                required_status_checks = @{
                    strict = $true
                    checks = @(
                        @{ context = "frontend-tests" }
                        @{ context = "backend-tests" }
                        @{ context = "docker-build-test" }
                    )
                }
                required_pull_request_reviews = @{
                    required_approving_review_count = 1
                    dismiss_stale_reviews = $true
                    require_code_owner_reviews = $true
                }
                required_conversation_resolution = @{
                    enabled = $true
                }
                enforce_admins = $false
                restrictions = $null
                allow_force_pushes = @{ enabled = $false }
                allow_deletions = @{ enabled = $false }
            } | ConvertTo-Json -Depth 10

            try {
                gh api -X PUT "repos/$owner/$repo_name/branches/main/protection" --input - 2>$null <<< $protection
                if ($LASTEXITCODE -eq 0) {
                    Write-ColorOutput "  ✓ Branch protection applied to 'main'" -Color Green
                    $settings_applied++
                } else {
                    Write-ColorOutput "  ⚠️  Branch protection (requires admin access or check if status checks exist)" -Color Yellow
                    $settings_failed++
                }
            } catch {
                Write-ColorOutput "  ⚠️  Branch protection (requires admin access)" -Color Yellow
                $settings_failed++
            }
        }
    } catch {
        Write-ColorOutput "  ⚠️  'main' branch not found, skipping branch protection" -Color Yellow
    }

    # 4. Actions Permissions
    Write-ColorOutput "🤖 Configuring GitHub Actions permissions..." -Color Yellow

    # Set actions permissions
    try {
        $actionsPerms = @{
            enabled = $true
            allowed_actions = "all"
        } | ConvertTo-Json

        $actionsPerms | gh api -X PUT "repos/$owner/$repo_name/actions/permissions" --input - 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ Actions permissions set" -Color Green
            $settings_applied++
        }
    } catch {
        Write-ColorOutput "  ⚠️  Actions permissions (may already be configured)" -Color Yellow
    }

    # Set workflow permissions
    try {
        $workflowPerms = @{
            default_workflow_permissions = "write"
            can_approve_pull_request_reviews = $true
        } | ConvertTo-Json

        $workflowPerms | gh api -X PUT "repos/$owner/$repo_name/actions/permissions/workflow" --input - 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "  ✓ Workflow permissions configured" -Color Green
            $settings_applied++
        }
    } catch {
        Write-ColorOutput "  ⚠️  Workflow permissions (requires admin access)" -Color Yellow
    }

    Write-Host ""
    if ($settings_applied -gt 0 -and $settings_failed -eq 0) {
        Write-ColorOutput "✅ Repository fully configured: $Repo" -Color Green
        $script:SUCCESS_COUNT++
    } elseif ($settings_applied -gt 0) {
        Write-ColorOutput "⚠️  Repository partially configured: $Repo" -Color Yellow
        $script:PARTIAL_COUNT++
    } else {
        Write-ColorOutput "❌ Repository configuration failed: $Repo" -Color Red
        $script:FAILED_COUNT++
    }
    Write-Host ""
}

# Main execution
if ($Mode -eq 'prompt') {
    Write-ColorOutput "Choose an option:" -Color Yellow
    Write-Host "1. Apply settings to ALL your personal repositories"
    Write-Host "2. Apply settings to a specific repository"
    Write-Host "3. Test on current repository only"
    Write-Host ""
    $choice = Read-Host "Enter choice (1-3)"
} else {
    $choice = switch ($Mode) {
        'all' { '1' }
        'specific' { '2' }
        'current' { '3' }
    }
}

switch ($choice) {
    '1' {
        Write-ColorOutput "📋 Fetching all your repositories..." -Color Yellow
        $repos = gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner' | ConvertFrom-Json

        $script:TOTAL_REPOS = $repos.Count
        Write-ColorOutput "Found $($script:TOTAL_REPOS) repositories" -Color Cyan
        Write-Host ""
        Write-ColorOutput "The following repositories will be configured:" -Color Magenta
        foreach ($repo in $repos) {
            Write-Host "  - $repo"
        }
        Write-Host ""

        $confirm = Read-Host "Apply settings to ALL your repositories? (yes/no)"

        if ($confirm -eq 'yes') {
            foreach ($repo in $repos) {
                Apply-RepoSettings -Repo $repo
            }
        } else {
            Write-ColorOutput "❌ Cancelled" -Color Red
            exit 0
        }
    }

    '2' {
        if (-not $RepositoryName) {
            $RepositoryName = Read-Host "Enter repository (format: owner/repo)"
        }
        $script:TOTAL_REPOS = 1
        Apply-RepoSettings -Repo $RepositoryName
    }

    '3' {
        # Get current repo
        try {
            $current_repo = gh repo view --json nameWithOwner -q .nameWithOwner
            if ($LASTEXITCODE -ne 0) {
                throw "Not in a git repository"
            }
            $script:TOTAL_REPOS = 1
            Apply-RepoSettings -Repo $current_repo
        } catch {
            Write-ColorOutput "❌ Not in a git repository" -Color Red
            exit 1
        }
    }

    default {
        Write-ColorOutput "❌ Invalid choice" -Color Red
        exit 1
    }
}

# Summary
Write-Host ""
Write-ColorOutput "╔════════════════════════════════════════════════════════╗" -Color Green
Write-ColorOutput "║   ✅ Configuration Complete!                          ║" -Color Green
Write-ColorOutput "╚════════════════════════════════════════════════════════╝" -Color Green
Write-Host ""
Write-ColorOutput "📊 Summary:" -Color Cyan
Write-Host "  Total repositories: $($script:TOTAL_REPOS)"
Write-ColorOutput "  ✓ Fully configured: $($script:SUCCESS_COUNT)" -Color Green
Write-ColorOutput "  ⚠ Partially configured: $($script:PARTIAL_COUNT)" -Color Yellow
Write-ColorOutput "  ✗ Failed: $($script:FAILED_COUNT)" -Color Red
Write-Host ""
Write-ColorOutput "📝 Next Steps:" -Color Cyan
Write-Host "  1. Verify branch protection rules in GitHub UI"
Write-Host "  2. Add required secrets to repositories (if needed)"
Write-Host "  3. Review Actions permissions in repository settings"
Write-Host "  4. Add/update CODEOWNERS file if not present"
Write-Host "  5. Add/update .github/dependabot.yml if not present"
Write-Host ""
Write-ColorOutput "💡 Tip: Visit your repository settings to verify all changes" -Color Magenta
Write-Host ""
