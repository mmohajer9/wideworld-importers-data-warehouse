


create table DimOrder(
	OrderKey int IDENTITY(1,1) primary key,
	OrderID int,
	CustomerID nvarchar(256),
	CustomerName nvarchar(200),
	OrderDate date,
	ExpectedDelivareDate date,
	Comments nvarchar(max),
	StockItemID int,
	StockItemDescription nvarchar(200),
	PrimaryContactPersonID int,
	PrimaryContactName nvarchar(100),
	PrimaryContactPhone nvarchar (25)
)



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


create table DimInvoice(
	InvoiceKey int IDENTITY(1,1) primary key,
	InvoiceID int ,
	CustomerID int,
	CustomerName nvarchar(200),
	BillToCustomerID int,
	BillCustomerName nvarchar(200),
	OrderID int,
	InvoiceDate date,
	StockItemID int,
	StockItemDescription nvarchar(200),
	PackedByPersonID int,
	PackedByPersonName nvarchar(100),
	DeliveryMethodID int,
	DeliveryMethodName nvarchar(100),
	DeliveryAddress nvarchar(max),
	DeliveryDate datetime null, --scd type one
	ReceivedBy nvarchar(200) null --scd type one
)
Go


CREATE TABLE DimPayment (
	PaymentID int ,
	PaymentMethodName nvarchar(100)
)



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