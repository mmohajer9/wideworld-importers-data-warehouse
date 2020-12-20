--*****************************start Staging People******************************
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







--***************************** start Staging InvoiceLines*******************************
create or alter procedure FillStagingInvoiceLines as
begin
	IF OBJECT_ID('dbo.tmp', 'U') IS NOT NULL
	drop table tmp
	create table tmp(id int)
	insert into tmp (id) select [InvoiceLineID] from StagingInvoiceLines
	insert into StagingInvoiceLines([InvoiceLineID],[InvoiceID],[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],
	[TaxRate],[TaxAmount],[LineProfit],[ExtendedPrice])
	select [InvoiceLineID],[InvoiceID],[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],
	[TaxRate],[TaxAmount],[LineProfit],[ExtendedPrice] from [WideWorldImporters].Sales.InvoiceLines where InvoiceLineID not in (select id from tmp)
	drop table tmp
end
GO
--***************************** end Staging InvoiceLines*******************************







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







--***************************** start Staging OrderLines*******************************
create or alter procedure FillStagingOrderLines as 
begin
	IF OBJECT_ID('dbo.tmp', 'U') IS NOT NULL
	drop table tmp
	create table tmp(id int)
	insert into tmp (id) select [OrderLineID] from StagingOrderLines

	insert into StagingOrderLines([OrderLineID],[OrderID],[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],[TaxRate],
	[PickedQuantity],[PickingCompletedWhen])
	select [OrderLineID],[OrderID],[StockItemID],[Description],[PackageTypeID],[Quantity],[UnitPrice],[TaxRate],
	[PickedQuantity],[PickingCompletedWhen]
	from [WideWorldImporters].Sales.OrderLines where [OrderLineID] not in (select id from tmp)
	drop table tmp
end
Go
--***************************** end Staging OrderLines**********************************







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
--***************************** end Staging Customer Transactions**********************************************



CREATE OR ALTER PROCEDURE FILL_SALES_STAGING_AREA
AS
BEGIN

	EXECUTE FillStagingPeople;
	EXECUTE FillStagingPaymentMethods;
	EXECUTE FillStagingDeliveryMethods;
	EXECUTE FillStagingCities;
	EXECUTE FillStagingStateProvinces;
	EXECUTE FillStagingBuyingGroups;
	EXECUTE FillStagingCustomerCategories;
	EXECUTE FillStagingCustomers;
	EXECUTE FillStagingInvoiceLines;
	EXECUTE FillStagingInvoices;
	EXECUTE FillStagingOrderLines;
	EXECUTE FillStagingOrders;
	EXECUTE FillStagingCustomerTransactions;

END
--------------------------------------------------------------------------------------------------------------
GO