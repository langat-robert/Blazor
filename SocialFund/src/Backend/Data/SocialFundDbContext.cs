using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.Data;
using System.Data.Common;


namespace Backend.Data
{
    public class SocialFundDbContext : DbContext
    {
        public SocialFundDbContext(DbContextOptions<SocialFundDbContext> options) : base(options) { }

        public DbSet<Applicant> Applicants { get; set; } = null!;
        public DbSet<SearchApplicant> SearchApplicants { get; set; } = null!;
        public DbSet<Application> Applications { get; set; } = null!;
        public DbSet<County> Counties { get; set; } = null!;
        public DbSet<SubCounty> SubCounties { get; set; } = null!;
        public DbSet<Location> Locations { get; set; } = null!;
        public DbSet<SubLocation> SubLocations { get; set; } = null!;
        public DbSet<Village> Villages { get; set; } = null!;
        public DbSet<LookupMaritalStatus> LookupMaritalStatuses { get; set; } = null!;
        public DbSet<AddressView> AddressViews { get; set; } = null!;
        public DbSet<LookupValue> LookupValues { get; set; } = null!;

        private DbConnection myConn;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Applicant>().ToTable("Applicants").HasKey(a => a.ApplicantID);
            modelBuilder.Entity<SearchApplicant>().HasNoKey().ToView(null);
            modelBuilder.Entity<Application>().ToTable("Applications").HasKey(a => a.ApplicationID);
            modelBuilder.Entity<County>().ToTable("County").HasKey(c => c.CountyID);
            modelBuilder.Entity<SubCounty>().ToTable("SubCounty").HasKey(sc => sc.SubCountyID);
            modelBuilder.Entity<Location>().ToTable("Location").HasKey(l => l.LocationID);
            modelBuilder.Entity<SubLocation>().ToTable("SubLocation").HasKey(sl => sl.SubLocationID);
            modelBuilder.Entity<Village>().ToTable("Village").HasKey(v => v.VillageID);
            modelBuilder.Entity<LookupMaritalStatus>().ToTable("LookupMaritalStatus").HasKey(lms => lms.MaritalStatusID);
            modelBuilder.Entity<AddressView>().HasNoKey().ToView("vw_Address");
            modelBuilder.Entity<LookupValue>().ToTable("LookupValue").HasKey(v => v.LookupID);
        }

        public async Task<List<LookupValue>> GetLookupAsync(string Codes)
        {
            var lookupValues = new List<LookupValue>();
            try
            {
                myConn ??= Database.GetDbConnection();
                if (myConn.State != ConnectionState.Open)
                {
                    await myConn.OpenAsync();
                }

                using var command = myConn.CreateCommand();
                command.CommandText = "sp_GetSpecificLookup";
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@Codes", Codes));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    lookupValues.Add(new LookupValue
                    {
                        LookupID = reader.GetInt32(reader.GetOrdinal("LookupID")),
                        LookupGroupID = reader.GetInt32(reader.GetOrdinal("LookupGroupID")),
                        LookupCode = reader.GetString(reader.GetOrdinal("LookupCode")),
                        LookupName = reader.GetString(reader.GetOrdinal("LookupName")),
                        LookupGroupCode = reader.GetString(reader.GetOrdinal("LookupGroupCode")),
                        LookupGroupName = reader.GetString(reader.GetOrdinal("LookupGroupName"))
                    });
                }
            }
            catch (Exception ex)
            {
                GlobalErrorHandler.ShowMessage($"Error fetching lookup values: {ex.Message}", true);
            }

            return lookupValues;
        }

        public async Task<int> AddEditApplicantAsync(Applicant applicant)
        {
            var parameters = new[]
            {
                new Microsoft.Data.SqlClient.SqlParameter("@ApplicantID", applicant.ApplicantID),
                new Microsoft.Data.SqlClient.SqlParameter("@FirstName", applicant.FirstName ?? (object)DBNull.Value),
                new Microsoft.Data.SqlClient.SqlParameter("@MiddleName", applicant.MiddleName ?? (object)DBNull.Value),
                new Microsoft.Data.SqlClient.SqlParameter("@LastName", applicant.LastName ?? (object)DBNull.Value),
                new Microsoft.Data.SqlClient.SqlParameter("@IDNumber", applicant.IDNumber ?? (object)DBNull.Value),
                new Microsoft.Data.SqlClient.SqlParameter("@ContactNumber", applicant.ContactNumber ?? (object)DBNull.Value),
                new Microsoft.Data.SqlClient.SqlParameter("@Email", applicant.Email ?? (object)DBNull.Value),
                new Microsoft.Data.SqlClient.SqlParameter("@SexID", applicant.SexID),
                new Microsoft.Data.SqlClient.SqlParameter("@MaritalStatusID", applicant.MaritalStatusID),
                new Microsoft.Data.SqlClient.SqlParameter("@VillageID", applicant.VillageID),
                new Microsoft.Data.SqlClient.SqlParameter("@UserID", applicant.CreatedBy)
            };
            return await Database.ExecuteSqlRawAsync("EXEC sp_AddEditApplicant @ApplicantID, @FirstName, @MiddleName, @LastName, @IDNumber, @ContactNumber, @Email, @SexID, @MaritalStatusID, @VillageID, @UserID", parameters);
        }

        public async Task<List<Applicant>> GetApplicantAsync(int? applicantId = null, string? idNumber = null, int pageNumber = 1, int pageSize = 1)
        {
            var applicants = new List<Applicant>();
            try
            {
                myConn ??= Database.GetDbConnection();

                if (myConn.State != ConnectionState.Open)
                {
                    await myConn.OpenAsync();
                }

                using var command = myConn.CreateCommand();
                command.CommandText = "sp_GetApplicants";
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicantID", applicantId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@IDNumber", idNumber ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@PageNumber", pageNumber));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@PageSize", pageSize));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    applicants.Add(new Applicant
                    {
                        ApplicantID = reader.GetInt32(reader.GetOrdinal("ApplicantID")),
                        FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                        MiddleName = reader.IsDBNull(reader.GetOrdinal("MiddleName")) ? null : reader.GetString(reader.GetOrdinal("MiddleName")),
                        LastName = reader.GetString(reader.GetOrdinal("LastName")),
                        IDNumber = reader.GetString(reader.GetOrdinal("IDNumber")),
                        ContactNumber = reader.IsDBNull(reader.GetOrdinal("ContactNumber")) ? null : reader.GetString(reader.GetOrdinal("ContactNumber")),
                        Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                        SexID = reader.GetInt32(reader.GetOrdinal("SexID")),
                        MaritalStatusID = reader.GetInt32(reader.GetOrdinal("MaritalStatusID")),
                        VillageID = reader.GetInt32(reader.GetOrdinal("VillageID")),
                        CreatedOn = reader.GetDateTime(reader.GetOrdinal("CreatedOn")),
                        CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? null : reader.GetString(reader.GetOrdinal("CreatedBy")),
                        ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                        ModifiedBy = reader.IsDBNull(reader.GetOrdinal("ModifiedBy")) ? null : reader.GetString(reader.GetOrdinal("ModifiedBy")),
                        TotalCount = reader.GetInt32(reader.GetOrdinal("TotalCount"))
                    });
                }
                
            }
            catch (Exception ex)
            {
                GlobalErrorHandler.ShowMessage($"Error fetching applicants: {ex.Message}", true);
            }

            return applicants;
        }

        public async Task<List<SearchApplicant>> SearchApplicantsAsync(
            int? applicantId = null,
            string? firstName = null,
            string? middleName = null,
            string? lastName = null,
            string? idNumber = null,
            string? contactNumber = null,
            string? email = null,
            int? sexId = null,
            int? maritalStatusId = null,
            int? villageId = null,
            int? subLocationId = null,
            int? locationId = null,
            int? subCountyId = null,
            int? countyId = null,
            int? pageNumber = 1, 
            int? pageSize = 1)
        {
            var searchapplicants = new List<SearchApplicant>();
            try
            {
                myConn ??= Database.GetDbConnection();

                if (myConn.State != ConnectionState.Open)
                {
                    await myConn.OpenAsync();
                }

                using var command = myConn.CreateCommand();
                command.CommandText = "sp_searchApplicant";
                command.CommandType = System.Data.CommandType.StoredProcedure;
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicantID", applicantId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@FirstName", firstName ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@MiddleName", middleName ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@LastName", lastName ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@IDNumber", idNumber ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ContactNumber", contactNumber ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@Email", email ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@SexID", sexId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@MaritalStatusID", maritalStatusId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@VillageID", villageId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@SubLocationID", subLocationId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@LocationID", locationId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@SubCountyID", subCountyId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@CountyID", countyId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@PageNumber", pageNumber ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@PageSize", pageSize ?? (object)DBNull.Value));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    searchapplicants.Add(new SearchApplicant
                    {
                        ApplicantID = reader.GetInt32(reader.GetOrdinal("ApplicantID")),
                        FirstName = reader.GetString(reader.GetOrdinal("FirstName")),
                        MiddleName = reader.IsDBNull(reader.GetOrdinal("MiddleName")) ? null : reader.GetString(reader.GetOrdinal("MiddleName")),
                        LastName = reader.GetString(reader.GetOrdinal("LastName")),
                        IDNumber = reader.GetString(reader.GetOrdinal("IDNumber")),
                        ContactNumber = reader.IsDBNull(reader.GetOrdinal("ContactNumber")) ? null : reader.GetString(reader.GetOrdinal("ContactNumber")),
                        Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                        SexID = reader.GetInt32(reader.GetOrdinal("SexID")),
                        MaritalStatusID = reader.GetInt32(reader.GetOrdinal("MaritalStatusID")),
                        VillageID = reader.GetInt32(reader.GetOrdinal("VillageID")),
                        SubLocationID = reader.GetInt32(reader.GetOrdinal("SubLocationID")),
                        LocationID = reader.GetInt32(reader.GetOrdinal("LocationID")),
                        SubCountyID = reader.GetInt32(reader.GetOrdinal("SubCountyID")),
                        CountyID = reader.GetInt32(reader.GetOrdinal("CountyID")),
                        CreatedOn = reader.GetDateTime(reader.GetOrdinal("CreatedOn")),
                        CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? null : reader.GetString(reader.GetOrdinal("CreatedBy")),
                        ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                        ModifiedBy = reader.IsDBNull(reader.GetOrdinal("ModifiedBy")) ? null : reader.GetString(reader.GetOrdinal("ModifiedBy")),
                        TotalCount = reader.GetInt32(reader.GetOrdinal("TotalCount"))
                    });
                }
                
                /* return await Applicants.FromSqlRaw(
                    "EXEC sp_searchApplicant @ApplicantID, @FirstName, @MiddleName, @LastName, @IDNumber, @ContactNumber, @Email, @SexID, @MaritalStatusID, @VillageID",
                    parameters). AsNoTracking().ToListAsync();*/
            }
            catch (Exception ex)
            {
                GlobalErrorHandler.ShowMessage($"Error in SearchApplicants DB: {ex.Message}", true);
            }
            return searchapplicants;
        }

        public async Task<List<AppProgramme?>> GetProgrammesAsync(int? applicationId = null)
        {
            var programmes = new List<AppProgramme>();
            //AppProgramme? programme = null;
            try
            {
                myConn ??= Database.GetDbConnection();

                if (myConn.State != ConnectionState.Open)
                {
                    await myConn.OpenAsync();
                }

                using var command = myConn.CreateCommand();
                command.CommandText = "sp_GetApplicationProgrammes";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicationID", applicationId));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    programmes.Add(new AppProgramme
                    {
                        ProgrammeID = reader.GetInt32(reader.GetOrdinal("ProgrammeID")),
                        ProgrammeCode = reader.GetString(reader.GetOrdinal("ProgrammeCode")),
                        ProgrammeName = reader.GetString(reader.GetOrdinal("ProgrammeName")),
                        AppProgrammeID = reader.IsDBNull(reader.GetOrdinal("AppProgrammeID")) ? null : reader.GetInt32(reader.GetOrdinal("AppProgrammeID")),
                        Applied = reader.GetBoolean(reader.GetOrdinal("Applied")),
                        ApplicationID = reader.IsDBNull(reader.GetOrdinal("ApplicationID")) ? null : reader.GetInt32(reader.GetOrdinal("ApplicationID")),
                        Narration = reader.IsDBNull(reader.GetOrdinal("Narration")) ? null : reader.GetString(reader.GetOrdinal("Narration")),
                        CreatedOn = reader.IsDBNull(reader.GetOrdinal("CreatedOn")) ? null : reader.GetDateTime(reader.GetOrdinal("CreatedOn")),
                        CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? null : reader.GetString(reader.GetOrdinal("CreatedBy")),
                        ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                        ModifiedBy = reader.IsDBNull(reader.GetOrdinal("ModifiedBy")) ? null : reader.GetString(reader.GetOrdinal("ModifiedBy"))
                    });
                }
            }
            catch (Exception ex)
            {
                GlobalErrorHandler.ShowMessage($"Error fetching programmes: {ex.Message}", true);
            }

            return programmes;
        }

        public async Task<int> AddEditApplicationAsync(Application application)
        {
            try
            {
                myConn ??= Database.GetDbConnection();

                if (myConn.State != ConnectionState.Open)
                {
                    await myConn.OpenAsync();
                }

                using var command = myConn.CreateCommand();
                command.CommandText = "sp_AddEditApplication";
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicationID", application.ApplicationID));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicantID", application.ApplicantID));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicationDate", application.ApplicationDate ?? (object)DBNull.Value));
                //command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApprovedBy", application.ApprovedBy ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@UserID", application.CreatedBy ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ProgrammesJSON", application.Programmes ?? (object)DBNull.Value));

                var result = await command.ExecuteScalarAsync();
                return Convert.ToInt32(result);
            }
            catch (Exception ex)
            {
                GlobalErrorHandler.ShowMessage($"Error adding/editing application: {ex.Message}", true);
                return -1;
            }
        }

        public async Task<int> ApplicationApprovalAsync(Application application)
        {
            try
            {
                myConn ??= Database.GetDbConnection();

                if (myConn.State != ConnectionState.Open)
                {
                    await myConn.OpenAsync();
                }

                using var command = myConn.CreateCommand();
                command.CommandText = "sp_ApplicationApproval";
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicationID", application.ApplicationID));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@Status", application.Status));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@UserID", application.CreatedBy ?? (object)DBNull.Value));

                var result = await command.ExecuteScalarAsync();
                return Convert.ToInt32(result);
            }
            catch (Exception ex)
            {
                GlobalErrorHandler.ShowMessage($"Error approval of application: {ex.Message}", true);
                return -1;
            }
        }

        public async Task<List<Application>> GetApplicationAsync(int? applicationId = null, int? userId = null, int pageNumber = 1, int pageSize = 2)
        {
            var applications = new List<Application>();
            try
            {
                myConn ??= Database.GetDbConnection();
                if (myConn.State != ConnectionState.Open)
                {
                    await myConn.OpenAsync();
                }

                using var command = myConn.CreateCommand();
                command.CommandText = "sp_GetApplication";
                command.CommandType = CommandType.StoredProcedure;
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicationID", applicationId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@UserID", userId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@PageNumber", pageNumber));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@PageSize", pageSize));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    applications.Add(new Application
                    {
                        ApplicationID = reader.GetInt32(reader.GetOrdinal("ApplicationID")),
                        ApplicantID = reader.GetInt32(reader.GetOrdinal("ApplicantID")),
                        FullName = reader.IsDBNull(reader.GetOrdinal("FullName")) ? null : reader.GetString(reader.GetOrdinal("FullName")),
                        IDNumber = reader.IsDBNull(reader.GetOrdinal("IDNumber")) ? null : reader.GetString(reader.GetOrdinal("IDNumber")),
                        Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                        ContactNumber = reader.IsDBNull(reader.GetOrdinal("ContactNumber")) ? null : reader.GetString(reader.GetOrdinal("ContactNumber")),
                        ApplicationDate = reader.IsDBNull(reader.GetOrdinal("ApplicationDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ApplicationDate")),
                        Status = reader.IsDBNull(reader.GetOrdinal("Status")) ? null : reader.GetString(reader.GetOrdinal("Status")),
                        ApprovedBy = reader.IsDBNull(reader.GetOrdinal("ApprovedBy")) ? null : reader.GetString(reader.GetOrdinal("ApprovedBy")),
                        CreatedOn = reader.GetDateTime(reader.GetOrdinal("CreatedOn")),
                        CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? null : reader.GetString(reader.GetOrdinal("CreatedBy")),
                        ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                        ModifiedBy = reader.IsDBNull(reader.GetOrdinal("ModifiedBy")) ? null : reader.GetString(reader.GetOrdinal("ModifiedBy")),
                        Programmes = reader.IsDBNull(reader.GetOrdinal("Programmes")) ? null : reader.GetString(reader.GetOrdinal("Programmes")),
                        TotalCount = reader.GetInt32(reader.GetOrdinal("TotalCount"))
                    });
                }
            }
            catch (Exception ex)
            {
                GlobalErrorHandler.ShowMessage($"Error fetching applications: {ex.Message}", true);
            }

            return applications;
        }

        public async Task<List<searchApplication>> SearchApplicationAsync(searchApplication searchApps, int? userId = null, int pageNumber = 1, int pageSize = 2)
        {
            var searchResults = new List<searchApplication>();
            try
            {
                myConn ??= Database.GetDbConnection();

                if (myConn.State != ConnectionState.Open)
                {
                    await myConn.OpenAsync();
                }

                using var command = myConn.CreateCommand();
                command.CommandText = "sp_searchApplication";
                command.CommandType = CommandType.StoredProcedure;

                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicationID", searchApps.ApplicationID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicantID", searchApps.ApplicantID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ApplicationDate", searchApps.ApplicationDate ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@FirstName", searchApps.FirstName ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@MiddleName", searchApps.MiddleName ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@LastName", searchApps.LastName ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@IDNumber", searchApps.IDNumber ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@ContactNumber", searchApps.ContactNumber ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@Email", searchApps.Email ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@SexID", searchApps.SexID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@MaritalStatusID", searchApps.MaritalStatusID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@VillageID", searchApps.VillageID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@SubLocationID", searchApps.SubLocationID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@LocationID", searchApps.LocationID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@SubCountyID", searchApps.SubCountyID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@CountyID", searchApps.CountyID ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@UserID", userId ?? (object)DBNull.Value));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@PageNumber", pageNumber));
                command.Parameters.Add(new Microsoft.Data.SqlClient.SqlParameter("@PageSize", pageSize));

                using var reader = await command.ExecuteReaderAsync();
                while (await reader.ReadAsync())
                {
                    searchResults.Add(new searchApplication
                    {
                        ApplicationID = reader.GetInt32(reader.GetOrdinal("ApplicationID")),
                        ApplicantID = reader.GetInt32(reader.GetOrdinal("ApplicantID")),
                        ApplicationDate = reader.IsDBNull(reader.GetOrdinal("ApplicationDate")) ? null : reader.GetDateTime(reader.GetOrdinal("ApplicationDate")),
                        FirstName = reader.IsDBNull(reader.GetOrdinal("FirstName")) ? null : reader.GetString(reader.GetOrdinal("FirstName")),
                        MiddleName = reader.IsDBNull(reader.GetOrdinal("MiddleName")) ? null : reader.GetString(reader.GetOrdinal("MiddleName")),
                        LastName = reader.IsDBNull(reader.GetOrdinal("LastName")) ? null : reader.GetString(reader.GetOrdinal("LastName")),
                        IDNumber = reader.IsDBNull(reader.GetOrdinal("IDNumber")) ? null : reader.GetString(reader.GetOrdinal("IDNumber")),
                        ContactNumber = reader.IsDBNull(reader.GetOrdinal("ContactNumber")) ? null : reader.GetString(reader.GetOrdinal("ContactNumber")),
                        Email = reader.IsDBNull(reader.GetOrdinal("Email")) ? null : reader.GetString(reader.GetOrdinal("Email")),
                        SexID = reader.IsDBNull(reader.GetOrdinal("SexID")) ? null : reader.GetInt32(reader.GetOrdinal("SexID")),
                        MaritalStatusID = reader.IsDBNull(reader.GetOrdinal("MaritalStatusID")) ? null : reader.GetInt32(reader.GetOrdinal("MaritalStatusID")),
                        VillageID = reader.IsDBNull(reader.GetOrdinal("VillageID")) ? null : reader.GetInt32(reader.GetOrdinal("VillageID")),
                        SubLocationID = reader.IsDBNull(reader.GetOrdinal("SubLocationID")) ? null : reader.GetInt32(reader.GetOrdinal("SubLocationID")),
                        LocationID = reader.IsDBNull(reader.GetOrdinal("LocationID")) ? null : reader.GetInt32(reader.GetOrdinal("LocationID")),
                        SubCountyID = reader.IsDBNull(reader.GetOrdinal("SubCountyID")) ? null : reader.GetInt32(reader.GetOrdinal("SubCountyID")),
                        CountyID = reader.IsDBNull(reader.GetOrdinal("CountyID")) ? null : reader.GetInt32(reader.GetOrdinal("CountyID")),
                        CreatedOn = reader.IsDBNull(reader.GetOrdinal("CreatedOn")) ? null : reader.GetDateTime(reader.GetOrdinal("CreatedOn")),
                        CreatedBy = reader.IsDBNull(reader.GetOrdinal("CreatedBy")) ? null : reader.GetString(reader.GetOrdinal("CreatedBy")),
                        ModifiedOn = reader.IsDBNull(reader.GetOrdinal("ModifiedOn")) ? null : reader.GetDateTime(reader.GetOrdinal("ModifiedOn")),
                        ModifiedBy = reader.IsDBNull(reader.GetOrdinal("ModifiedBy")) ? null : reader.GetString(reader.GetOrdinal("ModifiedBy")),
                        TotalCount = reader.GetInt32(reader.GetOrdinal("TotalCount"))
                    });
                }
            }
            catch (Exception ex)
            {
                GlobalErrorHandler.ShowMessage($"Error searching applications: {ex.Message}", true);
            }

            return searchResults;
        }
    }

    public class Applicant
    {
        [Key]
        public int ApplicantID { get; set; }

        [Required]
        [StringLength(50)]
        public string FirstName { get; set; } = string.Empty;

        [StringLength(50)]
        public string? MiddleName { get; set; }

        [Required]
        [StringLength(50)]
        public string LastName { get; set; } = string.Empty;

        [Required]
        [StringLength(20, ErrorMessage = "ID Number cannot be longer than 20 characters.")]
        public string IDNumber { get; set; } = string.Empty;

        [Phone]
        public string? ContactNumber { get; set; }

        [EmailAddress]
        public string? Email { get; set; }

        [Required]
        public int SexID { get; set; }

        [Required]
        public int MaritalStatusID { get; set; }

        [Required]
        public int VillageID { get; set; }

        [Required]
        public DateTime CreatedOn { get; set; } = DateTime.Now;

        public string? CreatedBy { get; set; }

        public DateTime? ModifiedOn { get; set; }

        public string? ModifiedBy { get; set; }
        public int TotalCount { get; set; } = 0;
    }

    public class SearchApplicant
    {
        public int? ApplicantID { get; set; } = null;
        public string FirstName { get; set; } = string.Empty;
        public string MiddleName { get; set; } = string.Empty;
        public string LastName { get; set; } = string.Empty;
        public string IDNumber { get; set; } = string.Empty;
        public string ContactNumber { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public int? SexID { get; set; }
        public int? MaritalStatusID { get; set; }
        public int? VillageID { get; set; }
        public int? SubLocationID { get; set; }
        public int? LocationID { get; set; }
        public int? SubCountyID { get; set; }
        public int? CountyID { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public string? ModifiedBy { get; set; }
        public int TotalCount { get; set; } = 0;
    }

    public class Application
    {
        public int? ApplicationID { get; set; }
        public int? ApplicantID { get; set; }
        public string? FullName { get; set; }
        public string? IDNumber { get; set; }
        public string? Email { get; set; }
        public string? ContactNumber { get; set; }
        public DateTime? ApplicationDate { get; set; }
        public string? Status { get; set; }
        public string? ApprovedBy { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public string? ModifiedBy { get; set; }
        public string? Programmes { get; set; }
        public int TotalCount { get; set; }
    }

    public class County
    {
        public int CountyID { get; set; }
        public string? CountyCode { get; set; }
        public string? CountyName { get; set; }
    }

    public class SubCounty
    {
        public int SubCountyID { get; set; }
        public string? SubCountyCode { get; set; }
        public string? SubCountyName { get; set; }
        public int CountyID { get; set; }
    }

    public class Location
    {
        public int LocationID { get; set; }
        public string? LocationCode { get; set; }
        public string? LocationName { get; set; }
        public int SubCountyID { get; set; }
    }

    public class SubLocation
    {
        public int SubLocationID { get; set; }
        public string? SubLocationCode { get; set; }
        public string? SubLocationName { get; set; }
        public int LocationID { get; set; }
    }

    public class Village
    {
        public int VillageID { get; set; }
        public string? VillageCode { get; set; }
        public string? VillageName { get; set; }
        public int SubLocationID { get; set; }
    }

    public class LookupMaritalStatus
    {
        public int MaritalStatusID { get; set; }

        [Required]
        public string MaritalStatus { get; set; } = string.Empty;
    }

    public class LookupValue
    {
        public int LookupID { get; set; }
        public int LookupGroupID { get; set; }
        public string? LookupCode { get; set; }
        public string? LookupName { get; set; }
        public string? LookupGroupCode { get; set; }
        public string? LookupGroupName { get; set; }
    }

    public class Sex
    {
        public int SexID { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class MaritalStatus
    {
        public int MaritalStatusID { get; set; }
        public string Name { get; set; } = string.Empty;
    }

    public class AddressIDs
    {
        public int? VillageID { get; set; } = null;
        public int? SubLocationID { get; set; } = null;
        public int? LocationID { get; set; } = null;
        public int? SubCountyID { get; set; } = null;
        public int? CountyID { get; set; } = null;
    }

    public class AppProgramme
    {
        public int ProgrammeID { get; set; }
        public string? ProgrammeCode { get; set; }
        public string? ProgrammeName { get; set; }
        public int? AppProgrammeID { get; set; }
        public bool Applied { get; set; }
        public int? ApplicationID { get; set; }
        public string? Narration { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public string? ModifiedBy { get; set; }
    }

    public class searchApplication
    {
        public int? ApplicationID { get; set; }
        public int? ApplicantID { get; set; }
        public DateTime? ApplicationDate { get; set; }
        public string? FirstName { get; set; }
        public string? MiddleName { get; set; }
        public string? LastName { get; set; }
        public string? IDNumber { get; set; }
        public string? ContactNumber { get; set; }
        public string? Email { get; set; }
        public int? SexID { get; set; }
        public int? MaritalStatusID { get; set; }
        public int? VillageID { get; set; }
        public int? SubLocationID { get; set; }
        public int? LocationID { get; set; }
        public int? SubCountyID { get; set; }
        public int? CountyID { get; set; }
        public DateTime? CreatedOn { get; set; }
        public string? CreatedBy { get; set; }
        public DateTime? ModifiedOn { get; set; }
        public string? ModifiedBy { get; set; }
        public int? TotalCount { get; set; } = 0;
    }
}