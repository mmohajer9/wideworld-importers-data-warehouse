CREATE OR ALTER PROCEDURE FillStagingPurchaseOrder
AS
BEGIN
    TRUNCATE TABLE StagingPurchaseOrder
    INSERT INTO StagingPurchaseOrder
        (
        PurchaseOrderID,
        SupplierID,
        OrderDate,
        DeliveryMethodID,
        ContactPersonID,
        ExpectedDeliveryDate,
        SupplierReference,
        IsOrderFinalized
        )
    SELECT
        PurchaseOrderID,
        SupplierID,
        OrderDate,
        DeliveryMethodID,
        ContactPersonID,
        ExpectedDeliveryDate,
        SupplierReference,
        CASE IsOrderFinalized
		    WHEN 1 then 'Yes' else 'No' 
	    END

    FROM [WideWorldImporters].[Purchasing].[PurchaseOrders]

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingPurchaseOrder',
    @action = 'INSERT',
    @TargetTable = 'StagingPurchaseOrder',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO



CREATE OR ALTER PROCEDURE FillStagingSupplierCategories
AS
BEGIN
    TRUNCATE TABLE StagingSupplierCategories
    INSERT INTO StagingSupplierCategories
        (
        SupplierCategoryID,
        SupplierCategoryName
        )
    SELECT
        SupplierCategoryID,
        SupplierCategoryName

    FROM [WideWorldImporters].[Purchasing].[SupplierCategories]

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingSupplierCategories',
    @action = 'INSERT',
    @TargetTable = 'StagingSupplierCategories',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FillStagingSupplier
AS
BEGIN
    TRUNCATE TABLE StagingSupplier
    INSERT INTO StagingSupplier
        (
        SupplierID,
        SupplierName,
        SupplierCategoryID,
        SupplierCategoryName,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        DeliveryMethodID,
        DeliveryCityID,
        PostalCityID,
        SupplierReference,
        BankAccountName,
        BankAccountBranch,
        BankAccountCode,
        BankAccountNumber,
        BankInternationalCode,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        DeliveryPostalCode,
        PostalAddressLine1,
        PostalAddressLine2,
        PostalPostalCode
        )
    SELECT
        SupplierID,
        SupplierName,
        a.SupplierCategoryID,
        b.SupplierCategoryName,
        PrimaryContactPersonID,
        AlternateContactPersonID,
        DeliveryMethodID,
        DeliveryCityID,
        PostalCityID,
        SupplierReference,
        BankAccountName,
        BankAccountBranch,
        BankAccountCode,
        BankAccountNumber,
        BankInternationalCode,
        PhoneNumber,
        FaxNumber,
        WebsiteURL,
        DeliveryAddressLine1,
        DeliveryAddressLine2,
        DeliveryPostalCode,
        PostalAddressLine1,
        PostalAddressLine2,
        PostalPostalCode

    FROM [WideWorldImporters].[Purchasing].[Suppliers] a INNER JOIN [WideWorldImporters].[Purchasing].[SupplierCategories] b
    ON (a.SupplierCategoryID = b.SupplierCategoryID)

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingSupplier',
    @action = 'INSERT',
    @TargetTable = 'StagingSupplier',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FillStagingSupplierTransactions
AS
BEGIN
    TRUNCATE TABLE StagingSupplierTransactions
    INSERT INTO StagingSupplierTransactions
        (
        SupplierTransactionID,
        SupplierID,
        TransactionTypeID,
        PurchaseOrderID,
        PaymentMethodID,
        SupplierInvoiceNumber,
        TransactionDate,
        AmountExcludingTax,
        TaxAmount,
        TransactionAmount,
        OutstandingBalance,
        FinalizationDate,
        IsFinalized
        )
    SELECT
        SupplierTransactionID,
        SupplierID,
        TransactionTypeID,
        PurchaseOrderID,
        PaymentMethodID,
        SupplierInvoiceNumber,
        TransactionDate,
        AmountExcludingTax,
        TaxAmount,
        TransactionAmount,
        OutstandingBalance,
        FinalizationDate,
        CASE IsFinalized
		    WHEN 1 then 'Yes' else 'No' 
	    END

    FROM [WideWorldImporters].[Purchasing].[SupplierTransactions]

    -------------------------------------------------------

    DECLARE @AFFECTED_ROWS INT;
    SET @AFFECTED_ROWS = @@ROWCOUNT;

    DECLARE @CURRENT_INSERT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    exec [AddStagingLog] 
    @procedure_name = 'FillStagingSupplierTransactions',
    @action = 'INSERT',
    @TargetTable = 'StagingSupplierTransactions',
    @Datetime = @CURRENT_INSERT_DATETIME,
    @AffectedRowsNumber = @AFFECTED_ROWS

END
--------------------------------------------------------------------------------------------------------------
GO


CREATE OR ALTER PROCEDURE FILL_PURCHASING_STAGING_AREA
    @FirstLoad BIT = 0
AS
BEGIN
    IF @FirstLoad = 1
    BEGIN
        TRUNCATE TABLE StagingPurchaseOrder
        TRUNCATE TABLE StagingSupplierCategories
        TRUNCATE TABLE StagingSupplier
        TRUNCATE TABLE StagingSupplierTransactions
    END

    EXEC FillStagingPurchaseOrder;
    EXEC FillStagingSupplierCategories;
    EXEC FillStagingSupplier;
    EXEC FillStagingSupplierTransactions;

END
--------------------------------------------------------------------------------------------------------------
GO