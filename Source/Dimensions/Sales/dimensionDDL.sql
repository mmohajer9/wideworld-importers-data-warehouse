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
--***************************************************************** END INVOICE DIMENTION AREA*************************








--***************************************************************** START PAYMENT DIMENTION AREA*************************
IF OBJECT_ID('dbo.DimPayment', 'U') IS NOT NULL
drop table DimPayment
CREATE TABLE DimPayment (PaymentKey int primary key , PaymentMethodName nvarchar(100))
Go
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
--***************************************************************** END PEOPLE DIMENTION AREA*************************