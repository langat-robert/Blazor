# Social Fund System

This README provides the necessary steps to set up and run the Social Fund System project in a Visual Studio Code environment.

## Prerequisites

Ensure you have the following installed on your system:

1. **.NET SDK**: Version 6.0 or later. You can download it from [Microsoft .NET](https://dotnet.microsoft.com/download).
2. **Node.js and npm**: Required for frontend dependencies. Download from [Node.js](https://nodejs.org/).
3. **SQL Server**: Ensure you have a running SQL Server instance for the database.
4. **Visual Studio Code**: Download from [VS Code](https://code.visualstudio.com/).
5. **C# Extension for VS Code**: Install the C# extension from the VS Code marketplace.

## Setup Instructions

Follow these steps to set up the project:

### 1. Clone the Repository

Clone the project repository to your local machine:

```bash
git clone <repository-url>
cd SocialFund
```

### 2. Restore Dependencies

Restore the required NuGet packages:

```bash
dotnet restore
```

### 3. Build the Solution

Build the solution to ensure all dependencies are correctly configured:

```bash
dotnet build SocialFund.sln
```

### 4. Configure the Database

1. Open the `src/Backend/appsettings.json` file and update the `ConnectionStrings` section with your SQL Server connection details.
2. Initialize the database by running the SQL scripts located in the `src/Backend/Database/` folder in the following order:
   - `Tables.sql`
   - `Functions.sql`
   - `Views.sql`
   - `SPs.sql`
   - `sample_data.sql`

### 5. Run the Application

Run the backend application:

```bash
dotnet run --project src/Backend/Backend.csproj
```

The application will be available at `https://localhost:7014`. port number might change based on your environment

### 6. Open in Visual Studio Code

1. Open the project folder in Visual Studio Code:

```bash
code .
```

2. Ensure the C# extension is installed and active.
3. Use the default build task to build the project (`Ctrl+Shift+B`).

### 7. Frontend Development (Optional)

If you need to work on the frontend:

1. Navigate to the `src/Frontend/` folder.
2. Install dependencies:

```bash
npm install
```

3. Start the development server:

```bash
npm start
```

## Additional Notes

- Ensure your SQL Server instance is running before starting the application.
- If you encounter any issues, check the logs or console output for error messages.
- For further details, refer to the documentation files in the `docs/` folder.
- Defualt Login for the test is UserName: R, pwd: 1. Encryptions currently ommited.