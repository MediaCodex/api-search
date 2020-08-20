/*
 * ECS
 */
resource "aws_ecs_service" "http" {
  name                = "search-http"
  cluster             = data.terraform_remote_state.core.outputs.ecs_api_cluster
  task_definition     = aws_ecs_task_definition.http.arn
  scheduling_strategy = "DAEMON"

  service_registries {
    registry_arn   = aws_service_discovery_service.http.arn
    container_name = "search-http"
    container_port = 3000
  }
}

resource "aws_ecs_task_definition" "http" {
  family             = "search"
  task_role_arn      = aws_iam_role.ecs_http.arn
  execution_role_arn = "arn:aws:iam::949257948165:role/ecsTaskExecutionRole"

  container_definitions = jsonencode([{
    image     = "${aws_ecr_repository.http.repository_url}:latest"
    name      = "search-http"
    memory    = 128
    essential = true
    portMappings = [{
      containerPort = 3000
      protocol      = "tcp"
    }]
    environment = [
      { name = "NODE_ENV", value = local.environment == "prod" ? "production" : "development" },
      { name = "PATH_PREFIX", value = "/v1/search" },
      { name = "AWS_DEFAULT_REGION", value = data.aws_region.current.name },
      { name = "AWS_REGION", value = data.aws_region.current.name }
    ],
    logConfiguration = {
      logDriver = "awslogs",
      options = {
        "awslogs-group"         = "/ecs/search-http",
        "awslogs-region"        = data.aws_region.current.name,
        "awslogs-stream-prefix" = "ecs",
        "awslogs-create-group"  = "true"
      }
    }
  }])
}

resource "aws_service_discovery_service" "http" {
  name = "search-http"

  dns_config {
    namespace_id = data.terraform_remote_state.core.outputs.ecs_api_namespace

    dns_records {
      ttl  = 10
      type = "SRV"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
}

/*
 * Repository
 */
resource "aws_ecr_repository" "http" {
  name                 = "search-http"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = var.default_tags
}

resource "aws_ecr_repository_policy" "http" {
  repository = aws_ecr_repository.http.name
  policy     = data.aws_iam_policy_document.repository_http.json
}
data "aws_iam_policy_document" "repository_http" {
  statement {
    sid = "Deploy User"
    principals {
      type = "AWS"
      identifiers = [
        join(":", [
          "arn:aws:iam:",
          data.aws_caller_identity.current.account_id,
          "user/deployment/deploy-search"
        ])
      ]
    }
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages"
    ]
  }
}

/*
 * Container IAM
 */
resource "aws_iam_role" "ecs_http" {
  name               = "search-http"
  path               = "/search/"
  assume_role_policy = data.aws_iam_policy_document.assume_ecs_http.json
}
data "aws_iam_policy_document" "assume_ecs_http" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = [
      "sts:AssumeRole"
    ]
    # condition {
    #   test     = "ArnEquals"
    #   variable = "ecs:task-definition"
    #   values = [
    #     join(":", [
    #       "arn:aws:ecs",
    #       data.aws_region.current.name,
    #       data.aws_caller_identity.current.account_id,
    #       "task-definition/search:*"
    #     ])
    #   ]
    # }
  }
}

/*
 * Gateway mapping
 */
resource "aws_apigatewayv2_integration" "ecs_http" {
  api_id                 = data.terraform_remote_state.core.outputs.gateway_id
  payload_format_version = "1.0"

  integration_type   = "HTTP_PROXY"
  integration_method = "GET"
  integration_uri    = aws_service_discovery_service.http.arn

  connection_type = "VPC_LINK"
  connection_id   = data.terraform_remote_state.core.outputs.ecs_api_gateway_link
}

resource "aws_apigatewayv2_route" "ecs_http_index" {
  api_id    = data.terraform_remote_state.core.outputs.gateway_id
  route_key = "POST /search"
  target    = "integrations/${aws_apigatewayv2_integration.ecs_http.id}"
}