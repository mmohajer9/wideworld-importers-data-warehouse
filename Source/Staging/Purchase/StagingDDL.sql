use [WWI-Staging];
GO

IF OBJECT_ID('dbo.StagingPurchaseOrder', 'U') IS NOT NULL
DROP TABLE StagingPurchaseOrder
CREATE TABLE StagingPurchaseOrder
(
	PurchaseOrderID INT PRIMARY KEY,
	SupplierID INT,
	OrderDate DATE,
	DeliveryMethodID INT,
	ContactPersonID INT,
	ExpectedDeliveryDate DATE,
	SupplierReference NVARCHAR(50),
	IsOrderFinalized NVARCHAR(10)
	,
	--^ bit in original source --> 1 : yes , 0 : no
);
GO

IF OBJECT_ID('dbo.StagingSupplierCategories' , 'U') IS NOT NULL
DROP TABLE StagingSupplierCategories

CREATE TABLE StagingSupplierCategories
(
	SupplierCategoryID INT,
	SupplierCategoryName NVARCHAR(100)
)


IF OBJECT_ID('dbo.StagingSupplier', 'U') IS NOT NULL
DROP TABLE StagingSupplier
CREATE TABLE StagingSupplier
(
	SupplierID INT PRIMARY KEY,
	SupplierName NVARCHAR(100),

	SupplierCategoryID INT,
	SupplierCategoryName NVARCHAR(100),
	--^ from Supplier Categories

	PrimaryContactPersonID INT,
	AlternateContactPersonID INT,

	DeliveryMethodID INT ,
	DeliveryCityID INT,
	PostalCityID INT,
	SupplierReference NVARCHAR(50) NULL,

	BankAccountName NVARCHAR(100),
	BankAccountBranch NVARCHAR(100),
	BankAccountCode NVARCHAR(100),
	BankAccountNumber NVARCHAR(100),
	BankInternationalCode NVARCHAR(100),

	PhoneNumber NVARCHAR(20),
	FaxNumber NVARCHAR(20),
	WebsiteURL NVARCHAR(256),

	DeliveryAddressLine1 NVARCHAR(60),
	DeliveryAddressLine2 NVARCHAR(60),
	DeliveryPostalCode NVARCHAR(20),

	PostalAddressLine1 NVARCHAR(60),
	PostalAddressLine2 NVARCHAR(60),
	PostalPostalCode NVARCHAR(20)
);
GO

IF OBJECT_ID('dbo.StagingSupplierTransactions', 'U') IS NOT NULL
DROP TABLE StagingSupplierTransactions
CREATE TABLE StagingSupplierTransactions
(
	[SupplierTransactionID] [int],
	[SupplierID] [int],
	[TransactionTypeID] [int],
	[PurchaseOrderID] [int] NULL,
	[PaymentMethodID] [int] NULL,
	[SupplierInvoiceNumber] [nvarchar](20) NULL,
	[TransactionDate] [date],
	[AmountExcludingTax] [decimal](20, 2),
	[TaxAmount] [decimal](20, 2),
	[TransactionAmount] [decimal](20, 2),
	[OutstandingBalance] [decimal](20, 2),
	[FinalizationDate] [date] NULL,
	[IsFinalized] NVARCHAR(10),
)
GO