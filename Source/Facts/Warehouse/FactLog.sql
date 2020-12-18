IF OBJECT_ID('dbo.FactLog', 'U') IS NOT NULL
DROP TABLE dbo.FactLog
GO

CREATE TABLE FactLog
(
    [FactLogID] INT IDENTITY(1 , 1) NOT NULL PRIMARY KEY,
    [ProcedureName] NVARCHAR(500) NOT NULL,
    [Action] NVARCHAR(500) NOT NULL,
    [FactName] NVARCHAR(500) NOT NULL,
    [Datetime] DATETIME2(7) NOT NULL,
    [AffectedRowsNumber] INT NOT NULL
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