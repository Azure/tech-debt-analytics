# Get real-time views of tech debt and modernisation efforts

Application modernisation isn't a one-time event. It's a continuous process that requires visibility and tracking. This project aims to provide you with functionality to allow you to understand the modernisation needs and velocity of your organisation.

This project consists of three main components:

- Azure environment (`infra`): The infrastructure as code for the central framework that will ingest and host the modernisation reports
- Shipper API (`shipper`): An Azure Function that CI/CD processes can submit modernisation json files to
- Tech Debt Analytics Dashboard (`report`): A Power BI report that provides insights and analytics over submitted modernisation reports

## Goal

Using our first party Azure Migration Application Assessment tooling, we want to allow you to build a continuous improvement and visibility approach to technical debt. By putting the assessment at the point of commit and posting the results to a central location you can get an instant view at the repository level or organisation level about modernisation needs. This will allow you to see trends and make decisions on where to focus your improvement efforts.

Use this solution to:

- Take a decentralised approach to modernisation adoption or tech debt tracking
- Gain a customisable program overview of any modernisation efforts
- Identify common issues across the estate and address comprehensively
- Build a network map of which repositories are active and who is working on them
- Give visibility into partner-led modernisation efforts

## Learn more

- [Getting started](docs/getting_started.md)
- [Making your own adjustments to the shipper API locally](docs/developing_functions_locally.md)
- [Architecture and design decisions (WIP)](docs/architecture.md)
- [Security and authentication](docs/security_and_authentication.md)
- [Application modernisation assessment tooling](docs/appcat.md)
- [The application modernisation assessment tooling](docs/appcat.md)

## Getting started

1. Create an app registration to use for the shipper API and a User Managed Identity for the infrastructure deployment
2. Deploy the infrastructure to host the modernisation reports
3. Add your CI/CD pipeline to submit modernisation results to the shipper API
4. Deploy and configure the Power BI report to see results from every repository with a modernisation CI/CD pipeline

Read more in [Getting started](docs/getting_started.md)

## Implement modernisation analytics within your CI/CD process

We can run the Azure Migration and Modernisation tooling on the command line to get an understanding of what's needed in a number of ways including JSON for use later and even a HTML dashboard.

```yaml
- name: Install appcat
      run: dotnet tool install -g dotnet-appcat --version 0.1.107
    - name: Run appcat JSON
      # This creates the payload for the datalake to give overall visibility of the modernisation effort
      run: appcat analyze ${{ env.DOTNET_APP_PATH }} --source folder --report ${{ env.REPORT_FOLDER }} --serializer json --non-interactive --code --binaries --target ${{ env.TARGET}}
    - name: Run appcat HTML
      # This creates a downloadable html report for this repo for the user to view
      run: appcat analyze ${{ env.DOTNET_APP_PATH }} --source folder --report ${{ env.REPORT_FOLDER }}/html --serializer html --non-interactive --code --binaries --target ${{ env.TARGET}}
```

This can be stored as an artifact for instant access by the developers of the repository.

```yaml
- name: Upload report
      uses: actions/upload-artifact@v2
      with:
        name: modernisation-report
        path: ${{ env.REPORT_FOLDER }}
```

Finally, we can send the JSON to the shipper API to be stored in the central data lake.

```yaml
- name: Send report
    run: |
    response=$(curl -X ${{ env.FUNCTION_APP_VERB }} -v \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer ${{ env.ACCESS_TOKEN }}" \
    --data @${{ env.REPORT_JSON_FILENAME }} \
    "${{ env.SHIPPER_URL }}")
```

## Good security practices embedded in the project

This repository aims to follow the latest good practices for the Azure and Fabric environments:

- Identity-based security between resources using [managed identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/overview)
- Identity-based security for CI/CD with a custom role that uses principal of least privilege
- Identity-based authentication for CI/CD pipelines that will send data via the shipper API
- Infrastructure as code for user managed identities

More info at [Security and authentication](docs/security_and_authentication.md)

## Legal Notices

### License

This project is licensed under the [MIT License](./LICENSE).

### Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft’s Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.

### Contributing

Please read the [Contributing](./CONTRIBUTING.md) guide to understand how to contribute to this project.
