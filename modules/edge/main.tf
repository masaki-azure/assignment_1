resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = "fd-health-${var.environment}"
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = "fde-health-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  tags                     = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "this" {
  name                     = "og-health-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    path                = "/"
    protocol            = "Https"
    request_type        = "GET"
    interval_in_seconds = 30
  }
}

resource "azurerm_cdn_frontdoor_origin" "this" {
  name                          = "origin-health-${var.environment}"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id

  host_name                      = var.origin_host_name
  origin_host_header              = var.origin_host_name
  certificate_name_check_enabled = true
  https_port                      = 443
}

resource "azurerm_cdn_frontdoor_route" "this" {
  name                          = "route-health-${var.environment}"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.this.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.this.id]

  supported_protocols    = ["Http", "Https"]
  patterns_to_match       = ["/*"]
  forwarding_protocol     = "HttpsOnly"
  https_redirect_enabled  = true
  link_to_default_domain  = true
}

# TODO: Container AppsはFront Doorをバイパスして直接アクセス可能な状態
# Front Doorが付与する X-Azure-FDID ヘッダーをWAFのカスタムルールで検証し、
# 一致しないリクエストをブロックする対策が本来必要（未実装）。
resource "azurerm_cdn_frontdoor_firewall_policy" "this" {
  name                = "wafhealth${var.environment}"
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  mode                = "Prevention"

  dynamic "managed_rule" {
    for_each = var.sku_name == "Premium_AzureFrontDoor" ? [1] : []
    content {
      type    = "DefaultRuleSet"
      version = "1.0"
      action  = "Block"
    }
  }
}

resource "azurerm_cdn_frontdoor_security_policy" "this" {
  name                     = "sp-health-${var.environment}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = azurerm_cdn_frontdoor_firewall_policy.this.id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.this.id
        }
        patterns_to_match = ["/*"]
      }
    }
  }
}
