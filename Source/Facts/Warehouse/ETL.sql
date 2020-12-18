CREATE OR ALTER PROCEDURE FillStockItemTranFact
    @to_date DATE
AS
BEGIN

    --? getting the the time key of the latest item that is added to fact
    DECLARE @LastAddedTimeKey INT = (SELECT max(TransactionDate) FROM FactStockItemTran)

    --^ getting the date of the latest item that is added to fact , if it is null --> 2012-12-31 default value
    DECLARE @LastAddedDate DATE = ISNULL((SELECT FullDateAlternateKey FROM DimTime WHERE TimeKey = @LastAddedTimeKey), '2012-12-31');


    IF OBJECT_ID('temp_fact_stock_item_transactions', 'U') IS NOT NULL
        DROP TABLE temp_fact_stock_item_transactions

    CREATE TABLE temp_fact_stock_item_transactions (
        StockItemTransactionID INT NOT NULL PRIMARY KEY,
        StockItemID INT NOT NULL FOREIGN KEY REFERENCES DimStockItems(StockItemID),
        UnitPackageTypeID INT FOREIGN KEY REFERENCES DimPackageTypes(PackageTypeID),
        OuterPackageTypeID INT FOREIGN KEY REFERENCES DimPackageTypes(PackageTypeID),
        ColorID INT FOREIGN KEY REFERENCES DimColors(ColorID),
        CustomerKey INT FOREIGN KEY REFERENCES DimCustomer(CustomerKey),
        CustomerID INT ,
        InvoiceKey INT FOREIGN KEY REFERENCES DimInvoice(InvoiceKey),
        SupplierID INT FOREIGN KEY REFERENCES DimSuplier(SupplierID),
        PurchaseOrderID INT FOREIGN KEY REFERENCES DimPurchaseOrder(PurchaseOrderID),
        TransactionTypeID INT FOREIGN KEY REFERENCES DimTransactionTypes(TransactionTypeID),
        TransactionDate INT FOREIGN KEY REFERENCES DimTime(TimeKey),
        MovementQuantity [NUMERIC](20 , 3) NOT NULL,
	)


    WHILE(@LastAddedDate < @to_date) 
    BEGIN

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
            MovementQuantity
        )
        SELECT 
            StockItemTransactionID,
            a.StockItemID,
            ISNULL(b.UnitPackageTypeID , -1) as UnitPackageTypeID,
            ISNULL(b.OuterPackageTypeID , -1) as OuterPackageTypeID,
            ISNULL(b.ColorID , -1) as ColorID,
            ISNULL(CustomerKey , -1) as CustomerKey,
            ISNULL(a.CustomerID , -1) as CustomerID,
            ISNULL(InvoiceID , -1) as InvoiceID,
            NULL,
            NULL,
            -- ISNULL(a.SupplierID , NULL) as SupplierID,
            -- ISNULL(PurchaseOrderID , NULL) as PurchaseOrderID,
            TransactionTypeID,
            TimeKey,
            Quantity
            
        FROM StagingStockItemTransactions a
        left outer join DimStockItems b on (a.StockItemID = b.StockItemID)
		left outer join DimTime c on (a.TransactionOccurredWhen = c.FullDateAlternateKey)
        left outer join DimCustomer d on (d.CustomerID = a.CustomerID)
		WHERE (TransactionOccurredWhen >= @LastAddedDate AND TransactionOccurredWhen < DATEADD(dd, 1, @LastAddedDate)) 
        AND (CurrentFlag = 1 or CurrentFlag is NULL)
        
    END

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
        MovementQuantity
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
        MovementQuantity
    FROM temp_fact_stock_item_transactions

    --? LOG



END
GO