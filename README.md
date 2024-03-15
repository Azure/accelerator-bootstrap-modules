# Accelerator Bootstrap Modules

This repository contains the Terraform modules that are used to deploy the bootstrap environments.

## Bootstrap Configuraiton Schema

The bootstrap configuration json file is used to define the locations and associated starter module for the bootstrap.

Schema:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://accelerator.ms/bootstrap.schema.json",
  "title": "Bootstrap Configuration",
  "description": "Configuration definition for the Azure Landing Zones Accelerator Bootstrap. This file is used to define the locations and associated starter module for the bootstrap.",
  "type": "object",
  "properties": {
    "bootstrap_modules": {"$ref": "#/definitions/mapBootstrap"},
    "starter_modules": {"$ref": "#/definitions/mapStarter"},
    "validators": {"$ref": "#/definitions/mapValidator"}
  },
  "required": [
    "bootstrap_modules",
    "starter_modules",
    "validators"
  ],
  "definitions": {
    "mapBootstrap": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "location": {
            "type": "string"
          },
          "description": {
            "type": "string"
          },
          "input_variable_files": {
            "type": "array",
            "items": [
              {
                "type": "string"
              }
            ],
          },
          "interface_variable_files": {
            "type": "array",
            "items": [
              {
                "type": "string"
              }
            ],
          },
          "interface_config_file": {
            "type": "string"
          },
          "aliases": {
            "type": "array",
            "items": [
              {
                "type": "string"
              }
            ],
          },
          "starter_modules": {
            "type": "string"
          }
        },
        "required": [
          "location",
          "description",
          "input_variable_files",
          "interface_variable_files",
          "interface_config_file",
          "aliases",
          "starter_modules"
        ]
      }
    },
    "mapStarter": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "bicep": {
            "type": "object",
            "additionalProperties": {
              "type": "object",
              "properties": {
                "url": {
                  "type": "string"
                },
                "module_path": {
                  "type": "string"
                },
                "pipeline_folder": {
                  "type": "string"
                }
              },
              "required": [
                "url",
                "module_path",
                "pipeline_folder"
              ]
            }
          },
          "terraform": {
            "type": "object",
            "additionalProperties": {
              "type": "object",
              "properties": {
                "url": {
                  "type": "string"
                },
                "module_path": {
                  "type": "string"
                },
                "pipeline_folder": {
                  "type": "string"
                }
              },
              "required": [
                "url",
                "module_path",
                "pipeline_folder"
              ]
            }
          }
        }
      }
    },
    "mapValidator": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "Type": {
            "type": "string"
          },
          "Description": {
            "type": "string"
          },
          "Valid": {
            "type": "string",
          },
          "AllowedValues": {
            "type": "object",
            "properties": {
              "Display": {
                "type": "boolean"
              },
              "Values": {
                "type": "array",
                "items": [
                  {
                    "type": "string"
                  }
                ]
              }
            }
          }
        },
        "required": [
          "Type",
          "Description"
        ]
      }
    }
  }
}
```

Example code:

```json
{
    "bootstrap_modules": {
        "alz_azuredevops": {
            "location": "alz/azuredevops",
            "description": "Azure Landing Zones with Azure DevOps",
            "input_variable_files": [ "variables.input.tf" ],
            "interface_variable_files": [ "variables.interface.tf" ],
            "interface_config_file": "alz/.config/ALZ-Powershell.config.json",
            "aliases": [ "azuredevops" ],
            "starter_modules": "alz"
        },
        "alz_github": {
            "location": "alz/github",
            "description": "Azure Landing Zones with GitHub",
            "input_variable_files": [ "variables.input.tf" ],
            "interface_variable_files": [ "variables.interface.tf" ],
            "interface_config_file": "alz/.config/ALZ-Powershell.config.json",
            "aliases": [ "github" ],
            "starter_modules": "alz"
        },
        "alz_local": {
            "location": "alz/local",
            "description": "Azure Landing Zones local file system",
            "input_variable_files": [ "variables.input.tf" ],
            "interface_variable_files": [ "variables.interface.tf" ],
            "interface_config_file": "alz/.config/ALZ-Powershell.config.json",
            "aliases": [ "local" ],
            "starter_modules": "alz"
        }
    },
    "starter_modules": {
        "alz": {
            "terraform": {
                "url": "https://github.com/Azure/alz-terraform-accelerator",
                "module_path": "templates",
                "pipeline_folder": "ci_cd"
            },
            "bicep": {
                "url": "https://github.com/Azure/ALZ-Bicep",
                "module_path": ".",
                "pipeline_folder": "."
            }
        }
    },
    "validators": {
        "auth_scheme": {
            "Type": "AllowedValues",
            "Description": "A valid authentication scheme e.g. 'WorkloadIdentityFederation'",
            "AllowedValues": {
                "Display": true,
                "Values": [
                    "WorkloadIdentityFederation",
                    "ManagedServiceIdentity"
                ]
            }
        },
        "azure_location": {
            "Type": "AllowedValues",
            "Description": "An Azure deployment location e.g. 'uksouth'",
            "AllowedValues": {
                "Display": false,
                "Values": [
                    "australiacentral",
                    "australiacentral2",
                    "australiaeast",
                    "australiasoutheast",
                    "brazilsouth",
                    "brazilsoutheast",
                    "centraluseuap",
                    "canadacentral",
                    "canadaeast",
                    "centralus",
                    "eastasia",
                    "eastus2euap",
                    "eastus",
                    "eastus2",
                    "francecentral",
                    "francesouth",
                    "germanycentral",
                    "germanynorth",
                    "germanynortheast",
                    "germanywestcentral",
                    "israelcentral",
                    "italynorth",
                    "centralindia",
                    "southindia",
                    "westindia",
                    "japaneast",
                    "japanwest",
                    "jioindiacentral",
                    "jioindiawest",
                    "koreacentral",
                    "koreasouth",
                    "northcentralus",
                    "northeurope",
                    "norwayeast",
                    "norwaywest",
                    "polandcentral",
                    "qatarcentral",
                    "southafricanorth",
                    "southafricawest",
                    "southcentralus",
                    "swedencentral",
                    "swedensouth",
                    "southeastasia",
                    "switzerlandnorth",
                    "switzerlandwest",
                    "uaecentral",
                    "uaenorth",
                    "uksouth",
                    "ukwest",
                    "westcentralus",
                    "westeurope",
                    "westus",
                    "westus2",
                    "westus3",
                    "usdodcentral",
                    "usdodeast",
                    "usgovarizona",
                    "usgoviowa",
                    "usgovtexas",
                    "usgovvirginia",
                    "usnateast",
                    "usnatwest",
                    "usseceast",
                    "ussecwest",
                    "chinanorth",
                    "chinanorth2",
                    "chinanorth3",
                    "chinaeast",
                    "chinaeast2",
                    "chinaeast3"
                ]
            }
        },
        "azure_subscription_id": {
            "Type": "Valid",
            "Description": "A valid subscription id GUID e.g. '12345678-1234-1234-1234-123456789012'",
            "Valid": "^( {){0,1}[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(}){0,1}$"
        },
        "azure_name": {
            "Type": "Valid",
            "Description": "A valid Azure name e.g. 'my-azure-name'",
            "Valid": "^[a-zA-Z0-9]{2,10}(-[a-zA-Z0-9]{2,10}){0,1}(-[a-zA-Z0-9]{2,10})?$"
        },
        "azure_name_section": {
            "Type": "Valid",
            "Description": "A valid Azure name with no hyphens and limited length e.g. 'abcd'",
            "Valid": "^[a-zA-Z0-9]{2,10}$"
        },
        "guid": {
            "Type": "Valid",
            "Description": "A valid GUID e.g. '12345678-1234-1234-1234-123456789012'",
            "Valid": "^( {){0,1}[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}(}){0,1}$"
        },
        "bool": {
            "Type": "AllowedValues",
            "Description": "A boolean value e.g. 'true'",
            "AllowedValues": {
                "Display": true,
                "Values": [
                    "true",
                    "false"
                ]
            }
        },
        "number": {
            "Type": "Valid",
            "Description": "A number e.g. '1234'",
            "Valid": "^(0|[1-9][0-9]*)$"
        },
        "cidr_range": {
            "Type": "Valid",
            "Description": "A valid CIDR range e.g '10.0.0.0/16'",
            "Valid": "^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(/(3[0-2]|[1-2][0-9]|[0-9]))$"
        },
        "configuration_file_path": {
            "Type": "Valid",
            "Description": "A valid yaml or json configuration file path e.g. './my-folder/my-config-file.yaml' or `c:\\my-folder\\my-config-file.yaml`",
            "Valid": "^.+\\.(yaml|yml|json)$"
        }
    }
}
```

## Input Configuration Schema

The bootstrap input json file is used to define the inputs that are required for the bootstrap and / or starter module.

Schema:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://accelerator.ms/input.schema.json",
  "title": "Accelerator Inputs",
  "description": "Input definition for the Azure Landing Zones Accelerator. This file is used to define the inputs that are required for the bootstrap and / or starter module.",
  "type": "object",
  "properties": {
    "inputs": {"$ref": "#/definitions/mapInput"}
  },
  "definitions": {
    "mapInput": {
      "type": "object",
      "additionalProperties": {
        "type": "object",
        "properties": {
          "type": {"type": "string"},
          "source": {"type": "string"},
          "maps_to": {"type": "array", "items": {"type": "string"}},
          "default": {"type": "string"},
          "required": {"type": "boolean"},
          "validation": {"type": "string"},
          "display_order": {"type": "integer"},
          "description": {"type": "string"},
          "display_map_filter": {"type": "string"}
        },
        "required": ["type", "source", "maps_to"]
      }
    }
  }
}
```

Example code:

```json
    "inputs": {
        "iac_type": { # The name of the input which maps to a variable in the Terraform module
            "type": "string", # The data type of the input
            "source": "powershell", # The source of the input. Can be `powershell` or `input`. If PowerShell is chosen, then ALZ PowerShell module will need to explicity set this value based on its input logic
            "maps_to": [ "bootstrap" ] # The modules the input maps to. The values can be `bootstrap` and / or `starter`. If the input is missing from the relvant module, then it will be ignored.
        },
        "root_parent_management_group_id": {
            "type": "string",
            "default": "Tenant Root Group", # For source `input`, a default empty value can be specified.
            "required": false, # For source `input`. Required `false` can be used in combination with a default value to make the input optional.
            "source": "input",
            "maps_to": [ "bootstrap", "starter" ],
            "display_order": 2, # The order in which the input will be displayed in the UI
            "description": "The identifier of the Tenant Root Management Group, if left blank will use the tenant id (Tenant Root Group)." # The description shown in the UI. This will be concatenated with the description of the input validation.
        },
        "subscription_id_connectivity": {
            "type": "string",
            "required": true, # For source `input`, required `true` can be used to make the input mandatory. This meant a non-empty value must be provided.
            "source": "input",
            "maps_to": [ "bootstrap", "starter" ],
            "validation": "azure_subscription_id", # Validation uses the validation type specified in the root .config file.
            "display_order": 3,
            "description": "The identifier of the Connectivity Subscription."
        },
        "configuration_file_path" :{
            "type": "string",
            "source": "input",
            "default": "", # For source `input`, a default empty value can be specified.
            "required": false,
            "maps_to": [ "bootstrap", "starter" ],
            "display_map_filter" : "starter", # Used to filter out this input if it is not present in the specified module. For example, if the `configuration_file_path` is not present in the `starter` module, then it will not be displayed in the UI and no attempt will be made to map it to the `starter` module. The default value will be set for the `bootstrap` module if it is present there.
            "validation": "configuration_file_path",
            "display_order": 6,
            "description": "The identifier of the Connectivity Subscription."
        }
    }

```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [https://cla.opensource.microsoft.com](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
