use [WWI-Staging];
GO

IF OBJECT_ID('dbo.StagingLog', 'U') IS NOT NULL
DROP TABLE dbo.StagingLog
GO

CREATE TABLE StagingLog
(
    [StagingLogID] INT IDENTITY(1 , 1) PRIMARY KEY,
    [ProcedureName] NVARCHAR(500),
    [Action] NVARCHAR(500),
    [TargetTable] NVARCHAR(500),
    [Datetime] DATETIME2(7),
    [AffectedRowsNumber] INT
);
GO


CREATE OR ALTER PROCEDURE AddStagingLog

    @procedure_name NVARCHAR(500) = "UNDEFINED",
    @action NVARCHAR(500) = "UNDEFINED",
    @TargetTable NVARCHAR(500) = "UNDEFINED",
    @Datetime DATETIME2,
    @AffectedRowsNumber INT = 0
AS
BEGIN

    INSERT INTO StagingLog
        (
        [ProcedureName],
        [Action],
        [TargetTable],
        [Datetime],
        [AffectedRowsNumber]
        )
    VALUES
        (
            @procedure_name,
            @action,
            @TargetTable,
            @Datetime,
            @AffectedRowsNumber        
    );

END
--------------------------------------------------------------------------------------------------------------
GO