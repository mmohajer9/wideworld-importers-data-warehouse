use [WWI-Staging];
GO

IF OBJECT_ID('dbo.StagingLog', 'U') IS NOT NULL
DROP TABLE dbo.StagingLog
GO

CREATE TABLE StagingLog
(
    [StagingLogID] INT IDENTITY(1 , 1) PRIMARY KEY,
    [ProcedureName] NVARCHAR(500),
    [Action] NVARCHAR(500),
    [TargetTable] NVARCHAR(500),
    [Datetime] DATETIME2(7),
    [AffectedRowsNumber] INT
);
GO


CREATE OR ALTER PROCEDURE AddStagingLog

    @procedure_name NVARCHAR(500) = "UNDEFINED",
    @action NVARCHAR(500) = "UNDEFINED",
    @TargetTable NVARCHAR(500) = "UNDEFINED",
    @Datetime DATETIME2,
    @AffectedRowsNumber INT = 0
AS
BEGIN

    INSERT INTO StagingLog
        (
        [ProcedureName],
        [Action],
        [TargetTable],
        [Datetime],
        [AffectedRowsNumber]
        )
    VALUES
        (
            @procedure_name,
            @action,
            @TargetTable,
            @Datetime,
            @AffectedRowsNumber        
    );

END
--------------------------------------------------------------------------------------------------------------
GO




use [WWI-Staging];
GO

IF OBJECT_ID('dbo.StagingPurchaseOrder', 'U') IS NOT NULL
DROP TABLE StagingPurchaseOrder
CREATE TABLE StagingPurchaseOrder
(
	PurchaseOrderID INT PRIMARY KEY,
	SupplierID INT,
	OrderDate DATE,
	DeliveryMethodID INT,
	ContactPersonID INT,
	ExpectedDeliveryDate DATE,
	SupplierReference NVARCHAR(50),
	IsOrderFinalized NVARCHAR(10)
	,
	--^ bit in original source --> 1 : yes , 0 : no
);
GO

IF OBJECT_ID('dbo.StagingSupplierCategories' , 'U') IS NOT NULL
DROP TABLE StagingSupplierCategories

CREATE TABLE StagingSupplierCategories
(
	SupplierCategoryID INT,
	SupplierCategoryName NVARCHAR(100)
)


IF OBJECT_ID('dbo.StagingSupplier', 'U') IS NOT NULL
DROP TABLE StagingSupplier
CREATE TABLE StagingSupplier
(
	SupplierID INT PRIMARY KEY,
	SupplierName NVARCHAR(100),

	SupplierCategoryID INT,
	SupplierCategoryName NVARCHAR(100),
	--^ from Supplier Categories

	PrimaryContactPersonID INT,
	AlternateContactPersonID INT,

	DeliveryMethodID INT ,
	DeliveryCityID INT,
	PostalCityID INT,
	SupplierReference NVARCHAR(50) NULL,

	BankAccountName NVARCHAR(100),
	BankAccountBranch NVARCHAR(100),
	BankAccountCode NVARCHAR(100),
	BankAccountNumber NVARCHAR(100),
	BankInternationalCode NVARCHAR(100),

	PhoneNumber NVARCHAR(20),
	FaxNumber NVARCHAR(20),
	WebsiteURL NVARCHAR(256),

	DeliveryAddressLine1 NVARCHAR(60),
	DeliveryAddressLine2 NVARCHAR(60),
	DeliveryPostalCode NVARCHAR(20),

	PostalAddressLine1 NVARCHAR(60),
	PostalAddressLine2 NVARCHAR(60),
	PostalPostalCode NVARCHAR(20)
);
GO

IF OBJECT_ID('dbo.StagingSupplierTransactions', 'U') IS NOT NULL
DROP TABLE StagingSupplierTransactions
CREATE TABLE StagingSupplierTransactions
(
	[SupplierTransactionID] [int],
	[SupplierID] [int],
	[TransactionTypeID] [int],
	[PurchaseOrderID] [int] NULL,
	[PaymentMethodID] [int] NULL,
	[SupplierInvoiceNumber] [nvarchar](20) NULL,
	[TransactionDate] [date],
	[AmountExcludingTax] [decimal](20, 2),
	[TaxAmount] [decimal](20, 2),
	[TransactionAmount] [decimal](20, 2),
	[OutstandingBalance] [decimal](20, 2),
	[FinalizationDate] [date] NULL,
	[IsFinalized] NVARCHAR(10),
)
GO

use [WWI-Staging]







--*****************************start Staging People******************************
IF OBJECT_ID('dbo.StagingPeople', 'U') IS NOT NULL
drop table StagingPeople
CREATE TABLE StagingPeople(
	PersonID int Primary key,
	FullName nvarchar(50),
	PreferredName nvarchar(50),
	IsEmployee nvarchar(5),
	IsSalesperson nvarchar(5),
	UserPreferences nvarchar(max) NULL,
	PhoneNumber nvarchar(20) NULL,
	FaxNumber nvarchar(20) NULL,
	EmailAddress nvarchar(256) NULL,
	Photo varbinary(max) NULL,
	CustomFields nvarchar(max) NULL,
	OtherLanguages  AS (json_query([CustomFields],N'$.OtherLanguages')),)
GO
--***************************** end Staging People*******************************





--***************************** start Staging PaymentMethod*******************************
IF OBJECT_ID('dbo.StagingPaymentMethods', 'U') IS NOT NULL
drop table StagingPaymentMethods
CREATE TABLE StagingPaymentMethods(
	[PaymentMethodID] [int],
	[PaymentMethodName] [nvarchar](50))
Go
--***************************** end Staging PaymentMethod*******************************





--***************************** start Staging Delivery method*******************************
IF OBJECT_ID('dbo.StagingDeliveryMethods', 'U') IS NOT NULL
drop table StagingDeliveryMethods
CREATE TABLE StagingDeliveryMethods(
	[DeliveryMethodID] [int],
	[DeliveryMethodName] [nvarchar](50))
Go
--***************************** end Staging delivery method*******************************





--***************************** start Staging Cities*******************************
IF OBJECT_ID('dbo.StagingCities', 'U') IS NOT NULL
drop table StagingCities
CREATE TABLE StagingCities(
	CityID [int] primary key,
	[CityName] [nvarchar](50),
	[StateProvinceID] [int],
	[LatestRecordedPopulation] [bigint] NULL,)
Go
--***************************** end Staging Cities*******************************





--***************************** start Staging Province*******************************
IF OBJECT_ID('dbo.StagingStateProvinces', 'U') IS NOT NULL
drop table StagingStateProvinces
CREATE TABLE StagingStateProvinces(
	[StateProvinceID] [int] primary key,
	[StateProvinceCode] [nvarchar](5),
	[StateProvinceName] [nvarchar](50),
	[CountryID] [int],
	[SalesTerritory] [nvarchar](50),
	[LatestRecordedPopulation] [bigint] NULL)
Go
--***************************** end Staging Province*********************************





--***************************** start Staging BuyingGroups*******************************
IF OBJECT_ID('dbo.StagingBuyingGroups', 'U') IS NOT NULL
drop table StagingBuyingGroups
CREATE TABLE StagingBuyingGroups(
	[BuyingGroupID] [int],
	[BuyingGroupName] [nvarchar](50)
)
GO
--***************************** end Staging BuyingGroups*********************************







--***************************** start Staging CustomerCategories*******************************
IF OBJECT_ID('dbo.StagingCustomerCategories', 'U') IS NOT NULL
drop table StagingCustomerCategories
CREATE TABLE StagingCustomerCategories(
	[CustomerCategoryID] [int],
	[CustomerCategoryName] [nvarchar](50))
Go
--***************************** end Staging CustomerCategories*******************************







--***************************** start Staging Customers*******************************
IF OBJECT_ID('dbo.StagingCustomers', 'U') IS NOT NULL
drop table StagingCustomers
CREATE TABLE StagingCustomers(
	[CustomerID] [int],
	[CustomerName] [nvarchar](100),
	[BillToCustomerID] [int],
	[CustomerCategoryID] [int],
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int],
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int],
	[DeliveryCityID] [int],
	[PostalCityID] [int],
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date],
	[StandardDiscountPercentage] [decimal](18, 3),
	[IsStatementSent] [bit],
	[IsOnCreditHold] [bit],
	[PaymentDays] [int],
	[PhoneNumber] [nvarchar](20),
	[FaxNumber] [nvarchar](20),
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256),
	[DeliveryAddressLine1] [nvarchar](60),
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10),
	[PostalAddressLine1] [nvarchar](60),
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10))
Go
--***************************** end Staging Customers**********************************














--***************************** start Staging Invoices*******************************
IF OBJECT_ID('dbo.StagingInvoices', 'U') IS NOT NULL
drop table StagingInvoices
CREATE TABLE StagingInvoices(
	[InvoiceID] [int],
	[CustomerID] [int],
	[BillToCustomerID] [int],
	[OrderID] [int] NULL,
	[DeliveryMethodID] [int],
	[ContactPersonID] [int],
	[AccountsPersonID] [int],
	[SalespersonPersonID] [int],
	[PackedByPersonID] [int],
	[InvoiceDate] [date],
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsCreditNote] [bit],
	[CreditNoteReason] [nvarchar](max) NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[TotalDryItems] [int],
	[TotalChillerItems] [int],
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[ReturnedDeliveryData] [nvarchar](max) NULL,
	[ConfirmedDeliveryTime]  AS (TRY_CONVERT([datetime2](7),json_value([ReturnedDeliveryData],N'$.DeliveredWhen'),(126))),
	[ConfirmedReceivedBy]  AS (json_value([ReturnedDeliveryData],N'$.ReceivedBy')),
)
go
--***************************** end Staging Invoices**********************************





--***************************** start Staging Orders************************************
IF OBJECT_ID('dbo.StagingOrders', 'U') IS NOT NULL
drop table StagingOrders
CREATE TABLE StagingOrders(
	[OrderID] [int],
	[CustomerID] [int],
	[SalespersonPersonID] [int],
	[PickedByPersonID] [int] NULL,
	[ContactPersonID] [int],
	[BackorderOrderID] [int] NULL,
	[OrderDate] [date],
	[ExpectedDeliveryDate] [date],
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsUndersupplyBackordered] [bit],
	[DeliveryInstructions] [nvarchar](max) NULL)
go
--***************************** end Staging Orders***************************************





--***************************** start Staging InvoiceLines************************************
IF OBJECT_ID('dbo.StagingInvoiceLines', 'U') IS NOT NULL
drop table StagingInvoiceLines
CREATE TABLE StagingInvoiceLines(
	InvoiceLineID int,
	InvoiceID int,
	StockItemID int,
	Description nvarchar(200),
	PackageTypeID int,
	Quantity int,
	UnitPrice decimal(25, 4) NULL,
	TaxRate decimal(25, 4),
	TaxAmount decimal(25, 4),
	LineProfit decimal(25, 4),
	ExtendedPrice decimal(25, 4))
--***************************** start Staging InvoiceLines************************************





--***************************** start Staging Customer Transactions************************************
IF OBJECT_ID('dbo.StagingCustomerTransactions', 'U') IS NOT NULL
drop table StagingCustomerTransactions
CREATE TABLE StagingCustomerTransactions(
	[CustomerTransactionID] [int],
	[CustomerID] [int],
	[TransactionTypeID] [int],
	[InvoiceID] [int] NULL,
	[PaymentMethodID] [int] NULL,
	[TransactionDate] [date],
	[AmountExcludingTax] [decimal](18, 2),
	[TaxAmount] [decimal](18, 2),
	[TransactionAmount] [decimal](18, 2)
)
Go
--***************************** end Staging Customer Transactions**********************************************
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


---------------------------------------------------------------------------------------------------------

use [WWI-Staging];
GO

CREATE OR ALTER PROCEDURE FillStagingPurchaseOrder
AS
BEGIN
    TRUNCATE TABLE StagingPurchaseOrder
    INSERT INTO StagingPurchaseOrder
        (
        PurchaseOrderID,
        SupplierID,
        OrderDate,
        DeliveryMethodID,
        ContactPersonID,
        ExpectedDeliveryDate,
        SupplierReference,
        IsOrderFinalized
        )
    SELECT
        PurchaseOrderID,
        SupplierID,
        OrderDate,
        DeliveryMethodID,
        ContactPersonID,
        ExpectedDeliveryDate,
        SupplierReference,
        CASE IsOrderFinalized
		    WHEN 1 then 'Yes' else 'No' 
	    END

    FROM [WideWorldImporters].[Purchasing].[PurchaseOrders]

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingPurchaseOrder',
    @action = 'INSERT',
    @TargetTable = 'StagingPurchaseOrder',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO



CREATE OR ALTER PROCEDURE FillStagingSupplierCategories
AS
BEGIN
    TRUNCATE TABLE StagingSupplierCategories
    INSERT INTO StagingSupplierCategories
        (
        SupplierCategoryID,
        SupplierCategoryName
        )
    SELECT
        SupplierCategoryID,
        SupplierCategoryName

    FROM [WideWorldImporters].[Purchasing].[SupplierCategories]

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingSupplierCategories',
    @action = 'INSERT',
    @TargetTable = 'StagingSupplierCategories',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FillStagingSupplier
AS
BEGIN
    TRUNCATE TABLE StagingSupplier
    INSERT INTO StagingSupplier
        (
        SupplierID,
        SupplierName,
        SupplierCategoryID,
        SupplierCategoryName,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        DeliveryMethodID,
        DeliveryCityID,
        PostalCityID,
        SupplierReference,
        BankAccountName,
        BankAccountBranch,
        BankAccountCode,
        BankAccountNumber,
        BankInternationalCode,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        DeliveryPostalCode,
        PostalAddressLine1,
        PostalAddressLine2,
        PostalPostalCode
        )
    SELECT
        SupplierID,
        SupplierName,
        a.SupplierCategoryID,
        b.SupplierCategoryName,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        DeliveryMethodID,
        DeliveryCityID,
        PostalCityID,
        SupplierReference,
        BankAccountName,
        BankAccountBranch,
        BankAccountCode,
        BankAccountNumber,
        BankInternationalCode,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        DeliveryPostalCode,
        PostalAddressLine1,
        PostalAddressLine2,
        PostalPostalCode

    FROM [WideWorldImporters].[Purchasing].[Suppliers] a INNER JOIN [WideWorldImporters].[Purchasing].[SupplierCategories] b
    ON (a.SupplierCategoryID = b.SupplierCategoryID)

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingSupplier',
    @action = 'INSERT',
    @TargetTable = 'StagingSupplier',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FillStagingSupplierTransactions
AS
BEGIN
    TRUNCATE TABLE StagingSupplierTransactions
    INSERT INTO StagingSupplierTransactions
        (
        SupplierTransactionID,
        SupplierID,
        TransactionTypeID,
        PurchaseOrderID,
        PaymentMethodID,
        SupplierInvoiceNumber,
        TransactionDate,
        AmountExcludingTax,
        TaxAmount,
        TransactionAmount,
        OutstandingBalance,
        FinalizationDate,
        IsFinalized
        )
    SELECT
        SupplierTransactionID,
        SupplierID,
        TransactionTypeID,
        PurchaseOrderID,
        PaymentMethodID,
        SupplierInvoiceNumber,
        TransactionDate,
        AmountExcludingTax,
        TaxAmount,
        TransactionAmount,
        OutstandingBalance,
        FinalizationDate,
        CASE IsFinalized
		    WHEN 1 then 'Yes' else 'No' 
	    END

    FROM [WideWorldImporters].[Purchasing].[SupplierTransactions]

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingSupplierTransactions',
    @action = 'INSERT',
    @TargetTable = 'StagingSupplierTransactions',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FILL_PURCHASING_STAGING_AREA
    @FirstLoad BIT = 0
AS
BEGIN
    IF @FirstLoad = 1
    BEGIN
        TRUNCATE TABLE StagingPurchaseOrder
        TRUNCATE TABLE StagingSupplierCategories
        TRUNCATE TABLE StagingSupplier
        TRUNCATE TABLE StagingSupplierTransactions
    END

    EXEC FillStagingPurchaseOrder;
    EXEC FillStagingSupplierCategories;
    EXEC FillStagingSupplier;
    EXEC FillStagingSupplierTransactions;

END
--------------------------------------------------------------------------------------------------------------
GO


use [WWI-Staging]


--*****************************start Staging People******************************
GO
CREATE or alter PROCEDURE FillStagingPeople AS
BEGIN
	truncate table StagingPeople
	insert into StagingPeople(
			PersonID,FullName,PreferredName,IsEmployee,
			IsSalesperson,UserPreferences,PhoneNumber,FaxNumber,EmailAddress,Photo,CustomFields)
	select 
			PersonID,FullName,PreferredName,case IsEmployee
			when 1 then 'Yes' else 'No' end,
			case IsSalesperson
			when 1 then 'Yes' else 'No' end,UserPreferences,PhoneNumber,FaxNumber,EmailAddress,Photo,CustomFields
	from [WideWorldImporters].Application.People

END
GO

--***************************** end Staging People*******************************





--***************************** start Staging PaymentMethod*******************************
create or alter procedure FillStagingPaymentMethods as
begin
	truncate table StagingPaymentMethods
	insert into StagingPaymentMethods([PaymentMethodID],[PaymentMethodName])
		select [PaymentMethodID],[PaymentMethodName] from [WideWorldImporters].Application.PaymentMethods
end
Go
--***************************** end Staging PaymentMethod*******************************





--***************************** start Staging Delivery method*******************************
create or alter procedure FillStagingDeliveryMethods as
begin
	truncate table StagingDeliveryMethods
	insert into StagingDeliveryMethods([DeliveryMethodID],[DeliveryMethodName])
		select [DeliveryMethodID],[DeliveryMethodName] from [WideWorldImporters].Application.DeliveryMethods
end
Go
--***************************** end Staging delivery method*******************************





--***************************** start Staging Cities*******************************
CREATE or alter PROCEDURE FillStagingCities AS
begin
	truncate table StagingCities
	insert into StagingCities(CityID,[CityName],[StateProvinceID],[LatestRecordedPopulation])
	select CityID,[CityName],[StateProvinceID],[LatestRecordedPopulation] From [WideWorldImporters].Application.Cities
end
GO
--***************************** end Staging Cities*******************************





--***************************** start Staging Province*******************************
CREATE or alter PROCEDURE FillStagingStateProvinces AS
begin
	truncate table StagingStateProvinces
	insert into StagingStateProvinces([StateProvinceID],[StateProvinceCode],[StateProvinceName],[CountryID],[SalesTerritory],
		[LatestRecordedPopulation])
	select [StateProvinceID],[StateProvinceCode],[StateProvinceName],[CountryID],[SalesTerritory],
		[LatestRecordedPopulation] from [WideWorldImporters].Application.StateProvinces
end
GO
--***************************** end Staging Province*********************************





--***************************** start Staging BuyingGroups*******************************
CREATE or alter PROCEDURE FillStagingBuyingGroups AS
begin
	truncate table StagingBuyingGroups
	insert into StagingBuyingGroups([BuyingGroupID],[BuyingGroupName])
	select [BuyingGroupID],[BuyingGroupName] from [WideWorldImporters].Sales.BuyingGroups
end
GO
--***************************** end Staging BuyingGroups*********************************







--***************************** start Staging CustomerCategories*******************************
create or alter procedure FillStagingCustomerCategories as
begin
	truncate table StagingCustomerCategories
	insert into StagingCustomerCategories([CustomerCategoryID],[CustomerCategoryName])
		select [CustomerCategoryID],[CustomerCategoryName] from [WideWorldImporters].Sales.CustomerCategories
end
Go
--***************************** end Staging CustomerCategories*******************************







--***************************** start Staging Customers*******************************
create or alter procedure FillStagingCustomers as 
begin
	truncate table StagingCustomers
	insert into StagingCustomers([CustomerID],[CustomerName],[BillToCustomerID],[CustomerCategoryID],[BuyingGroupID],[PrimaryContactPersonID],
	[AlternateContactPersonID],[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[CreditLimit],[AccountOpenedDate],[StandardDiscountPercentage],
	[IsStatementSent],[IsOnCreditHold],[PaymentDays],[PhoneNumber],[FaxNumber],[DeliveryRun],[RunPosition],[WebsiteURL],[DeliveryAddressLine1],
	[DeliveryAddressLine2],[DeliveryPostalCode],[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode])
	select [CustomerID],[CustomerName],[BillToCustomerID],[CustomerCategoryID],[BuyingGroupID],[PrimaryContactPersonID],
	[AlternateContactPersonID],[DeliveryMethodID],[DeliveryCityID],[PostalCityID],[CreditLimit],[AccountOpenedDate],[StandardDiscountPercentage],
	[IsStatementSent],[IsOnCreditHold],[PaymentDays],[PhoneNumber],[FaxNumber],[DeliveryRun],[RunPosition],[WebsiteURL],[DeliveryAddressLine1],
	[DeliveryAddressLine2],[DeliveryPostalCode],[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode] from [WideWorldImporters].Sales.Customers
end
GO
--***************************** end Staging Customers**********************************









--***************************** start Staging Invoices*******************************
create or alter procedure FillStagingInvoices as 
begin
	
	truncate table StagingInvoices

	declare @first_date date = (select isnull(min(InvoiceDate),'2012-12-31') from [WideWorldImporters].Sales.Invoices)
	declare @last_date date = (select isnull(max(InvoiceDate),'2012-12-31') from [WideWorldImporters].Sales.Invoices)
	while(@first_date <= @last_date) begin
		insert into StagingInvoices([InvoiceID],[CustomerID],[BillToCustomerID],[OrderID],[DeliveryMethodID],[ContactPersonID],[AccountsPersonID],
		[SalespersonPersonID],[PackedByPersonID],[InvoiceDate],[CustomerPurchaseOrderNumber],[IsCreditNote],[CreditNoteReason],[Comments],
		[DeliveryInstructions],[InternalComments],[TotalDryItems],[TotalChillerItems],[DeliveryRun],[RunPosition],[ReturnedDeliveryData])
		select [InvoiceID],[CustomerID],[BillToCustomerID],[OrderID],[DeliveryMethodID],[ContactPersonID],[AccountsPersonID],
		[SalespersonPersonID],[PackedByPersonID],[InvoiceDate],[CustomerPurchaseOrderNumber],[IsCreditNote],[CreditNoteReason],[Comments],
		[DeliveryInstructions],[InternalComments],[TotalDryItems],[TotalChillerItems],[DeliveryRun],[RunPosition],[ReturnedDeliveryData]
		from [WideWorldImporters].Sales.Invoices where InvoiceDate = @first_date
		set @first_date = DATEADD(dd,1,@first_date)
	end

end
GO
--***************************** end Staging Invoices**********************************






--***************************** start Staging InvoiceLine************************************
create or alter procedure FillStagingInvoiceLine as 
begin
	IF OBJECT_ID('dbo.tmp', 'U') IS NOT NULL
	drop table tmp
	create table tmp(id int)
		insert into tmp(id) select StagingInvoiceLines.InvoiceLineID from StagingInvoiceLines
	
	insert into StagingInvoiceLines(
		InvoiceLineID,InvoiceID,StockItemID,Description,PackageTypeID,Quantity,UnitPrice,TaxRate,TaxAmount,
		LineProfit,ExtendedPrice
	)select InvoiceLineID,InvoiceID,StockItemID,Description,PackageTypeID,Quantity,UnitPrice,TaxRate,TaxAmount,
		LineProfit,ExtendedPrice from [WideWorldImporters].Sales.InvoiceLines where InvoiceLineID not in (select id from tmp)
	drop table tmp
end
Go

create or alter procedure FillStagingInvoiceLineFirstLoad as 
begin
	truncate table StagingInvoiceLines
	exec FillStagingInvoiceLine
end
Go
--***************************** end Staging InvoiceLine***************************************







--***************************** start Staging Orders************************************
create or alter procedure FillStagingOrders as 
begin
	IF OBJECT_ID('dbo.tmp', 'U') IS NOT NULL
	drop table tmp
	create table tmp(id int)
		insert into tmp(id) select StagingOrders.OrderID from StagingOrders
	
	insert into StagingOrders([OrderID],[CustomerID],[SalespersonPersonID],[PickedByPersonID],[ContactPersonID],[BackorderOrderID],
			[OrderDate],[ExpectedDeliveryDate],[CustomerPurchaseOrderNumber],[IsUndersupplyBackordered],[DeliveryInstructions])
	select [OrderID],[CustomerID],[SalespersonPersonID],[PickedByPersonID],[ContactPersonID],[BackorderOrderID],
			[OrderDate],[ExpectedDeliveryDate],[CustomerPurchaseOrderNumber],[IsUndersupplyBackordered],[DeliveryInstructions]
		from [WideWorldImporters].Sales.Orders where OrderID not in (select id from tmp)
	drop table tmp
end
Go

create or alter procedure FillStagingOrdersFirstLoad as 
begin
	truncate table StagingOrders
	exec FillStagingOrders
end
Go
--***************************** end Staging Orders***************************************







--***************************** start Staging Customer Transactions************************************
create or alter procedure FillStagingCustomerTransactions as
begin
		declare @today date = (select max([TransactionDate]) from [WideWorldImporters].Sales.CustomerTransactions)
		declare @last_added date = (select isnull(max([TransactionDate]),'2012-12-31') from StagingCustomerTransactions)

		while(@last_added < @today)begin
		set @last_added = DATEADD(dd,1,@last_added)
			insert into StagingCustomerTransactions([CustomerTransactionID],[CustomerID],[TransactionTypeID],[InvoiceID],[PaymentMethodID],
			[TransactionDate],[AmountExcludingTax],[TaxAmount],[TransactionAmount])
			select [CustomerTransactionID],[CustomerID],[TransactionTypeID],[InvoiceID],[PaymentMethodID],
			[TransactionDate],[AmountExcludingTax],[TaxAmount],[TransactionAmount]
			from [WideWorldImporters].Sales.CustomerTransactions where TransactionDate = @last_added
		end
end
GO

create or alter procedure FillStagingCustomerTransactionsFirstLoad as 
begin
	truncate table StagingCustomerTransactions
	exec FillStagingCustomerTransactions
end
Go
--***************************** end Staging Customer Transactions**********************************************





use [WWI-Staging];
GO


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
        CASE IsChillerStock
		    WHEN 1 then 'Yes' else 'No' 
	    END,
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
        [StockItemTransactionID] [int],
        [StockItemID] [int],
        [TransactionTypeID] [int],
        [CustomerID] [int] NULL,
        [InvoiceID] [int] NULL,
        [SupplierID] [int] NULL,
        [PurchaseOrderID] [int] NULL,
        [TransactionOccurredWhen] [datetime2](7),
        [Quantity] [decimal](18, 3),
    );

    --^ declarations for logs
    DECLARE @AFFECTED_ROWS INT;
    DECLARE @CURRENT_DATETIME DATETIME2;

    --^ date of the last transaction in the "source table"
    declare @today DATETIME2 = (
        select ISNULL(MAX([TransactionOccurredWhen]) , @to_date)
    from [WideWorldImporters].[Warehouse].[StockItemTransactions]
    )

    --^ date of the last transaction in the "staging area"
    DECLARE @last_added DATETIME2 = (
        SELECT ISNULL(MAX([TransactionOccurredWhen]) , @from_date)
    FROM [WWI-Staging].[dbo].[StagingStockItemTransactions]
    )

    while(@last_added < @today)
    BEGIN

        --? truncate temp table
        TRUNCATE TABLE temp_staging_stock_items_till_today;

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


        SET @AFFECTED_ROWS = @@ROWCOUNT;

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        exec [AddStagingLog] 
            @procedure_name = 'FillStagingStockItemTransactions',
            @action = 'INSERT',
            @TargetTable = 'StagingStockItemTransactions',
            @Datetime = @CURRENT_DATETIME,
            @AffectedRowsNumber = @AFFECTED_ROWS

    END



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


