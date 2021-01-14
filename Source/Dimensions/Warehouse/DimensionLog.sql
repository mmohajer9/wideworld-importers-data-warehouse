IF OBJECT_ID('dbo.DimensionLog', 'U') IS NOT NULL
DROP TABLE dbo.DimensionLog
GO

CREATE TABLE DimensionLog
(
    [DimensionLogID] INT IDENTITY(1 , 1) PRIMARY KEY,
    [ProcedureName] NVARCHAR(500),
    [Action] NVARCHAR(500),
    [DimensionName] NVARCHAR(500),
    [Datetime] DATETIME2(7),
    [AffectedRowsNumber] INT
);
GO


CREATE OR ALTER PROCEDURE AddDimensionLog

    @procedure_name NVARCHAR(500) = "UNDEFINED",
    @action NVARCHAR(500) = "UNDEFINED",
    @DimensionName NVARCHAR(500) = "UNDEFINED",
    @Datetime DATETIME2,
    @AffectedRowsNumber INT = 0
AS
BEGIN

    INSERT INTO DimensionLog
        (
        [ProcedureName],
        [Action],
        [DimensionName],
        [Datetime],
        [AffectedRowsNumber]
        )
    VALUES
        (
            @procedure_name,
            @action,
            @DimensionName,
            @Datetime,
            @AffectedRowsNumber        
    );

END
--------------------------------------------------------------------------------------------------------------
GO