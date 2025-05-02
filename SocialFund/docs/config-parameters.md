1. Create an interface to maintain records in lookup tables using ConfigurableParameters.razor.

2. Table schema is in the schema.sql file, use Lookups and LookupGroup.
3. Use stored procedure sp_AddEdiLookupGroup as included in schema.sql for saving records in LookupGroup , the database logic has already been implemented. 
4. Use stored procedure sp_AddEditLookup as included in schema.sql for saving records in Lookups table , the database logic has already been implemented.
5. To Retrieve records use sp_GetLookup for records in Lookups table and sp_GetLookupGroup for records in LookupGroup table.
6. Fields visible for Add/Edit/View in the inteface are LookupGroupCode and LookupGroupName for LookupGroup table.
7. Use a dropdown searchable field to display LookupGroupName, once you find a record, use the LookupGroupID for the record to retrieve records from Lookups where LookupGroupID matches and display records in a tabular format below it. Use sp_Get_Lookup, pagination in the procedure has been implemented and the interface should implement it too.
8. Have option to add/edit or Disable in the table displaying the Lookups records.
Fields visible for Add/Edit/View in the inteface are LookupCode and LookupName for Lookups table




