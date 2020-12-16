-- Create a new table called 'DimStockGroup' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.DimStockGroup', 'U') IS NOT NULL
DROP TABLE dbo.DimStockGroup
GO
-- Create the table in the specified schema
CREATE TABLE dbo.DimStockGroup
(
    StockGroupID INT NOT NULL PRIMARY KEY,
    -- primary key column
    StockGroupName [NVARCHAR](100) NOT NULL
    -- specify more columns here
);
GO


-- Create a new table called 'DimPackageTypes' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.DimPackageTypes', 'U') IS NOT NULL
DROP TABLE dbo.DimPackageTypes
GO
-- Create the table in the specified schema
CREATE TABLE dbo.DimPackageTypes
(
    PackageTypeID INT NOT NULL PRIMARY KEY,
    -- primary key column
    PackageTypeName [NVARCHAR](100) NOT NULL
    -- specify more columns here
);
GO



-- Create a new table called 'DimTransactionTypes' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.DimTransactionTypes', 'U') IS NOT NULL
DROP TABLE dbo.DimTransactionTypes
GO
-- Create the table in the specified schema
CREATE TABLE dbo.DimTransactionTypes
(
    TransactionTypeID INT NOT NULL PRIMARY KEY,
    -- primary key column
    TransactionTypeName [NVARCHAR](100) NOT NULL
    -- specify more columns here
);
GO


-- Create a new table called 'DimColors' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.DimColors', 'U') IS NOT NULL
DROP TABLE dbo.DimColors
GO
-- Create the table in the specified schema
CREATE TABLE dbo.DimColors
(
    ColorID INT NOT NULL PRIMARY KEY,
    -- primary key column
    ColorName [NVARCHAR](100) NOT NULL
    -- specify more columns here
);
GO

-- Create a new table called 'DimStockItems' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.DimStockItems', 'U') IS NOT NULL
DROP TABLE dbo.DimStockItems
GO
-- Create the table in the specified schema
CREATE TABLE dbo.DimStockItems
(
    StockItemID INT NOT NULL,
    -- primary key column
    StockItemName [NVARCHAR](100) NOT NULL,

    --^ columns from stockitems

    Brand [NVARCHAR](100),
    Size [NVARCHAR](50),
    IsChillerStock BIT NOT NULL,
    Barcode [NVARCHAR](100),

    --* some numeric columns

    TaxRate [NUMERIC](20 , 3) NOT NULL,
    UnitPrice [NUMERIC](20 , 3) NOT NULL,
    RecommendedRetailPrice [NUMERIC](20 , 3),
    TypicalWeightPerUnit [NUMERIC](20 , 3) NOT NULL,

    --^ columns from stockitemholdings


    --& SCD Type 3
    OriginalBinLocation [NVARCHAR](40) NOT NULL,
    CurrentBinLocation [NVARCHAR](40) NOT NULL,
    EffectiveDate [DATE] NOT NULL,
    --& SCD Type 3

    LastCostPrice [NUMERIC](20 , 3) NOT NULL,
    QuantityOnHand INT NOT NULL,
    LastStocktakeQuantity INT NOT NULL,

    TargetStockLevel INT NOT NULL,
    ReorderLevel INT NOT NULL,

);
GO




--& Date --> derakhshan *
--& Customer --> derakhshan
--& Invoice --> derakhshan
--& Payment Method --> Derakhshan

--^ Supplier --> javad
--^ PurchaseOrder --> javad

--? Transaction Types --> Mamad
