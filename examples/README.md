# S3 Module Examples

Practical examples of using the S3 module for different use cases.

## Examples Overview

### 1. [Basic](./basic/)
Simple S3 bucket with default security settings.

**Features:**
- Default encryption (AES256)
- Versioning enabled
- Public access blocked
- Basic tagging

**Use Case:** General purpose storage with security best practices.

### 2. [Website](./website/)
S3 bucket configured for static website hosting with public read access.

**Features:**
- Website configuration (index.html, error.html)
- CORS configuration for web applications
- Public read access for website hosting
- Lifecycle policies for cost optimization
- Sample HTML files included

**Use Case:** Static website hosting, single-page applications, documentation sites.

### 3. [Data Lake](./data-lake/)
Enterprise-grade S3 bucket for data lake storage with comprehensive lifecycle management.

**Features:**
- KMS encryption
- Comprehensive lifecycle policies
- Intelligent tiering for cost optimization
- Object lock for compliance
- Event notifications for data processing
- CORS configuration for data access
- Structured folder organization

**Use Case:** Data lakes, analytics platforms, compliance storage, enterprise data management.

## Running Examples

Each example can be run independently:

```bash
# Navigate to an example
cd examples/basic

# Initialize Terraform
terraform init

# Plan the deployment
terraform plan

# Apply the configuration
terraform apply

# Clean up when done
terraform destroy
```

## Example-Specific Notes

### Basic Example
- Uses random string for unique bucket names
- Minimal configuration for quick testing
- Good starting point for learning the module

### Website Example
- Overrides public access settings for website hosting
- Includes sample HTML files
- Demonstrates bucket policy configuration

### Data Lake Example
- Requires KMS key for encryption
- Complex lifecycle policies for cost management
- Shows advanced features like object lock and intelligent tiering

## Customization

Each example can be customized by modifying the variables in `main.tf`. Common customizations include:

- Changing bucket names
- Adjusting lifecycle policies
- Modifying encryption settings
- Adding custom tags
- Configuring different regions

## Testing

All examples include validation and can be tested using the module's test suite:

```bash
# Run all tests
make test

# Run specific example tests
cd test && go test -v -run TestS3BucketBasic
```

## Security Considerations

- The basic example follows security best practices by default
- The website example requires public access for hosting
- The data lake example uses enhanced security features
- Always review and adjust security settings for your specific use case

## Cost Optimization

- Basic example: Minimal cost with standard storage
- Website example: Lifecycle policies for cost optimization
- Data lake example: Comprehensive cost management with intelligent tiering

## Next Steps

After running these examples:

1. Review the created resources in the AWS Console
2. Test the functionality (upload files, access website, etc.)
3. Modify configurations to match your requirements
4. Integrate into your larger infrastructure
5. Set up monitoring and alerting 