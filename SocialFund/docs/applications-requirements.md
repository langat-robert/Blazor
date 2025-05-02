1. Create Application Class in SocialFundDbContext.cs with below nullable fields:
    ApplicationID   int,
    ApplicantID     int,
    FullName        string,
    IDNumber        string,
    Email           string,
    ContactNumber   string,
    ApplicationDate Date,
    Status          string,
    ApprovedBy      string,
    CreatedOn       DateTime,
    CreatedBy       string,
    ModifiedOn      DateTime,
    ModifiedBy      string,
    Programmes      string,
    TotalCount      int

2. Create AppProgramme Class in SocialFundDbContext.cs with below nullable fields:
    ProgrammeID         int,
    ProgrammeCode       string,
    ProgrammeName       string,
    AppProgrammeID		int,
    Applied             boolean,
    ApplicationID		int,
    Narration			string,
    CreatedOn			DateTme,
    CreatedBy			string,
    ModifiedOn			DateTime,
    ModifiedBy			string
    
3. Create searchApplication Class in SocialFundDbContext.cs with below nullable fields:
    ApplicationID   int,
    ApplicantID     int,
    ApplicationDate Date,
    FirstName       string,
    MiddleName      string,
    LastName        string,
    IDNumber        string,
    ContactNumber   string,
    Email           string,
    SexID           int,
    MaritalStatusID int,
    VillageID       int,
    SubLocationID   int,
    LocationID      int,
    SubCountyID     int,
    CountyID        int,
    CreatedOn       DateTime,
    CreatedBy       string,
    ModifiedOn      DateTime,
    ModifiedBy      string,
    TotalCount      int

4. Create GetProgrammesAsync Method in SocialFundDbContext.cs with below specifications:
    public async Task<AppProgramme?> GetProgrammesAsync(int applicantId)
    Populate AppProgramme class with stored procedure sp_GetApplicationProgrammes @ApplicantID = applicantId

5. Create AddEditApplicationAsync Method in SocialFundDbContext.cs with below specifications:
    public async Task<int> AddEditApplicationAsync(Application application) 
    use the application class parameter to pass parameters to stored procedure sp_AddEditApplications 

6. Create GetApplicationAsync Method in SocialFundDbContext.cs with below specifications:
    public async Task<List<Application>> GetApplicationAsync(int? applicationId = null, int? userId = null, int pageNumber = 1, int pageSize = 2)
    Populate Application class with stored procedure sp_GetApplication @ApplicantID = applicantId, @UserID = userId

7. Create SearchApplicationAsync Method in SocialFundDbContext.cs with below specifications:
    public async Task<List<searchApplication>> SearchApplicationAsync(searchApplication searchApps, int? userId = null, int pageNumber = 1, int pageSize = 2)
    Populate searchApplication class with stored procedure sp_searchApplicantion use parameter values from searchApps

8. Create a search form SearchApplicationModal.razor for searching Applications:
    Use logic implemented in SearchApplicantModal.razor,with few adjustments i.e. Adding ApplicationID field as the first field, use SearchApplicationAsync for database call, use of searchApplication as the class.

9. Create a razor form ApplicationManagement.razor in the Pages folder, with below specifications:
    Use the Application and AppProgramme Classes from SocialFundDbContext.cs in this form.
    Fields for user inteface- ApplicationID(have search utility next to it to call SearchApplicationModal.razor), ApplicantID(have search utility next to it to SearchApplicantModal.razor),FullName(not editable all),,ContactNumber (not editable all),ApplicationDate(use date control, Editable).
    Below the fields have a Table using AppProgramme for field mapping, display columns in the order of Applied(should be a checkbox),ProgrammeName,Narration(Should be editable when Applied checkbox is ticked).
    Have the buttons for Add, Edit, Save, Cancel.
    Have ToggleFields method to be used to enable/disable fields

    
     
 