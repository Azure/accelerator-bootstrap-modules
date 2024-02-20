# Azure Landing Zones Accelerator Bootstrap Modules

This repository contains the Terraform modules that are used to deploy the Azure Landing Zones (ALZ) bootstrap environment.

## Bootstrap Specific Configurstion Schema

```json
    "inputs": {
        "iac_type": {
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
            "display_map_filter" : "starter", # This setting is used to filter out this input if it is not present in the specified module. For example, if the `configuration_file_path` is not present in the `starter` module, then it will not be displayed in the UI and no attempt will be made to map it to the `starter` module. The default value will be set for the `bootstrap` module if it is present there.
            "validation": "configuration_file_path",
            "display_order": 6,
            "description": "The identifier of the Connectivity Subscription."
        }
    }

```

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

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
