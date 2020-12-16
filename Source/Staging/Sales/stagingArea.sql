use WideWorldImporters



--*****************************start Staging People******************************
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
CREATE or alter PROCEDURE FillStagingPeople AS
BEGIN
	truncate table StagingPeople
	insert into StagingPeople(
			PersonID,FullName,PreferredName,IsPermittedToLogon,IsExternalLogonProvider,IsSystemUser,IsEmployee,
			IsSalesperson,UserPreferences,PhoneNumber,FaxNumber,EmailAddress,Photo,CustomFields)
	select 
			PersonID,FullName,PreferredName,IsPermittedToLogon,IsExternalLogonProvider,IsSystemUser,IsEmployee,
			IsSalesperson,UserPreferences,PhoneNumber,FaxNumber,EmailAddress,Photo,CustomFields
	from Application.People

END
GO
--***************************** end Staging People*******************************





--***************************** start Staging PaymentMethod*******************************
drop table StagingPaymentMethods
CREATE TABLE StagingPaymentMethods(
	[PaymentMethodID] [int] NOT NULL,
	[PaymentMethodName] [nvarchar](50) NOT NULL)
Go
create or alter procedure FillStagingPaymentMethods as
begin
	truncate table StagingPaymentMethods
	insert into StagingPaymentMethods([PaymentMethodID],[PaymentMethodName])
		select [PaymentMethodID],[PaymentMethodName] from Application.PaymentMethods
end

select * from StagingPaymentMethods
exec FillStagingPaymentMethods
select * from StagingPaymentMethods
--***************************** end Staging PaymentMethod*******************************





--***************************** start Staging Delivery method*******************************
drop table StagingDeliveryMethods
CREATE TABLE StagingDeliveryMethods(
	[DeliveryMethodID] [int] NOT NULL,
	[DeliveryMethodName] [nvarchar](50) NOT NULL)
Go
create or alter procedure FillStagingDeliveryMethods as
begin
	truncate table StagingDeliveryMethods
	insert into StagingDeliveryMethods([DeliveryMethodID],[DeliveryMethodName])
		select [DeliveryMethodID],[DeliveryMethodName] from Application.DeliveryMethods
end

select * from StagingDeliveryMethods
exec FillStagingDeliveryMethods
select * from StagingDeliveryMethods
--***************************** end Staging delivery method*******************************





--***************************** start Staging Cities*******************************
drop table StagingCities
CREATE TABLE StagingCities(
	CityID [int] NOT NULL primary key,
	[CityName] [nvarchar](50) NOT NULL,
	[StateProvinceID] [int] NOT NULL,
	[LatestRecordedPopulation] [bigint] NULL,)
Go
CREATE or alter PROCEDURE FillStagingCities AS
begin
	truncate table StagingCities
	insert into StagingCities(CityID,[CityName],[StateProvinceID],[LatestRecordedPopulation])
	select CityID,[CityName],[StateProvinceID],[LatestRecordedPopulation] From Application.Cities
end
GO
select * from StagingCities
exec FillStagingCities
select * from StagingCities
--***************************** end Staging Cities*******************************





--***************************** start Staging Province*******************************
drop table StagingStateProvinces
CREATE TABLE StagingStateProvinces(
	[StateProvinceID] [int] NOT NULL primary key,
	[StateProvinceCode] [nvarchar](5) NOT NULL,
	[StateProvinceName] [nvarchar](50) NOT NULL,
	[CountryID] [int] NOT NULL,
	[SalesTerritory] [nvarchar](50) NOT NULL,
	[LatestRecordedPopulation] [bigint] NULL)
Go
CREATE or alter PROCEDURE FillStagingStateProvinces AS
begin
	truncate table StagingStateProvinces
	insert into StagingStateProvinces([StateProvinceID],[StateProvinceCode],[StateProvinceName],[CountryID],[SalesTerritory],
		[LatestRecordedPopulation])
	select [StateProvinceID],[StateProvinceCode],[StateProvinceName],[CountryID],[SalesTerritory],[Border],
		[LatestRecordedPopulation] from Application.StateProvinces
end
GO
select * from StagingStateProvinces
exec FillStagingStateProvinces
select * from StagingStateProvinces
--***************************** end Staging Province*********************************





--***************************** start Staging BuyingGroups*******************************
drop table StagingBuyingGroups
CREATE TABLE StagingBuyingGroups(
	[BuyingGroupID] [int] NOT NULL,
	[BuyingGroupName] [nvarchar](50) NOT NULL
)
GO
CREATE or alter PROCEDURE FillStagingBuyingGroups AS
begin
	truncate table StagingBuyingGroups
	insert into StagingBuyingGroups([BuyingGroupID],[BuyingGroupName])
	select [BuyingGroupID],[BuyingGroupName] from Sales.BuyingGroups
end
GO
select * from StagingBuyingGroups
exec FillStagingBuyingGroups
select * from StagingBuyingGroups
--***************************** end Staging BuyingGroups*********************************







--***************************** start Staging CustomerCategories*******************************
drop table StagingCustomerCategories
CREATE TABLE StagingCustomerCategories(
	[CustomerCategoryID] [int] NOT NULL,
	[CustomerCategoryName] [nvarchar](50) NOT NULL)
Go
create or alter procedure FillStagingCustomerCategories as
begin
	truncate table StagingCustomerCategories
	insert into StagingCustomerCategories([CustomerCategoryID],[CustomerCategoryName])
		select [CustomerCategoryID],[CustomerCategoryName] from Sales.CustomerCategories
end
Go
select * from StagingCustomerCategories
exec FillStagingCustomerCategories
select * from StagingCustomerCategories
--***************************** end Staging CustomerCategories*******************************







--***************************** start Staging Customers*******************************
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
	[DeliveryAddressLine2],[DeliveryPostalCode],[PostalAddressLine1],[PostalAddressLine2],[PostalPostalCode] from Sales.Customers
end
GO
select * from StagingCustomers
exec FillStagingCustomers
select * from StagingCustomers
--***************************** end Staging Customers**********************************







--***************************** start Staging InvoiceLines*******************************
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
create or alter procedure FillStagingInvoiceLines as
begin
	create table tmp(id int)
	insert into tmp (id) select [InvoiceLineID] from StagingInvoiceLines
	insert into StagingInvoiceLines([InvoiceLineID],[InvoiceID],[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],
	[TaxRate],[TaxAmount],[LineProfit],[ExtendedPrice])
	select [InvoiceLineID],[InvoiceID],[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],
	[TaxRate],[TaxAmount],[LineProfit],[ExtendedPrice] from Sales.InvoiceLines where InvoiceLineID not in (select id from tmp)
	drop table tmp
end
go
select * from StagingInvoiceLines
exec FillStagingInvoiceLines
select * from StagingInvoiceLines
--***************************** end Staging InvoiceLines*******************************







--***************************** start Staging Invoices*******************************
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
create or alter procedure FillStagingInvoices as 
begin
	
	declare @last_added date = (select isnull(max(InvoiceDate),'2012-12-31') from StagingInvoices)

	insert into StagingInvoices([InvoiceID],[CustomerID],[BillToCustomerID],[OrderID],[DeliveryMethodID],[ContactPersonID],[AccountsPersonID],
	[SalespersonPersonID],[PackedByPersonID],[InvoiceDate],[CustomerPurchaseOrderNumber],[IsCreditNote],[CreditNoteReason],[Comments],
	[DeliveryInstructions],[InternalComments],[TotalDryItems],[TotalChillerItems],[DeliveryRun],[RunPosition],[ReturnedDeliveryData])
	select [InvoiceID],[CustomerID],[BillToCustomerID],[OrderID],[DeliveryMethodID],[ContactPersonID],[AccountsPersonID],
	[SalespersonPersonID],[PackedByPersonID],[InvoiceDate],[CustomerPurchaseOrderNumber],[IsCreditNote],[CreditNoteReason],[Comments],
	[DeliveryInstructions],[InternalComments],[TotalDryItems],[TotalChillerItems],[DeliveryRun],[RunPosition],[ReturnedDeliveryData]
	from Sales.Invoices where InvoiceDate > @last_added

end

select * from StagingInvoices
exec FillStagingInvoices
select * from StagingInvoices
--***************************** end Staging Invoices**********************************







--***************************** start Staging OrderLines*******************************
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
create or alter procedure FillStagingOrderLines as 
begin
	create table tmp(id int)
	insert into tmp (id) select [OrderLineID] from StagingOrderLines

	insert into StagingOrderLines([OrderLineID],[OrderID],[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],[TaxRate],
	[PickedQuantity],[PickingCompletedWhen])
	select [OrderLineID],[OrderID],[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],[TaxRate],
	[PickedQuantity],[PickingCompletedWhen]
	from Sales.OrderLines where [OrderLineID] not in (select id from tmp)
	drop table tmp
end
select * from StagingOrderLines
exec FillStagingOrderLines
select * from StagingOrderLines
--***************************** end Staging OrderLines**********************************







--***************************** start Staging Orders************************************
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
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[PickingCompletedWhen] [datetime2](7) NULL)
go
create or alter procedure FillStagingOrders as 
begin
	declare @last_added date = (select isnull(max([OrderDate]),'2012-12-31') from StagingOrders)
	insert into StagingOrders([OrderID],[CustomerID],[SalespersonPersonID],[PickedByPersonID],[ContactPersonID],[BackorderOrderID],
	[OrderDate],[ExpectedDeliveryDate],[CustomerPurchaseOrderNumber],[IsUndersupplyBackordered],[Comments],[DeliveryInstructions],
	[InternalComments],[PickingCompletedWhen])
	select [OrderID],[CustomerID],[SalespersonPersonID],[PickedByPersonID],[ContactPersonID],[BackorderOrderID],
	[OrderDate],[ExpectedDeliveryDate],[CustomerPurchaseOrderNumber],[IsUndersupplyBackordered],[Comments],[DeliveryInstructions],
	[InternalComments],[PickingCompletedWhen]
	from Sales.Orders where OrderDate > @last_added
end

select * from StagingOrders
exec FillStagingOrders
select * from StagingOrders
--***************************** end Staging OrderLines***************************************







--***************************** start Staging Customer Transactions************************************
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
	[TransactionAmount] [decimal](18, 2) NOT NULL,
	[OutstandingBalance] [decimal](18, 2) NOT NULL,
	[FinalizationDate] [date] NULL,
	[IsFinalized]  AS (case when [FinalizationDate] IS NULL then CONVERT([bit],(0)) else CONVERT([bit],(1)) end) PERSISTED,
)
Go
create or alter procedure FillStagingCustomerTransactions as
begin
		declare @last_added date = (select isnull(max([TransactionDate]),'2012-12-31') from StagingCustomerTransactions)
		insert into StagingCustomerTransactions([CustomerTransactionID],[CustomerID],[TransactionTypeID],[InvoiceID],[PaymentMethodID],
		[TransactionDate],[AmountExcludingTax],[TaxAmount],[TransactionAmount],[OutstandingBalance],[FinalizationDate])
		select [CustomerTransactionID],[CustomerID],[TransactionTypeID],[InvoiceID],[PaymentMethodID],
		[TransactionDate],[AmountExcludingTax],[TaxAmount],[TransactionAmount],[OutstandingBalance],[FinalizationDate]
		from Sales.CustomerTransactions where TransactionDate > @last_added
end
select * from StagingCustomerTransactions
exec FillStagingCustomerTransactions
select * from StagingCustomerTransactions

--***************************** end Staging Customer Transactions**********************************************
