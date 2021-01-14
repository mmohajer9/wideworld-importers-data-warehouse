use [WWI-DW];
GO


-- Create a new table called 'FactStockItemTran' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.FactStockItemTran', 'U') IS NOT NULL
DROP TABLE dbo.FactStockItemTran
GO
-- Create the table in the specified schema
CREATE TABLE dbo.FactStockItemTran
(
    StockItemTransactionID INT PRIMARY KEY,
    -- primary key column

    --^ FOREIGN KEYS

    StockItemID INT NOT NULL, 
    -- FOREIGN KEY 
    -- REFERENCES DimStockItems(StockItemID),

    UnitPackageTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPackageTypes(PackageTypeID),

    OuterPackageTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPackageTypes(PackageTypeID),

    ColorID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimColors(ColorID),

    CustomerKey INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimCustomer(CustomerKey),

    CustomerID INT,

    InvoiceKey INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimInvoice(InvoiceKey),

    SupplierID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimSuplier(SupplierID),

    PurchaseOrderID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPurchaseOrder(PurchaseOrderID),

    TransactionTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimTransactionTypes(TransactionTypeID),

    TransactionDate INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimTime(TimeKey),

    --^ MEASURES --> transactional

    MovementQuantity [NUMERIC](20 , 3),
);
GO



-- Create a new table called 'FactDailyStockItemTran' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.FactDailyStockItemTran', 'U') IS NOT NULL
DROP TABLE dbo.FactDailyStockItemTran
GO
-- Create the table in the specified schema
CREATE TABLE dbo.FactDailyStockItemTran
(

    --^ FOREIGN KEYS

    StockItemID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimStockItems(StockItemID),

    UnitPackageTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPackageTypes(PackageTypeID),

    OuterPackageTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPackageTypes(PackageTypeID),

    ColorID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimColors(ColorID),

    SupplierID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimSuplier(SupplierID),

    EffectiveDate INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimTime(TimeKey),

    --^ MEASURES --> Daily Fact

    TotalMovementQuantityInDay [NUMERIC](20 , 3),
    TotalEntryMovementQuantityInDay [NUMERIC](20 , 3),
    TotalWriteOffMovementQuantityInDay [NUMERIC](20 , 3),

    TotalDaysOffCountTillToday INT,

    MaximumMovementQuantityInDay [NUMERIC](20 , 3),
    MinimumMovementQuantityInDay [NUMERIC](20 , 3),
    

);
GO



-- Create a new table called 'FactAccStockItemTran' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.FactAccStockItemTran', 'U') IS NOT NULL
DROP TABLE dbo.FactAccStockItemTran
GO
-- Create the table in the specified schema
CREATE TABLE dbo.FactAccStockItemTran
(


    --^ FOREIGN KEYS

    StockItemID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimStockItems(StockItemID),

    UnitPackageTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPackageTypes(PackageTypeID),

    OuterPackageTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPackageTypes(PackageTypeID),

    ColorID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimColors(ColorID),

    SupplierID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimSuplier(SupplierID),


    --^ MEASURES --> Acc Fact

    TotalMovementQuantity [NUMERIC](20 , 3),
    TotalEntryMovementQuantity [NUMERIC](20 , 3),
    TotalWriteOffMovementQuantity [NUMERIC](20 , 3),
    
    TotalDaysOffCount INT,
);
GO


CREATE INDEX FactStockItemTranIndex ON FactStockItemTran(StockItemID , TransactionDate,CustomerKey,InvoiceKey,TransactionTypeID)