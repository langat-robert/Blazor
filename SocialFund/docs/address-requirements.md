# Address Form Requirements

This document outlines the requirements for the `Address.razor` form.

## Overview

- The `Address.razor` form can be used independently or embedded within other forms.
- A menu item in `NavMenu.razor` called **Locations** should link to the `Address.razor` form when used independently.

## Parameters

The form should support the following optional parameters when embedded in other forms:

- `VillageID`
- `SubLocationID`
- `LocationID`
- `SubCountyID`
- `CountyID`

These parameters will be used to load values into the corresponding controls:

- **Village**
- **SubLocation**
- **Location**
- **SubCounty**
- **County**

## Initialization

- When the form is initialized, it should create a dataset named `addresses`.
- The dataset schema should match the view `vw_Address` (defined in `vw_Address.sql`).
- Data for the dataset should be loaded using the stored procedure `sp_GetAddress` (defined in `SPs.sql`).
- Use `SocialFundDbContext.cs` for database access logic.

## Control Population

1. **County Control**:
   - Populate with unique values of `CountyID` and `CountyName` from the `addresses` dataset.

2. **SubCounty Control**:
   - Implement the `OnCountyChange` method to populate this control with unique values of `SubCountyID` and `SubCountyName` where `CountyID` matches the selected county.

3. **Location Control**:
   - Implement the `OnSubCountyChange` method to populate this control with unique values of `LocationID` and `LocationName` where `SubCountyID` matches the selected sub-county.

4. **SubLocation Control**:
   - Implement the `OnLocationChange` method to populate this control with unique values of `SubLocationID` and `SubLocationName` where `LocationID` matches the selected location.

5. **Village Control**:
   - Implement the `OnSubLocationChange` method to populate this control with unique values of `VillageID` and `VillageName` where `SubLocationID` matches the selected sub-location.

## Embedded Form Behavior

- When the form is embedded in another form and the `VillageID` parameter is set, implement the `LoadVillage` method:
  1. Use the `VillageID` parameter to filter records from the `addresses` dataset where `VillageID` matches.
  2. Select the correct county option using `CountyID` and trigger the `OnCountyChange` method.
  3. Select the correct sub-county option using `SubCountyID` and trigger the `OnSubCountyChange` method.
  4. Select the correct location option using `LocationID` and trigger the `OnLocationChange` method.
  5. Select the correct sub-location option using `SubLocationID` and trigger the `OnSubLocationChange` method.
  6. Finally, select the correct village option based on `VillageID`.
