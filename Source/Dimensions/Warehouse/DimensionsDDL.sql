-- Create a new table called 'DimStockGroup' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.DimStockGroup', 'U') IS NOT NULL
DROP TABLE dbo.DimStockGroup
GO
-- Create the table in the specified schema
CREATE TABLE dbo.DimStockGroup
(
    -- primary key column
    StockGroupID INT PRIMARY KEY,
    StockGroupName [NVARCHAR](100)
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
    -- primary key column
    PackageTypeID INT PRIMARY KEY,
    PackageTypeName [NVARCHAR](100)
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
    -- primary key column
    TransactionTypeID INT PRIMARY KEY,
    TransactionTypeName [NVARCHAR](100)
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
    -- primary key column
    ColorID INT PRIMARY KEY,
    ColorName [NVARCHAR](100)
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
    -- primary key column
    StockItemID INT PRIMARY KEY,
    StockItemName [NVARCHAR](200),

    --^ columns from stockitems
    [SupplierID] [int],
    [SupplierName] [NVARCHAR](100), --^ added for more details
    
    Brand [NVARCHAR](100),
    Size [NVARCHAR](50),
    IsChillerStock [NVARCHAR](10), --^ in source it was bit field => changed to nvarchar
    Barcode [NVARCHAR](100),

    ColorID INT,
    ColorName [NVARCHAR](100) ,

    UnitPackageTypeID INT,
    UnitPackageTypeName [NVARCHAR](100),

    OuterPackageTypeID INT,
    OuterPackageTypeName [NVARCHAR](100),
    --* some numeric columns

    TaxRate [NUMERIC](20 , 3),

    --& SCD Type 3
    OriginalUnitPrice [NUMERIC](20 , 3),
    CurrentUnitPrice [NUMERIC](20 , 3),
    UnitPriceEffectiveDate [DATE],
    --& SCD Type 3


    RecommendedRetailPrice [NUMERIC](20 , 3),
    TypicalWeightPerUnit [NUMERIC](20 , 3),

    --^ columns from stockitemholdings

    LastCostPrice [NUMERIC](20 , 3),
    QuantityOnHand INT,
    LastStocktakeQuantity INT,

    TargetStockLevel INT,
    ReorderLevel INT,

    --& SCD Type 3
    OriginalBinLocation [NVARCHAR](40),
    CurrentBinLocation [NVARCHAR](40),
    BinLocationEffectiveDate [DATE],
    --& SCD Type 3



);
GO




--& Date --> derakhshan *
--& Customer --> derakhshan
--& Invoice --> derakhshan
--& Payment Method --> Derakhshan

--^ Supplier --> javad
--^ PurchaseOrder --> javad

--? Transaction Types --> Mamad
