-- Create a new table called 'FactStockItemTran' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.FactStockItemTran', 'U') IS NOT NULL
DROP TABLE dbo.FactStockItemTran
GO
-- Create the table in the specified schema
CREATE TABLE dbo.FactStockItemTran
(
    StockItemTransactionID INT NOT NULL PRIMARY KEY,
    -- primary key column

    --^ FOREIGN KEYS

    StockItemID INT NOT NULL FOREIGN KEY 
    REFERENCES DimStockItems(StockItemID),

    UnitPackageTypeID INT FOREIGN KEY 
    REFERENCES DimPackageTypes(PackageTypeID),

    OuterPackageTypeID INT FOREIGN KEY 
    REFERENCES DimPackageTypes(PackageTypeID),

    ColorID INT FOREIGN KEY 
    REFERENCES DimColors(ColorID),

    CustomerKey INT FOREIGN KEY 
    REFERENCES DimCustomer(CustomerKey),

    CustomerID INT,

    InvoiceKey INT FOREIGN KEY 
    REFERENCES DimInvoice(InvoiceKey),

    SupplierID INT FOREIGN KEY 
    REFERENCES DimSuplier(SupplierID),

    PurchaseOrderID INT FOREIGN KEY 
    REFERENCES DimPurchaseOrder(PurchaseOrderID),

    TransactionTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimTransactionTypes(TransactionTypeID),

    TransactionDate INT NOT NULL FOREIGN KEY 
    REFERENCES DimTime(TimeKey),

    --^ MEASURES --> transactional

    MovementQuantity [NUMERIC](20 , 3) NOT NULL,
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

    --? Surrogate Key --> be ezaye har stock item har rooz 1 record
    TranDailyFactID INT IDENTITY(1,1) PRIMARY KEY,

    --^ FOREIGN KEYS

    StockItemID INT NOT NULL FOREIGN KEY 
    REFERENCES DimStockItems(StockItemID),

    UnitPackageTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimPackageTypes(PackageTypeID),

    OuterPackageTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimPackageTypes(PackageTypeID),

    ColorID INT NOT NULL FOREIGN KEY 
    REFERENCES DimColors(ColorID),

    CustomerKey INT NOT NULL FOREIGN KEY 
    REFERENCES DimCustomer(CustomerKey),

    CustomerID INT,

    InvoiceKey INT NOT NULL FOREIGN KEY 
    REFERENCES DimInvoice(InvoiceKey),

    SupplierID INT NOT NULL FOREIGN KEY 
    REFERENCES DimSuplier(SupplierID),

    PurchaseOrderID INT NOT NULL FOREIGN KEY 
    REFERENCES DimPurchaseOrder(PurchaseOrderID),

    TransactionTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimTransactionTypes(TransactionTypeID),

    EffectiveDate INT NOT NULL FOREIGN KEY 
    REFERENCES DimTime(TimeKey),

    --^ MEASURES --> Daily Fact

    TotalMovementQuantityInDay [NUMERIC](20 , 3) NOT NULL,
    TotalEntryMovementQuantityInDay [NUMERIC](20 , 3) NOT NULL,
    TotalWriteOffMovementQuantityInDay [NUMERIC](20 , 3) NOT NULL,

    TotalDaysOffCountTillToday INT NOT NULL,

    MaximumMovementQuantityInDay [NUMERIC](20 , 3) NOT NULL,
    MinimumMovementQuantityInDay [NUMERIC](20 , 3) NOT NULL,
    

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

    --? Surrogate Key --> be ezaye har stock item har rooz 1 record
    TranDailyFactID INT IDENTITY(1,1) PRIMARY KEY,

    --^ FOREIGN KEYS

    StockItemID INT NOT NULL FOREIGN KEY 
    REFERENCES DimStockItems(StockItemID),

    UnitPackageTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimPackageTypes(PackageTypeID),

    OuterPackageTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimPackageTypes(PackageTypeID),

    ColorID INT NOT NULL FOREIGN KEY 
    REFERENCES DimColors(ColorID),

    CustomerKey INT NOT NULL FOREIGN KEY 
    REFERENCES DimCustomer(CustomerKey),

    CustomerID INT,

    InvoiceKey INT NOT NULL FOREIGN KEY 
    REFERENCES DimInvoice(InvoiceKey),

    SupplierID INT NOT NULL FOREIGN KEY 
    REFERENCES DimSuplier(SupplierID),

    PurchaseOrderID INT NOT NULL FOREIGN KEY 
    REFERENCES DimPurchaseOrder(PurchaseOrderID),

    TransactionTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimTransactionTypes(TransactionTypeID),

    --^ MEASURES --> Acc Fact

    TotalMovementQuantity [NUMERIC](20 , 3) NOT NULL,
    TotalEntryMovementQuantity [NUMERIC](20 , 3) NOT NULL,
    TotalWriteOffMovementQuantity [NUMERIC](20 , 3) NOT NULL,
    
    TotalDaysOffCount INT NOT NULL,
);
GO