# Architecture and design decisions

This project consists of three main components:

- Azure environment (`infra`): The infrastructure code for the central framework that will ingest and host the modernisation reports
- Shipper API (`shipper`): An Azure Function that CI/CD processes can submit modernisation json files to
- Tech Debt Analytics Dashboard (`report`): A Power BI report that provides insights and analytics over submitted modernisation reports

## The Azure environment

The `infra/` directory contains the infrastructure code for deploying the project. It includes configuration files, scripts, and templates for provisioning the necessary resources on the cloud platform.

Key resources created are:

- A storage account to store the modernisation reports
- An Azure Function App to host the shipper API

![The resources created](bicep-visualiser.png)

The deployment and the resources being deployed leverage [Azure User Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview) to ensure that the resources are deployed securely. You can use the Github workflow with a provisioned OIDC connection to deploy to Azure or you can use the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) to deploy the bicep. To provision OIDC connections for GitHub Actions, you can follow the instructions provided in the [GitHub Actions documentation](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows).

## The shipper API

The `shipper/` directory contains an Azure Function that different CI/CD processes can submit their modernisation results to. Currently this will yield an API that will accept a PUT request with the modernisation results in the body and CI/CD metadata in the url parameters. The Azure Function will then store the results in an Azure Storage Account for the report to show the results of.

More info on changing this Function at [Developing functions locally](docs/developing_functions_locally.md)

## The Tech Debt Analytics Dashboard

The `report/` directory contains a [Power BI report project](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview). The goal of this is to provide a starter report that allows you to understand modernisation needs and velocity. You are able to modify this report to meet your individual organisation's needs.
