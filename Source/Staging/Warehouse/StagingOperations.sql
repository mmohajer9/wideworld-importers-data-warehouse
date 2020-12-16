-- Create a new stored procedure called 'FillStagingStockItems' in schema 'dbo'
-- Drop the stored procedure if it already exists
IF EXISTS (
SELECT *
    FROM INFORMATION_SCHEMA.ROUTINES
WHERE SPECIFIC_SCHEMA = N'dbo'
    AND SPECIFIC_NAME = N'FillStagingStockItems'
)
DROP PROCEDURE dbo.FillStagingStockItems
GO
-- Create the stored procedure in the specified schema
CREATE PROCEDURE dbo.FillStagingStockItems
    -- @param1 /*parameter name*/ int /*datatype_for_param1*/ = 0, /*default_value_for_param1*/
    -- @param2 /*parameter name*/ int /*datatype_for_param1*/ = 0 /*default_value_for_param2*/
-- add more stored procedure parameters here
AS
    -- body of the stored procedure
    
GO

EXECUTE dbo.FillStagingStockItems;

GO