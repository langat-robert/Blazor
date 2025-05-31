
CREATE OR ALTER PROCEDURE sp_GetSelectOptions
	@Codes NVARCHAR(1000) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        L.LookupID,
        L.LookupName
    FROM Lookups L
    INNER JOIN LookupGroup G ON L.LookupGroupID = G.LookupGroupID
    WHERE 
        G.LookupGroupCode IN (SELECT Value FROM dbo.SplitString(@Codes, ',')
    )
    ORDER BY 2
END;

GO


CREATE OR ALTER PROCEDURE spGetVillagesBySubLocation
(
	@SubLocationId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT VillageID,VillageName
    FROM Village
	WHERE SubLocationID = @SubLocationId
    ORDER BY 2;
END;

GO

CREATE OR ALTER PROCEDURE spGetSubLocationsByLocation
(
	@LocationId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SubLocationID,SubLocationName
    FROM SubLocation
	WHERE LocationID = @LocationId
    ORDER BY 2;
END;

GO

CREATE OR ALTER PROCEDURE spGetLocationsBySubCounty
(
	@SubCountyId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT LocationID,LocationName
    FROM Location
	WHERE SubCountyID = @SubCountyId
    ORDER BY 2;
END;

GO

CREATE OR ALTER PROCEDURE spGetSubCountiesByCounty
(
	@CountyId INT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT SubCountyID,SubCountyName
    FROM SubCounty
	WHERE CountyID = @CountyId
    ORDER BY 2;
END;

GO

CREATE OR ALTER PROCEDURE spGetCounties
AS
BEGIN
    SET NOCOUNT ON;

    SELECT CountyID,CountyName
    FROM county
    ORDER BY 2;
END;

GO

CREATE OR ALTER PROCEDURE sp_GetUserReports
	@UserID			INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
	--@UserID implement permission logic 
    SELECT ReportID, Name, Description, ReportSP, Filters
    FROM Reports
	WHERE IsActive=1 
	ORDER BY 2;
END;

GO

CREATE OR ALTER PROCEDURE GetUserByUsername
    @Username VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT UserID,PassKey
    FROM Users
    WHERE Username = @Username AND IsActive=1;
END;

GO
--EXEC GetUserByUsername 'R';
CREATE OR ALTER PROCEDURE sp_LogChange
    @TableName NVARCHAR(100),
    @RecordID INT,
    @OldData NVARCHAR(MAX),
    @ChangedBy INT
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO ChangeLog (
        TableName,
        RecordID,
        OldData,
        ChangedBy
    )
    VALUES (
        @TableName,
        @RecordID,
        @OldData,
        @ChangedBy
    );
END;

GO


CREATE OR ALTER PROCEDURE sp_AddEditLookupGroup
    @LookupGroupID INT = NULL,
    @LookupGroupCode NVARCHAR(10),
    @LookupGroupName NVARCHAR(100),
    @UserID INT,
	@Result INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF ISNULL(@LookupGroupID, 0) = 0
        BEGIN
            -- Insert
            INSERT INTO LookupGroup (
                LookupGroupCode, 
                LookupGroupName, 
                CreatedBy, 
                CreatedOn
            )
            VALUES (
                @LookupGroupCode, 
                @LookupGroupName, 
                @UserID, 
                GETDATE()
            );
            SET @Result = 1;
        END
        ELSE
        BEGIN
            DECLARE @OldCode NVARCHAR(10), @OldName NVARCHAR(100);
            DECLARE @Changes NVARCHAR(MAX);

            SELECT 
                @OldCode = LookupGroupCode,
                @OldName = LookupGroupName
            FROM LookupGroup(nolock)
            WHERE LookupGroupID = @LookupGroupID;

            SET @Changes = (
                SELECT 
                    CASE WHEN @OldCode <> @LookupGroupCode THEN JSON_QUERY('{"Field":"LookupGroupCode","OldValue":"' + ISNULL(@OldCode, '') + '"}') END LookupGroupCode,
                    CASE WHEN @OldName <> @LookupGroupName THEN JSON_QUERY('{"Field":"LookupGroupName","OldValue":"' + ISNULL(@OldName, '') + '"}') END LookupGroupName
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );


			IF ISJSON(@Changes) = 1 AND LEN(@Changes) > 2
            BEGIN
                -- Log the change
                EXEC sp_LogChange 
                    @TableName = 'LookupGroup',
                    @RecordID = @LookupGroupID,
                    @OldData = @Changes,
                    @ChangedBy = @UserID;
            END

            -- Proceed with update
            UPDATE LookupGroup
            SET 
                LookupGroupCode = @LookupGroupCode,
                LookupGroupName = @LookupGroupName,
                ModifiedBy = @UserID,
                ModifiedOn = GETDATE()
            WHERE LookupGroupID = @LookupGroupID;

            SET @Result = 2;
        END
    END TRY
    BEGIN CATCH
        SET @Result = -1;
    END CATCH
END;

GO

CREATE OR ALTER PROCEDURE sp_GetLookupGroup
    @LookupGroupID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        LookupGroupID,
        LookupGroupCode,
        LookupGroupName,
        CreatedOn,
        CreatedBy,
        ModifiedOn,
        ModifiedBy
    FROM LookupGroup
    WHERE (@LookupGroupID IS NULL OR LookupGroupID = @LookupGroupID);
END;

GO


CREATE OR ALTER PROCEDURE sp_AddEditLookup
    @LookupID INT = NULL,
    @LookupGroupID INT,
    @LookupCode NVARCHAR(10),
    @LookupName NVARCHAR(100),
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF ISNULL(@LookupID, 0) = 0
        BEGIN
		
            -- Insert
            INSERT INTO Lookups (
                LookupGroupID,
                LookupCode,
                LookupName,
                CreatedBy,
                CreatedOn
            )
            VALUES (
                @LookupGroupID,
                @LookupCode,
                @LookupName,
                @UserID,
                GETDATE()
            );
			
            RETURN 1;
        END
        ELSE
        BEGIN
            DECLARE 
                @OldCode NVARCHAR(10),
                @OldName NVARCHAR(100),
                @OldGroupID INT;

            DECLARE 
                @ChangedFields NVARCHAR(MAX) = '',
                @OldData NVARCHAR(MAX);

            SELECT 
                @OldCode = LookupCode,
                @OldName = LookupName,
                @OldGroupID = LookupGroupID
            FROM Lookups
            WHERE LookupID = @LookupID;

            -- Compare fields
            IF ISNULL(@OldCode, '') <> ISNULL(@LookupCode, '')
                SET @ChangedFields += 'LookupCode,';
            IF ISNULL(@OldName, '') <> ISNULL(@LookupName, '')
                SET @ChangedFields += 'LookupName,';
            IF ISNULL(@OldGroupID, 0) <> ISNULL(@LookupGroupID, 0)
                SET @ChangedFields += 'LookupGroupID,';

            -- Clean trailing comma
            IF RIGHT(@ChangedFields, 1) = ','
                SET @ChangedFields = LEFT(@ChangedFields, LEN(@ChangedFields) - 1);

            IF LEN(@ChangedFields) > 0
            BEGIN
                SELECT @OldData = (
                    SELECT LookupCode, LookupName, LookupGroupID
                    FROM Lookups
                    WHERE LookupID = @LookupID
                    FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
                );

                EXEC sp_LogChange 
                    @TableName = 'Lookups',
                    @RecordID = @LookupID,
                    @ChangedFields = @ChangedFields,
                    @OldData = @OldData,
                    @ChangedBy = @UserID;
            END

            -- Update
            UPDATE Lookups
            SET 
                --LookupGroupID = @LookupGroupID,
                LookupCode = @LookupCode,
                LookupName = @LookupName,
                ModifiedBy = @UserID,
                ModifiedOn = GETDATE()
            WHERE LookupID = @LookupID;

            RETURN 2;
        END
    END TRY
    BEGIN CATCH
	    THROW 51000, 'Database Error, ask DB Admin to investigate @Bob', 1;
        RETURN -1;
    END CATCH
END;

GO


CREATE OR ALTER PROCEDURE sp_GetLookup
	@LookupID INT = NULL,
	@LookupGroupID INT = NULL,
	@PageNumber INT = 1,
	@PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;

    -- Get total count first
    DECLARE @TotalCount INT;

    SELECT @TotalCount = COUNT(*)
    FROM Lookups L
    WHERE L.LookupID = ISNULL(@LookupID,'') OR L.LookupGroupID = iSNULL(@LookupGroupID,'');
       -- (@LookupID IS NULL OR L.LookupID = @LookupID)
       -- AND (@LookupGroupID IS NULL OR L.LookupGroupID = @LookupGroupID);

    -- Paged result
    SELECT 
        L.LookupID,
        L.LookupCode,
        L.LookupName,
        L.LookupGroupID,
        G.LookupGroupCode,
        G.LookupGroupName,
        L.CreatedOn,
        L.CreatedBy,
        L.ModifiedOn,
        L.ModifiedBy,
        TotalCount = @TotalCount
    FROM Lookups L
    INNER JOIN LookupGroup G ON L.LookupGroupID = G.LookupGroupID
    WHERE 
        --(@LookupID IS NULL OR L.LookupID = @LookupID)
        --AND (@LookupGroupID IS NULL OR L.LookupGroupID = @LookupGroupID)
		L.LookupID = ISNULL(@LookupID,'') OR L.LookupGroupID = iSNULL(@LookupGroupID,'')
    ORDER BY L.LookupID
    --OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;

GO


CREATE OR ALTER PROCEDURE sp_AddEditApplicant
    @ApplicantID INT = NULL,
    @FirstName NVARCHAR(50),
    @MiddleName NVARCHAR(50) = NULL,
    @LastName NVARCHAR(50),
    @IDNumber NVARCHAR(20),
    @ContactNumber NVARCHAR(15) = NULL,
    @Email NVARCHAR(100) = NULL,
    @SexID INT,
    @MaritalStatusID INT,
    @VillageID INT,
    @UserID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Applicants WHERE ApplicantID = @ApplicantID)
        BEGIN
            -- Declare variables to hold old values
            DECLARE 
                @OldFirstName NVARCHAR(50),
                @OldMiddleName NVARCHAR(50),
                @OldLastName NVARCHAR(50),
                @OldIDNumber NVARCHAR(20),
                @OldContactNumber NVARCHAR(15),
                @OldEmail NVARCHAR(100),
                @OldSexID INT,
                @OldMaritalStatusID INT,
                @OldVillageID INT;

            -- Single SELECT to get all old values
            SELECT 
                @OldFirstName = FirstName,
                @OldMiddleName = MiddleName,
                @OldLastName = LastName,
                @OldIDNumber = IDNumber,
                @OldContactNumber = ContactNumber,
                @OldEmail = Email,
                @OldSexID = SexID,
                @OldMaritalStatusID = MaritalStatusID,
                @OldVillageID = VillageID
            FROM Applicants
            WHERE ApplicantID = @ApplicantID;

            -- Build JSON only with changed fields
            DECLARE @Changes NVARCHAR(MAX) = '';
            SET @Changes = (
                SELECT 
                    CASE WHEN @OldFirstName <> @FirstName THEN JSON_QUERY('{"Field":"FirstName","OldValue":"' + ISNULL(@OldFirstName, '') + '"}') END FirstName,
                    CASE WHEN @OldMiddleName <> @MiddleName THEN JSON_QUERY('{"Field":"MiddleName","OldValue":"' + ISNULL(@OldMiddleName, '') + '"}') END MiddleName,
                    CASE WHEN @OldLastName <> @LastName THEN JSON_QUERY('{"Field":"LastName","OldValue":"' + ISNULL(@OldLastName, '') + '"}') END LastName,
                    CASE WHEN @OldIDNumber <> @IDNumber THEN JSON_QUERY('{"Field":"IDNumber","OldValue":"' + ISNULL(@OldIDNumber, '') + '"}') END IDNumber,
                    CASE WHEN @OldContactNumber <> @ContactNumber THEN JSON_QUERY('{"Field":"ContactNumber","OldValue":"' + ISNULL(@OldContactNumber, '') + '"}') END ContactNumber,
                    CASE WHEN @OldEmail <> @Email THEN JSON_QUERY('{"Field":"Email","OldValue":"' + ISNULL(@OldEmail, '') + '"}') END Email,
                    CASE WHEN @OldSexID <> @SexID THEN JSON_QUERY('{"Field":"SexID","OldValue":"' + CAST(ISNULL(@OldSexID, '') AS NVARCHAR) + '"}') END SexID,
                    CASE WHEN @OldMaritalStatusID <> @MaritalStatusID THEN JSON_QUERY('{"Field":"MaritalStatusID","OldValue":"' + CAST(ISNULL(@OldMaritalStatusID, '') AS NVARCHAR) + '"}') END MaritalStatusID,
                    CASE WHEN @OldVillageID <> @VillageID THEN JSON_QUERY('{"Field":"VillageID","OldValue":"' + CAST(ISNULL(@OldVillageID, '') AS NVARCHAR) + '"}') END VillageID 
                FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
            );

            -- Remove empty JSON array if no changes
            IF ISJSON(@Changes) = 1 AND LEN(@Changes) > 2
            BEGIN
                EXEC sp_LogChange 
                    @TableName = 'Applicants',
                    @RecordID = @ApplicantID,
                    @OldData = @Changes,
                    @ChangedBy = @UserID;
            END

            -- Update record
            UPDATE Applicants
            SET
                FirstName = @FirstName,
                MiddleName = @MiddleName,
                LastName = @LastName,
                IDNumber = @IDNumber,
                ContactNumber = @ContactNumber,
                Email = @Email,
                SexID = @SexID,
                MaritalStatusID = @MaritalStatusID,
                VillageID = @VillageID,
                ModifiedOn = GETDATE(),
                ModifiedBy = @UserID
            WHERE ApplicantID = @ApplicantID;
        END
        ELSE
        BEGIN
            -- Insert new record
            INSERT INTO Applicants (
                FirstName, MiddleName, LastName, IDNumber,
                ContactNumber, Email, SexID, MaritalStatusID, VillageID, CreatedBy
            )
            VALUES (
                @FirstName, @MiddleName, @LastName, @IDNumber,
                @ContactNumber, @Email, @SexID, @MaritalStatusID, @VillageID, @UserID
            );

            SET @ApplicantID = SCOPE_IDENTITY();
			SELECT @ApplicantID AS ApplicantID;
        END
    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        THROW 51004, 'An error occurred while saving applicant data.', 1;
    END CATCH
END;

GO


CREATE OR ALTER PROCEDURE sp_GetApplicants
    @ApplicantID	INT = NULL,
    @IDNumber		NVARCHAR(20) = NULL,
    @VillageID		INT = NULL,
    @PageNumber		INT = 1,
    @PageSize		INT = 10,
	@UserID			INT =NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
	DECLARE @TotalCount INT;		

    BEGIN TRY

		SELECT @TotalCount=COUNT(ApplicantID) FROM Applicants(nolock)
			LEFT JOIN Users A (nolock) ON Applicants.CreatedBy = A.UserID
			LEFT JOIN Users B (nolock) ON Applicants.ModifiedBy = B.UserID
        WHERE (@ApplicantID IS NULL OR ApplicantID = @ApplicantID) AND
            (@IDNumber IS NULL OR IDNumber = @IDNumber)

        SELECT 
            ApplicantID,
            FirstName,
            MiddleName,
            LastName,
            IDNumber,
            ContactNumber,
            Email,
            SexID,
            MaritalStatusID,
            VillageID,
            Applicants.CreatedOn,
            A.UserName AS CreatedBy,
            Applicants.ModifiedOn,
            B.UserName As ModifiedBy,
			@TotalCount TotalCount
        FROM Applicants(nolock)
			LEFT JOIN Users A (nolock) ON Applicants.CreatedBy = A.UserID
			LEFT JOIN Users B (nolock) ON Applicants.ModifiedBy = B.UserID
        WHERE 
            (@ApplicantID IS NULL OR ApplicantID = @ApplicantID) AND
            (@IDNumber IS NULL OR IDNumber = @IDNumber) --AND
            --(@VillageID IS NULL OR VillageID = @VillageID)
        ORDER BY ApplicantID DESC
        OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
    END TRY
    BEGIN CATCH
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        THROW 51002, 'An error occurred while retrieving applicant records.', 1;
    END CATCH
END;

GO

CREATE OR ALTER PROCEDURE sp_GetAddress
(
	@VillageID INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
    VillageID, VillageCode, VillageName, SubLocationID, SubLocationCode, SubLocationName, LocationID, LocationCode, LocationName, SubCountyID, SubCountyCode, SubCountyName, CountyID, CountyCode, CountyName
    FROM vw_Address
    WHERE 
        (@VillageID IS NULL OR VillageID = @VillageID)
    ORDER BY CountyName,SubCountyName,LocationName,SubLocationName,VillageName;
END;

GO

CREATE OR ALTER PROCEDURE sp_searchApplicant
    @ApplicantID	INT = NULL,
    @FirstName		NVARCHAR(100) = NULL,
    @MiddleName		NVARCHAR(100) = NULL,
    @LastName		NVARCHAR(100) = NULL,
    @IDNumber		NVARCHAR(50) = NULL,
    @ContactNumber	NVARCHAR(50) = NULL,
    @Email			NVARCHAR(100) = NULL,
    @SexID			INT = NULL,
    @MaritalStatusID INT = NULL,
    @VillageID		INT = NULL,
    @SubLocationID	INT = NULL,
    @LocationID		INT = NULL,
    @SubCountyID	INT = NULL,
    @CountyID		INT = NULL,
	@PageNumber		INT = 1,
    @PageSize		INT = 2
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
	DECLARE @TotalCount INT;

	SELECT @TotalCount=COUNT(ApplicantID) FROM vw_SearchApplicant
    WHERE
        (@ApplicantID IS NULL OR ApplicantID = @ApplicantID) AND
        (@FirstName IS NULL OR FirstName LIKE '%' + @FirstName + '%') AND
        (@MiddleName IS NULL OR ISNULL(MiddleName,'') LIKE '%' + @MiddleName + '%') AND
        (@LastName IS NULL OR LastName LIKE '%' + @LastName + '%') AND
        (ISNULL(@IDNumber,'') ='' OR IDNumber = @IDNumber) AND
        (ISNULL(@ContactNumber,'')='' OR ContactNumber = @ContactNumber) AND
        (@Email IS NULL OR Email LIKE '%' + @Email + '%') AND
        (@SexID IS NULL OR SexID = @SexID) AND
        (@MaritalStatusID IS NULL OR MaritalStatusID = @MaritalStatusID) AND
        (@VillageID IS NULL OR VillageID = @VillageID) AND
        (@SubLocationID IS NULL OR SubLocationID = @SubLocationID) AND
        (@LocationID IS NULL OR LocationID = @LocationID) AND
        (@SubCountyID IS NULL OR SubCountyID = @SubCountyID) AND
        (@CountyID IS NULL OR CountyID = @CountyID)

    SELECT ApplicantID,FirstName,MiddleName,LastName,IDNumber,ContactNumber,Email,SexID,MaritalStatusID,VillageID,CreatedOn,CreatedBy,ModifiedOn, ModifiedBy,
		SubLocationID, LocationID, SubCountyID,CountyID,@TotalCount TotalCount
    FROM vw_SearchApplicant
    WHERE
        (@ApplicantID IS NULL OR ApplicantID = @ApplicantID) AND
        (@FirstName IS NULL OR FirstName LIKE '%' + @FirstName + '%') AND
        (@MiddleName IS NULL OR ISNULL(MiddleName,'') LIKE '%' + @MiddleName + '%') AND
        (@LastName IS NULL OR LastName LIKE '%' + @LastName + '%') AND
        (ISNULL(@IDNumber,'') ='' OR IDNumber = @IDNumber) AND
        (ISNULL(@ContactNumber,'')='' OR ContactNumber = @ContactNumber) AND
        (@Email IS NULL OR Email LIKE '%' + @Email + '%') AND
        (@SexID IS NULL OR SexID = @SexID) AND
        (@MaritalStatusID IS NULL OR MaritalStatusID = @MaritalStatusID) AND
        (@VillageID IS NULL OR VillageID = @VillageID) AND
        (@SubLocationID IS NULL OR SubLocationID = @SubLocationID) AND
        (@LocationID IS NULL OR LocationID = @LocationID) AND
        (@SubCountyID IS NULL OR SubCountyID = @SubCountyID) AND
        (@CountyID IS NULL OR CountyID = @CountyID)
	ORDER BY ApplicantID DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;

GO

CREATE OR ALTER PROCEDURE sp_GetSpecificLookup
	@Codes NVARCHAR(1000) = NULL,
	@PageNumber INT = 1,
	@PageSize INT = 10
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        L.LookupID,
		L.LookupCode,
        L.LookupName,		
        L.LookupGroupID,
        G.LookupGroupCode,
        G.LookupGroupName
    FROM Lookups L
    INNER JOIN LookupGroup G ON L.LookupGroupID = G.LookupGroupID
    WHERE 
        G.LookupGroupCode IN (SELECT Value FROM dbo.SplitString(@Codes, ',')
    )
    ORDER BY LookupGroupID,L.LookupCode
END;

GO

CREATE OR ALTER PROCEDURE sp_AddEditApplication
    @ApplicationID	INT = NULL,  -- NULL for insert, value for update
    @ApplicantID	INT,
    @ApplicationDate DATE,
    @ApprovedBy		INT = NULL,
    @UserID			INT,
    @ProgrammesJSON NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now		DATETIME = GETDATE();
    DECLARE @IsInsert	BIT = IIF(@ApplicationID IS NULL, 1, 0);
    DECLARE @OldData	NVARCHAR(MAX) = '';
    DECLARE @NewApplicationID INT;
	DECLARE @Status		NVARCHAR(50)

	BEGIN TRY
		BEGIN TRANSACTION;
		-- Step 1: Insert or update Applications
		IF @IsInsert = 1
		BEGIN
			SET @Status='New';
			INSERT INTO Applications (ApplicantID, ApplicationDate, Status, ApprovedBy, CreatedOn, CreatedBy)
			VALUES (@ApplicantID, @ApplicationDate, @Status, @ApprovedBy, @Now, @UserID);

			SET @NewApplicationID = SCOPE_IDENTITY();
		END
		ELSE
		BEGIN
			-- Capture old values for comparison
			DECLARE @OldApplicantID INT, @OldAppDate DATE, @OldStatus NVARCHAR(50), @OldApprovedBy INT;
			SELECT 
				@OldApplicantID = ApplicantID,
				@OldAppDate = ApplicationDate,
				--@OldStatus = [Status],
				@OldApprovedBy = ApprovedBy
			FROM Applications(nolock) WHERE ApplicationID = @ApplicationID;

			SET @OldData = (
					SELECT 
						CASE WHEN @OldApplicantID <> @ApplicantID THEN JSON_QUERY('{"Field":"ApplicantID","OldValue":"' + CAST(@OldApplicantID AS NVARCHAR) + '"}') END ApplicantID,
						CASE WHEN @OldAppDate <> @ApplicationDate THEN JSON_QUERY('{"Field":"ApplicationDate","OldValue":"' + CONVERT(NVARCHAR,@OldAppDate,120) + '"}') END ApplicationDate,
						--CASE WHEN @OldStatus <> @Status THEN JSON_QUERY('{"Field":"Status","OldValue":"' + ISNULL(@OldStatus, '') + '"}') END [Status],
						CASE WHEN ISNULL(@OldApprovedBy, 0) <> ISNULL(@ApprovedBy, 0) THEN JSON_QUERY('{"Field":"ApprovedBy","OldValue":"' + CAST(@OldApprovedBy AS NVARCHAR)  + '"}') END ApprovedBy
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				);

			UPDATE Applications
			SET ApplicantID = @ApplicantID,
				ApplicationDate = @ApplicationDate,
				--Status = @Status,
				ApprovedBy = @ApprovedBy,
				ModifiedOn = @Now,
				ModifiedBy = @UserID
			WHERE ApplicationID = @ApplicationID;

			SET @NewApplicationID = @ApplicationID;

			IF ISJSON(@OldData) = 1 AND LEN(@OldData) > 2
			BEGIN
				SET @OldData = LEFT(@OldData, LEN(@OldData) - 1); -- trim last comma
				EXEC sp_LogChange @TableName = 'Applications', @RecordID = @ApplicationID, @OldData = @OldData, @ChangedBy = @UserID;
			END
		END

		-- Step 2: Handle Application_Programme
		-- Create a table variable to parse the JSON
		DECLARE @Programmes TABLE (
			ProgrammeID INT,
			Narration NVARCHAR(100),
			CreatedBy INT
		);

		INSERT INTO @Programmes (ProgrammeID, Narration, CreatedBy)
		SELECT ProgrammeID, Narration, CreatedBy
		FROM OPENJSON(@ProgrammesJSON)
		WITH (
			ProgrammeID INT,
			Narration NVARCHAR(100),
			CreatedBy INT
		);

		-- Delete programmes not in the new list
		DELETE FROM Application_Programme
		WHERE ApplicationID = @NewApplicationID
		  AND ProgrammeID NOT IN (SELECT ProgrammeID FROM @Programmes);

		-- Insert or update entries
		MERGE Application_Programme AS TARGET
		USING (
			SELECT ProgrammeID, Narration, CreatedBy FROM @Programmes
		) AS SOURCE
		ON TARGET.ApplicationID = @NewApplicationID AND TARGET.ProgrammeID = SOURCE.ProgrammeID
		WHEN MATCHED THEN
			UPDATE SET 
				Narration = SOURCE.Narration,
				ModifiedOn = @Now,
				ModifiedBy = @UserID
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (ApplicationID, ProgrammeID, Narration, CreatedOn, CreatedBy)
			VALUES (@NewApplicationID, SOURCE.ProgrammeID, SOURCE.Narration, @Now, @UserID);

		-- Optional: Log updates to Application_Programme (simplified logging)
		DECLARE @ProgChanges NVARCHAR(MAX);

		SELECT @ProgChanges = STRING_AGG(CONCAT('ProgrammeID=', ProgrammeID, ' updated/added'), '; ')
		FROM @Programmes;

		IF @ProgChanges IS NOT NULL
		BEGIN
			EXEC sp_LogChange @TableName = 'Application_Programme', @RecordID = @NewApplicationID, @OldData = @ProgChanges, @ChangedBy = @UserID;
		END
	        
		COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT, @ErrState INT;
        SELECT 
            @ErrMsg = ERROR_MESSAGE(), 
            @ErrSeverity = ERROR_SEVERITY(), 
            @ErrState = ERROR_STATE();

        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
    END CATCH
END

GO

CREATE OR ALTER PROCEDURE sp_GetApplicationProgrammes
    @ApplicationID INT = NULL,
    @UserID INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

	SELECT 
		PR.ProgrammeID,
		PR.ProgrammeCode,
		PR.ProgrammeName,
		APG.AppProgrammeID,
		CAST(IIF(APG.AppProgrammeID IS NULL, 0, 1) AS BIT) AS Applied,
		APG.ApplicationID,
		APG.Narration,
		APG.CreatedOn,
		C.UserName CreatedBy,
		APG.ModifiedOn,
		M.UserName ModifiedBy
	FROM Application_Programme APG
	RIGHT JOIN Programme PR ON APG.ProgrammeID = PR.ProgrammeID 
	AND APG.ApplicationID = @ApplicationID
	LEFT JOIN Users C ON APG.CreatedBy=C.UserID
	LEFT JOIN Users M ON APG.CreatedBy=M.UserID
    ORDER BY ProgrammeID;

END

GO

CREATE OR ALTER PROCEDURE sp_GetApplication
    @ApplicationID	INT = NULL,  -- Optional filter
	@UserID			INT = NULL,
	@PageNumber		INT = 1,
    @PageSize		INT = 10	
AS
BEGIN
    SET NOCOUNT ON;

    -- Calculate offset
    DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
	DECLARE @TotalCount INT;

	SELECT @TotalCount = COUNT(A.ApplicationID)
	FROM Applications A
	WHERE @ApplicationID IS NULL OR A.ApplicationID = @ApplicationID;

    SELECT 
        A.ApplicationID,
        A.ApplicantID,
       CONCAT(FirstName, ' ',MiddleName,' ', LastName) AS FullName,
        AP.IDNumber,         -- Replace as appropriate
		AP.ContactNumber,
        AP.Email,              -- Replace as appropriate
        A.ApplicationDate,
        A.Status,
        R.UserName ApprovedBy,
        A.CreatedOn,
        C.UserName CreatedBy,
        A.ModifiedOn,
        M.UserName ModifiedBy,
		(SELECT APG.AppProgrammeID,
				A.ApplicationID,
                APG.ProgrammeID,
                APG.Narration,
                APG.CreatedOn,
                --APG.CreatedBy,
                APG.ModifiedOn
                --APG.ModifiedBy
            FROM Application_Programme APG
            WHERE APG.ApplicationID = A.ApplicationID
            FOR JSON PATH
        ) AS Programmes,
		@TotalCount TotalCount
    FROM Applications A
		INNER JOIN Applicants AP ON A.ApplicantID = AP.ApplicantID
		LEFT JOIN Users C ON A.CreatedBy=C.UserID
		LEFT JOIN Users M ON A.CreatedBy=M.UserID
		LEFT JOIN Users R ON A.CreatedBy=R.UserID
    WHERE 
        @ApplicationID IS NULL OR A.ApplicationID = @ApplicationID
    ORDER BY 
        A.ApplicationDate DESC
    OFFSET @Offset ROWS
    FETCH NEXT @PageSize ROWS ONLY;
END

GO

CREATE OR ALTER PROCEDURE sp_searchApplication
	@ApplicationID	INT = NULL,
    @ApplicantID	INT = NULL,
	@ApplicationDate	DATE = NULL,
    @FirstName		NVARCHAR(100) = NULL,
    @MiddleName		NVARCHAR(100) = NULL,
    @LastName		NVARCHAR(100) = NULL,
    @IDNumber		NVARCHAR(50) = NULL,
    @ContactNumber	NVARCHAR(50) = NULL,
    @Email			NVARCHAR(100) = NULL,
    @SexID			INT = NULL,
    @MaritalStatusID INT = NULL,
    @VillageID		INT = NULL,
    @SubLocationID	INT = NULL,
    @LocationID		INT = NULL,
    @SubCountyID	INT = NULL,
    @CountyID		INT = NULL,
	@UserID			INT = NULL,
	@PageNumber		INT = 1,
    @PageSize		INT = 2
AS
BEGIN
    SET NOCOUNT ON;

	DECLARE @Offset INT = (@PageNumber - 1) * @PageSize;
	DECLARE @TotalCount	INT;

	SELECT @TotalCount = COUNT(ApplicationID)
    FROM vw_SearchApplications
    WHERE
		(@ApplicationID IS NULL OR ApplicationID = @ApplicationID) AND
        (@ApplicantID IS NULL OR ApplicantID = @ApplicantID) AND
        (@FirstName IS NULL OR FirstName LIKE '%' + @FirstName + '%') AND
        (@MiddleName IS NULL OR ISNULL(MiddleName,'') LIKE '%' + @MiddleName + '%') AND
        (@LastName IS NULL OR LastName LIKE '%' + @LastName + '%') AND
        (ISNULL(@IDNumber,'') ='' OR IDNumber = @IDNumber) AND
        (ISNULL(@ContactNumber,'')='' OR ContactNumber = @ContactNumber) AND
        (@Email IS NULL OR Email LIKE '%' + @Email + '%') AND
        (@SexID IS NULL OR SexID = @SexID) AND
        (@MaritalStatusID IS NULL OR MaritalStatusID = @MaritalStatusID) AND
        (@VillageID IS NULL OR VillageID = @VillageID) AND
        (@SubLocationID IS NULL OR SubLocationID = @SubLocationID) AND
        (@LocationID IS NULL OR LocationID = @LocationID) AND
        (@SubCountyID IS NULL OR SubCountyID = @SubCountyID) AND
        (@CountyID IS NULL OR CountyID = @CountyID);

    SELECT ApplicationID,ApplicantID,ApplicationDate,FirstName,MiddleName,LastName,IDNumber,ContactNumber,Email,SexID,MaritalStatusID,VillageID,CreatedOn,CreatedBy,ModifiedOn, ModifiedBy,
		SubLocationID, LocationID, SubCountyID,CountyID, @TotalCount TotalCount
    FROM vw_SearchApplications
    WHERE
        (@ApplicantID IS NULL OR ApplicantID = @ApplicantID) AND
        (@FirstName IS NULL OR FirstName LIKE '%' + @FirstName + '%') AND
        (@MiddleName IS NULL OR ISNULL(MiddleName,'') LIKE '%' + @MiddleName + '%') AND
        (@LastName IS NULL OR LastName LIKE '%' + @LastName + '%') AND
        (ISNULL(@IDNumber,'') ='' OR IDNumber = @IDNumber) AND
        (ISNULL(@ContactNumber,'')='' OR ContactNumber = @ContactNumber) AND
        (@Email IS NULL OR Email LIKE '%' + @Email + '%') AND
        (@SexID IS NULL OR SexID = @SexID) AND
        (@MaritalStatusID IS NULL OR MaritalStatusID = @MaritalStatusID) AND
        (@VillageID IS NULL OR VillageID = @VillageID) AND
        (@SubLocationID IS NULL OR SubLocationID = @SubLocationID) AND
        (@LocationID IS NULL OR LocationID = @LocationID) AND
        (@SubCountyID IS NULL OR SubCountyID = @SubCountyID) AND
        (@CountyID IS NULL OR CountyID = @CountyID)
	ORDER BY ApplicationID DESC
    OFFSET @Offset ROWS FETCH NEXT @PageSize ROWS ONLY;
END;

GO

CREATE OR ALTER PROCEDURE sp_GetProgrammes
    @ProgrammeID	INT = NULL,
    @UserID			INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        ProgrammeID,
        ProgrammeCode,
        ProgrammeName,
        CreatedOn,
        CreatedBy,
        ModifiedOn,
        ModifiedBy
    FROM 
        Programme
    WHERE IsActive = 1 AND
        (@ProgrammeID IS NULL OR ProgrammeID = @ProgrammeID)
    ORDER BY 
        ProgrammeID;
END

GO

CREATE OR ALTER PROCEDURE sp_ApplicationApproval
    @ApplicationID	INT,
	@Status			NVARCHAR(50),
    @UserID			INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Now		DATETIME = GETDATE();
    DECLARE @OldData	NVARCHAR(MAX) = '';

	BEGIN TRY
		BEGIN TRANSACTION;

				-- Capture old values for comparison
			DECLARE @OldStatus NVARCHAR(50), @OldApprovedBy INT, @OldApprovedDate DATETIME;
			SELECT	@OldStatus = [Status],
					@OldApprovedBy = ApprovedBy,
					@OldApprovedDate = ApprovedDate
			FROM Applications(nolock) WHERE ApplicationID = @ApplicationID;

			SET @OldData = (
					SELECT 
						CASE WHEN @OldStatus <> @Status THEN JSON_QUERY('{"Field":"Status","OldValue":"' + ISNULL(@OldStatus, '') + '"}') END [Status],
						CASE WHEN ISNULL(@OldApprovedBy, 0) <> ISNULL(@UserID, 0) THEN JSON_QUERY('{"Field":"ApprovedBy","OldValue":"' + CAST(@OldApprovedBy AS NVARCHAR)  + '"}') END ApprovedBy,
						CASE WHEN ISNULL(@OldApprovedDate, @Now) <> @Now THEN JSON_QUERY('{"Field":"ApprovedDate","OldValue":"' + CAST(@OldApprovedDate AS NVARCHAR)  + '"}') END ApprovedDate
					FOR JSON PATH, WITHOUT_ARRAY_WRAPPER
				);

			IF ISJSON(@OldData) = 1 AND LEN(@OldData) > 2
			BEGIN
				SET @OldData = LEFT(@OldData, LEN(@OldData) - 1); -- trim last comma
				EXEC sp_LogChange @TableName = 'Applications', @RecordID = @ApplicationID, @OldData = @OldData, @ChangedBy = @UserID;
			END

			UPDATE Applications 
				SET Status= @Status,
					ApprovedBy= @UserID,
					ApprovedDate = @Now,
					ModifiedOn =@Now
			WHERE ApplicationID=@ApplicationID;

			COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE @ErrMsg NVARCHAR(4000), @ErrSeverity INT, @ErrState INT;
        SELECT 
            @ErrMsg = ERROR_MESSAGE(), 
            @ErrSeverity = ERROR_SEVERITY(), 
            @ErrState = ERROR_STATE();

        RAISERROR(@ErrMsg, @ErrSeverity, @ErrState);
    END CATCH

END

GO

CREATE OR ALTER PROCEDURE rpt_Applicants
	@FromDate		Date = NULL,
	@ToDate			Date = NULL,
    @SexID			INT = NULL,
    @MaritalStatusID INT = NULL,
    @VillageID		INT = NULL,
    @SubLocationID	INT = NULL,
    @LocationID		INT = NULL,
    @SubCountyID	INT = NULL,
    @CountyID		INT = NULL,
	@UserID			INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT ApplicantID,FirstName,ISNULL(MiddleName,'') MiddleName,LastName,IDNumber,ContactNumber,Email/*,SexID,MaritalStatusID,VillageID,CreatedOn,CreatedBy,ModifiedOn, ModifiedBy,
		SubLocationID, LocationID, SubCountyID,CountyID,*/
    FROM vw_SearchApplicant
    /*WHERE
		CAST(CreatedOn AS DATE) BETWEEN @FromDate AND @ToDate AND
        (@SexID IS NULL OR SexID = @SexID) AND
        (@MaritalStatusID IS NULL OR MaritalStatusID = @MaritalStatusID) AND
        (@VillageID IS NULL OR VillageID = @VillageID) AND
        (@SubLocationID IS NULL OR SubLocationID = @SubLocationID) AND
        (@LocationID IS NULL OR LocationID = @LocationID) AND
        (@SubCountyID IS NULL OR SubCountyID = @SubCountyID) AND
        (@CountyID IS NULL OR CountyID = @CountyID)*/
	ORDER BY ApplicantID;
END;

GO

--exec rpt_Applicants @FromDate=N'2025-05-30',@ToDate=N'2025-05-31',@CountyID=N'3',@SubCountyID=N'2',@LocationID=N'7',@SubLocationID=N'4',@VillageID=N'8',@SexID=N'2',@MaritalStatusID=N'4'
