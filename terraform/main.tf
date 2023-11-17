module "ecr" {
    source = "./modules/ecr"
    repository_name = var.repository_name
}

module "lambda" {
    source = "./modules/lambda"

    repository_name = var.repository_name
    ecr_repository_url = module.ecr.ecr_repository_url
}

module "api_gateway" {
    source = "./modules/api_gateway"
    
    # module.lambda에서 outputs.tf로 내보낸 변수들을 사용
    function_name = module.lambda.function_name
    invoke_arn = module.lambda.invoke_arn
}

data "tls_certificate" "github" {
    url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

# Create the OIDC Provider in the AWS Account
resource "aws_iam_openid_connect_provider" "github_actions" {
    url             = "https://token.actions.githubusercontent.com"
    client_id_list  = ["sts.amazonaws.com"]
    thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

# Create an IAM Role that can be assumed by Actions Runners running
# against repos in the list
resource "aws_iam_role" "gha_oidc_assume_role" {
    name = "gha_oidc_assume_role"

    # Terraform's "jsonencode" function converts a
    # Terraform expression result to valid JSON syntax.
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                "Effect" : "Allow",
                "Principal" : {
                    "Federated" : "${aws_iam_openid_connect_provider.github_actions.arn}"
                },
                "Action" : "sts:AssumeRoleWithWebIdentity",
                "Condition" : {
                    "StringEquals" : {
                        "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
                    },
                    "StringLike" : {
                        "token.actions.githubusercontent.com:sub" : ["repo:ojwsakin/ci-cd-pipeline:*"]
                    }
                }
            }
        ]
    })
}

# Attach a policy to the role allowing whatever you need for Terraform
# To do its thing
resource "aws_iam_role_policy" "gha_oidc_terraform_permissions" {
    name = "gha_oidc_terraform_permissions"
    role = aws_iam_role.gha_oidc_assume_role.id

    # Terraform's "jsonencode" function converts a
    # Terraform expression result to valid JSON syntax.
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = [
                    "sns:*", # EXAMPLE ONLY MAKE THESE MINIMUM PERMISSION SET
                    "lambda:*",
                    "iam:*",
                    "ecr:*"
                ]
                Effect   = "Allow"
                Resource = "*"
            },
        ]
    })
}

# Needed for adding to your Github Action
output "role_arn" {
    value = aws_iam_role.gha_oidc_assume_role.arn
}