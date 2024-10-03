provider "aws" {
    region = "us-west-2"
}

resource "aws_instance" "monitoring" {
    ami           =  "ami-04dd23e62ed049936"
    instance_type =  "t2.micro"

    tags = {
        Name = "monitoring-instance"
    }
}

resource "aws_db_instance" "default" {
    instance_class = "db.t3.micro"  # Choose a supported instance class
    engine = "postgres"
    engine_version = "16.3"  # Choose a supported engine version
    license_model = "postgresql-license"  # Or "bring-your-own-license" if applicable
    allocated_storage   = 20
    username            = "moro"
    password            = "moro123"
    publicly_accessible = true
    skip_final_snapshot = true

    tags = {
    Name = "mydb"
  }
}

resource "aws_s3_bucket_acl" "mybucket" {
    bucket = "mybucket"
    acl    = "public-read"
}

resource "aws_lambda_function" "my_lambda" {
    function_name      = "myLambdaFunction"
    role               = aws_iam_role.lambda_exec.arn
    handler            = "index.handler"
    runtime            = "nodejs12.x"
    filename           = "index.zip"
    source_code_hash   = filebase64sha256("index.zip")
}

resource "aws_iam_role" "lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutBucketAcl"
      ],
      "Resource": [
        "arn:aws:s3:::mybucket"  # Replace with your bucket ARN
      ]
    }
  ]
})
}


data "aws_cloudwatch_log_group" "existing_log_group" {
  name = "/aws/lambda/myLambdaFunction"
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  count             = length(data.aws_cloudwatch_log_group.existing_log_group) == 0 ? 1 : 0
  name              = "/aws/lambda/myLambdaFunction"
  retention_in_days = 14
}
