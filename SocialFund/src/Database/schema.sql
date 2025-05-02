-- Create the Applicants table
CREATE TABLE Applicants (
    ApplicantID			INT IDENTITY(1,1) PRIMARY KEY,
    FirstName			NVARCHAR(50) NOT NULL,
    MiddleName			NVARCHAR(50),
    LastName			NVARCHAR(50) NOT NULL,
    IDNumber			NVARCHAR(20) NOT NULL,
    ContactNumber		NVARCHAR(15),
    Email				NVARCHAR(100),
    SexID				INT NOT NULL,
    MaritalStatusID		INT NOT NULL,
    VillageID			INT NOT NULL,
	CreatedOn			DATETIME NOT NULL DEFAULT GETDATE(),
	CreatedBy			INT,
	ModifiedOn			DATETIME NULL,
    ModifiedBy			INT NULL,
	FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
	FOREIGN KEY (ModifiedBy) REFERENCES Users(UserID),
	CONSTRAINT UQ_Applicants_IDNumber UNIQUE (IDNumber),
    FOREIGN KEY (SexID) REFERENCES Lookups(LookupID),
    FOREIGN KEY (MaritalStatusID) REFERENCES Lookups(LookupID),
    FOREIGN KEY (VillageID) REFERENCES Village(VillageID)
);

-- Create the Applications table
CREATE TABLE Applications (
    ApplicationID INT IDENTITY(1,1) PRIMARY KEY,
    ApplicantID INT NOT NULL,
    ApplicationDate DATE NOT NULL,
    Status NVARCHAR(50) NOT NULL,
    FOREIGN KEY (ApplicantID) REFERENCES Applicants(ApplicantID)
);

-- Create the County table
CREATE TABLE County (
    CountyID INT IDENTITY(1,1) PRIMARY KEY,
    CountyCode NVARCHAR(10) NOT NULL UNIQUE,
    CountyName NVARCHAR(100) NOT NULL
);

-- Create the SubCounty table
CREATE TABLE SubCounty (
    SubCountyID INT IDENTITY(1,1) PRIMARY KEY,
    SubCountyCode NVARCHAR(10) NOT NULL UNIQUE,
    SubCountyName NVARCHAR(100) NOT NULL,
    CountyID INT NOT NULL,
    FOREIGN KEY (CountyID) REFERENCES County(CountyID)
);

-- Create the Location table
CREATE TABLE Location (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    LocationCode NVARCHAR(10) NOT NULL UNIQUE,
    LocationName NVARCHAR(100) NOT NULL,
    SubCountyID INT NOT NULL,
    FOREIGN KEY (SubCountyID) REFERENCES SubCounty(SubCountyID)
);

-- Create the SubLocation table
CREATE TABLE SubLocation (
    SubLocationID INT IDENTITY(1,1) PRIMARY KEY,
    SubLocationCode NVARCHAR(10) NOT NULL UNIQUE,
    SubLocationName NVARCHAR(100) NOT NULL,
    LocationID INT NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

-- Create the Village table
CREATE TABLE Village (
    VillageID INT IDENTITY(1,1) PRIMARY KEY,
    VillageCode NVARCHAR(10) NOT NULL UNIQUE,
    VillageName NVARCHAR(100) NOT NULL,
    SubLocationID INT NOT NULL,
    FOREIGN KEY (SubLocationID) REFERENCES SubLocation(SubLocationID)
);

CREATE TABLE Users (
    UserID		INT IDENTITY(1,1) PRIMARY KEY,
    UserName	NVARCHAR(50) NOT NULL,
	PassKey		NVARCHAR(50) NOT NULL,
    CreatedOn	DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive	BIT NOT NULL DEFAULT 0
);

CREATE PROCEDURE GetUserByUsername
    @Username VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserID,PassKey
    FROM Users
    WHERE Username = @Username AND IsActive=1;
END;

GO

CREATE TABLE Lookups (
    LookupID		INT IDENTITY(1,1) PRIMARY KEY,
	LookupGroupID	INT NOT NULL,
    LookupCode		NVARCHAR(10),
    LookupName		NVARCHAR(100),
	CreatedOn		DATETIME NOT NULL DEFAULT GETDATE(),
	CreatedBy		INT,
	ModifiedOn		DATETIME NULL,
    ModifiedBy		INT NULL,
	FOREIGN KEY (LookupGroupID) REFERENCES LookupGroup(LookupGroupID),
	FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
	FOREIGN KEY (ModifiedBy) REFERENCES Users(UserID),
	CONSTRAINT UQ_Lookups_LookupCode UNIQUE (LookupCode)
);

CREATE TABLE LookupGroup (
    LookupGroupID		INT IDENTITY(1,1) PRIMARY KEY,
    LookupGroupCode		NVARCHAR(10),
    LookupGroupName		NVARCHAR(100),
	CreatedOn			DATETIME NOT NULL DEFAULT GETDATE(),
	CreatedBy			INT,
	ModifiedOn			DATETIME NULL,
    ModifiedBy			INT NULL,
	FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
	FOREIGN KEY (ModifiedBy) REFERENCES Users(UserID),
	CONSTRAINT UQ_LookupGroup_LookupGroupCode UNIQUE (LookupGroupCode)
);

CREATE OR ALTER PROCEDURE sp_AddEdiLookupGroup
    @LookupGroupID INT = NULL,
    @LookupGroupCode NVARCHAR(10),
    @LookupGroupName NVARCHAR(100),
    @UserID INT
AS
BEGIN

END;

CREATE OR ALTER PROCEDURE sp_GetLookupGroup
    @LookupGroupID INT = NULL
AS
BEGIN

END;

CREATE OR ALTER PROCEDURE sp_AddEditLookup
    @LookupID INT = NULL,
    @LookupGroupID INT,
    @LookupCode NVARCHAR(10),
    @LookupName NVARCHAR(100),
    @UserID INT
AS
BEGIN

END;

CREATE OR ALTER PROCEDURE sp_GetLookup
    @LookupID INT = NULL,
    @LookupGroupID INT = NULL,
    @PageNumber INT = 1,
    @PageSize INT = 10
AS
BEGIN

END;