# Tech debt analytics at scale

## Goal

Using our first party Azure Migration Application Assessment tooling, we want to allow you to build a continuous improvement and visibility approach to technical debt. By putting the assessment on the CI/CD and posting the results to a central location you can get an instant report at the repository level and then see results at the whole app estate level. This will allow you to see trends and make decisions on where to focus your improvement efforts.

Helps reduce the following challenges with static code analysis tools to support modernisation efforts:

- They mostly give a point in time snapshots
- They can be hard to scale across a large estate
- They can be hard to get visibility on the whole estate
- They can be hard to get trending data
- They only work if you can access the code

Use this solution to:

- Take a decentralised approach to modernisation adoption or tech debt tracking
- Gain a customisable program overview of any modernisation efforts
- Identify common issues across the estate and address comprehensively
- Build a network map of which repositories are active and who is working on them
- Give visibility into partner-led modernisation efforts

## Key moving parts

This project consists of three main components: `infra/`, `shipper/`, and `report/`. Each component serves a specific functionality and requires different deployment and running instructions.

- `infra/`: Contains the infrastructure code for the central framework that will ingest and host the modernisation reports
- `shipper/`: Contains an Azure Function that CI/CD processes can submit modernisation json files to
- `report/`: Contains a Power BI report that provides insights and analytics over submitted modernisation reports

### infra/

The `infra/` directory contains the infrastructure code for deploying the project. It includes configuration files, scripts, and templates for provisioning the necessary resources on the cloud platform. You can use the Github workflow with a provisioned OIDC connection to deploy to Azure or you can use the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) to deploy the bicep. To provision OIDC connections for GitHub Actions, you can follow the instructions provided in the [GitHub Actions documentation](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows).

![The resources created](infra/bicep-visualiser.png)

### shipper/

The `shipper/` directory contains an Azure Function that that different CI/CD processes can submit their modernisation results to.

#### Running the Azure Function locally

To run the Azure Function locally, follow these steps:

1. Install the [Azure Functions Core Tools](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local?tabs=windows%2Cisolated-process%2Cnode-v4%2Cpython-v2%2Chttp-trigger%2Ccontainer-apps&pivots=programming-language-csharp).
2. Navigate to the `shipper/` directory.
3. Configure the necessary environment variables (e.g., connection strings, API keys).
4. Run the Azure Functions host locally using the command `func start`.

### report/

The `report/` directory contains a [Power BI report project](https://learn.microsoft.com/en-us/power-bi/developer/projects/projects-overview). The goal of this is to provide a starter report that allows you to understand modernisation needs and velocity. You are able to modify this report to meet your individual organisation's needs.


## Legal Notices

### License

This project is licensed under the [MIT License](./LICENSE).

### Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft’s Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.