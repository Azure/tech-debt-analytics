# The application modernisation assessment tooling

## Modernisation for dotnet

> Azure Migrate application and code assessment for .NET allows you to assess .NET source code, configurations, and binaries of your application to identify migration opportunities to Azure. It helps you identify any issues your application might have when ported to Azure and improve the performance, scalability, and security by suggesting modern, cloud-native solutions.

The modernisation tooling for dotnet is available as an extension or a command line tool. The extension is available in the Visual Studio marketplace and the command line tool is available as a dotnet global tool.

[Docs](https://learn.microsoft.com/en-us/azure/migrate/appcat/dotnet)

### Installation

```bash
dotnet tool install -g dotnet-appcat
```

### Targets

Current targets for dotnet modernisation are:

- Azure App Service (Linux) `AppService.Linux`
- Azure App Service (Windows) `AppService.Windows`
- Azure App Service Container (Linux)
- Azure App Service Container (Windows)
- Azure Container Apps
- Azure Kubernetes Service (Linux)
- Azure Kubernetes Service (Windows)  

### Usage

The primary function of the CLI is the `analyze` command. This command will analyze the specified project and generate a report with the results. It can be used in interactive mode or arguments can be provided.

```bash
appcat analyze --help
# Saving of args here from running `appcat analyze --help`
# DESCRIPTION:
# Scan and analyze .NET applications source code to identify replatforming and migration opportunities for Azure.
# 
# USAGE:
#     appcat analyze [APPLICATION] [OPTIONS]
# 
# EXAMPLES:
#     appcat analyze
#     appcat analyze <APPLICATION_PATH>
#     appcat analyze <APPLICATION_PATH> --target AppService.Windows
#     appcat analyze <FOLDER_PATH> --source folder --target AppService.Windows
#     appcat analyze <IISSITE_NAME> --source IISServer --target AppService.Linux --config <CONFIG_PATH>
#     appcat analyze <APPLICATION_PATH> --report MyAppReport --serializer html --code --binaries
# 
# ARGUMENTS:
#     [APPLICATION]    Path to the application to be analyzed (could be repo folder, solution or project file path)
# 
# OPTIONS:
#     -h, --help                          Prints help information
#     -e, --extensions <EXTENSIONSDIR>    List of directories separated by ':' and containing exports.json file with
#                                         additional extensibility assemblies
#     -s, --source <SOURCE>               Source which the tool should analyze (Solution, Folder, IISServer)
#     -t, --target <TARGET>               Target toward which the tool should analyze the application
#     -c, --config <CONFIG>               Config file to customize analysis (select binaries, add or modify analysis
#                                         rules)
#     -r, --report <REPORT>               Path or name of the report to be generated after analysis is complete (could be
#                                         folder or file name depending on specified serializer)
#         --serializer <SERIALIZER>       Specifies the format for the report to be used after analysis is complete (HTML,
#                                         CSV, JSON, etc)
#         --non-interactive               When specified, it would only use arguments specified in command line and not
#                                         ask questions. If any required piece of data missing it would stop and print an
#                                         error message
#         --code                          Includes all your code, configs and settings in selected projects
#         --binaries                      Includes all external binary dependencies of selected projects
```

For use in automated processes it is recommended to set the `DOTNET_APPCAT_SKIP_FIRST_TIME_EXPERIENCE` environment variable to `TRUE` to avoid interactive prompts causing errors.

```yaml
env:
# This prevents first startup interactive expectations generating errors for the app cat CLI👇
  DOTNET_APPCAT_SKIP_FIRST_TIME_EXPERIENCE: true
```

You can then use the `appcat analyze` command with the required arguments to generate a report.

```bash
appcat analyze $appPath --source folder --report $destination --serializer json --non-interactive --code --binaries --target $target
```

## Modernisation for Java

> appcat is a command-line tool from Azure Migrate to assess Java application binaries and source code to identify replatforming and migration opportunities for Azure. It helps you modernize and replatform large-scale Java applications by identifying common use cases and code patterns and proposing recommended changes.

[Docs](https://learn.microsoft.com/en-us/azure/migrate/appcat/java)
[CLI reference](https://azure.github.io/appcat-docs/cli/)