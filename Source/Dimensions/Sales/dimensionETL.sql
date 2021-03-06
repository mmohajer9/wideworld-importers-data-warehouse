use [WWI-DW]



--***************************************************************** START Invoice DIMENTION AREA*************************
Go
CREATE OR ALTER  Procedure FillDimInvoice as
Begin
	
	declare @init bit = (select isnull((select InvoiceKey from DimInvoice where DimInvoice.InvoiceKey = -1), 0))
	if(@init = 0) begin
		insert into DimInvoice(InvoiceKey) values(-1)
	end


	IF OBJECT_ID('dbo.TMP', 'U') IS NOT NULL
		DROP TABLE TMP
	CREATE TABLE TMP(ID int)
	insert into TMP(ID) select InvoiceKey from DimInvoice 
	join [WWI-Staging].dbo.StagingInvoices AS Invoice ON DimInvoice.InvoiceKey = Invoice.InvoiceID AND 
	DimInvoice.ReceivedBy IS NULL AND Invoice.ConfirmedReceivedBy <> NULL


	insert into LogSales(ActionName,TableName,date,RecordId)
	select 'delete','DimInvoice',getdate(),DimInvoice.InvoiceKey from DimInvoice where InvoiceKey in(select tmp.ID from TMP)
	delete from DimInvoice where DimInvoice.InvoiceKey IN (select ID From TMP)



	truncate table tmp
	insert into TMP(ID) select InvoiceKey from DimInvoice 


	INSERT INTO [WWI-DW].dbo.DimInvoice(InvoiceKey, CustomerID, CustomerName, BillToCustomerID,BillCustomerName,
		OrderID, InvoiceDate,PackedByPersonID,PackedByPersonName,DeliveryMethodID,DeliveryMethodName,
		DeliveryAddress,DeliveryDate,ReceivedBy,ExpectedDelivareDate, PrimaryContactPersonID, PrimaryContactName,
		PrimaryContactPhone)
		SELECT Invoice.InvoiceID, Invoice.CustomerID,Customer.CustomerName, Invoice.BillToCustomerID , BillCustomer.CustomerName,
		Invoice.OrderID, Invoice.InvoiceDate, Invoice.PackedByPersonID, People.FullName, Invoice.DeliveryMethodID,
		Delivery.DeliveryMethodName, Invoice.DeliveryInstructions, Invoice.ConfirmedDeliveryTime,Invoice.ConfirmedReceivedBy,
		orders.ExpectedDeliveryDate, Orders.ContactPersonID, PrimaryPerson.FullName, PrimaryPerson.PhoneNumber
		FROM [WWI-Staging].dbo.StagingInvoices AS Invoice
		JOIN [WWI-Staging].dbo.StagingCustomers AS Customer ON Customer.CustomerID = Invoice.CustomerID
		JOIN [WWI-Staging].dbo.StagingCustomers AS BillCustomer ON BillCustomer.CustomerID = Invoice.BillToCustomerID
		JOIN [WWI-Staging].dbo.StagingPeople AS People ON People.PersonID = Invoice.PackedByPersonID
		JOIN [WWI-Staging].dbo.StagingDeliveryMethods AS Delivery ON Delivery.DeliveryMethodID = Invoice.DeliveryMethodID
		JOIN [WWI-Staging].dbo.StagingOrders AS Orders ON Orders.OrderID = Invoice.OrderID
		JOIN [WWI-Staging].dbo.StagingPeople AS PrimaryPerson ON PrimaryPerson.PersonID = Orders.ContactPersonID
		where Invoice.InvoiceID NOT IN (select ID From TMP)

	
	insert into LogSales(ActionName,TableName,date,RecordId)
	select 'insert','DimInvoice',getdate(),DimInvoice.InvoiceKey from DimInvoice where InvoiceKey Not in(select tmp.ID from TMP)

	DROP TABLE TMP
END
GO


create or alter procedure FillDimInvoiceFirstLoad as 
begin
	truncate table DimInvoice
	exec FillDimInvoice
end
Go
--***************************************************************** END Invoice DIMENTION AREA*************************












--***************************************************************** START CUSTOMER DIMENTION AREA*************************
CREATE OR ALTER PROCEDURE FillDimCustomer AS
BEGIN

	SET IDENTITY_INSERT DimCustomer ON
	declare @init bit = (select isnull((select CustomerKey from DimCustomer where DimCustomer.CustomerKey = -1), 0))
	if(@init = 0) begin
		insert into DimCustomer(CustomerKey) values(-1)
		end
	SET IDENTITY_INSERT DimCustomer OFF



	IF OBJECT_ID('dbo.TMP', 'U') IS NOT NULL
	DROP TABLE TMP
	CREATE TABLE TMP(
		CustomerID int,CustomerName nvarchar(200),CategoryID int,CategoryName nvarchar(256),BuyingGroupID int,BuyingGroupName nvarchar(100),
		AccountOpenDate date,Website nvarchar(300),DeliveryCityID int,DeliveryCityName nvarchar(100),DeliveryProvinceName nvarchar(100),
		DeliveryAddressLine1 nvarchar(100),DeliveryAddressLine2 nvarchar(100),DeliveryPostalCode nvarchar(20),PrimaryContactPersonID int,
		PrimaryContactName nvarchar(100),PhoneNumber nvarchar(30),)
	INSERT INTO TMP(CustomerID,CustomerName,CategoryID,CategoryName,BuyingGroupID,BuyingGroupName,AccountOpenDate,Website,DeliveryCityID,
		DeliveryCityName,DeliveryProvinceName,DeliveryAddressLine1,DeliveryAddressLine2,DeliveryPostalCode,PrimaryContactPersonID,
		PrimaryContactName,PhoneNumber)
		SELECT Customer.CustomerID, Customer.CustomerName, Customer.CustomerCategoryID, Category.CustomerCategoryName, Customer.BuyingGroupID,
				BuyGroup.BuyingGroupName, Customer.AccountOpenedDate, Customer.WebsiteURL, Customer.DeliveryCityID, City.CityName, Province.StateProvinceName,
				Customer.DeliveryAddressLine1,Customer.DeliveryAddressLine2, Customer.DeliveryPostalCode, Customer.PrimaryContactPersonID, People.FullName,Customer.PhoneNumber
		FROM [WWI-Staging].dbo.StagingCustomers AS Customer 
		JOIN [WWI-Staging].dbo.StagingCustomerCategories As Category ON Category.CustomerCategoryID = Customer.CustomerCategoryID
		LEFT JOIN [WWI-Staging].dbo.StagingBuyingGroups AS BuyGroup ON BuyGroup.BuyingGroupID = Customer.BuyingGroupID
		JOIN [WWI-Staging].dbo.StagingPeople AS People ON People.PersonID = Customer.PrimaryContactPersonID
		Join [WWI-Staging].dbo.StagingCities As City On Customer.DeliveryCityID = City.CityID
		Join [WWI-Staging].dbo.StagingStateProvinces As Province ON City.StateProvinceID = Province.StateProvinceID

		IF OBJECT_ID('dbo.TMP_ID', 'U') IS NOT NULL
		DROP TABLE TMP_ID
		CREATE TABLE TMP_ID(ID int)

		INSERT INTO TMP_ID
			SELECT TMP.CustomerID from TMP JOIN DimCustomer ON DimCustomer.CustomerID = TMP.CustomerID AND 
				DimCustomer.PhoneNumber <> TMP.PhoneNumber

		UPDATE DimCustomer SET CurrentFlag = 0 , EndDate = getdate()
			WHERE CustomerID IN (SELECT ID FROM TMP_ID)

		insert into LogSales(ActionName,TableName,date,RecordId,RecordSurrogateKey)
		select 'update','DimCustomer',getdate(), DimCustomer.CustomerID,DimCustomer.CustomerKey 
		from DimCustomer where DimCustomer.CustomerID  in(select ID from TMP_ID)


		insert into TMP_ID
			select CustomerID from TMP where CustomerID not in (select isnull(CustomerID,-1) from DimCustomer)

		INSERT INTO DimCustomer (CustomerID ,CustomerName ,CategoryID ,CategoryName ,BuyingGroupID ,BuyingGroupName ,AccountOpenDate ,
					Website ,DeliveryCityID,DeliveryCityName,DeliveryProvinceName,DeliveryAddressLine1 ,DeliveryAddressLine2 ,DeliveryPostalCode ,PrimaryContactPersonID ,
					PrimaryContactName ,PhoneNumber ,EndDate ,StartDate ,CurrentFlag)
		SELECT CustomerID,CustomerName,CategoryID,CategoryName,BuyingGroupID,BuyingGroupName,AccountOpenDate,Website,
							DeliveryCityID,DeliveryCityName,DeliveryProvinceName,DeliveryAddressLine1,DeliveryAddressLine2,DeliveryPostalCode,PrimaryContactPersonID,
							PrimaryContactName, PhoneNumber, NULL, getdate(), 1 
		FROM TMP WHERE CustomerID IN (SELECT distinct ID FROM TMP_ID)

		insert into LogSales(ActionName,TableName,date,RecordId,RecordSurrogateKey)
		select 'insert','DimCustomer',getdate(), DimCustomer.CustomerID,DimCustomer.CustomerKey 
		from DimCustomer where DimCustomer.CustomerID  in(select ID from TMP_ID)

		DROP table TMP
		DROP Table TMP_ID
END
GO


create or alter procedure FillDimCustomerFirstLoad as 
begin
	truncate table DimCustomer
	exec FillDimCustomer
end
Go
--***************************************************************** END CUSTOMER DIMENTION AREA*************************













--***************************************************************** START PAYMENT DIMENTION AREA*************************
CREATE OR ALTER PROCEDURE FillDimPayment AS
BEGIN
	declare @init bit = (select isnull((select PaymentKey from DimPayment where DimPayment.PaymentKey = -1), 0))
	if(@init = 0) 
		insert into DimPayment(PaymentKey) values(-1)

	IF OBJECT_ID('dbo.tmp', 'U') IS NOT NULL
	DROP TABLE tmp
	create table tmp(id int)
		insert into tmp(id) select PaymentKey from DimPayment
	
	Insert Into DimPayment(PaymentKey, PaymentMethodName)
		select PaymentMethodID, PaymentMethodName from [WWI-Staging].dbo.StagingPaymentMethods where PaymentMethodID not in (select id from tmp)
	DROP TABLE tmp	
END
Go

create or alter procedure FillDimPaymentFirstLoad as 
begin
	truncate table DimPayment
	exec FillDimPayment
end
Go
--***************************************************************** END PAYMENT DIMENTION AREA*************************








--***************************************************************** START PEOPLE DIMENTION AREA*************************
CREATE OR ALTER PROCEDURE FillDimPeople AS
BEGIN
	declare @today date = getdate()

	declare @init bit = (select isnull((select PeopleKey from DimPeople where DimPeople.PeopleKey = -1), 0))
	if(@init = 0) 
		insert into DimPeople(PeopleKey) values(-1)

	IF OBJECT_ID('dbo.tmp', 'U') IS NOT NULL
	DROP TABLE tmp
	create table tmp(PeopleKey int)
	insert into tmp(PeopleKey)
		select PeopleKey From DimPeople Join [WWI-Staging].dbo.StagingPeople as People ON
		People.PersonID = DimPeople.PeopleKey AND DimPeople.CurrentPhoneNumber <> People.PhoneNumber

	Update DimPeople SET PreviousPhoneNumber = DimPeople.CurrentPhoneNumber,
	CurrentPhoneNumber = (Select PhoneNumber From [WWI-Staging].dbo.StagingPeople as p Where p.PersonID = DimPeople.PeopleKey),
	PhoneEffectiveDate = @today
	where DimPeople.PeopleKey IN (select PeopleKey from tmp)

	insert into LogSales(ActionName,TableName,date,RecordId)
		select 'update','DimPeople',getdate(), tmp.PeopleKey from tmp
	truncate table tmp

	insert into tmp(PeopleKey)
		select PeopleKey From DimPeople Join [WWI-Staging].dbo.StagingPeople as People ON
		People.PersonID = DimPeople.PeopleKey AND DimPeople.CurrentEmailAddress <> People.EmailAddress

	Update DimPeople SET PreviousEmailAddress = DimPeople.CurrentEmailAddress,
	CurrentEmailAddress = (Select EmailAddress From [WWI-Staging].dbo.StagingPeople as p Where p.PersonID = DimPeople.PeopleKey),
	EmailEffectiveDate = @today
	where DimPeople.PeopleKey IN (select PeopleKey from tmp)

	insert into LogSales(ActionName,TableName,date,RecordId)
		select 'update','DimPeople',getdate(), tmp.PeopleKey from tmp
	truncate table tmp


	insert into tmp select PeopleKey from DimPeople

	insert into DimPeople(PeopleKey,FullName,PreferredName,IsEmployee,IsSalesPerson,CurrentPhoneNumber,PreviousPhoneNumber,
		PhoneEffectiveDate,FaxNumber,CurrentEmailAddress,PreviousEmailAddress,EmailEffectiveDate)
		select PersonID,FullName,PreferredName,IsEmployee,IsSalesPerson,PhoneNumber,NULL,
		@today,FaxNumber,EmailAddress,NULL,@today from [WWI-Staging].dbo.StagingPeople as People where People.PersonID not in (select tmp.PeopleKey From tmp)

	insert into LogSales(ActionName,TableName,date,RecordId)
		select 'insert','DimPeople',getdate(), DimPeople.PeopleKey
		from DimPeople where DimPeople.PeopleKey  not in (select tmp.PeopleKey From tmp)

	drop table tmp
END
Go


create or alter procedure FillDimPeopleFirstLoad as 
begin
	truncate table DimPeople
	exec FillDimPeople
end
Go
--***************************************************************** END PEOPLE DIMENTION AREA*************************

