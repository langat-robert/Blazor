# Configurable Parameters Interface Requirements

This document outlines the requirements for creating an interface to manage records in lookup tables using `ConfigurableParameters.razor`.

## Overview

The interface will allow users to:

1. Add, edit, or disable records in the `LookupGroup` and `Lookups` tables.
2. Retrieve and display records with pagination.
3. Use a searchable dropdown to filter and display related records.

## Database Schema

- **Tables**:
  - `LookupGroup`
  - `Lookups`
- The schema for these tables is defined in `schema.sql`.

## Stored Procedures

- **Save Records**:
  - `sp_AddEdiLookupGroup`: Save records in the `LookupGroup` table.
  - `sp_AddEditLookup`: Save records in the `Lookups` table.
- **Retrieve Records**:
  - `sp_GetLookupGroup`: Retrieve records from the `LookupGroup` table.
  - `sp_GetLookup`: Retrieve records from the `Lookups` table (with pagination).

## Interface Design

### LookupGroup Management

1. **Fields for Add/Edit/View**:
   - `LookupGroupCode`
   - `LookupGroupName`

2. **Searchable Dropdown**:
   - Display `LookupGroupName` in a dropdown.
   - On selecting a record, use the `LookupGroupID` to retrieve related records from the `Lookups` table.

### Lookups Management

1. **Fields for Add/Edit/View**:
   - `LookupCode`
   - `LookupName`

2. **Tabular Display**:
   - Display records from the `Lookups` table in a table format.
   - Include options to add, edit, or disable records.

### Pagination

- Implement pagination for the `Lookups` table using the logic in `sp_GetLookup`.

## Implementation Steps

1. **Dropdown for LookupGroup**:
   - Create a searchable dropdown to display `LookupGroupName`.
   - On selection, fetch records from the `Lookups` table where `LookupGroupID` matches the selected record.

2. **Table for Lookups**:
   - Display records in a table format with the following columns:
     - `LookupCode`
     - `LookupName`
     - Actions (Add/Edit/Disable)

3. **Add/Edit Functionality**:
   - Use `sp_AddEdiLookupGroup` for managing `LookupGroup` records.
   - Use `sp_AddEditLookup` for managing `Lookups` records.

4. **Disable Functionality**:
   - Add an option to disable records in the `Lookups` table.

5. **Pagination**:
   - Implement pagination for the `Lookups` table using the logic in `sp_GetLookup`.

## Notes

- Ensure the interface is user-friendly and responsive.
- Validate all inputs before saving records.
- Handle errors gracefully and provide meaningful feedback to the user.




