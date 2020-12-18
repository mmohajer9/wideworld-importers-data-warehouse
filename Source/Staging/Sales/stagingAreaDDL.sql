use WideWorldImporters





IF OBJECT_ID('dbo.LogSales', 'U') IS NOT NULL
drop table LogSales
create table LogSales(
	Id bigint IDENTITY(1,1) primary key,
	ActionName nvarchar(30),
	TableName nvarchar(100),
	date date,
	RecordId	int,
	RecordSurrogateKey int null)

Go



--*****************************start Staging People******************************
IF OBJECT_ID('dbo.StagingPeople', 'U') IS NOT NULL
drop table StagingPeople
CREATE TABLE StagingPeople(
	PersonID int NOT NULL Primary key,
	FullName nvarchar(50) NOT NULL,
	PreferredName nvarchar(50) NOT NULL,
	SearchName  AS (concat([PreferredName],N' ',[FullName])) PERSISTED NOT NULL,
	IsPermittedToLogon bit NOT NULL,
	IsExternalLogonProvider bit NOT NULL,
	IsSystemUser bit NOT NULL,
	IsEmployee bit NOT NULL,
	IsSalesperson bit NOT NULL,
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
	[PaymentMethodID] [int] NOT NULL,
	[PaymentMethodName] [nvarchar](50) NOT NULL)
Go
--***************************** end Staging PaymentMethod*******************************





--***************************** start Staging Delivery method*******************************
IF OBJECT_ID('dbo.StagingDeliveryMethods', 'U') IS NOT NULL
drop table StagingDeliveryMethods
CREATE TABLE StagingDeliveryMethods(
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryMethodName] [nvarchar](50) NOT NULL)
Go
--***************************** end Staging delivery method*******************************





--***************************** start Staging Cities*******************************
IF OBJECT_ID('dbo.StagingCities', 'U') IS NOT NULL
drop table StagingCities
CREATE TABLE StagingCities(
	CityID [int] NOT NULL primary key,
	[CityName] [nvarchar](50) NOT NULL,
	[StateProvinceID] [int] NOT NULL,
	[LatestRecordedPopulation] [bigint] NULL,)
Go
--***************************** end Staging Cities*******************************





--***************************** start Staging Province*******************************
IF OBJECT_ID('dbo.StagingStateProvinces', 'U') IS NOT NULL
drop table StagingStateProvinces
CREATE TABLE StagingStateProvinces(
	[StateProvinceID] [int] NOT NULL primary key,
	[StateProvinceCode] [nvarchar](5) NOT NULL,
	[StateProvinceName] [nvarchar](50) NOT NULL,
	[CountryID] [int] NOT NULL,
	[SalesTerritory] [nvarchar](50) NOT NULL,
	[LatestRecordedPopulation] [bigint] NULL)
Go
--***************************** end Staging Province*********************************





--***************************** start Staging BuyingGroups*******************************
IF OBJECT_ID('dbo.StagingBuyingGroups', 'U') IS NOT NULL
drop table StagingBuyingGroups
CREATE TABLE StagingBuyingGroups(
	[BuyingGroupID] [int] NOT NULL,
	[BuyingGroupName] [nvarchar](50) NOT NULL
)
GO
--***************************** end Staging BuyingGroups*********************************







--***************************** start Staging CustomerCategories*******************************
IF OBJECT_ID('dbo.StagingCustomerCategories', 'U') IS NOT NULL
drop table StagingCustomerCategories
CREATE TABLE StagingCustomerCategories(
	[CustomerCategoryID] [int] NOT NULL,
	[CustomerCategoryName] [nvarchar](50) NOT NULL)
Go
--***************************** end Staging CustomerCategories*******************************







--***************************** start Staging Customers*******************************
IF OBJECT_ID('dbo.StagingCustomers', 'U') IS NOT NULL
drop table StagingCustomers
CREATE TABLE StagingCustomers(
	[CustomerID] [int] NOT NULL,
	[CustomerName] [nvarchar](100) NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[CustomerCategoryID] [int] NOT NULL,
	[BuyingGroupID] [int] NULL,
	[PrimaryContactPersonID] [int] NOT NULL,
	[AlternateContactPersonID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryCityID] [int] NOT NULL,
	[PostalCityID] [int] NOT NULL,
	[CreditLimit] [decimal](18, 2) NULL,
	[AccountOpenedDate] [date] NOT NULL,
	[StandardDiscountPercentage] [decimal](18, 3) NOT NULL,
	[IsStatementSent] [bit] NOT NULL,
	[IsOnCreditHold] [bit] NOT NULL,
	[PaymentDays] [int] NOT NULL,
	[PhoneNumber] [nvarchar](20) NOT NULL,
	[FaxNumber] [nvarchar](20) NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[WebsiteURL] [nvarchar](256) NOT NULL,
	[DeliveryAddressLine1] [nvarchar](60) NOT NULL,
	[DeliveryAddressLine2] [nvarchar](60) NULL,
	[DeliveryPostalCode] [nvarchar](10) NOT NULL,
	[PostalAddressLine1] [nvarchar](60) NOT NULL,
	[PostalAddressLine2] [nvarchar](60) NULL,
	[PostalPostalCode] [nvarchar](10) NOT NULL)
Go
--***************************** end Staging Customers**********************************







--***************************** start Staging InvoiceLines*******************************
IF OBJECT_ID('dbo.StagingInvoiceLines', 'U') IS NOT NULL
drop table StagingInvoiceLines
CREATE TABLE StagingInvoiceLines(
	[InvoiceLineID] [int] NOT NULL,
	[InvoiceID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[LineProfit] [decimal](18, 2) NOT NULL,
	[ExtendedPrice] [decimal](18, 2) NOT NULL)
GO
--***************************** end Staging InvoiceLines*******************************







--***************************** start Staging Invoices*******************************
IF OBJECT_ID('dbo.StagingInvoices', 'U') IS NOT NULL
drop table StagingInvoices
CREATE TABLE StagingInvoices(
	[InvoiceID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[BillToCustomerID] [int] NOT NULL,
	[OrderID] [int] NULL,
	[DeliveryMethodID] [int] NOT NULL,
	[ContactPersonID] [int] NOT NULL,
	[AccountsPersonID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PackedByPersonID] [int] NOT NULL,
	[InvoiceDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsCreditNote] [bit] NOT NULL,
	[CreditNoteReason] [nvarchar](max) NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[TotalDryItems] [int] NOT NULL,
	[TotalChillerItems] [int] NOT NULL,
	[DeliveryRun] [nvarchar](5) NULL,
	[RunPosition] [nvarchar](5) NULL,
	[ReturnedDeliveryData] [nvarchar](max) NULL,
	[ConfirmedDeliveryTime]  AS (TRY_CONVERT([datetime2](7),json_value([ReturnedDeliveryData],N'$.DeliveredWhen'),(126))),
	[ConfirmedReceivedBy]  AS (json_value([ReturnedDeliveryData],N'$.ReceivedBy')),
)
go
--***************************** end Staging Invoices**********************************







--***************************** start Staging OrderLines*******************************
IF OBJECT_ID('dbo.StagingOrderLines', 'U') IS NOT NULL
drop table StagingOrderLines
CREATE TABLE StagingOrderLines(
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[PickedQuantity] [int] NOT NULL,
	[PickingCompletedWhen] datetime NULL)
go
--***************************** end Staging OrderLines**********************************







--***************************** start Staging Orders************************************
IF OBJECT_ID('dbo.StagingOrders', 'U') IS NOT NULL
drop table StagingOrders
CREATE TABLE StagingOrders(
	[OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PickedByPersonID] [int] NULL,
	[ContactPersonID] [int] NOT NULL,
	[BackorderOrderID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[ExpectedDeliveryDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsUndersupplyBackordered] [bit] NOT NULL,
	[DeliveryInstructions] [nvarchar](max) NULL)
go
--***************************** end Staging Orders***************************************







--***************************** start Staging Customer Transactions************************************
IF OBJECT_ID('dbo.StagingCustomerTransactions', 'U') IS NOT NULL
drop table StagingCustomerTransactions
CREATE TABLE StagingCustomerTransactions(
	[CustomerTransactionID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[TransactionTypeID] [int] NOT NULL,
	[InvoiceID] [int] NULL,
	[PaymentMethodID] [int] NULL,
	[TransactionDate] [date] NOT NULL,
	[AmountExcludingTax] [decimal](18, 2) NOT NULL,
	[TaxAmount] [decimal](18, 2) NOT NULL,
	[TransactionAmount] [decimal](18, 2) NOT NULL
)
Go
--***************************** end Staging Customer Transactions**********************************************
