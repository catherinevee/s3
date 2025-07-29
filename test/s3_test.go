package test

import (
	"testing"
	"time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/aws"
	"github.com/stretchr/testify/assert"
)

func TestS3BucketBasic(t *testing.T) {
	// Configure Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/basic",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"bucket_name": "test-bucket-" + time.Now().Format("20060102150405"),
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	// Clean up resources with "terraform destroy" at the end of the test
	defer terraform.Destroy(t, terraformOptions)

	// Run "terraform init" and "terraform apply"
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the values of output variables
	bucketName := terraform.Output(t, terraformOptions, "bucket_name")
	bucketArn := terraform.Output(t, terraformOptions, "bucket_arn")

	// Verify that the bucket exists
	aws.AssertS3BucketExists(t, "us-east-1", bucketName)

	// Verify bucket properties
	bucket := aws.GetS3BucketVersioning(t, "us-east-1", bucketName)
	assert.Equal(t, "Enabled", bucket.Status)

	// Verify bucket encryption
	encryption := aws.GetS3BucketEncryption(t, "us-east-1", bucketName)
	assert.NotNil(t, encryption)

	// Verify bucket public access block
	publicAccessBlock := aws.GetS3BucketPublicAccessBlock(t, "us-east-1", bucketName)
	assert.True(t, publicAccessBlock.BlockPublicAcls)
	assert.True(t, publicAccessBlock.BlockPublicPolicy)
	assert.True(t, publicAccessBlock.IgnorePublicAcls)
	assert.True(t, publicAccessBlock.RestrictPublicBuckets)

	// Verify outputs
	assert.NotEmpty(t, bucketName)
	assert.NotEmpty(t, bucketArn)
	assert.Contains(t, bucketArn, bucketName)
}

func TestS3BucketWebsite(t *testing.T) {
	// Configure Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/website",
		Vars: map[string]interface{}{
			"bucket_name": "test-website-" + time.Now().Format("20060102150405"),
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	// Clean up resources
	defer terraform.Destroy(t, terraformOptions)

	// Run Terraform
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	websiteEndpoint := terraform.Output(t, terraformOptions, "website_endpoint")
	bucketName := terraform.Output(t, terraformOptions, "bucket_name")

	// Verify website configuration
	websiteConfig := aws.GetS3BucketWebsite(t, "us-east-1", bucketName)
	assert.NotNil(t, websiteConfig)
	assert.Equal(t, "index.html", websiteConfig.IndexDocument)
	assert.Equal(t, "error.html", websiteConfig.ErrorDocument)

	// Verify website endpoint
	assert.NotEmpty(t, websiteEndpoint)
	assert.Contains(t, websiteEndpoint, bucketName)
}

func TestS3BucketDataLake(t *testing.T) {
	// Configure Terraform options
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../examples/data-lake",
		Vars: map[string]interface{}{
			"bucket_name": "test-datalake-" + time.Now().Format("20060102150405"),
		},
		EnvVars: map[string]string{
			"AWS_DEFAULT_REGION": "us-east-1",
		},
	})

	// Clean up resources
	defer terraform.Destroy(t, terraformOptions)

	// Run Terraform
	terraform.InitAndApply(t, terraformOptions)

	// Get outputs
	bucketName := terraform.Output(t, terraformOptions, "data_lake_bucket_name")
	encryptionAlgorithm := terraform.Output(t, terraformOptions, "data_lake_encryption_algorithm")

	// Verify bucket exists
	aws.AssertS3BucketExists(t, "us-east-1", bucketName)

	// Verify encryption
	assert.Equal(t, "aws:kms", encryptionAlgorithm)

	// Verify lifecycle configuration
	lifecycleRules := aws.GetS3BucketLifecycle(t, "us-east-1", bucketName)
	assert.NotEmpty(t, lifecycleRules)

	// Verify object lock configuration
	objectLockConfig := aws.GetS3BucketObjectLockConfiguration(t, "us-east-1", bucketName)
	assert.NotNil(t, objectLockConfig)
} 