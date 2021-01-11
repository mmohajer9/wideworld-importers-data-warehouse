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
    [StockItemID] [int],
    [StockItemName] [nvarchar](100),
    [SupplierID] [int],
    [ColorID] [int] ,
    [UnitPackageID] [int],
    [OuterPackageID] [int],
    [Brand] [nvarchar](50) ,
    [Size] [nvarchar](20) ,

    -- [LeadTimeDays] [int],
    -- [QuantityPerOuter] [int],

    [IsChillerStock] [nvarchar](20), --^ prev type : bit field
    [Barcode] [nvarchar](50) ,
    [TaxRate] [decimal](18, 3),
    [UnitPrice] [decimal](18, 2),
    [RecommendedRetailPrice] [decimal](18, 2) ,
    [TypicalWeightPerUnit] [decimal](18, 3),
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
    [StockItemID] [int],
    [QuantityOnHand] [int],
    [BinLocation] [nvarchar](20),
    [LastStocktakeQuantity] [int],
    [LastCostPrice] [decimal](18, 2),
    [ReorderLevel] [int],
    [TargetStockLevel] [int],
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
    [StockGroupID] [int],
    [StockGroupName] [nvarchar](50),
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
    [StockItemStockGroupID] [int],
    [StockItemID] [int],
    [StockGroupID] [int],
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
    [PackageTypeID] [int],
    [PackageTypeName] [nvarchar](50),
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
    [ColorID] [int],
    [ColorName] [nvarchar](20),
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
	[TransactionTypeID] [int],
	[TransactionTypeName] [nvarchar](50),
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

	[StockItemTransactionID] [int],
	[StockItemID] [int],
	[TransactionTypeID] [int],
	[CustomerID] [int] ,
	[InvoiceID] [int] ,
	[SupplierID] [int] ,
	[PurchaseOrderID] [int] ,
	[TransactionOccurredWhen] [DATE],
	[Quantity] [decimal](18, 3),
);
GO