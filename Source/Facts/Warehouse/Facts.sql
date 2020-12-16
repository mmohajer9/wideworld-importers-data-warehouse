-- Create a new table called 'StockItemTranFact' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StockItemTranFact', 'U') IS NOT NULL
DROP TABLE dbo.StockItemTranFact
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StockItemTranFact
(


    StockItemTransactionID INT NOT NULL PRIMARY KEY,
    -- primary key column

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

    InvoiceKey INT NOT NULL FOREIGN KEY 
    REFERENCES DimInvoice(InvoiceKey),

    TransactionTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimTransactionTypes(TransactionTypeID),

    TransactionDate [DATE] NOT NULL FOREIGN KEY 
    REFERENCES DimTime(TimeKey),

    --^ MEASURES --> transactional

    MovementQuantity [NUMERIC](20 , 3) NOT NULL,
    TotalMovementQuantityTillNow [NUMERIC](20 , 3) NOT NULL,
);
GO



-- Create a new table called 'StockItemTranDailyFact' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StockItemTranDailyFact', 'U') IS NOT NULL
DROP TABLE dbo.StockItemTranDailyFact
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StockItemTranDailyFact
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

    InvoiceKey INT NOT NULL FOREIGN KEY 
    REFERENCES DimInvoice(InvoiceKey),

    TransactionTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimTransactionTypes(TransactionTypeID),

    EffectiveDate [DATE] NOT NULL FOREIGN KEY 
    REFERENCES DimTime(TimeKey),

    --^ MEASURES --> Daily Fact

    TotalMovementQuantityInDay [NUMERIC](20 , 3) NOT NULL,
    TotalEntryMovementQuantityInDay [NUMERIC](20 , 3) NOT NULL,
    TotalWriteOffMovementQuantityInDay [NUMERIC](20 , 3) NOT NULL,
    TotalDaysOffCountTillToday INT NOT NULL,
    

);
GO



-- Create a new table called 'StockItemTranAccumlativeFact' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.StockItemTranAccumlativeFact', 'U') IS NOT NULL
DROP TABLE dbo.StockItemTranAccumlativeFact
GO
-- Create the table in the specified schema
CREATE TABLE dbo.StockItemTranAccumlativeFact
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

    InvoiceKey INT NOT NULL FOREIGN KEY 
    REFERENCES DimInvoice(InvoiceKey),

    TransactionTypeID INT NOT NULL FOREIGN KEY 
    REFERENCES DimTransactionTypes(TransactionTypeID),

    --^ MEASURES --> Acc Fact

    TotalMovementQuantity [NUMERIC](20 , 3) NOT NULL,
    TotalEntryMovementQuantity [NUMERIC](20 , 3) NOT NULL,
    TotalWriteOffMovementQuantity [NUMERIC](20 , 3) NOT NULL,
    TotalDaysOffCount INT NOT NULL,
);
GO