use WideWorldImporters



--***************************************************************** START ORDER DIMENTION AREA*************************
;----------------order dim table---------------------------
IF OBJECT_ID('dbo.DimOrder', 'U') IS NOT NULL
drop table DimOrder
create table DimOrder(
	OrderKey int primary key,
	CustomerID nvarchar(256),
	CustomerName nvarchar(200),
	OrderDate date,
	ExpectedDelivareDate date,
	PrimaryContactPersonID int,
	PrimaryContactName nvarchar(100),
	PrimaryContactPhone nvarchar (25)
)
Go
;--------------------Fill Procedure------------------------------
CREATE OR ALTER  Procedure FillDimOrder as
Begin

	CREATE TABLE TMP(OrderID int)
	insert into TMP select Distinct OrderKey from DimOrder

	INSERT INTO dbo.DimOrder (OrderKey, CustomerID, CustomerName, OrderDate, ExpectedDelivareDate,
	 PrimaryContactPersonID, PrimaryContactName, PrimaryContactPhone)
	SELECT StagingOrders.OrderID, StagingOrders.CustomerID, StagingCustomers.CustomerName, StagingOrders.OrderDate,
			StagingOrders.ExpectedDeliveryDate,
			StagingOrders.ContactPersonID, StagingPeople.FullName, StagingPeople.PhoneNumber
	from StagingOrders JOIN StagingCustomers ON StagingCustomers.CustomerID = StagingOrders.CustomerID
			JOIN StagingPeople ON StagingPeople.PersonID = StagingOrders.ContactPersonID
			where StagingOrders.OrderID Not IN (select TMP.OrderID from TMP)

	insert into LogSales(ActionName,TableName,date,RecordId)
	select 'insert','DimOrder',getdate(),DimOrder.OrderKey from DimOrder where OrderKey Not in(select tmp.OrderID from TMP)

	DROP TABLE TMP
END
;--------------------END Fill Procedure--------------------------
EXEC FillDimOrder
SELECT * FROM DimOrder order by OrderKey
--***************************************************************** END ORDER DIMENTION AREA*************************






--***************************************************************** START CUSTOMER DIMENTION AREA*************************
;----------------customer dim table---------------------------
IF OBJECT_ID('dbo.DimCustomer', 'U') IS NOT NULL
drop table DimCustomer
create table DimCustomer(
	CustomerKey int IDENTITY(1,1) primary key, -- surggate key
	CustomerID int,
	CustomerName nvarchar(200),
	CategoryID int,
	CategoryName nvarchar(256),
	BuyingGroupID int,
	BuyingGroupName nvarchar(100),
	AccountOpenDate date,
	Website nvarchar(300),
	DeliveryCityID int,
	DeliveryCityName nvarchar(100),
	DeliveryProvinceName nvarchar(100),
	DeliveryAddressLine1 nvarchar(100),
	DeliveryAddressLine2 nvarchar(100),
	DeliveryPostalCode nvarchar(20),
	PrimaryContactPersonID int,
	PrimaryContactName nvarchar(100),
	PhoneNumber nvarchar(30), -- can change with scd type 2
	StartDate date,
	EndDate date,
	CurrentFlag bit
)
GO
;--------------------Fill Procedure------------------------------
CREATE OR ALTER PROCEDURE FillDimCustomer AS
BEGIN

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
		FROM StagingCustomers AS Customer 
		JOIN StagingCustomerCategories As Category ON Category.CustomerCategoryID = Customer.CustomerCategoryID
		LEFT JOIN StagingBuyingGroups AS BuyGroup ON BuyGroup.BuyingGroupID = Customer.BuyingGroupID
		JOIN StagingPeople AS People ON People.PersonID = Customer.PrimaryContactPersonID
		Join StagingCities As City On Customer.DeliveryCityID = City.CityID
		Join StagingStateProvinces As Province ON City.StateProvinceID = Province.StateProvinceID

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
			select CustomerID from TMP where CustomerID not in (select CustomerID from DimCustomer)
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
;--------------------END Fill Procedure--------------------------
EXEC FillDimCustomer
SELECT * FROM DimCustomer order by CustomerID
--***************************************************************** END CUSTOMER DIMENTION AREA*************************







--***************************************************************** START INVOICE DIMENTION AREA*************************
;----------------invoice dim table---------------------------
IF OBJECT_ID('dbo.DimInvoice', 'U') IS NOT NULL
drop table DimInvoice
create table DimInvoice(
	InvoiceKey int primary key,
	CustomerID int,
	CustomerName nvarchar(200),
	BillToCustomerID int,
	BillCustomerName nvarchar(200),
	OrderID int,
	InvoiceDate date,
	PackedByPersonID int,
	PackedByPersonName nvarchar(100),
	DeliveryMethodID int,
	DeliveryMethodName nvarchar(100),
	DeliveryAddress nvarchar(max),
	DeliveryDate datetime null, --scd type one
	ReceivedBy nvarchar(200) null --scd type one
)
Go
;--------------------Fill Procedure------------------------------
CREATE OR ALTER PROCEDURE FillDimInvoice AS
BEGIN

	CREATE TABLE TMP_ID (ID int)
	INSERT INTO TMP_ID
		SELECT DISTINCT InvoiceKey FROM DimInvoice WHERE DimInvoice.DeliveryDate IS NULL AND DimInvoice.ReceivedBy IS NULL

	UPDATE DimInvoice Set DeliveryDate = (SELECT StagingInvoices.ConfirmedDeliveryTime from StagingInvoices WHERE StagingInvoices.InvoiceID = DimInvoice.InvoiceKey),
				ReceivedBy = (SELECT StagingInvoices.ConfirmedReceivedBy from StagingInvoices WHERE StagingInvoices.InvoiceID = DimInvoice.InvoiceKey)
	WHERE InvoiceKey IN (SELECT distinct ID FROM TMP_ID)

	insert into LogSales(ActionName,TableName,date,RecordId)
	select 'update','DimInvoice',getdate(), DimInvoice.InvoiceKey
	from DimInvoice where DimInvoice.InvoiceKey  in(select ID from TMP_ID)

	truncate table TMP_ID
	insert into TMP_ID select InvoiceKey from DimInvoice

	INSERT INTO DimInvoice (InvoiceKey, CustomerID, CustomerName, BillToCustomerID, BillCustomerName, OrderID, InvoiceDate,
		PackedByPersonID, PackedByPersonName, DeliveryMethodID, DeliveryMethodName,DeliveryAddress, DeliveryDate, ReceivedBy)
		SELECT Invoice.InvoiceID, Invoice.CustomerID, Customer.CustomerName, Invoice.BillToCustomerID, BillCustomer.CustomerName,
		Invoice.OrderID, Invoice.InvoiceDate,  Invoice.PackedByPersonID , People.FullName,
		Invoice.DeliveryMethodID , Delivery.DeliveryMethodName, Invoice.DeliveryInstructions, Invoice.ConfirmedDeliveryTime , Invoice.ConfirmedReceivedBy
		FROM StagingInvoices AS Invoice
		JOIN StagingCustomers AS Customer ON Customer.CustomerID = Invoice.CustomerID
		JOIN StagingCustomers AS BillCustomer ON BillCustomer.CustomerID = Invoice.BillToCustomerID
		JOIN StagingPeople As People ON People.PersonID = Invoice.PackedByPersonID
		JOIN StagingDeliveryMethods As Delivery On Delivery.DeliveryMethodID = Invoice.DeliveryMethodID
		where Invoice.InvoiceID not in (select id from TMP_ID)

	insert into LogSales(ActionName,TableName,date,RecordId)
	select 'insert','DimInvoice',getdate(), DimInvoice.InvoiceKey
	from DimInvoice where DimInvoice.InvoiceKey not in(select ID from TMP_ID)


	DROP TABLE TMP_ID;
END


;--------------------END Fill Procedure--------------------------
EXEC FillDimInvoice
select * from DimInvoice
--***************************************************************** END INVOICE DIMENTION AREA*************************








--***************************************************************** START PAYMENT DIMENTION AREA*************************
IF OBJECT_ID('dbo.DimPayment', 'U') IS NOT NULL
drop table DimPayment
CREATE TABLE DimPayment (PaymentKey int primary key , PaymentMethodName nvarchar(100))
Go
CREATE OR ALTER PROCEDURE FillDimPayment AS
BEGIN
	truncate table dbo.DimPayment
	Insert Into dbo.DimPayment(PaymentKey, PaymentMethodName)
		select PaymentMethodID, PaymentMethodName from StagingPaymentMethods
END
;--------------------END Fill Procedure--------------------------
exec FillDimPayment
select * from DimPayment
--***************************************************************** END PAYMENT DIMENTION AREA*************************








--***************************************************************** START PEOPLE DIMENTION AREA*************************
;----------------people dim table---------------------------
IF OBJECT_ID('dbo.DimPeople', 'U') IS NOT NULL
drop table DimPeople
create table DimPeople(
	PeopleKey int primary key,
	FullName nvarchar(100),
	PreferredName nvarchar(100),
	IsEmployee bit,
	IsSalesPerson bit,
	CurrentPhoneNumber nvarchar(30),--scd type three
	PreviousPhoneNumber nvarchar(30),
	PhoneEffectiveDate date,
	FaxNumber nvarchar(30),
	CurrentEmailAddress nvarchar(300),--scd type three
	PreviousEmailAddress nvarchar(300),
	EmailEffectiveDate date
)
Go
;--------------------Fill Procedure------------------------------
CREATE OR ALTER PROCEDURE FillDimPeople AS
BEGIN
	declare @today date = getdate()

	create table tmp(PeopleKey int)
	insert into tmp(PeopleKey)
		select PeopleKey From DimPeople Join StagingPeople as People ON
		People.PersonID = DimPeople.PeopleKey AND DimPeople.CurrentPhoneNumber <> People.PhoneNumber

	Update DimPeople SET PreviousPhoneNumber = DimPeople.CurrentPhoneNumber,
	CurrentPhoneNumber = (Select PhoneNumber From StagingPeople as p Where p.PersonID = DimPeople.PeopleKey),
	PhoneEffectiveDate = @today
	where DimPeople.PeopleKey IN (select PeopleKey from tmp)

	insert into LogSales(ActionName,TableName,date,RecordId)
		select 'update','DimPeople',getdate(), tmp.PeopleKey from tmp
	truncate table tmp

	insert into tmp(PeopleKey)
		select PeopleKey From DimPeople Join StagingPeople as People ON
		People.PersonID = DimPeople.PeopleKey AND DimPeople.CurrentEmailAddress <> People.EmailAddress

	Update DimPeople SET PreviousEmailAddress = DimPeople.CurrentEmailAddress,
	CurrentEmailAddress = (Select EmailAddress From StagingPeople as p Where p.PersonID = DimPeople.PeopleKey),
	EmailEffectiveDate = @today
	where DimPeople.PeopleKey IN (select PeopleKey from tmp)

	insert into LogSales(ActionName,TableName,date,RecordId)
		select 'update','DimPeople',getdate(), tmp.PeopleKey from tmp
	truncate table tmp


	insert into tmp select PeopleKey from DimPeople

	insert into DimPeople(PeopleKey,FullName,PreferredName,IsEmployee,IsSalesPerson,CurrentPhoneNumber,PreviousPhoneNumber,
		PhoneEffectiveDate,FaxNumber,CurrentEmailAddress,PreviousEmailAddress,EmailEffectiveDate)
		select PersonID,FullName,PreferredName,IsEmployee,IsSalesPerson,PhoneNumber,NULL,
		@today,FaxNumber,EmailAddress,NULL,@today from StagingPeople as People where People.PersonID not in (select tmp.PeopleKey From tmp)

	insert into LogSales(ActionName,TableName,date,RecordId)
		select 'insert','DimPeople',getdate(), DimPeople.PeopleKey
		from DimPeople where DimPeople.PeopleKey  not in (select tmp.PeopleKey From tmp)

	drop table tmp
END
;--------------------END Fill Procedure--------------------------
exec FillDimPeople
select * from DimPeople order by PeopleKey
--***************************************************************** END PEOPLE DIMENTION AREA*************************

