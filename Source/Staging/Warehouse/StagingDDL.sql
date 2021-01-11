use [WWI-Staging];
GO


-- Create a new table called 'StagingStockItems' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingStockItems', 'U') IS NOT NULL
DROP TABLE dbo.StagingStockItems
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingStockItems
(
    [StockItemID] [int] NOT NULL,
    [StockItemName] [nvarchar](100) NOT NULL,
    [SupplierID] [int] NOT NULL,
    [ColorID] [int] NULL,
    [UnitPackageID] [int] NOT NULL,
    [OuterPackageID] [int] NOT NULL,
    [Brand] [nvarchar](50) NULL,
    [Size] [nvarchar](20) NULL,

    -- [LeadTimeDays] [int] NOT NULL,
    -- [QuantityPerOuter] [int] NOT NULL,

    [IsChillerStock] [bit] NOT NULL,
    [Barcode] [nvarchar](50) NULL,
    [TaxRate] [decimal](18, 3) NOT NULL,
    [UnitPrice] [decimal](18, 2) NOT NULL,
    [RecommendedRetailPrice] [decimal](18, 2) NULL,
    [TypicalWeightPerUnit] [decimal](18, 3) NOT NULL,
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
    [StockItemID] [int] NOT NULL,
    [QuantityOnHand] [int] NOT NULL,
    [BinLocation] [nvarchar](20) NOT NULL,
    [LastStocktakeQuantity] [int] NOT NULL,
    [LastCostPrice] [decimal](18, 2) NOT NULL,
    [ReorderLevel] [int] NOT NULL,
    [TargetStockLevel] [int] NOT NULL,
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
    [StockGroupID] [int] NOT NULL,
    [StockGroupName] [nvarchar](50) NOT NULL,
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
    [StockItemStockGroupID] [int] NOT NULL,
    [StockItemID] [int] NOT NULL,
    [StockGroupID] [int] NOT NULL,
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
    [PackageTypeID] [int] NOT NULL,
    [PackageTypeName] [nvarchar](50) NOT NULL,
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
    [ColorID] [int] NOT NULL,
    [ColorName] [nvarchar](20) NOT NULL,
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
	[TransactionTypeID] [int] NOT NULL,
	[TransactionTypeName] [nvarchar](50) NOT NULL,
);
GO



-- Create a new table called 'StagingStockItemTransactions' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StagingStockItemTransactions', 'U') IS NOT NULL
DROP TABLE dbo.StagingStockItemTransactions
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StagingStockItemTransactions
(

    --^ FIXME: NOTE THIS TABLE --> INCREMENTAL APPROACH

	[StockItemTransactionID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[TransactionTypeID] [int] NOT NULL,
	[CustomerID] [int] NULL,
	[InvoiceID] [int] NULL,
	[SupplierID] [int] NULL,
	[PurchaseOrderID] [int] NULL,
	[TransactionOccurredWhen] [DATE] NOT NULL,
	[Quantity] [decimal](18, 3) NOT NULL,
);
GO