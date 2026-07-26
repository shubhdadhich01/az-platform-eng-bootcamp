#########################################################
# Certificate Key Vault (lab cert store, RBAC)
#########################################################

# App Gateway identity can read the certificate secret
resource "azurerm_role_assignment" "appgw_secret_user" {
  depends_on = [ time_sleep.wait_for_rbac ]
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.appgw_indentity_id
}

resource "time_sleep" "wait_for_rbac" {
  create_duration = "90s"
}

#########################################################
# Self-Signed Certificate (lab TLS)
#########################################################

resource "azurerm_key_vault_certificate" "appgw_cert" {
  depends_on = [ azurerm_role_assignment.appgw_secret_user ]
  name         = var.cert_name
  key_vault_id = var.key_vault_id

  certificate_policy {
    issuer_parameters {
        name = "Self"
    }
    key_properties {
        exportable = true
        key_size = "2048"
        key_type = "RSA"
        reuse_key = true
    }
    lifetime_action {
        action {action_type = "AutoRenew"}
        trigger {days_before_expiry = 30}
   }
   secret_properties {content_type = "application/x-pkcs12"}
   x509_certificate_properties {
     key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyEncipherment",
        "keyAgreement",
        "keyCertSign",
     ]
     subject = "CN=northwind-storefront.local"
     validity_in_months = 12
     subject_alternative_names {
       dns_names = ["northwind-storefront.local"]
     }
   }
  }
}