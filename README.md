# 🚀 Azure Static Web Apps Deploy (Small)

A lightweight GitHub Action to deploy your Azure Static Web App using the SWA CLI, without downloading a 1.5 GB Docker image every time!  
No official Azure Static Web Apps Action required.

## ✨ Features

- ⚡ Fast, minimal, and easy to use
- 🔑 Supports both federated credentials (recommended) and API tokens (why?)
- 📦 Installs and uses the [SWA CLI](https://github.com/Azure/static-web-apps-cli)
- 🛡️ Secure token handling

## 🛠️ Usage federated credentials

```yaml
- name: Deploy to Azure Static Web Apps
  uses: svrooij/azure-static-web-app-deploy-action@v1
  with:
    tenant_id: ${{ secrets.AZURE_TENANT_ID }}                # Required for federated credentials
    client_id: ${{ secrets.AZURE_CLIENT_ID }}                #Required for federated credentials
    static_web_app_name: <your-swa-name>                     # Required for federated credentials
    app_location: '.'                                        # Optional, default '.'
    api_location: 'api'                                      # Optional, default 'api'
    output_location: '.'                                     # Optional, default '.'
    swa_environment: 'production'                            # Optional, default 'production'
```

## 🛠️ Usage token

```yaml
- name: Deploy to Azure Static Web Apps
  uses: svrooij/azure-static-web-app-deploy-action@v1
  with:
    azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }} # Required if not using federated credentials
    app_location: '.'                                        # Optional, default '.'
    api_location: 'api'                                      # Optional, default 'api'
    output_location: '.'                                     # Optional, default '.'
    swa_environment: 'production'                            # Optional, default 'production'
```

## 🔑 Authentication

You can authenticate using either:

- **Federated credentials** (recommended): Provide `tenant_id`, `client_id`, and `static_web_app_name`.
- **API token**: Provide `azure_static_web_apps_api_token`.

## 📥 Inputs

| Name                           | Description                                                      | Required | Default      |
|---------------------------------|------------------------------------------------------------------|----------|--------------|
| `tenant_id`                    | The Azure tenant ID                                              | No       | `''`         |
| `client_id`                    | The Azure client ID                                              | No       | `''`         |
| `static_web_app_name`          | The name of the Azure Static Web App                             | No       | `''`         |
| `azure_static_web_apps_api_token` | The API token for Azure Static Web Apps                        | No       | `''`         |
| `app_location`                 | The location of the app to deploy (relative path)                | No       | `'.'`        |
| `api_location`                 | The location of the API to deploy (relative path)                | No       | `'api'`      |
| `output_location`              | The location where the app is built (relative path)              | No       | `'.'`        |
| `swa_environment`              | The environment to deploy to                                     | No       | `'production'`|

---

## 📝 Example Workflow

```yaml
name: Deploy SWA

on:
  push:
    branches:
      - main

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to Azure Static Web Apps
        uses: <your-username>/azure-static-web-app-deploy-action@v1
        with:
          tenant_id: ${{ secrets.AZURE_TENANT_ID }}
          client_id: ${{ secrets.AZURE_CLIENT_ID }}
          static_web_app_name: <your-swa-name>
          app_location: '.'
          api_location: 'api'
          output_location: '.'
          swa_environment: 'production'
```

---

## 📚 License

[MIT](LICENSE)

---

## 💬 Feedback

Feel free to open issues or pull requests to improve this action!
