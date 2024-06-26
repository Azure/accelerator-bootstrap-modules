# Azure Variables
agent_container_image = "microsoftavm/azure-devops-agent:1.1.0"

# Names
resource_names = {
  resource_group_state                                       = "rg-{{service_name}}-{{environment_name}}-state-{{azure_location}}-{{postfix_number}}"
  resource_group_identity                                    = "rg-{{service_name}}-{{environment_name}}-identity-{{azure_location}}-{{postfix_number}}"
  resource_group_agents                                      = "rg-{{service_name}}-{{environment_name}}-agents-{{azure_location}}-{{postfix_number}}"
  resource_group_network                                     = "rg-{{service_name}}-{{environment_name}}-network-{{azure_location}}-{{postfix_number}}"
  user_assigned_managed_identity_plan                        = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-plan-{{postfix_number}}"
  user_assigned_managed_identity_apply                       = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-apply-{{postfix_number}}"
  user_assigned_managed_identity_federated_credentials_plan  = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-plan"
  user_assigned_managed_identity_federated_credentials_apply = "id-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-apply"
  storage_account                                            = "sto{{service_name}}{{environment_name}}{{azure_location_short}}{{postfix_number}}{{random_string}}"
  storage_container                                          = "{{environment_name}}-tfstate"
  container_instance_01                                      = "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
  container_instance_02                                      = "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number_plus_1}}"
  container_instance_03                                      = "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number_plus_2}}"
  container_instance_04                                      = "aci-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number_plus_3}}"
  agent_01                                                   = "agent-{{service_name}}-{{environment_name}}-{{postfix_number}}"
  agent_02                                                   = "agent-{{service_name}}-{{environment_name}}-{{postfix_number_plus_1}}"
  agent_03                                                   = "agent-{{service_name}}-{{environment_name}}-{{postfix_number_plus_2}}"
  agent_04                                                   = "agent-{{service_name}}-{{environment_name}}-{{postfix_number_plus_3}}"
  version_control_system_repository                          = "{{service_name}}-{{environment_name}}"
  version_control_system_repository_templates                = "{{service_name}}-{{environment_name}}-templates"
  version_control_system_service_connection_plan             = "sc-{{service_name}}-{{environment_name}}-plan"
  version_control_system_service_connection_apply            = "sc-{{service_name}}-{{environment_name}}-apply"
  version_control_system_environment_plan                    = "{{service_name}}-{{environment_name}}-plan"
  version_control_system_environment_apply                   = "{{service_name}}-{{environment_name}}-apply"
  version_control_system_variable_group                      = "{{service_name}}-{{environment_name}}"
  version_control_system_agent_pool                          = "{{service_name}}-{{environment_name}}"
  version_control_system_group                               = "{{service_name}}-{{environment_name}}-approvers"
  version_control_system_pipeline_name_ci                    = "01 Azure Landing Zone Continuous Integration"
  version_control_system_pipeline_name_cd                    = "02 Azure Landing Zone Continuous Delivery"
  virtual_network                                            = "vnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
  public_ip                                                  = "pip-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
  nat_gateway                                                = "nat-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
  subnet_container_instances                                 = "subnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-aci"
  subnet_storage                                             = "subnet-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}-sto"
  private_endpoint                                           = "pe-{{service_name}}-{{environment_name}}-{{azure_location}}-{{postfix_number}}"
}
