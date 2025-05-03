# Applications Requirements

This document outlines the requirements for managing applications in the Social Fund System.

## 1. Application Class

Create an `Application` class in `SocialFundDbContext.cs` with the following nullable fields:

- `ApplicationID` (int)
- `ApplicantID` (int)
- `FullName` (string)
- `IDNumber` (string)
- `Email` (string)
- `ContactNumber` (string)
- `ApplicationDate` (Date)
- `Status` (string)
- `ApprovedBy` (string)
- `CreatedOn` (DateTime)
- `CreatedBy` (string)
- `ModifiedOn` (DateTime)
- `ModifiedBy` (string)
- `Programmes` (string)
- `TotalCount` (int)

## 2. AppProgramme Class

Create an `AppProgramme` class in `SocialFundDbContext.cs` with the following nullable fields:

- `ProgrammeID` (int)
- `ProgrammeCode` (string)
- `ProgrammeName` (string)
- `AppProgrammeID` (int)
- `Applied` (boolean)
- `ApplicationID` (int)
- `Narration` (string)
- `CreatedOn` (DateTime)
- `CreatedBy` (string)
- `ModifiedOn` (DateTime)
- `ModifiedBy` (string)

## 3. searchApplication Class

Create a `searchApplication` class in `SocialFundDbContext.cs` with the following nullable fields:

- `ApplicationID` (int)
- `ApplicantID` (int)
- `ApplicationDate` (Date)
- `FirstName` (string)
- `MiddleName` (string)
- `LastName` (string)
- `IDNumber` (string)
- `ContactNumber` (string)
- `Email` (string)
- `SexID` (int)
- `MaritalStatusID` (int)
- `VillageID` (int)
- `SubLocationID` (int)
- `LocationID` (int)
- `SubCountyID` (int)
- `CountyID` (int)
- `CreatedOn` (DateTime)
- `CreatedBy` (string)
- `ModifiedOn` (DateTime)
- `ModifiedBy` (string)
- `TotalCount` (int)

## 4. GetProgrammesAsync Method

Create a method `GetProgrammesAsync` in `SocialFundDbContext.cs`:

```csharp
public async Task<AppProgramme?> GetProgrammesAsync(int applicantId)
```

- Populate the `AppProgramme` class using the stored procedure `sp_GetApplicationProgrammes` with the parameter `@ApplicantID = applicantId`.

## 5. AddEditApplicationAsync Method

Create a method `AddEditApplicationAsync` in `SocialFundDbContext.cs`:

```csharp
public async Task<int> AddEditApplicationAsync(Application application)
```

- Use the `Application` class parameter to pass values to the stored procedure `sp_AddEditApplications`.

## 6. GetApplicationAsync Method

Create a method `GetApplicationAsync` in `SocialFundDbContext.cs`:

```csharp
public async Task<List<Application>> GetApplicationAsync(int? applicationId = null, int? userId = null, int pageNumber = 1, int pageSize = 2)
```

- Populate the `Application` class using the stored procedure `sp_GetApplication` with parameters `@ApplicantID = applicationId`, `@UserID = userId`.

## 7. SearchApplicationAsync Method

Create a method `SearchApplicationAsync` in `SocialFundDbContext.cs`:

```csharp
public async Task<List<searchApplication>> SearchApplicationAsync(searchApplication searchApps, int? userId = null, int pageNumber = 1, int pageSize = 2)
```

- Populate the `searchApplication` class using the stored procedure `sp_searchApplication` with parameter values from `searchApps`.

## 8. SearchApplicationModal.razor

Create a search form `SearchApplicationModal.razor` for searching applications:

- Use the logic implemented in `SearchApplicantModal.razor` with the following adjustments:
  - Add an `ApplicationID` field as the first field.
  - Use `SearchApplicationAsync` for database calls.
  - Use the `searchApplication` class.

## 9. ApplicationManagement.razor

Create a Razor form `ApplicationManagement.razor` in the `Pages` folder with the following specifications:

- Use the `Application` and `AppProgramme` classes from `SocialFundDbContext.cs`.
- Fields for the user interface:
  - `ApplicationID` (with a search utility to call `SearchApplicationModal.razor`)
  - `ApplicantID` (with a search utility to call `SearchApplicantModal.razor`)
  - `FullName` (not editable)
  - `ContactNumber` (not editable)
  - `ApplicationDate` (editable, use a date control)
- Below the fields, add a table using `AppProgramme` for field mapping:
  - Display columns in the order: `Applied` (checkbox), `ProgrammeName`, `Narration` (editable when `Applied` checkbox is ticked).
- Add buttons for `Add`, `Edit`, `Save`, and `Cancel`.
- Implement a `ToggleFields` method to enable/disable fields.



