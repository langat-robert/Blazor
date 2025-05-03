# Database Initialization Guide

This document provides instructions for initializing the database for the Social Fund System.

## Prerequisites

- Ensure you have SQL Server 2022 or a compatible version installed.
- Create a blank database named `MoLSP`. If you choose a different name, update the connection string in `appsettings.json` accordingly.

## Steps to Initialize the Database

1. Navigate to the `src/Database` folder in the project directory.
2. Execute the SQL scripts in the following order:
   - `Tables.sql`
   - `Views.sql`
   - `Functions.sql`
   - `SPs.sql`
   - `sample_data.sql`

## Notes

- Ensure each script executes successfully before proceeding to the next.
- If you encounter any errors, review the script and ensure all dependencies are met.
- The database schema and sample data are designed for SQL Server 2022.