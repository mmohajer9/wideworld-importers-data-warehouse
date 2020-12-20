IF OBJECT_ID('dbo.StagingPurchaseOrder', 'U') IS NOT NULL
    drop table StagingPurchaseOrder
CREATE TABLE StagingPurchaseOrder(
	PurchaseOrderID int NOT NULL PRIMARY KEY,
	SupplierID int NOT NULL,
	OrderDate date NOT NULL,
	DeliveryMethodID int NOT NULL,
	ContactPersonID int NOT NULL,
	ExpectedDeliveryDate date NULL,
	SupplierReference nvarchar(20) NULL,
	IsOrderFinalized bit NOT NULL,
	Comments nvarchar(max) NULL,
	InternalComments nvarchar(max) NULL,
	LastEditedBy int NOT NULL,
	LastEditedWhen datetime2(7) NOT NULL,
);
GO


IF OBJECT_ID('dbo.StagingSuplier', 'U') IS NOT NULL
    drop table StagingSuplier
CREATE TABLE StagingSuplier(
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
GO


IF OBJECT_ID('dbo.StagingOrderline', 'U') IS NOT NULL
    drop table StagingOrderline
CREATE TABLE StagingOrderline(
	PurchaseOrderLineID int NOT NULL PRIMARY KEY,
	PurchaseOrderID int NOT NULL,
	StockItemID int NOT NULL,
	OrderedOuters int NOT NULL,
	Description nvarchar(100) NOT NULL,
	ReceivedOuters int NOT NULL,
	PackageTypeID int NOT NULL,
	ExpectedUnitPricePerOuter [decimal](18, 2) NULL,
	LastReceiptDate date NULL,
	IsOrderLineFinalized bit NOT NULL,
	LastEditedBy int NOT NULL,
	LastEditedWhen datetime2(7) NOT NULL,
);
GO