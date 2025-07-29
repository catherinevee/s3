#!/bin/bash

# S3 Module Validation Script
# This script validates the module structure and runs basic checks

set -e

echo "🔍 Validating S3 Module..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✅ $2${NC}"
    else
        echo -e "${RED}❌ $2${NC}"
        exit 1
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if required files exist
echo "Checking required files..."

[ -f "main.tf" ] && print_status 0 "main.tf exists" || print_status 1 "main.tf missing"
[ -f "variables.tf" ] && print_status 0 "variables.tf exists" || print_status 1 "variables.tf missing"
[ -f "outputs.tf" ] && print_status 0 "outputs.tf exists" || print_status 1 "outputs.tf missing"
[ -f "versions.tf" ] && print_status 0 "versions.tf exists" || print_status 1 "versions.tf missing"
[ -f "README.md" ] && print_status 0 "README.md exists" || print_status 1 "README.md missing"

# Check if examples directory exists
if [ -d "examples" ]; then
    print_status 0 "examples directory exists"
    for example in examples/*/; do
        if [ -d "$example" ]; then
            echo "  Checking example: $(basename "$example")"
            [ -f "${example}main.tf" ] && print_status 0 "    main.tf exists" || print_warning "    main.tf missing"
            [ -f "${example}outputs.tf" ] && print_status 0 "    outputs.tf exists" || print_warning "    outputs.tf missing"
        fi
    done
else
    print_warning "examples directory missing"
fi

# Check if test directory exists
if [ -d "test" ]; then
    print_status 0 "test directory exists"
    [ -f "test/s3_test.go" ] && print_status 0 "s3_test.go exists" || print_warning "s3_test.go missing"
    [ -f "test/go.mod" ] && print_status 0 "go.mod exists" || print_warning "go.mod missing"
else
    print_warning "test directory missing"
fi

# Validate Terraform configuration
echo ""
echo "Validating Terraform configuration..."

if command -v terraform >/dev/null 2>&1; then
    terraform init -backend=false >/dev/null 2>&1
    if terraform validate >/dev/null 2>&1; then
        print_status 0 "Terraform configuration is valid"
    else
        print_status 1 "Terraform configuration is invalid"
    fi
else
    print_warning "Terraform not found, skipping validation"
fi

# Format check
echo ""
echo "Checking Terraform formatting..."

if command -v terraform >/dev/null 2>&1; then
    if terraform fmt -check -recursive >/dev/null 2>&1; then
        print_status 0 "Terraform code is properly formatted"
    else
        print_warning "Terraform code needs formatting (run: terraform fmt -recursive)"
    fi
else
    print_warning "Terraform not found, skipping format check"
fi

# Lint check
echo ""
echo "Checking Terraform linting..."

if command -v tflint >/dev/null 2>&1; then
    if tflint >/dev/null 2>&1; then
        print_status 0 "Terraform code passes linting"
    else
        print_warning "Terraform code has linting issues"
    fi
else
    print_warning "tflint not found, skipping lint check"
fi

# Security scan
echo ""
echo "Running security scan..."

if command -v tfsec >/dev/null 2>&1; then
    if tfsec --no-color >/dev/null 2>&1; then
        print_status 0 "No security issues found"
    else
        print_warning "Security issues found (run: tfsec for details)"
    fi
else
    print_warning "tfsec not found, skipping security scan"
fi

# Check documentation
echo ""
echo "Checking documentation..."

if [ -f "README.md" ]; then
    # Check if README has required sections
    if grep -q "## Usage" README.md; then
        print_status 0 "README has Usage section"
    else
        print_warning "README missing Usage section"
    fi
    
    if grep -q "## Inputs" README.md; then
        print_status 0 "README has Inputs section"
    else
        print_warning "README missing Inputs section"
    fi
    
    if grep -q "## Outputs" README.md; then
        print_status 0 "README has Outputs section"
    else
        print_warning "README missing Outputs section"
    fi
fi

echo ""
echo "🎉 Module validation complete!"
echo ""
echo "Next steps:"
echo "1. Review any warnings above"
echo "2. Test the module with: make examples"
echo "3. Run tests with: make test"
echo "4. Deploy to your environment" 