# Applicant Form Requirements

This document outlines the requirements for the `Applicants.razor` form.

## Overview

- Use the existing `Applicants.razor` file for implementing the requirements.
- The database table schema is defined in `schema.sql` under the name `Applicants`.
- Align the `DbContext` classes in `SocialFundDbContext.cs` for database access logic.

## Interface Design

1. **Flexible Layout**:
   - Arrange controls in two/three columns for larger screens and one column for smaller screens.

2. **Dropdown Controls**:
   - Create a dropdown named `sexDropdown` to display options matching `SexID`.
   - Create a dropdown named `maritalDropdown` to display options matching `MaritalStatusID`.

3. **Address Integration**:
   - Reference `Address.razor` as part of the form.

4. **Control Arrangement**:
   - Arrange the display controls in the following order:
     - `ApplicantID`, `FirstName`, `MiddleName`, `LastName`, `IDNumber`, `ContactNumber`, `Email`, `sexDropdown`, `maritalDropdown`, `Address.razor`, `CreatedOn`, `CreatedBy`, `ModifiedOn`, `ModifiedBy`.

## Common Methods

1. **Dropdown Population**:
   - Create a common method to populate `sexDropdown` and `maritalDropdown` when the form loads.
   - Use the stored procedure `sp_GetLookup` with the following parameters:
     - `@LookupGroupID=1` for `sexDropdown`.
     - `@LookupGroupID=2` for `maritalDropdown`.

2. **Add/Edit Functionality**:
   - Implement add/edit functionality using the stored procedure `sp_AddEditApplicant`.

3. **Retrieve Records**:
   - Create a common method `GetApplicant` to retrieve records and display them on the form.
   - The method should accept the following optional parameters:
     - `ApplicantID`, `IDNumber`, `PageNumber`, `PageSize`.
   - Call the stored procedure `sp_GetApplicants` and pass the parameters to fetch records.

## Search Functionality

1. **Search Modal**:
   - Create a modal form with the following search fields:
     - `ApplicantID`, `FirstName`, `MiddleName`, `LastName`, `IDNumber`, `ContactNumber`, `Email`, `sexDropdown`, `maritalDropdown`, `Address.razor`.
   - Add a table below the search fields to display results when the search button is clicked.
   - Call the stored procedure `sp_searchApplicant` and pass all search fields as parameters.
   - On double-clicking a record in the search results, return the `ApplicantID` value to the calling function.

2. **ApplicantID Field**:
   - Add an input field for `ApplicantID`.
   - Allow users to type the ID and press Enter to call the `GetApplicant` method and display records.
   - Add a search icon to the right of the field to trigger the search functionality.

## Recent Records Table

- Add a table below the save button to display the two most recently saved records created/edited by the logged-in user.
- Use the stored procedure `sp_GetApplicants` to fetch records.
- Ensure the table updates to display the saved record immediately after a save operation.
