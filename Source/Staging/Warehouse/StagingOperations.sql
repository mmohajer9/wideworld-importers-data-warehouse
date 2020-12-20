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

    -------------------------------------------------------
    
    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingStockItems',
    @action = 'INSERT',
    @TargetTable = 'StagingStockItems',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

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


    -------------------------------------------------------
    
    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingStockGroups',
    @action = 'INSERT',
    @TargetTable = 'StagingStockGroups',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS


END
--------------------------------------------------------------------------------------------------------------
GO

CREATE OR ALTER PROCEDURE FillStagingStockItemStockGroups
AS
BEGIN
    TRUNCATE TABLE StagingStockItemStockGroups
    INSERT INTO StagingStockItemStockGroups
        (
        [StockItemStockGroupID],
        [StockItemID],
        [StockGroupID]
        )
    SELECT
        [StockItemStockGroupID],
        [StockItemID],
        [StockGroupID]

    FROM [WideWorldImporters].[Warehouse].[StockItemStockGroups]

    -------------------------------------------------------
    
    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingStockItemStockGroups',
    @action = 'INSERT',
    @TargetTable = 'StagingStockItemStockGroups',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

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

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingColors',
    @action = 'INSERT',
    @TargetTable = 'StagingColors',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO

CREATE OR ALTER PROCEDURE FillStagingTransactionTypes
AS
BEGIN

    DECLARE @CURRENT_TRUNCATE_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    TRUNCATE TABLE StagingTransactionTypes

    INSERT INTO StagingTransactionTypes
        (
        [TransactionTypeID],
        [TransactionTypeName]
        )
    SELECT
        [TransactionTypeID],
        [TransactionTypeName]

    FROM [WideWorldImporters].[Application].[TransactionTypes]

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingTransactionTypes',
    @action = 'INSERT',
    @TargetTable = 'StagingTransactionTypes',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO





CREATE OR ALTER PROCEDURE FillStagingStockItemTransactions

    @from_date DATETIME2 = '2012-12-31',
    @to_date DATETIME2 = '2020-12-31'

AS
BEGIN

    --? temp table for gathering needed rows
    IF OBJECT_ID('temp_staging_stock_items_till_today', 'U') IS NOT NULL
        DROP TABLE temp_staging_stock_items_till_today

    CREATE TABLE temp_staging_stock_items_till_today
    (
        [StockItemTransactionID] [int] NOT NULL,
        [StockItemID] [int] NOT NULL,
        [TransactionTypeID] [int] NOT NULL,
        [CustomerID] [int] NULL,
        [InvoiceID] [int] NULL,
        [SupplierID] [int] NULL,
        [PurchaseOrderID] [int] NULL,
        [TransactionOccurredWhen] [datetime2](7) NOT NULL,
        [Quantity] [decimal](18, 3) NOT NULL,
    );


    --^ date of the last transaction in the "source table"
    declare @today DATETIME2 = (
        select ISNULL(MAX([TransactionOccurredWhen]) , @to_date) 
        from [WideWorldImporters].[Warehouse].[StockItemTransactions]
    )
    
    --^ date of the last transaction in the "staging area"
    DECLARE @last_added DATETIME2 = (
        SELECT ISNULL(MAX([TransactionOccurredWhen]) , @from_date)
        FROM [WWI-DW].[dbo].[StagingStockItemTransactions]
    )

    while(@last_added < @today)
    BEGIN
        --? first we should go to the next day
        SET @last_added = DATEADD(dd, 1, @last_added)

        --? then we should insert new data day by day incrementally --> in opposite of bulk insert --> high load + efficient use of RAM
        INSERT INTO temp_staging_stock_items_till_today
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
        WHERE (TransactionOccurredWhen >= @last_added AND TransactionOccurredWhen < DATEADD(dd, 1, @last_added))
    END

    INSERT INTO StagingStockItemTransactions
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
    FROM temp_staging_stock_items_till_today

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingStockItemTransactions',
    @action = 'INSERT',
    @TargetTable = 'StagingStockItemTransactions',
    @Datetime = @CURRENT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FILL_WAREHOUSE_STAGING_AREA
    @FirstLoad BIT = 0
AS
BEGIN
    IF @FirstLoad = 1
    BEGIN
        TRUNCATE TABLE StagingStockItems;
        TRUNCATE TABLE StagingStockItemHoldings;
        TRUNCATE TABLE StagingStockGroups;
        TRUNCATE TABLE StagingStockItemStockGroups;
        TRUNCATE TABLE StagingPackageTypes;
        TRUNCATE TABLE StagingColors;
        TRUNCATE TABLE StagingTransactionTypes;
        TRUNCATE TABLE StagingStockItemTransactions;
    END
    
    EXECUTE FillStagingStockItems;
    EXECUTE FillStagingStockItemHoldings;
    EXECUTE FillStagingStockGroups;
    EXECUTE FillStagingStockItemStockGroups;
    EXECUTE FillStagingPackageTypes;
    EXECUTE FillStagingColors;
    EXECUTE FillStagingTransactionTypes;
    EXECUTE FillStagingStockItemTransactions;

END
--------------------------------------------------------------------------------------------------------------
GO


