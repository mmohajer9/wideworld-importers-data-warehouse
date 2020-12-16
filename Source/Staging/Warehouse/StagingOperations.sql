CREATE OR ALTER PROCEDURE FillStagingStockItems
AS
BEGIN
    TRUNCATE TABLE StagingStockItems
    INSERT INTO StagingStockItems
        (
        [StockItemID],
        [StockItemName],
        [SupplierID],
        [ColorID],
        [UnitPackageID],
        [OuterPackageID],
        [Brand],
        [Size],
        [IsChillerStock],
        [Barcode],
        [TaxRate],
        [UnitPrice],
        [RecommendedRetailPrice],
        [TypicalWeightPerUnit]
        )
    SELECT
        [StockItemID],
        [StockItemName],
        [SupplierID],
        [ColorID],
        [UnitPackageID],
        [OuterPackageID],
        [Brand],
        [Size],
        [IsChillerStock],
        [Barcode],
        [TaxRate],
        [UnitPrice],
        [RecommendedRetailPrice],
        [TypicalWeightPerUnit]
    FROM [WideWorldImporters].[Warehouse].[StockItems]

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FillStagingStockItemHoldings
AS
BEGIN
    TRUNCATE TABLE StagingStockItemHoldings
    INSERT INTO StagingStockItemHoldings
        (
        [StockItemID],
        [QuantityOnHand],
        [BinLocation],
        [LastStocktakeQuantity],
        [LastCostPrice],
        [ReorderLevel],
        [TargetStockLevel]
        )
    SELECT
        [StockItemID],
        [QuantityOnHand],
        [BinLocation],
        [LastStocktakeQuantity],
        [LastCostPrice],
        [ReorderLevel],
        [TargetStockLevel]

    FROM [WideWorldImporters].[Warehouse].[StockItemHoldings]

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FillStagingStockGroups
AS
BEGIN
    TRUNCATE TABLE StagingStockGroups
    INSERT INTO StagingStockGroups
        (
        [StockGroupID],
        [StockGroupName]
        )
    SELECT
        [StockGroupID],
        [StockGroupName]

    FROM [WideWorldImporters].[Warehouse].[StockGroups]

END
--------------------------------------------------------------------------------------------------------------
GO

CREATE OR ALTER PROCEDURE FillStagingStockItemStockGroups
AS
BEGIN
    TRUNCATE TABLE StagingStockItemStockGroups
    INSERT INTO StagingStockItemStockGroups
        (
        [StockGroupID],
        [StockGroupName]
        )
    SELECT
        [StockGroupID],
        [StockGroupName]

    FROM [WideWorldImporters].[Warehouse].[StockItemStockGroups]

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FillStagingPackageTypes
AS
BEGIN
    TRUNCATE TABLE StagingPackageTypes
    INSERT INTO StagingPackageTypes
        (
        [PackageTypeID],
        [PackageTypeName]
        )
    SELECT
        [PackageTypeID],
        [PackageTypeName]

    FROM [WideWorldImporters].[Warehouse].[PackageTypes]

END
--------------------------------------------------------------------------------------------------------------
GO

CREATE OR ALTER PROCEDURE FillStagingColors
AS
BEGIN
    TRUNCATE TABLE StagingColors
    INSERT INTO StagingColors
        (
        [ColorID],
        [ColorName]
        )
    SELECT
        [ColorID],
        [ColorName]

    FROM [WideWorldImporters].[Warehouse].[Colors]

END
--------------------------------------------------------------------------------------------------------------
GO

CREATE OR ALTER PROCEDURE FillStagingTransactionTypes
AS
BEGIN
    TRUNCATE TABLE StagingTransactionTypes
    INSERT INTO StagingTransactionTypes
        (
        [TransactionTypeID],
        [TransactionTypeName]
        )
    SELECT
        [TransactionTypeID],
        [TransactionTypeName]

    FROM [WideWorldImporters].[Warehouse].[TransactionTypes]

END
--------------------------------------------------------------------------------------------------------------
GO

CREATE OR ALTER PROCEDURE FillStagingStockItemTransactions
AS
BEGIN
    DECLARE @last_added DATE = (
        SELECT isnull(max([TransactionDate]),'2012-12-31')
    FROM [WideWorldImporters].[Warehouse].[StockItemTransactions]
    )
    INSERT INTO StagingCustomerTransactions
        (
        [StockItemTransactionID],
        [StockItemID],
        [TransactionTypeID],
        [CustomerID],
        [InvoiceID],
        [SupplierID],
        [PurchaseOrderID],
        [TransactionOccurredWhen],
        [Quantity]
        )
    SELECT
        [StockItemTransactionID],
        [StockItemID],
        [TransactionTypeID],
        [CustomerID],
        [InvoiceID],
        [SupplierID],
        [PurchaseOrderID],
        [TransactionOccurredWhen],
        [Quantity]
    FROM [WideWorldImporters].[Warehouse].[StockItemTransactions]
    WHERE TransactionOccurredWhen > @last_added
END
--------------------------------------------------------------------------------------------------------------
GO