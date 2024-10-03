output "public_ip" {
    description = "public_ip"
    value = aws_instance.monitoring.public_ip
}


output "rds_endpoint" {
    description = "rds_endpoint"
    value = aws_db_instance.default.endpoint


}

output "aws_s3_bucket" {
    description = "s3 bucket"
    value = aws_s3_bucket_acl.mybucket.bucket
}