CREATE TABLE DimPurchaseOrder(
	PurchaseOrderID int NOT NULL PRIMARY KEY,
	SupplierID int NOT NULL,
	OrderDate date NOT NULL,
	DeliveryMethodID int NOT NULL,
	ExpectedDeliveryDate date,
	Comments nvarchar(max) NULL,
	IsOrderFinalized bit NOT NULL,
);
--------------------------------------------------
CREATE TABLE DimSuplier(
	SupplierID int NOT NULL PRIMARY KEY,
	SupplierName nvarchar(100) NOT NULL,
	SupplierCategoryID int NOT NULL,
	PrimaryContactPersonID int NOT NULL,
	AlternateContactPersonID int NOT NULL,
	DeliveryMethodID int NULL,
	DeliveryCityID int NOT NULL,
	PostalCityID int NOT NULL,
	PhoneNumber nvarchar(20) NOT NULL,	
	FaxNumber nvarchar(20) NOT NULL,
	WebsiteURL nvarchar(256) NOT NULL,
	DeliveryAddressLine1 nvarchar(60) NOT NULL,	
	PostalPostalCode nvarchar(10) NOT NULL,	
);
---------------------------------------------------

----------------------------------------------------
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
);
--------------------------------------------------------
CREATE TABLE DimTransactionTypes
(
    TransactionTypeID INT NOT NULL PRIMARY KEY,
    TransactionTypeName [NVARCHAR](100) NOT NULL
);
---------------------------------------------------------
CREATE TABLE DimPayment (
	PaymentID int PRIMARY KEY,
	PaymentMethodName nvarchar(100)
)