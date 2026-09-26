resource "aws_cognito_user_pool" "portal" {
  name                = "User pool - jksal"
  deletion_protection = "ACTIVE"

  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  mfa_configuration = "OPTIONAL"
  user_pool_tier    = "ESSENTIALS"

  password_policy {
    minimum_length                   = 8
    require_uppercase                = true
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7
  }

  software_token_mfa_configuration {
    enabled = true
  }

  admin_create_user_config {
    allow_admin_create_user_only = true
  }

  username_configuration {
    case_sensitive = false
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }

    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  schema {
    name                     = "email"
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    required                 = true

    string_attribute_constraints {
      min_length = 0
      max_length = 2048
    }
  }

  lifecycle {
    ignore_changes = [
      web_authn_configuration
    ]
  }
}

resource "aws_cognito_user_pool_client" "portal" {
  name         = "SecuraNova Portal v2"
  user_pool_id = aws_cognito_user_pool.portal.id

  generate_secret = true

  callback_urls = [
    "https://portal.securanova.net/oauth2/idpresponse"
  ]

  allowed_oauth_flows = ["code"]

  allowed_oauth_scopes = [
    "email",
    "openid",
    "profile"
  ]

  allowed_oauth_flows_user_pool_client = true
  supported_identity_providers         = ["COGNITO"]

  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_AUTH",
    "ALLOW_USER_SRP_AUTH"
  ]

  prevent_user_existence_errors = "ENABLED"

  lifecycle {
    ignore_changes = [
      generate_secret
    ]
  }

  token_validity_units {
    access_token  = "minutes"
    id_token      = "minutes"
    refresh_token = "days"
  }
}

resource "aws_cognito_user_pool_domain" "portal" {
  domain       = "eu-central-1szfecw8ep"
  user_pool_id = aws_cognito_user_pool.portal.id

  managed_login_version = 2
}
