# Security Audit Plugin

Comprehensive security toolkit for Claude Code that brings enterprise-grade security analysis directly into your development workflow.

## Features

### 🔍 `/security:scan` - Comprehensive Security Scanning
- **SAST Analysis** - Static application security testing across 6+ languages
- **Dependency Vulnerabilities** - CVE detection in npm, pip, bundler, and more
- **Configuration Security** - Checks for insecure configs, missing headers, debug mode
- **OWASP Top 10 Mapping** - Findings mapped to OWASP categories
- **CWE Top 25 Mapping** - Identifies most dangerous software weaknesses
- **CVSS Severity Scoring** - Critical/High/Medium/Low prioritization

**Supported Languages:**
- JavaScript/TypeScript (Node.js, React, Vue, Angular)
- Python (Django, Flask, FastAPI)
- Ruby (Rails, Sinatra)
- Go
- Java
- C#/.NET

**Integrated Tools:**
- Semgrep (multi-language SAST)
- npm audit, yarn audit (JavaScript)
- pip-audit, safety (Python)
- bundler-audit, brakeman (Ruby)
- gosec (Go)
- Language-specific security linters

### 🔐 `/security:secrets` - Secrets Detection
- **700+ Secret Patterns** - AWS keys, API tokens, database passwords, private keys
- **Git History Scanning** - Find secrets in historical commits
- **Entropy Analysis** - Detect high-entropy strings (random-looking keys)
- **Credential Verification** - Checks if secrets are active/valid
- **Remediation Guidance** - Step-by-step instructions to rotate and secure

**Detected Secret Types:**
- AWS Access Keys, Azure credentials, GCP service accounts
- GitHub/GitLab tokens
- Slack webhooks
- Stripe API keys
- Database connection strings (PostgreSQL, MySQL, MongoDB)
- Private keys (RSA, SSH, PGP)
- JWT secrets
- Generic API keys and passwords

**Integrated Tools:**
- TruffleHog (entropy + pattern matching)
- Gitleaks (pattern-based with git history)
- Fallback to pattern-based Grep scanning

## Installation

### Prerequisites

**Recommended Tools (Install for Best Results):**

```bash
# Semgrep - Multi-language SAST (Highly Recommended)
pip install semgrep
# or
brew install semgrep

# TruffleHog - Secrets detection (Highly Recommended)
brew install trufflesecurity/trufflehog/trufflehog
# or
pip install trufflehog

# Gitleaks - Alternative secrets scanner
brew install gitleaks
```

**Language-Specific Tools (Optional):**

```bash
# JavaScript/TypeScript
npm install -g eslint eslint-plugin-security

# Python
pip install bandit pip-audit safety

# Ruby
gem install bundler-audit brakeman

# Go
go install github.com/securego/gosec/v2/cmd/gosec@latest
```

### Plugin Installation

This plugin is part of the raptortech-plugins marketplace:

```bash
# Plugin is already installed if you have this repository
# Reload plugins in Claude Code:
/plugin
```

## Usage

### Security Scan

```bash
# Full repository scan
/security:scan

# Scan specific directory
/security:scan src/auth

# Scan changed files only
/security:scan --git-diff

# Focus on specific area
/security:scan --focus dependencies
/security:scan --focus sast
/security:scan --focus config
```

**Example Output:**

```
## Security Scan Results

Scanned: 432 files across JavaScript, Python
Scan duration: 45 seconds

### Summary

| Severity | Count | Percentage |
|----------|-------|------------|
| Critical | 2     | 3%         |
| High     | 8     | 13%        |
| Medium   | 25    | 40%        |
| Low      | 27    | 44%        |

### Critical Issues (Immediate Action Required)

#### 1. SQL Injection in User Authentication
**File:** src/auth/login.js:42
**Severity:** CRITICAL (CVSS 9.8)
**OWASP:** A03:2021 - Injection

**Vulnerable Code:**
```javascript
const query = 'SELECT * FROM users WHERE id=' + userId
```

**Recommendation:**
Use parameterized queries...
```

### Secrets Detection

```bash
# Scan current codebase
/security:secrets

# Scan git history (finds removed secrets still in history)
/security:secrets --history

# Comprehensive scan (codebase + history)
/security:secrets --all

# Scan specific directory
/security:secrets config/
```

**Example Output:**

```
## Secrets Detection Results

Scanned: 432 files, 1,250 commits
Scan duration: 2 minutes

### CRITICAL: Active Secrets in Current Codebase

#### 1. AWS Access Key (VERIFIED ACTIVE)
**File:** config/aws-config.js:15
**Severity:** CRITICAL

**Exposed Secret:**
AKIA****************MPLE

**Verification:** ✅ This credential was verified as ACTIVE

**IMMEDIATE ACTIONS:**
1. Rotate this key NOW (within 1 hour)
2. Review AWS CloudTrail for unauthorized access
3. Use environment variables instead
4. Add to .gitignore
...
```

## Reference Documentation

The plugin includes comprehensive security reference materials:

- **`references/owasp-top10.md`** - Complete guide to OWASP Top 10 web app risks
- **`references/cwe-top25.md`** - CWE Top 25 most dangerous software weaknesses
- **`references/secure-coding-standards.md`** - Language-specific secure coding guidelines (JS, Python, Ruby, Go, Java, C#)
- **`references/remediation-playbook.md`** - Step-by-step fixes for common vulnerabilities

These references are automatically consulted by the skills to provide accurate, detailed guidance.

## Integration with Other Plugins

The security plugin integrates seamlessly with your existing plugins:

### With `issues` Plugin
```bash
# After running security scan:
# Create Jira issues for findings
/issues:create-jira-issue

# Add security context to merge requests
/issues:create-mr
```

### With `jira-improve` Plugin
```bash
# Improve security-related Jira issues
/jira-improve SEC-123
```

### With `planning` Plugin
```bash
# Include security requirements in Intent docs
/planning:aidlc-plan
```

## CI/CD Integration

### GitHub Actions

Create `.github/workflows/security-scan.yml`:

```yaml
name: Security Scan
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Install Semgrep
        run: pip install semgrep

      - name: Run Semgrep
        run: semgrep --config=auto --config=p/owasp-top-ten --json .

      - name: Install TruffleHog
        run: |
          wget https://github.com/trufflesecurity/trufflehog/releases/latest/download/trufflehog_linux_amd64.tar.gz
          tar -xzf trufflehog_linux_amd64.tar.gz
          sudo mv trufflehog /usr/local/bin/

      - name: Run TruffleHog
        run: trufflehog filesystem . --json --fail

      - name: Run npm audit
        run: npm audit --audit-level=high
```

### GitLab CI

Add to `.gitlab-ci.yml`:

```yaml
security_scan:
  stage: test
  script:
    - pip install semgrep
    - semgrep --config=auto --config=p/owasp-top-ten .
    - npm audit --audit-level=high
  allow_failure: false
```

## Examples

### Example 1: Pre-Commit Security Check

```bash
# Before committing code
/security:scan src/

# Fix any critical/high issues
# Then commit with confidence
```

### Example 2: Preventing Secret Leaks

```bash
# Before pushing to remote
/security:secrets

# If secrets found, rotate immediately
# Update .gitignore
# Use environment variables
```

### Example 3: Compliance Audit Prep

```bash
# Run comprehensive security scan
/security:scan

# Export results
# Create Jira issues for gaps
# Track remediation progress
```

### Example 4: Onboarding New Project

```bash
# Scan inherited codebase
/security:scan

# Scan for historical secret leaks
/security:secrets --history

# Prioritize critical issues
# Create remediation roadmap
```

## Common Workflows

### Weekly Security Review

```bash
1. /security:scan
2. Review critical/high findings
3. Create Jira issues for tracking
4. Schedule remediation in sprint
```

### Pre-Release Security Check

```bash
1. /security:scan --focus all
2. /security:secrets --history
3. Ensure no critical/high issues
4. Document any accepted risks
5. Get security sign-off
```

### Incident Response - Suspected Breach

```bash
1. /security:secrets --history
2. Check for exposed credentials
3. Rotate all compromised secrets
4. Review access logs
5. Implement additional monitoring
```

## Best Practices

### For Developers

- **Run scans locally** before committing code
- **Use pre-commit hooks** to catch secrets automatically
- **Fix critical issues immediately** (within 24 hours)
- **Don't commit secrets** - use environment variables
- **Keep dependencies updated** - run `npm audit` regularly

### For Security Teams

- **Automate scanning in CI/CD** - fail builds on critical issues
- **Set SLAs for remediation** - Critical: 24hrs, High: 1 week, Medium: 1 month
- **Track metrics** - Scan coverage, MTTR, vulnerability trends
- **Provide training** - Share secure coding standards with team
- **Regular audits** - Run comprehensive scans weekly

### For DevOps

- **Enable Dependabot/Renovate** - Auto-update vulnerable dependencies
- **Secrets management** - Use AWS Secrets Manager, HashiCorp Vault
- **Security headers** - Configure in load balancer/reverse proxy
- **Monitoring** - Alert on security scan failures
- **Immutable infrastructure** - Rebuild on vulnerabilities, don't patch

## Troubleshooting

### "No security tools found"

**Solution:** Install Semgrep (for scanning) and/or TruffleHog (for secrets):

```bash
pip install semgrep
brew install trufflesecurity/trufflehog/trufflehog
```

The plugin will fall back to basic pattern-based scanning if tools aren't available, but tool-based scanning is much more accurate.

### "Scan taking too long"

**Solutions:**
- Scan specific directories instead of full repo
- Use `--focus` flag to limit scope
- Exclude `node_modules`, `vendor`, `build` directories
- Run scans in parallel for different areas

### "Too many false positives"

**Solutions:**
- Focus on Critical/High severity first
- Use tool allowlists/ignore files (`.semgrepignore`, `.gitleaksignore`)
- Tune sensitivity based on your codebase
- Provide context to Claude about acceptable patterns

### "Secrets found in git history - what now?"

**Critical Steps:**
1. **Rotate exposed secrets immediately** (within 1 hour)
2. **Review access logs** for unauthorized use
3. **Notify security team**
4. **Scrub git history** using BFG Repo Cleaner or git-filter-repo
5. **Force push** (coordinate with team - destructive operation)
6. **Team re-clones** repository
7. **Implement pre-commit hooks** to prevent future leaks

## Limitations

- **Tool dependency:** Best results require external security tools installed
- **Language coverage:** Some languages better supported than others
- **False positives:** Pattern-based detection can flag non-issues
- **Performance:** Large repositories may take several minutes to scan
- **Git history:** Scanning full history can be slow for large repos

## Roadmap

### Phase 2 (Next Release - v1.1.0)
- `/security:remediate` - Guided vulnerability fixes with auto-remediation
- Support for additional languages (PHP, Rust, Kotlin)
- HTML/PDF report exports
- Jira integration for vulnerability tracking
- Historical trend analysis

### Phase 3 (v1.2.0)
- `/security:threat-model` - Interactive STRIDE threat modeling
- `/security:compliance` - OWASP, PCI-DSS, SOC 2 compliance checking
- Confluence integration for threat model docs
- Custom security rules and policies

### Future (v2.0.0)
- Container and infrastructure scanning
- CI/CD pipeline security analysis
- Team dashboard and metrics
- Real-time vulnerability alerts

## Contributing

Found a bug or have a feature request? Please:

1. Check existing issues in the repository
2. Create a new issue with detailed description
3. Include example vulnerable code (if applicable)
4. Suggest remediation approach

## License

MIT License - See repository LICENSE file

## Support

- **Documentation:** See `references/` directory for detailed security guidance
- **Issues:** Report bugs/requests in repository issues
- **Questions:** Ask in team chat or Claude Code community

---

## Quick Start

```bash
# 1. Install recommended tools
pip install semgrep
brew install trufflesecurity/trufflehog/trufflehog

# 2. Run your first security scan
/security:scan

# 3. Check for exposed secrets
/security:secrets

# 4. Review findings and remediate critical issues

# 5. Set up automated scanning in CI/CD
```

**That's it! You're now scanning for security vulnerabilities with AI-powered analysis.**

---

**Version:** 1.0.0
**Author:** DevTools Team
**Last Updated:** 2026-02-02
