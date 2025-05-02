CREATE OR ALTER FUNCTION dbo.SplitString
(
    @Input NVARCHAR(MAX),
    @Delimiter CHAR(1)
)
RETURNS @Output TABLE (Value NVARCHAR(100))
AS
BEGIN
    DECLARE @Start INT = 1, @End INT

    SET @Input = @Input + @Delimiter

    WHILE CHARINDEX(@Delimiter, @Input, @Start) > 0
    BEGIN
        SET @End = CHARINDEX(@Delimiter, @Input, @Start)
        INSERT INTO @Output(Value)
        VALUES(LTRIM(RTRIM(SUBSTRING(@Input, @Start, @End - @Start))))
        SET @Start = @End + 1
    END

    RETURN
END

GO
