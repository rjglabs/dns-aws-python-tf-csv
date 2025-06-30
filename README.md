# DNS AWS Python Terraform CSV

[![CI](https://github.com/rjglabs/dns-aws-python-tf-csv/actions/workflows/ci.yml/badge.svg)](https://github.com/rjglabs/dns-aws-python-tf-csv/actions/workflows/ci.yml)
[![SonarCloud](https://sonarcloud.io/api/project_badges/measure?project=rjglabs_dns-aws-python-tf-csv&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=rjglabs_dns-aws-python-tf-csv)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=rjglabs_dns-aws-python-tf-csv&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=rjglabs_dns-aws-python-tf-csv)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=rjglabs_dns-aws-python-tf-csv&metric=coverage)](https://sonarcloud.io/summary/new_code?id=rjglabs_dns-aws-python-tf-csv)

> **Enterprise-grade DNS record automation tool for AWS Route53 with comprehensive security scanning and code quality enforcement.**

## 🚀 Overview

This project provides a robust automation solution for managing DNS records in AWS Route53 using CSV files as the data source. The system combines Python data processing with Terraform infrastructure-as-code, featuring an extensive CI/CD pipeline with **15+ security and quality checks**.

### Key Features

- 📊 **CSV-driven DNS management** - Manage DNS records through simple CSV files
- 🏗️ **Infrastructure as Code** - Terraform modules for AWS Route53 automation
- 🛡️ **Enterprise Security** - Multiple layers of security scanning and vulnerability detection
- 🔍 **Code Quality Enforcement** - Comprehensive linting, formatting, and type checking
- 🚀 **CI/CD Pipeline** - Automated testing, security scanning, and deployment validation
- 📈 **Coverage Tracking** - 100% test coverage with detailed reporting

## 📁 Project Structure

```
dns-aws-python-tf-csv/
├── 📄 parse_dns_csvs.py          # Python CSV parser and JSON converter
├── 🏗️ main.tf                    # Terraform configuration for Route53
├── 📋 variables.tf               # Terraform variable definitions
├── 📤 outputs.tf                 # Terraform output definitions
├── 📊 records/                   # CSV files for DNS record management
│   ├── a_records.csv
│   ├── cname_records.csv
│   ├── mx_records.csv
│   └── ... (20+ DNS record types)
├── 🧪 test/                      # Python test suite
├── ⚙️ .github/workflows/         # CI/CD pipeline configuration
├── 🔧 pyproject.toml            # Python project configuration
└── 📝 README.md                 # This file
```

## 🐍 Python CSV Parser

The `parse_dns_csvs.py` script processes DNS record CSV files and converts them to JSON format for Terraform consumption.

### Features
- ✅ **Selective Processing** - Only processes records with `enabled=yes`
- 📝 **Comprehensive Logging** - Detailed execution logs with timestamps
- 🔧 **Flexible Format** - Supports 20+ DNS record types
- 🛡️ **Error Handling** - Robust error handling with graceful degradation
- 🧹 **Data Cleaning** - Removes administrative columns from output

### Supported DNS Record Types
- A, AAAA, CNAME, MX, NS, SRV, PTR, CAA
- SPF, DMARC, TXT, SOA, NAPTR, TLSA, SSHFP
- SVCB, HTTPS, URI, LOC, CERT

### Usage
```bash
# Run the parser
python parse_dns_csvs.py

# With Poetry
poetry run python parse_dns_csvs.py
```

## 🏗️ Terraform Infrastructure

The Terraform configuration automates DNS record creation in AWS Route53 based on the JSON output from the Python parser.

### Components
- **Provider Configuration** - AWS provider with configurable region
- **Data Sources** - External data source for Python script execution
- **Route53 Records** - Dynamic resource creation for all DNS record types
- **Variables** - Configurable parameters for flexibility

### Usage
```bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

## � Code Signing & Verification

This project uses GPG signing to ensure code authenticity and integrity. All commits and releases are signed with the project maintainer's GPG key.

### 📋 GPG Key Information
- **Key ID**: `36ADD0949C5C38BF`
- **Owner**: Richard Geiger <geiger_richard@hotmail.com>
- **Key File**: `GPG-KEY.txt` (included in repository)

### 🔧 GPG Key Import & Verification

```bash
# Import the GPG public key
gpg --import GPG-KEY.txt

# Verify the key fingerprint
gpg --fingerprint geiger_richard@hotmail.com

# Expected fingerprint: 8908 ED9E 90D3 2D59 E01A 4B4E 36AD D094 9C5C 38BF

# Verify a signed commit (example)
git verify-commit HEAD

# Verify a signed tag (example)
git verify-tag v1.0.0
```

### 🛡️ Security Benefits
- **Authenticity**: Confirms code originates from trusted maintainer
- **Integrity**: Ensures code hasn't been tampered with
- **Trust Chain**: Establishes cryptographic proof of authorship
- **Supply Chain Security**: Protects against malicious code injection

## �🛡️ Security & Quality Assurance

This project implements **enterprise-grade security and code quality standards** with 15+ automated checks:

### 🔐 Security Scanning Tools

| Tool | Purpose | Status |
|------|---------|--------|
| **Bandit** | Python security vulnerability scanner | ✅ Active |
| **Safety** | Python dependency vulnerability database | ✅ Active (Dedicated Workflow) |
| **pip-audit** | Python package security auditing | ✅ Active |
| **Snyk** | Comprehensive vulnerability scanning | ✅ Active |
| **Snyk IaC** | Infrastructure security analysis | ✅ Active |
| **SonarCloud** | Code quality & security analysis | ✅ Active |
| **Checkov** | Infrastructure policy-as-code scanner | ✅ Active |
| **TFSec** | Terraform static security analysis | ✅ Active |

### 🧹 Code Quality Tools

| Tool | Purpose | Configuration |
|------|---------|---------------|
| **Black** | Python code formatting | Line length: 79 characters |
| **Flake8** | Python linting & style guide | PEP 8 compliance |
| **isort** | Import statement sorting | Consistent import order |
| **MyPy** | Static type checking | Type safety validation |
| **Terraform fmt** | Terraform code formatting | HCL syntax consistency |
| **Terraform validate** | Configuration validation | Syntax & logic validation |
| **TFLint** | Terraform linting | Best practices enforcement |

### 📊 Testing & Coverage

| Tool | Purpose | Target |
|------|---------|--------|
| **pytest** | Python unit testing framework | 100% test coverage |
| **coverage** | Code coverage measurement | Detailed reporting |
| **Codecov** | Coverage tracking & reporting | Trend analysis |

## 🚀 CI/CD Pipeline

The GitHub Actions workflow provides comprehensive automation with the following stages:

### 🏗️ Build & Setup
- Python 3.11 environment setup
- Poetry dependency management
- Dependency caching for performance
- Terraform 1.5.0 installation

### 🧪 Testing Phase
- Unit test execution with pytest
- Code coverage analysis
- Coverage report generation
- Codecov integration

### 🛡️ Security Scanning Phase
- **Python Security**: Bandit, Safety, pip-audit
- **Dependency Scanning**: Snyk vulnerability analysis
- **Infrastructure Security**: Checkov, TFSec, Snyk IaC
- **Code Quality**: SonarCloud analysis

### 🔧 Code Quality Phase
- **Formatting**: Black code formatting validation (79 character line limit)
- **Linting**: Flake8 style guide enforcement  
- **Import Sorting**: isort consistency check
- **Type Checking**: MyPy static analysis
- **Infrastructure**: Terraform fmt/validate

### 📊 Reporting Phase
- SARIF report generation for GitHub Security
- JSON reports for artifact storage
- Coverage reports to Codecov
- SonarCloud integration

## 🔧 Development Setup

### Prerequisites
- Python 3.9.2+ 
- Poetry for dependency management
- Terraform 1.5.0+
- AWS CLI configured
- Node.js (for Snyk)

### Installation
```bash
# Clone the repository
git clone https://github.com/rjglabs/dns-aws-python-tf-csv.git
cd dns-aws-python-tf-csv

# Install Python dependencies
poetry install

# Install additional security tools
npm install -g snyk
```

### Local Development Commands
```bash
# Run all Python quality checks
poetry run black --check --line-length 79 parse_dns_csvs.py
poetry run flake8 parse_dns_csvs.py
poetry run isort --check-only parse_dns_csvs.py
poetry run mypy parse_dns_csvs.py
poetry run bandit -r parse_dns_csvs.py

# Run security scans
poetry run safety scan
poetry run pip-audit
snyk test
snyk iac test

# Run tests with coverage
poetry run coverage run -m pytest test/
poetry run coverage report --show-missing

# Terraform validation
terraform fmt -check
terraform validate
poetry run checkov -d . --framework terraform
tfsec .
```

## 📈 Quality Metrics

Current project health metrics:

- **Code Coverage**: 100% (Python codebase)
- **Security Vulnerabilities**: 0 known issues
- **Code Quality**: SonarCloud Grade A
- **Test Coverage**: 100% line coverage
- **Security Hotspots**: 0 active issues
- **Technical Debt**: < 5 minutes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Ensure all quality checks pass locally
4. Commit your changes (`git commit -m 'Add amazing feature'`)
5. Push to the branch (`git push origin feature/amazing-feature`)
6. Open a Pull Request

### Pull Request Requirements
- ✅ All CI checks must pass
- ✅ 100% test coverage maintained
- ✅ No new security vulnerabilities
- ✅ Code quality standards met
- ✅ Documentation updated
- ✅ Commits must be GPG signed

### 🔐 Setting up GPG Signing for Contributors

```bash
# Generate a new GPG key (if you don't have one)
gpg --full-generate-key

# List your GPG keys
gpg --list-secret-keys --keyid-format LONG

# Configure Git to use your GPG key
git config --global user.signingkey YOUR_KEY_ID
git config --global commit.gpgsign true
git config --global tag.gpgsign true

# Add your GPG key to GitHub
gpg --armor --export YOUR_KEY_ID
# Copy the output and add it to your GitHub account settings
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🏷️ Tags

`aws` `route53` `dns` `terraform` `python` `csv` `automation` `iac` `security` `ci-cd` `devops` `poetry` `pytest` `sonarcloud` `snyk` `bandit` `checkov` `tfsec` `gpg-signed` `verified`

---

**Built with ❤️ and comprehensive security scanning | GPG Signed & Verified ✅**
