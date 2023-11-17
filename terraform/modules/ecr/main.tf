locals {
    create_private_repository = var.create && var.create_repository && var.repository_type == "private"
}

# ecr
resource "aws_ecr_repository" "lambda_repository" {

    name                 = var.repository_name
    image_tag_mutability = var.repository_image_tag_mutability

    image_scanning_configuration {
        scan_on_push = var.repository_image_scan_on_push
    }
}

resource "null_resource" "null_for_ecr_get_login_password" {
    provisioner "local-exec" {
        command = <<EOF
            aws ecr get-login-password --region ap-northeast-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.lambda_repository.repository_url}
        EOF
    }
}