plugin "azurerm" {
    enabled = true
    version = "0.27.0"
}

rule "terraform_module_pinned_source" {
  enabled = false
}

rule "terraform_unused_declarations" {
  enabled = true
}
