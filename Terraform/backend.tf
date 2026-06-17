# Remote state stores tfstate in S3 with DynamoDB locking.
# Bootstrap: create the bucket and table once manually (or via a separate bootstrap module)
# before running terraform init on this project.
#
#   aws s3api create-bucket --bucket terraform-state-arturo-project --region us-east-1
#   aws dynamodb create-table \
#     --table-name terraform-locks \
#     --attribute-definitions AttributeName=LockID,AttributeType=S \
#     --key-schema AttributeName=LockID,KeyType=HASH \
#     --billing-mode PAY_PER_REQUEST

terraform {
  backend "s3" {
    bucket         = "terraform-state-arturo-project"
    key            = "arturo-project/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
