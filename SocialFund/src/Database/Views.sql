
CREATE OR ALTER VIEW vw_Address AS
SELECT
    VillageID, VillageCode, VillageName, 
	SubLocation.SubLocationID, SubLocationCode, SubLocationName, 
	Location.LocationID, LocationCode, LocationName,
	SubCounty.SubCountyID, SubCountyCode, SubCountyName,
	County.CountyID, CountyCode, CountyName
FROM Village (nolock)
	Inner Join SubLocation  (nolock) On Village.SubLocationID=SubLocation.SubLocationID
	Inner Join Location  (nolock) On Location.LocationID=SubLocation.LocationID
	Inner Join SubCounty  (nolock) On SubCounty.SubCountyID=Location.SubCountyID
	Inner Join County  (nolock) On County.CountyID=SubCounty.CountyID

GO

--Select * from vw_Address;

CREATE OR ALTER VIEW vw_SearchApplicant AS
	SELECT
		ApplicantID,FirstName,MiddleName,LastName,IDNumber,ContactNumber,Email,SexID,MaritalStatusID,Applicants.VillageID,CreatedOn,CAST(CreatedBy AS varchar) CreatedBy,ModifiedOn, CAST(ModifiedBy AS varchar) ModifiedBy,
		SubLocation.SubLocationID, Location.LocationID, SubCounty.SubCountyID,County.CountyID
	FROM Applicants (nolock)
	INNER JOIN Village (nolock) ON Applicants.VillageID=Village.VillageID
	INNER JOIN SubLocation  (nolock) ON Village.SubLocationID=SubLocation.SubLocationID
	INNER JOIN Location  (nolock) ON Location.LocationID=SubLocation.LocationID
	INNER JOIN SubCounty  (nolock) ON SubCounty.SubCountyID=Location.SubCountyID
	INNER JOIN County  (nolock) ON County.CountyID=SubCounty.CountyID

GO

CREATE OR ALTER VIEW vw_SearchApplications AS
	SELECT
		A.ApplicationID,A.ApplicantID, ApplicationDate,ApprovedBy,A.Status,A.CreatedOn,CAST(A.CreatedBy AS varchar) CreatedBy,A.ModifiedOn, CAST(A.ModifiedBy AS varchar) ModifiedBy,
		FirstName,MiddleName,LastName,IDNumber,ContactNumber,Email,SexID,MaritalStatusID,Applicants.VillageID,
		SubLocation.SubLocationID, Location.LocationID, SubCounty.SubCountyID,County.CountyID
	FROM Applications(nolock) A
	INNER JOIN Applicants (nolock) ON A.ApplicantID=Applicants.ApplicantID
	INNER JOIN Village (nolock) ON Applicants.VillageID=Village.VillageID
	INNER JOIN SubLocation  (nolock) ON Village.SubLocationID=SubLocation.SubLocationID
	INNER JOIN Location  (nolock) ON Location.LocationID=SubLocation.LocationID
	INNER JOIN SubCounty  (nolock) ON SubCounty.SubCountyID=Location.SubCountyID
	INNER JOIN County (nolock) ON County.CountyID=SubCounty.CountyID

GO



