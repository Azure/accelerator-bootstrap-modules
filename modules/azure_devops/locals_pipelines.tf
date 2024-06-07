locals {
  pipelines = { for key, value in var.pipelines : key => {
    pipeline_name = value.pipeline_name
    file          = azuredevops_git_repository_file.alz[value.pipeline_file_name].file
    environments = [for environment_key in value.environment_keys :
      {
        environment_key = environment_key
        environment_id  = azuredevops_environment.alz[environment_key].id
      }
    ]
    service_connections = [for service_connection_key in value.service_connection_keys :
      {
        service_connection_key = service_connection_key
        service_connection_id  = azuredevops_serviceendpoint_azurerm.alz[service_connection_key].id
      }
    ]
    }
  }

  pipeline_environments = flatten([for pipeline_key, pipeline in local.pipelines :
    [for environment in pipeline.environments : {
      pipeline_key    = pipeline_key
      environment_key = environment.environment_key
      pipeline_id     = azuredevops_build_definition.alz[pipeline_key].id
      environment_id  = environment.environment_id
      }
    ]
  ])

  pipeline_service_connections = flatten([for pipeline_key, pipeline in local.pipelines :
    [for service_connection in pipeline.service_connections : {
      pipeline_key           = pipeline_key
      service_connection_key = service_connection.service_connection_key
      pipeline_id            = azuredevops_build_definition.alz[pipeline_key].id
      service_connection_id  = service_connection.service_connection_id
      }
    ]
  ])

  pipeline_environments_map = { for pipeline_environment in local.pipeline_environments : "${pipeline_environment.pipeline_key}-${pipeline_environment.environment_key}" => {
    pipeline_id    = pipeline_environment.pipeline_id
    environment_id = pipeline_environment.environment_id
    }
  }

  pipeline_service_connections_map = { for pipeline_service_connection in local.pipeline_service_connections : "${pipeline_service_connection.pipeline_key}-${pipeline_service_connection.service_connection_key}" => {
    pipeline_id           = pipeline_service_connection.pipeline_id
    service_connection_id = pipeline_service_connection.service_connection_id
    }
  }
}
