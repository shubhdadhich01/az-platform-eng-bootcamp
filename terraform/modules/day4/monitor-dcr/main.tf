resource "azurerm_monitor_data_collection_rule" "monitor-dcr" {
 
 description = "Collect Linux Syslog and Performance Metrics"

 name                = var.monitor_dcr_name
 location            = var.location
 resource_group_name = var.resource_group_name
 kind                = "Linux"
 destinations {
   log_analytics {
    name                  = "logAnalyticsDestination"
    workspace_resource_id = var.log_analytics_workspace_id
   }
 }

 data_flow {
   streams      = ["Microsoft-Perf", "Microsoft-Syslog"]
   destinations = ["logAnalyticsDestination"]
 }

 data_sources {
   performance_counter {
    name                          = "performanceCounters"
    streams                       = ["Microsoft-Perf"]
    sampling_frequency_in_seconds = 60

    counter_specifiers = [
      "\\Processor Information(_Total)\\% Processor Time",
      "\\Memory\\Available MBytes",
      "\\Logical Disk(/)\\% Used Space"
    ]
   }

   syslog {
    name = "syslogData"
    facility_names = [
        "auth",
        "authpriv",
        "cron",
        "daemon",
        "kern",
        "syslog"
      ]

      log_levels = [
        "Emergency",
        "Alert",
        "Critical",
        "Error",
        "Warning",
        "Notice",
        "Info"
      ]

      streams = ["Microsoft-Syslog"]
   }
 }
 # day6
 tags = var.tags
}

resource "azurerm_monitor_data_collection_rule_association" "monitor-association" {
  for_each = var.vm_ids

  name                    = "${each.key}-dcr-association"
  target_resource_id      = each.value
  data_collection_rule_id = azurerm_monitor_data_collection_rule.monitor-dcr.id
}