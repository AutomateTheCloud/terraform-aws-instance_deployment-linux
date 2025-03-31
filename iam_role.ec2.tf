resource "aws_iam_role" "ec2" {
  name               = "${local.scope.abbr}-${local.purpose.abbr}-${local.environment.abbr}-${local.aws.region.abbr}-ec2"
  description        = "${local.scope.name} - ${local.purpose.name} [${local.environment.name}] (${local.aws.region.name}): EC2"
  assume_role_policy = data.aws_iam_policy_document.iam_role-ec2-assume_role_policy.json
  tags               = local.tags
  provider           = aws.this
}

data "aws_iam_policy_document" "iam_role-ec2-assume_role_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com"
      ]
    }
  }
  provider = aws.this
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2.id
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  provider   = aws.this
}

resource "aws_iam_role_policy" "ec2-init" {
  name     = "EC2_Base"
  role     = aws_iam_role.ec2.id
  policy   = data.aws_iam_policy_document.iam_role_policy-ec2-init.json
  provider = aws.this
}

data "aws_iam_policy_document" "iam_role_policy-ec2-init" {
  policy_id = "ec2-init"
  ##-------------------------------------------------------
  # SSM
  statement {
    effect = "Allow"
    actions = [
      "ssm:DescribeAssociation",
      "ssm:GetDeployablePatchSnapshotForInstance",
      "ssm:GetDocument",
      "ssm:DescribeDocument",
      "ssm:GetManifest",
      "ssm:GetParameters",
      "ssm:ListAssociations",
      "ssm:ListInstanceAssociations",
      "ssm:PutInventory",
      "ssm:PutComplianceItems",
      "ssm:PutConfigurePackageResult",
      "ssm:UpdateAssociationStatus",
      "ssm:UpdateInstanceAssociationStatus",
      "ssm:UpdateInstanceInformation"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetEncryptionConfiguration"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::aws-ssm-${local.aws.region.name}/*",
      "arn:aws:s3:::amazon-ssm-${local.aws.region.name}/*",
      "arn:aws:s3:::amazon-ssm-packages-${local.aws.region.name}/*",
      "arn:aws:s3:::${local.aws.region.name}-birdwatcher-prod/*",
      "arn:aws:s3:::patch-baseline-snapshot-${local.aws.region.name}/*"
    ]
  }

  ##-------------------------------------------------------
  # Autoscaling
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:SetInstanceHealth",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics"
    ]
    resources = ["*"]
  }

  ##-------------------------------------------------------
  # Logging
  statement {
    effect = "Allow"
    actions = [
      "ec2messages:AcknowledgeMessage",
      "ec2messages:DeleteMessage",
      "ec2messages:FailMessage",
      "ec2messages:GetEndpoint",
      "ec2messages:GetMessages",
      "ec2messages:SendReply",
      "cloudwatch:PutMetricData",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }

  ##-------------------------------------------------------
  # ECR
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage"
    ]
    resources = ["*"]
  }

  ##-------------------------------------------------------
  # Secrets
  statement {
    effect = "Allow"
    actions = [
      "ssm:GetParametersByPath",
      "ssm:GetParameter",
      "ssm:GetParameters"
    ]
    resources = [
      "arn:aws:ssm:${local.aws.region.name}:${local.aws.account.id}:parameter/secrets/${local.scope.abbr}/${local.purpose.abbr}/${local.environment.abbr}/*",
      "arn:aws:ssm:${local.aws.region.name}:${local.aws.account.id}:parameter/secrets/${local.scope.abbr}/${local.purpose.abbr}/global/*"
    ]
  }

  dynamic "statement" {
    for_each = try(data.aws_kms_key.data[0].arn, null) != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      resources = [
        data.aws_kms_key.data[0].arn
      ]
    }
  }

  ##-------------------------------------------------------
  # EFS
  dynamic "statement" {
    for_each = try(data.aws_kms_key.efs[0].arn, null) != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "kms:Decrypt"
      ]
      resources = [
        data.aws_kms_key.efs[0].arn
      ]
    }
  }

  ##-------------------------------------------------------
  # CodeDeploy
  dynamic "statement" {
    for_each = try(var.codedeploy.app, null) != null ? [1] : []
    content {
      effect = "Allow"
      actions = [
        "s3:ListBucket",
        "s3:GetObject"
      ]
      resources = [
        "arn:aws:s3:::aws-codedeploy-${local.aws.region.name}",
        "arn:aws:s3:::aws-codedeploy-${local.aws.region.name}/*",
        "arn:aws:s3:::${var.codedeploy.app.s3_bucket.id}",
        "arn:aws:s3:::${var.codedeploy.app.s3_bucket.id}/*"
      ]
    }
  }

  provider = aws.this
}
