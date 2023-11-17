output "ecr_registry_id" {
    description = "ECR registry id"
    value = aws_ecr_repository.lambda_repository.registry_id
}

output "ecr_repository_url" {
    description = "ECR repository URL"
    value = aws_ecr_repository.lambda_repository.repository_url
}