data "aws_ecr_repository" "lambda_repository" {
    name = var.repository_name
}

data "aws_ecr_image" "service_image" {
    repository_name = data.aws_ecr_repository.lambda_repository.name
    most_recent     = true  # 최신 이미지를 가져오도록 설정
}

resource "aws_lambda_function" "lambda_function" {
    function_name = "lambda_function"
    timeout = 5
    image_uri = "${var.ecr_repository_url}@${data.aws_ecr_image.service_image.image_digest}"
    package_type = "Image"
    architectures = ["x86_64"]

    role = aws_iam_role.lambda.arn
}

resource "aws_iam_role" "lambda" {
    name = "lambda"

    assume_role_policy = jsonencode({
        Statement = [
            {
                Action = "sts:AssumeRole"
                Effect = "Allow"
                Principal = {
                    Service = "lambda.amazonaws.com"
                }
            },
        ]
    })
}

resource "aws_iam_policy_attachment" "lambda_ecr_access" {
    name       = "lambda_ecr_access"
    roles      = [aws_iam_role.lambda.name]
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}