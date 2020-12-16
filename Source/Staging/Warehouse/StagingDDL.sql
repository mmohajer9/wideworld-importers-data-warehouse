-- Create a new table called 'StagingStockItems' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingStockItems', 'U') IS NOT NULL
DROP TABLE dbo.StagingStockItems
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingStockItems
(
    StagingStockItemsId INT NOT NULL PRIMARY KEY, -- primary key column
    Column1 [NVARCHAR](50) NOT NULL,
    Column2 [NVARCHAR](50) NOT NULL
    -- specify more columns here
);
GO


-- Create a new table called 'StagingStockItemHoldings' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingStockItemHoldings', 'U') IS NOT NULL
DROP TABLE dbo.StagingStockItemHoldings
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingStockItemHoldings
(
    StagingStockItemsId INT NOT NULL PRIMARY KEY, -- primary key column
    Column1 [NVARCHAR](50) NOT NULL,
    Column2 [NVARCHAR](50) NOT NULL
    -- specify more columns here
);
GO


-- Create a new table called 'StagingStockGroups' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingStockGroups', 'U') IS NOT NULL
DROP TABLE dbo.StagingStockGroups
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingStockGroups
(
    StagingStockItemsId INT NOT NULL PRIMARY KEY, -- primary key column
    Column1 [NVARCHAR](50) NOT NULL,
    Column2 [NVARCHAR](50) NOT NULL
    -- specify more columns here
);
GO


-- Create a new table called 'StagingStockItemStockGroups' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingStockItemStockGroups', 'U') IS NOT NULL
DROP TABLE dbo.StagingStockItemStockGroups
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingStockItemStockGroups
(
    StagingStockItemsId INT NOT NULL PRIMARY KEY, -- primary key column
    Column1 [NVARCHAR](50) NOT NULL,
    Column2 [NVARCHAR](50) NOT NULL
    -- specify more columns here
);
GO



-- Create a new table called 'StagingPackageTypes' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingPackageTypes', 'U') IS NOT NULL
DROP TABLE dbo.StagingPackageTypes
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingPackageTypes
(
    StagingStockItemsId INT NOT NULL PRIMARY KEY, -- primary key column
    Column1 [NVARCHAR](50) NOT NULL,
    Column2 [NVARCHAR](50) NOT NULL
    -- specify more columns here
);
GO


-- Create a new table called 'StagingColors' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingColors', 'U') IS NOT NULL
DROP TABLE dbo.StagingColors
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingColors
(
    StagingStockItemsId INT NOT NULL PRIMARY KEY, -- primary key column
    Column1 [NVARCHAR](50) NOT NULL,
    Column2 [NVARCHAR](50) NOT NULL
    -- specify more columns here
);
GO


-- Create a new table called 'StagingTransactionTypes' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingTransactionTypes', 'U') IS NOT NULL
DROP TABLE dbo.StagingTransactionTypes
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingTransactionTypes
(
    StagingStockItemsId INT NOT NULL PRIMARY KEY, -- primary key column
    Column1 [NVARCHAR](50) NOT NULL,
    Column2 [NVARCHAR](50) NOT NULL
    -- specify more columns here
);
GO