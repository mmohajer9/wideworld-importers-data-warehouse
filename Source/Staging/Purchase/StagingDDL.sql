IF OBJECT_ID('dbo.StagingPurchaseOrder', 'U') IS NOT NULL
    DROP TABLE StagingPurchaseOrder
CREATE TABLE StagingPurchaseOrder
(
	PurchaseOrderID INT NOT NULL PRIMARY KEY,
	SupplierID INT NOT NULL,
	OrderDate DATE NOT NULL,
	DeliveryMethodID INT NOT NULL,
	ContactPersonID INT NOT NULL,
	ExpectedDeliveryDate DATE NULL,
	SupplierReference NVARCHAR(50) NULL,
	IsOrderFinalized NVARCHAR(10) NOT NULL,
	--^ bit in original source --> 1 : yes , 0 : no
);
GO

IF OBJECT_ID('dbo.StagingSupplierCategories' , 'U') IS NOT NULL
	DROP TABLE StagingSupplierCategories

CREATE TABLE StagingSupplierCategories
(
	SupplierCategoryID INT NOT NULL,
	SupplierCategoryName NVARCHAR(100) NOT NULL
)


IF OBJECT_ID('dbo.StagingSupplier', 'U') IS NOT NULL
    DROP TABLE StagingSupplier
CREATE TABLE StagingSupplier
(
	SupplierID INT NOT NULL PRIMARY KEY,
	SupplierName NVARCHAR(100) NOT NULL,

	SupplierCategoryID INT NOT NULL,
	SupplierCategoryName NVARCHAR(100) NOT NULL,
	--^ from Supplier Categories

	PrimaryContactPersonID INT NOT NULL,
	AlternateContactPersonID INT NOT NULL,

	DeliveryMethodID INT ,
	DeliveryCityID INT NOT NULL,
	PostalCityID INT NOT NULL,
	SupplierReference NVARCHAR(50) NULL,

	BankAccountName NVARCHAR(100) NOT NULL,
	BankAccountBranch NVARCHAR(100) NOT NULL,
	BankAccountCode NVARCHAR(100) NOT NULL,
	BankAccountNumber NVARCHAR(100) NOT NULL,
	BankInternationalCode NVARCHAR(100) NOT NULL,

	PhoneNumber NVARCHAR(20) NOT NULL,
	FaxNumber NVARCHAR(20) NOT NULL,
	WebsiteURL NVARCHAR(256) NOT NULL,

	DeliveryAddressLine1 NVARCHAR(60) NOT NULL,
	DeliveryAddressLine2 NVARCHAR(60) NOT NULL,
	DeliveryPostalCode NVARCHAR(20) NOT NULL,

	PostalAddressLine1 NVARCHAR(60) NOT NULL,
	PostalAddressLine2 NVARCHAR(60) NOT NULL,
	PostalPostalCode NVARCHAR(20) NOT NULL
);
GO

IF OBJECT_ID('dbo.StagingSupplierTransactions', 'U') IS NOT NULL
    DROP TABLE StagingSupplierTransactions
CREATE TABLE StagingSupplierTransactions
(
	[SupplierTransactionID] [int] NOT NULL,
	[SupplierID] [int] NOT NULL,
	[TransactionTypeID] [int] NOT NULL,
	[PurchaseOrderID] [int] NULL,
	[PaymentMethodID] [int] NULL,
	[SupplierInvoiceNumber] [nvarchar](20) NULL,
	[TransactionDate] [date] NOT NULL,
	[AmountExcludingTax] [decimal](20, 2) NOT NULL,
	[TaxAmount] [decimal](20, 2) NOT NULL,
	[TransactionAmount] [decimal](20, 2) NOT NULL,
	[OutstandingBalance] [decimal](20, 2) NOT NULL,
	[FinalizationDate] [date] NULL,
	[IsFinalized] NVARCHAR(10) NOT NULL,
)
GO