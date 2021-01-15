use [WWI-Staging]





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
