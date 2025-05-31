
--Initialize Sample data for County, SubCounty, Locations, Sublocations and Village, for test purpose.
CREATE TABLE village_data (
    ID					INT IDENTITY(1,1) PRIMARY KEY,
    Village				NVARCHAR(50),
    Sublocation			NVARCHAR(50),
    [Location]			NVARCHAR(50),
	Subcounty			NVARCHAR(50),
	County				NVARCHAR(50)
);


INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Wundanyi', 'Mwanda', 'Wundanyi', 'Wundanyi', 'Taita Taveta');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Muthaiga', 'Muthaiga', 'Parklands', 'Westlands', 'Nairobi');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Gatuanyaga', 'Thika Township', 'Kiganjo', 'Thika East', 'Kiambu');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Kisauni', 'Majaoni', 'Kisauni', 'Kisauni', 'Mombasa');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Baragoi', 'Nachola', 'Baragoi', 'Samburu North', 'Samburu');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Kipkorir', 'Chemelil', 'Koru', 'Muhoroni', 'Kisumu');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Kapsigilai', 'Kabartonjo', 'Kaptama', 'Baringo North', 'Baringo');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Lelmokwo', 'Lelmokwo', 'Kabisaga', 'Nandi Central', 'Nandi');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Nyagacho', 'Township', 'Kericho Town', 'Ainamoi', 'Kericho');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Gachoka', 'Mwea', 'Makutano', 'Mbeere South', 'Embu');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Lodwar', 'Lodwar Township', 'Kanamkemer', 'Turkana Central', 'Turkana');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Hola', 'Mikinduni', 'Hola', 'Tana River', 'Tana River');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Kapenguria', 'Kapenguria', 'Siyoi', 'West Pokot', 'West Pokot');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Mbitini', 'Kyangwithya', 'Kitui Central', 'Kitui Central', 'Kitui');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Ol Kalou', 'Rurii', 'Ol Kalou', 'Ol Kalou', 'Nyandarua');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Nyahururu', 'Igwamiti', 'Nyahururu', 'Laikipia West', 'Laikipia');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Kinango', 'Puma', 'Kinango', 'Kinango', 'Kwale');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Iten', 'Chepkorio', 'Iten', 'Keiyo North', 'Elgeyo Marakwet');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Malindi', 'Shella', 'Malindi', 'Malindi', 'Kilifi');
INSERT INTO village_data (Village, Sublocation, Location, Subcounty, County) VALUES ('Garba Tulla', 'Sericho', 'Garba Tulla', 'Isiolo South', 'Isiolo');



INSERT INTO County(CountyCode,CountyName)
SELECT DISTINCT LEFT(UPPER(County),10), County FROM village_data;

INSERT INTO SubCounty(SubCountyCode,SubCountyName,CountyID)
SELECT DISTINCT LEFT(UPPER(Subcounty),10), Subcounty,(SELECT CountyID FROM County WHERE CountyName=village_data.County ) FROM village_data;

INSERT INTO Location(LocationCode,LocationName,SubCountyID)
SELECT DISTINCT LEFT(UPPER(Location),10), Location,(SELECT SubCountyID FROM SubCounty WHERE SubCountyName=village_data.Subcounty ) FROM village_data;

INSERT INTO SubLocation(SubLocationCode,SubLocationName,LocationID)
SELECT DISTINCT LEFT(UPPER(Sublocation),10), Sublocation,(SELECT LocationID FROM Location WHERE LocationName=village_data.Location ) FROM village_data;

INSERT INTO Village(VillageCode,VillageName,SubLocationID)
SELECT DISTINCT LEFT(UPPER(Village),10), Village,(SELECT SubLocationID FROM SubLocation WHERE SubLocationName=village_data.Sublocation ) FROM village_data;


-- Initialize test user
Insert Into Users(UserName,PassKey,IsActive)
VALUES('R','1',1);
GO

--Initialize lookup parameters
Insert Into LookupGroup(LookupGroupCode,LookupGroupName,CreatedBy)
Values('Sex','Sex',1),
	('Marital','Marital Status',1);

Insert Into Lookups(LookupGroupID,LookupCode,LookupName,CreatedBy)
Select LookupGroupID,'M','Male',1 from LookupGroup where LookupGroupCode='Sex'
UNION
Select LookupGroupID ,'S','Single',1 from LookupGroup where LookupGroupCode='Marital'

GO
--Initialize Programmes
INSERT INTO Programme(ProgrammeCode,ProgrammeName,CreatedBy)
VALUES('ORPHANS','Orphans and vulnerable children',1),
	('POORELD','Poor elderly persons',1),
	('DISABILITY','Persons with disability',1),
	('EXTREME','Persons in extreme poverty ',1),
	('ANYOTHER','Any other',1)

GO


IF NOT EXISTS(SELECT * FROM Reports WHERE Name='Applicants')
INSERT INTO Reports (Name, Description, ReportSP, Filters)
VALUES 
(
    'Applicants',
    'List of applicants with location filters',
    'rpt_Applicants',
	'[
		{
			"name": "FromDate",
			"label": "From Date",
			"type": "Date",
			"required": true
		},
		{
			"name": "ToDate",
			"label": "To Date",
			"type": "Date",
			"required": true
		},
		{
			"name": "CountyID",
			"label": "County",
			"type": "Dropdown",
			"dataSourceSP": "spGetCounties",
			"required": false
		},
		{
			"name": "SubCountyID",
			"label": "SubCounty",
			"type": "Dropdown",
			"dataSourceSP": "spGetSubCountiesByCounty",
			"dataSourceParameters": [
				{
					"name": "CountyId",
					"sourceFilter": "CountyID"
				}
			],
			"required": false
		},
		{
			"name": "LocationID",
			"label": "Location",
			"type": "Dropdown",
			"dataSourceSP": "spGetLocationsBySubCounty",
			"dataSourceParameters": [
				{
					"name": "SubCountyId",
					"sourceFilter": "SubCountyID"
				}
			],
			"required": false
		},
		{
			"name": "SubLocationID",
			"label": "Sub Location",
			"type": "Dropdown",
			"dataSourceSP": "spGetSubLocationsByLocation",
			"dataSourceParameters": [
				{
					"name": "LocationId",
					"sourceFilter": "LocationID"
				}
			],
			"required": false
		},
		{
			"name": "VillageID",
			"label": "Village",
			"type": "Dropdown",
			"dataSourceSP": "spGetVillagesBySubLocation",
			"dataSourceParameters": [
				{
					"name": "SubLocationId",
					"sourceFilter": "SubLocationID"
				}
			],
			"required": false
		},
		{
			"Name": "SexID",
			"Label": "Gender",
			"Type": "Dropdown",
			"DataSourceSP": "sp_GetSelectOptions",
			"DataSourceParameters": [
			  {
				"Name": "Codes",
				"StaticValue": "Sex"
			  }
			]
		},
		{
			"Name": "MaritalStatusID",
			"Label": "Marital Status",
			"Type": "Dropdown",
			"DataSourceSP": "sp_GetSelectOptions",
			"DataSourceParameters": [
			  {
				"Name": "Codes",
				"StaticValue": "Marital"
			  }
			]
		  }
	]'

);

GO



