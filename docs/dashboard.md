# The Tech Debt Analytics dashboard

This report is designed to provide insights and analytics over submitted modernisation reports. It is a Power BI report that can be deployed and configured to see results from every repository with a modernisation CI/CD pipeline. The report is designed to be used by developers, architects, and project managers to understand the modernisation effort across the organisation.

![Dashboard example](dashboard-example.png)

## Editing the report

The report is designed to be customisable to your organisation's needs. The report is built using Power BI Desktop and can be edited to include additional visualisations or to change the existing ones. The report is built using the data lake as a source, so as you iterate and extend what gets contributed to the data lake, you'll be able to incorporate into the report.

### Power BI projects

This project contains a Power BI project file that can be opened in Power BI Desktop. The project file contains the report and the data model that the report is built on. The data model is built to be extensible, so you can add additional fields to the data lake and then extend the report to include those fields.

### Data model

The data model is built to be extensible. The data model is built on the following tables:

- `dotnet modernisation` which consumes JSON files produced by the `appcat` tool

