CREATE TABLE DimPurchaseOrder(
	PurchaseOrderID int PRIMARY KEY,
	SupplierID int,
	OrderDate date,
	DeliveryMethodID int,
	ExpectedDeliveryDate date,
	Comments nvarchar(max) NULL,
	IsOrderFinalized bit,
);
--------------------------------------------------
CREATE TABLE DimSupplier(
	SupplierID int PRIMARY KEY,
	SupplierName nvarchar(100),
	SupplierCategoryID int,
	PrimaryContactPersonID int,
	AlternateContactPersonID int,
	DeliveryMethodID int NULL,
	DeliveryCityID int,
	PostalCityID int,
	PhoneNumber nvarchar(20),	
	FaxNumber nvarchar(20),
	WebsiteURL nvarchar(256),
	DeliveryAddressLine1 nvarchar(60),	
	PostalPostalCode nvarchar(10),	
);
---------------------------------------------------

----------------------------------------------------
