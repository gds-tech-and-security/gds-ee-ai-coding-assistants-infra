data "tls_certificate" "github" {
  count = var.enable_github_actions ? 1 : 0

  url = var.github_actions_provider_config.url
}

resource "aws_iam_openid_connect_provider" "github" {
  count = var.enable_github_actions ? 1 : 0

  url = var.github_actions_provider_config.url

  client_id_list = var.github_actions_provider_config.client_id_list

  thumbprint_list = try(var.github_actions_provider_config.thumbprint_list,
    [
      for c in data.tls_certificate.github[0].certificates :
      c.sha1_fingerprint
    ]
  )
}
