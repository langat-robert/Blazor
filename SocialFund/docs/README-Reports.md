# Reports Module Documentation

## Overview
The Reports module in this project is designed to dynamically generate and display reports based on user-specific data. It provides features such as filtering, exporting, and rendering reports in various formats like Excel, CSV, and PDF.

## Key Components

### 1. `Reports.razor`
This is the front-end component responsible for rendering the user interface for the Reports module. It includes the following features:
- **Dynamic Report Viewer**: Displays reports dynamically based on user selection.
- **Filters**: Allows users to apply filters based on report settings.
- **Export Options**: Provides options to export reports in Excel, CSV, and PDF formats.

### 2. `ReportService.cs`
This is the back-end service responsible for generating reports. It includes the following functionalities:
- **Dynamic Report Creation**: Generates reports dynamically using Stimulsoft's reporting engine.
- **Data Binding**: Binds data from the database to the report.
- **Customizable Layout**: Allows customization of report layout, including headers, footers, and data bands.

## How It Works

### Front-End Workflow
1. The user navigates to the Reports page (`Reports.razor`).
2. The page fetches the list of available reports for the logged-in user.
3. The user selects a report and applies filters.
4. The report is displayed dynamically in the viewer.
5. The user can export the report in the desired format.

### Back-End Workflow
1. The `ReportService` class fetches data from the database using stored procedures.
2. The data is registered with the Stimulsoft report engine.
3. The report layout is dynamically generated, including headers, footers, and data bands.
4. The report is rendered and returned to the front-end for display.

## Features
- **Dynamic Report Generation**: Reports are generated dynamically based on user-specific data and settings.
- **Filtering**: Users can apply filters to customize the data displayed in the report.
- **Export Options**: Reports can be exported in Excel, CSV, and PDF formats.
- **Customizable Layout**: The layout of the report can be customized, including fonts, colors, and alignment.

## Dependencies
- **Stimulsoft Reports Engine**: Used for generating and rendering reports.
- **Database**: Data is fetched from the database using stored procedures.

## Setup Instructions
1. Ensure that the `Stimulsoft.Reports.Blazor` NuGet package is installed.
2. Configure the database connection in `appsettings.json`.
3. Place the logo image in the `wwwroot/images/` directory.
4. Run the application and navigate to the Reports page.

## Example Usage

### Front-End
```razor
<NavLink class="nav-link" href="reports">
    <span class="oi oi-bar-chart" aria-hidden="true"></span> Reports
</NavLink>
```

### Back-End
```csharp
var report = new ReportService(DbContext);
var generatedReport = report.CreateDynamicReport("Sales Report", "Admin");
```

## Future Enhancements
- Add support for additional export formats.
- Implement advanced filtering options.
- Improve the user interface for better usability.

## Troubleshooting
- If reports are not displaying, ensure that the `Stimulsoft.Reports.Engine` package is installed and configured correctly.
- Check the database connection and stored procedures for errors.
- Verify that the logo image is present in the `wwwroot/images/` directory.
