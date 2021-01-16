use [WWI-DW];
GO

-- Create a new table called 'TotalMovementQuantityForStockItemPerDay' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.TotalMovementQuantityForStockItemPerDay', 'U') IS NOT NULL
DROP TABLE dbo.TotalMovementQuantityForStockItemPerDay
GO
-- Create the table in the specified schema
CREATE TABLE dbo.TotalMovementQuantityForStockItemPerDay
(
    StockItemID INT,
    [Date] DATE,
    TotalMovementQuantityInDay [NUMERIC](20 , 3), --* all
);
GO


-- Create a new table called 'TotalEntryMovementQuantityForStockItemPerDay' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.TotalEntryMovementQuantityForStockItemPerDay', 'U') IS NOT NULL
DROP TABLE dbo.TotalEntryMovementQuantityForStockItemPerDay
GO
-- Create the table in the specified schema
CREATE TABLE dbo.TotalEntryMovementQuantityForStockItemPerDay
(
    StockItemID INT,
    [Date] DATE,
    TotalEntryMovementQuantityInDay [NUMERIC](20 , 3), --* +
);
GO


-- Create a new table called 'TotalWriteOffMovementQuantityForStockItemPerDay' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.TotalWriteOffMovementQuantityForStockItemPerDay', 'U') IS NOT NULL
DROP TABLE dbo.TotalWriteOffMovementQuantityForStockItemPerDay
GO
-- Create the table in the specified schema
CREATE TABLE dbo.TotalWriteOffMovementQuantityForStockItemPerDay
(
    StockItemID INT,
    [Date] DATE,
    TotalWriteOffMovementQuantityInDay [NUMERIC](20 , 3), --* -
);
GO




CREATE OR ALTER PROCEDURE FillStockItemTranFact
    @to_date DATE
AS
BEGIN

    --? getting the the time key of the latest item that is added to fact
    DECLARE @LastAddedTimeKey INT = (SELECT max(TransactionDate)
    FROM FactStockItemTran)
    --^ getting the date of the latest item that is added to fact , if it is null --> 2012-12-31 default value
    DECLARE @LastAddedDate DATE = ISNULL((SELECT FullDateAlternateKey
    FROM DimTime
    WHERE TimeKey = @LastAddedTimeKey), '2012-12-31');

    DECLARE @CURRENT_DATETIME DATETIME2;


    IF OBJECT_ID('temp_fact_stock_item_transactions', 'U') IS NOT NULL
        DROP TABLE temp_fact_stock_item_transactions

    CREATE TABLE temp_fact_stock_item_transactions
    (
        StockItemTransactionID INT PRIMARY KEY,
        StockItemID INT,
        UnitPackageTypeID INT,
        OuterPackageTypeID INT,
        ColorID INT,
        CustomerKey INT,
        CustomerID INT ,
        InvoiceKey INT,
        SupplierID INT,
        PurchaseOrderID INT,
        TransactionTypeID INT,
        TransactionDate INT,
        MovementQuantity [NUMERIC](20 , 3),
        RemainingQuantityAfterThisTransaction [NUMERIC](20 , 3),
    )


    WHILE(@LastAddedDate < @to_date) 
    BEGIN

        TRUNCATE TABLE temp_fact_stock_item_transactions;

        --? go to the next day
        SET @LastAddedDate = DATEADD(dd, 1, @LastAddedDate)
        SET @LastAddedTimeKey = @LastAddedTimeKey + 1;

        --^ inserting into the temporary table then join then bulk insert into fact
        INSERT INTO temp_fact_stock_item_transactions
            (
            StockItemTransactionID,
            StockItemID,
            UnitPackageTypeID,
            OuterPackageTypeID,
            ColorID,
            CustomerKey,
            CustomerID,
            InvoiceKey,
            SupplierID,
            PurchaseOrderID,
            TransactionTypeID,
            TransactionDate,
            MovementQuantity,
            RemainingQuantityAfterThisTransaction
            )
        SELECT
            StockItemTransactionID,
            a.StockItemID,
            ISNULL(b.UnitPackageTypeID , -1) as UnitPackageTypeID,
            ISNULL(b.OuterPackageTypeID , -1) as OuterPackageTypeID,
            ISNULL(b.ColorID , -1) as ColorID,

            --^ Sales Fields
            ISNULL(CustomerKey , -1) as CustomerKey,
            ISNULL(a.CustomerID , -1) as CustomerID,
            ISNULL(InvoiceID , -1) as InvoiceID,

            -- ^ Purchase Fields
            ISNULL(a.SupplierID , -1) as SupplierID,
            ISNULL(PurchaseOrderID , -1) as PurchaseOrderID,

            TransactionTypeID,
            TimeKey,
            Quantity,

            SUM(Quantity) OVER (PARTITION BY a.StockItemID ORDER BY StockItemTransactionID) + ISNULL(e.TotalMovementQuantityInDay,0)

        FROM [WWI-Staging].dbo.StagingStockItemTransactions a
            LEFT OUTER JOIN TotalMovementQuantityForStockItemPerDay e 
            on (e.StockItemID = a.StockItemID and e.Date = DATEADD(dd, -1, @LastAddedDate))
            LEFT OUTER JOIN DimStockItems b on (a.StockItemID = b.StockItemID)
            LEFT OUTER JOIN DimTime c on (a.TransactionOccurredWhen = c.FullDateAlternateKey)
            LEFT OUTER JOIN DimCustomer d on (d.CustomerID = a.CustomerID)
        WHERE (TransactionOccurredWhen >= @LastAddedDate AND TransactionOccurredWhen < DATEADD(dd, 1, @LastAddedDate))
            AND (CurrentFlag = 1 or CurrentFlag is NULL)
        
        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO FactStockItemTran
            (
            StockItemTransactionID,
            StockItemID,
            UnitPackageTypeID,
            OuterPackageTypeID,
            ColorID,
            CustomerKey,
            CustomerID,
            InvoiceKey,
            SupplierID,
            PurchaseOrderID,
            TransactionTypeID,
            TransactionDate,
            MovementQuantity,
            RemainingQuantityAfterThisTransaction
            )
        SELECT
            StockItemTransactionID,
            StockItemID,
            UnitPackageTypeID,
            OuterPackageTypeID,
            ColorID,
            CustomerKey,
            CustomerID,
            InvoiceKey,
            SupplierID,
            PurchaseOrderID,
            TransactionTypeID,
            TransactionDate,
            MovementQuantity,
            RemainingQuantityAfterThisTransaction
        FROM temp_fact_stock_item_transactions

        --? LOG
        EXEC AddFactLog
            @procedure_name = 'FillStockItemTranFact',
            @action = 'INSERT',
            @FactName = 'FactStockItemTran',
            @Datetime = @CURRENT_DATETIME,
            @AffectedRowsNumber = @@ROWCOUNT;
        
        WITH T1 (StockItemID,TotalMovementQuantityInDay)
            AS
            (
                SELECT a.StockItemID , SUM(MovementQuantity)
                FROM temp_fact_stock_item_transactions a
                GROUP BY a.StockItemID
            )
            INSERT INTO TotalMovementQuantityForStockItemPerDay
            (
                StockItemID,
                [Date],
                TotalMovementQuantityInDay
            )
            SELECT StockItemID , @LastAddedDate , TotalMovementQuantityInDay
            FROM T1;


        WITH T2 (StockItemID,TotalEntryMovementQuantityInDay)
            AS
            (
                SELECT a.StockItemID , SUM(MovementQuantity)
                FROM temp_fact_stock_item_transactions a
                WHERE MovementQuantity > 0
                GROUP BY a.StockItemID
            )
            INSERT INTO TotalEntryMovementQuantityForStockItemPerDay
            (
                StockItemID,
                [Date],
                TotalEntryMovementQuantityInDay
            )
            SELECT StockItemID , @LastAddedDate , TotalEntryMovementQuantityInDay
            FROM T2;

        WITH T3 (StockItemID,TotalWriteOffMovementQuantityInDay)
            AS
            (
                SELECT a.StockItemID , SUM(MovementQuantity)
                FROM temp_fact_stock_item_transactions a
                WHERE MovementQuantity < 0
                GROUP BY a.StockItemID
            )
            INSERT INTO TotalWriteOffMovementQuantityForStockItemPerDay
            (
                StockItemID,
                [Date],
                TotalWriteOffMovementQuantityInDay
            )
            SELECT StockItemID , @LastAddedDate , TotalWriteOffMovementQuantityInDay
            FROM T3;


        --????
        
    
    END


END
GO
