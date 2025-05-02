
-- Create change log table for audit purpose
IF OBJECT_ID('ChangeLog') is null
CREATE TABLE ChangeLog (
    ChangeLogID INT IDENTITY(1,1) PRIMARY KEY,
    TableName NVARCHAR(100),
    RecordID INT,
    OldData NVARCHAR(MAX),       -- JSON of old data
    ChangedBy INT,
    ChangedOn DATETIME DEFAULT GETDATE()
);

-- Create lookup tables for configurable items
IF OBJECT_ID('LookupGroup') is null
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

IF OBJECT_ID('Lookups') is null
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
	CONSTRAINT UQ_Lookups_LookupCode UNIQUE (LookupGroupID,LookupCode)
);

/*
Insert Into LookupGroup(LookupGroupCode,LookupGroupName,CreatedBy)
Values('Sex','Sex',1),
	('Marital','Marital Status',1);

Insert Into Lookups(LookupGroupID,LookupCode,LookupName,CreatedBy)
Values(1,'M','Male',1),
	(1,'F','Female',1),
	(2,'S','Single',1)
*/

-- Create the Applications table
IF OBJECT_ID('Users') IS NULL
CREATE TABLE Users (
    UserID		INT IDENTITY(1,1) PRIMARY KEY,
    UserName	NVARCHAR(50) NOT NULL,
	PassKey		NVARCHAR(50) NOT NULL,
    CreatedOn	DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive	BIT NOT NULL DEFAULT 0
);

/*
Insert Into Users(UserName,PassKey,IsActive)
VALUES('R','1',1);
GO
*/

-- Create the County table
IF OBJECT_ID('County') is null
CREATE TABLE County (
    CountyID INT IDENTITY(1,1) PRIMARY KEY,
    CountyCode NVARCHAR(10) NOT NULL UNIQUE,
    CountyName NVARCHAR(100) NOT NULL
);

-- Create the SubCounty table
IF OBJECT_ID('SubCounty') is null
CREATE TABLE SubCounty (
    SubCountyID INT IDENTITY(1,1) PRIMARY KEY,
    SubCountyCode NVARCHAR(10) NOT NULL UNIQUE,
    SubCountyName NVARCHAR(100) NOT NULL,
    CountyID INT NOT NULL,
    FOREIGN KEY (CountyID) REFERENCES County(CountyID)
);

-- Create the Location table
IF OBJECT_ID('Location') is null
CREATE TABLE Location (
    LocationID INT IDENTITY(1,1) PRIMARY KEY,
    LocationCode NVARCHAR(10) NOT NULL UNIQUE,
    LocationName NVARCHAR(100) NOT NULL,
    SubCountyID INT NOT NULL,
    FOREIGN KEY (SubCountyID) REFERENCES SubCounty(SubCountyID)
);

-- Create the SubLocation table
IF OBJECT_ID('SubLocation') is null
CREATE TABLE SubLocation (
    SubLocationID INT IDENTITY(1,1) PRIMARY KEY,
    SubLocationCode NVARCHAR(10) NOT NULL UNIQUE,
    SubLocationName NVARCHAR(100) NOT NULL,
    LocationID INT NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Location(LocationID)
);

-- Create the Village table
IF OBJECT_ID('Village') is null
CREATE TABLE Village (
    VillageID INT IDENTITY(1,1) PRIMARY KEY,
    VillageCode NVARCHAR(10) NOT NULL UNIQUE,
    VillageName NVARCHAR(100) NOT NULL,
    SubLocationID INT NOT NULL,
    FOREIGN KEY (SubLocationID) REFERENCES SubLocation(SubLocationID)
);

-- Create the Applicants table
IF OBJECT_ID('Applicants') is null
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

-- Create the Programme table to be used for applications
IF OBJECT_ID('Programme') is null
CREATE TABLE Programme (
    ProgrammeID			INT IDENTITY(1,1) PRIMARY KEY,
	ProgrammeCode		NVARCHAR(10) NOT NULL UNIQUE,
	ProgrammeName		NVARCHAR(100) NOT NULL,
	IsActive			BIT NOT NULL DEFAULT 1,
	CreatedOn			DATETIME NOT NULL DEFAULT GETDATE(),
	CreatedBy			INT,
	ModifiedOn			DATETIME NULL,
    ModifiedBy			INT NULL,
	FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
	FOREIGN KEY (ModifiedBy) REFERENCES Users(UserID)
);


-- Create the Applications table
IF OBJECT_ID('Applications') is null
CREATE TABLE Applications (
    ApplicationID		INT IDENTITY(1,1) PRIMARY KEY,
    ApplicantID			INT NOT NULL,
    ApplicationDate		DATE NOT NULL,
    Status				NVARCHAR(50) NOT NULL,
	ApprovedBy			INT,
	ApprovedDate		DATETIME NULL,
	CreatedOn			DATETIME NOT NULL DEFAULT GETDATE(),
	CreatedBy			INT,
	ModifiedOn			DATETIME NULL,
    ModifiedBy			INT NULL,
    FOREIGN KEY (ApplicantID) REFERENCES Applicants(ApplicantID),
	FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
	FOREIGN KEY (ModifiedBy) REFERENCES Users(UserID),
	FOREIGN KEY (ApprovedBy) REFERENCES Users(UserID)
);

-- Create the Applications table
IF OBJECT_ID('Application_Programme') is null
CREATE TABLE Application_Programme (
    AppProgrammeID		INT IDENTITY(1,1) PRIMARY KEY,
    ApplicationID		INT NOT NULL,
	ProgrammeID			INT NOT NULL,
	Narration			NVARCHAR(100) NOT NULL,
	CreatedOn			DATETIME NOT NULL DEFAULT GETDATE(),
	CreatedBy			INT,
	ModifiedOn			DATETIME NULL,
    ModifiedBy			INT NULL,
    FOREIGN KEY (ApplicationID) REFERENCES Applications(ApplicationID),
	FOREIGN KEY (ProgrammeID) REFERENCES Programme(ProgrammeID),
	FOREIGN KEY (CreatedBy) REFERENCES Users(UserID),
	FOREIGN KEY (ModifiedBy) REFERENCES Users(UserID)
);




/*
DROP TABLE Lookups ;
DROP TABLE LookupGroup; 
DROP TABLE Applications;
DROP TABLE Applicants;
DROP TABLE LookupMaritalStatus;
DROP TABLE LookupSex;
DROP TABLE County;
DROP TABLE SubCounty;
DROP TABLE Location;
DROP TABLE SubLocation;
DROP TABLE Village;
*/
