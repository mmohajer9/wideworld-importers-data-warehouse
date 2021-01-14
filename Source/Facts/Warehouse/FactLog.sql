use [WWI-DW];
GO


IF OBJECT_ID('dbo.FactLog', 'U') IS NOT NULL
DROP TABLE dbo.FactLog
GO

CREATE TABLE FactLog
(
    [FactLogID] INT IDENTITY(1 , 1) PRIMARY KEY,
    [ProcedureName] NVARCHAR(500),
    [Action] NVARCHAR(500),
    [FactName] NVARCHAR(500),
    [Datetime] DATETIME2(7),
    [AffectedRowsNumber] INT
);
GO


CREATE OR ALTER PROCEDURE AddFactLog

    @procedure_name NVARCHAR(500) = "UNDEFINED",
    @action NVARCHAR(500) = "UNDEFINED",
    @FactName NVARCHAR(500) = "UNDEFINED",
    @Datetime DATETIME2,
    @AffectedRowsNumber INT = 0
AS
BEGIN

    INSERT INTO FactLog
        (
        [ProcedureName],
        [Action],
        [FactName],
        [Datetime],
        [AffectedRowsNumber]
        )
    VALUES
        (
            @procedure_name,
            @action,
            @FactName,
            @Datetime,
            @AffectedRowsNumber        
    );

END
--------------------------------------------------------------------------------------------------------------
GO