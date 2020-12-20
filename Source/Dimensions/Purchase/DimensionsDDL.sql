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
