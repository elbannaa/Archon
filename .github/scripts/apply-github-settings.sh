#!/bin/bash

# GitHub Settings Global Applier for Personal Repositories
# This script applies standardized GitHub repository settings across all YOUR repositories
# Requires: GitHub CLI (gh) to be installed and authenticated

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   GitHub Repository Settings Global Applier          ║${NC}"
echo -e "${BLUE}║   For Your Personal Repositories                      ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) is not installed.${NC}"
    echo "Install it from: https://cli.github.com/"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo -e "${YELLOW}⚠️  Not authenticated with GitHub CLI${NC}"
    echo "Run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✓ GitHub CLI is installed and authenticated${NC}"
echo ""

# Get current user
GITHUB_USER=$(gh api user -q .login)
echo -e "👤 Logged in as: ${BLUE}${GITHUB_USER}${NC}"
echo ""

# Counters for summary
TOTAL_REPOS=0
SUCCESS_COUNT=0
PARTIAL_COUNT=0
FAILED_COUNT=0

# Function to apply settings to a single repository
apply_repo_settings() {
    local repo=$1
    local owner=$(echo $repo | cut -d'/' -f1)
    local repo_name=$(echo $repo | cut -d'/' -f2)
    local settings_applied=0
    local settings_failed=0

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "📦 Configuring: ${GREEN}${repo}${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    # 1. General Repository Settings
    echo -e "${YELLOW}⚙️  Applying general settings...${NC}"
    if gh repo edit "$repo" \
        --enable-issues \
        --enable-discussions \
        --enable-wiki=false \
        --enable-projects \
        --delete-branch-on-merge \
        --allow-squash-merge \
        --allow-merge-commit \
        --allow-rebase-merge \
        --default-branch main 2>/dev/null; then
        echo -e "${GREEN}  ✓ General settings applied${NC}"
        ((settings_applied++))
    else
        echo -e "${YELLOW}  ⚠️  Some general settings may require admin access${NC}"
        ((settings_failed++))
    fi

    # 2. Security Features
    echo -e "${YELLOW}🔐 Enabling security features...${NC}"

    # Enable vulnerability alerts
    if gh api -X PUT "repos/${owner}/${repo_name}/vulnerability-alerts" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Vulnerability alerts enabled${NC}"
        ((settings_applied++))
    else
        echo -e "${YELLOW}  ⚠️  Vulnerability alerts (may already be enabled)${NC}"
    fi

    # Enable automated security fixes
    if gh api -X PUT "repos/${owner}/${repo_name}/automated-security-fixes" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Automated security fixes enabled${NC}"
        ((settings_applied++))
    else
        echo -e "${YELLOW}  ⚠️  Automated security fixes (may already be enabled)${NC}"
    fi

    # Enable secret scanning (for public repos)
    if gh api -X PUT "repos/${owner}/${repo_name}/secret-scanning" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Secret scanning enabled${NC}"
        ((settings_applied++))
    else
        echo -e "${YELLOW}  ⚠️  Secret scanning (requires public repo or GitHub Advanced Security)${NC}"
    fi

    # Enable secret scanning push protection
    if gh api -X PUT "repos/${owner}/${repo_name}/secret-scanning/push-protection" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Secret scanning push protection enabled${NC}"
        ((settings_applied++))
    else
        echo -e "${YELLOW}  ⚠️  Secret scanning push protection (requires public repo or GitHub Advanced Security)${NC}"
    fi

    # Enable private vulnerability reporting
    if gh api -X PUT "repos/${owner}/${repo_name}/private-vulnerability-reporting" 2>/dev/null; then
        echo -e "${GREEN}  ✓ Private vulnerability reporting enabled${NC}"
        ((settings_applied++))
    else
        echo -e "${YELLOW}  ⚠️  Private vulnerability reporting (may require specific plan)${NC}"
    fi

    # 3. Branch Protection for main branch
    echo -e "${YELLOW}🛡️  Setting up branch protection for 'main'...${NC}"

    # Check if main branch exists
    if gh api "repos/${owner}/${repo_name}/branches/main" &>/dev/null; then
        # Apply branch protection
        if gh api -X PUT "repos/${owner}/${repo_name}/branches/main/protection" \
            -f required_status_checks[strict]=true \
            -F required_status_checks[checks][][context]=frontend-tests \
            -F required_status_checks[checks][][context]=backend-tests \
            -F required_status_checks[checks][][context]=docker-build-test \
            -f required_pull_request_reviews[required_approving_review_count]=1 \
            -f required_pull_request_reviews[dismiss_stale_reviews]=true \
            -f required_pull_request_reviews[require_code_owner_reviews]=true \
            -f required_conversation_resolution[enabled]=true \
            -f enforce_admins=false \
            -f restrictions=null \
            -f allow_force_pushes[enabled]=false \
            -f allow_deletions[enabled]=false 2>/dev/null; then
            echo -e "${GREEN}  ✓ Branch protection applied to 'main'${NC}"
            ((settings_applied++))
        else
            echo -e "${YELLOW}  ⚠️  Branch protection (requires admin access or check if status checks exist)${NC}"
            ((settings_failed++))
        fi
    else
        echo -e "${YELLOW}  ⚠️  'main' branch not found, skipping branch protection${NC}"
    fi

    # 4. Actions Permissions
    echo -e "${YELLOW}🤖 Configuring GitHub Actions permissions...${NC}"

    # Set actions permissions
    if gh api -X PUT "repos/${owner}/${repo_name}/actions/permissions" \
        -f enabled=true \
        -f allowed_actions=all 2>/dev/null; then
        echo -e "${GREEN}  ✓ Actions permissions set${NC}"
        ((settings_applied++))
    else
        echo -e "${YELLOW}  ⚠️  Actions permissions (may already be configured)${NC}"
    fi

    # Set workflow permissions
    if gh api -X PUT "repos/${owner}/${repo_name}/actions/permissions/workflow" \
        -f default_workflow_permissions=write \
        -f can_approve_pull_request_reviews=true 2>/dev/null; then
        echo -e "${GREEN}  ✓ Workflow permissions configured${NC}"
        ((settings_applied++))
    else
        echo -e "${YELLOW}  ⚠️  Workflow permissions (requires admin access)${NC}"
    fi

    echo ""
    if [ $settings_applied -gt 0 ] && [ $settings_failed -eq 0 ]; then
        echo -e "${GREEN}✅ Repository fully configured: ${repo}${NC}"
        ((SUCCESS_COUNT++))
    elif [ $settings_applied -gt 0 ]; then
        echo -e "${YELLOW}⚠️  Repository partially configured: ${repo}${NC}"
        ((PARTIAL_COUNT++))
    else
        echo -e "${RED}❌ Repository configuration failed: ${repo}${NC}"
        ((FAILED_COUNT++))
    fi
    echo ""
}

# Main execution
echo -e "${YELLOW}Choose an option:${NC}"
echo "1. Apply settings to ALL your personal repositories"
echo "2. Apply settings to a specific repository"
echo "3. Test on current repository only (dry run)"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        echo -e "${YELLOW}📋 Fetching all your repositories...${NC}"
        repos=$(gh repo list --limit 1000 --json nameWithOwner -q '.[].nameWithOwner')

        TOTAL_REPOS=$(echo "$repos" | wc -l)
        echo -e "${BLUE}Found ${TOTAL_REPOS} repositories${NC}"
        echo ""
        echo -e "${MAGENTA}The following repositories will be configured:${NC}"
        echo "$repos" | sed 's/^/  - /'
        echo ""
        read -p "Apply settings to ALL your repositories? (yes/no): " confirm

        if [ "$confirm" == "yes" ]; then
            for repo in $repos; do
                apply_repo_settings "$repo"
            done
        else
            echo -e "${RED}❌ Cancelled${NC}"
            exit 0
        fi
        ;;

    2)
        read -p "Enter repository (format: owner/repo): " repo
        TOTAL_REPOS=1
        apply_repo_settings "$repo"
        ;;

    3)
        # Get current repo
        current_repo=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)
        if [ -z "$current_repo" ]; then
            echo -e "${RED}❌ Not in a git repository${NC}"
            exit 1
        fi
        TOTAL_REPOS=1
        apply_repo_settings "$current_repo"
        ;;

    *)
        echo -e "${RED}❌ Invalid choice${NC}"
        exit 1
        ;;
esac

# Summary
echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅ Configuration Complete!                          ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo -e "  Total repositories: ${TOTAL_REPOS}"
echo -e "  ${GREEN}✓ Fully configured: ${SUCCESS_COUNT}${NC}"
echo -e "  ${YELLOW}⚠ Partially configured: ${PARTIAL_COUNT}${NC}"
echo -e "  ${RED}✗ Failed: ${FAILED_COUNT}${NC}"
echo ""
echo -e "${BLUE}📝 Next Steps:${NC}"
echo "  1. Verify branch protection rules in GitHub UI"
echo "  2. Add required secrets to repositories (if needed)"
echo "  3. Review Actions permissions in repository settings"
echo "  4. Add/update CODEOWNERS file if not present"
echo "  5. Add/update .github/dependabot.yml if not present"
echo ""
echo -e "${MAGENTA}💡 Tip: Visit your repository settings to verify all changes${NC}"
echo ""
