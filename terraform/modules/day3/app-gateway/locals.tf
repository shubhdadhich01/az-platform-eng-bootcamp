locals {
  frontend_ip_config    = "appgw-frontend-ip"
  frontend_port_http    = "port-80"
  frontend_port_https   = "port-443"
  backend_pool          = "Web-backend-pool"
  backend_http_settings = "web-http-settings"
  http_listner          = "http-listner"
  https_listner         = "https-listner"
  probe-name            = "healthz-probe"
  ssl_cert_name         = "appgw-ssl-cert"
  redirect_config       = "http-to-https"
}
