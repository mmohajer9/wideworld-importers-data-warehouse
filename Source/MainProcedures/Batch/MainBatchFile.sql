use [WWI-DW]


Go
CREATE OR ALTER PROCEDURE FILL_SALES_MART(@date date) AS
BEGIN

	EXEC [WWI-Staging].dbo.FillStagingBuyingGroups
	EXEC [WWI-Staging].dbo.FillStagingCities
	EXEC [WWI-Staging].dbo.FillStagingCustomerCategories
	EXEC [WWI-Staging].dbo.FillStagingCustomers
	EXEC [WWI-Staging].dbo.FillStagingCustomerTransactions
	EXEC [WWI-Staging].dbo.FillStagingDeliveryMethods
	EXEC [WWI-Staging].dbo.FillStagingInvoices
	EXEC [WWI-Staging].dbo.FillStagingInvoiceLine
	EXEC [WWI-Staging].dbo.FillStagingOrders
	EXEC [WWI-Staging].dbo.FillStagingPaymentMethods
	EXEC [WWI-Staging].dbo.FillStagingPeople
	EXEC [WWI-Staging].dbo.FillStagingStateProvinces


	EXEC [WWI-DW].dbo.FillDimCustomer
	EXEC [WWI-DW].dbo.FillDimInvoice
	EXEC [WWI-DW].dbo.FillDimPayment
	EXEC [WWI-DW].dbo.FillDimPeople


	EXEC [WWI-DW].dbo.FillFactSalesTransaction @date
	EXEC [WWI-DW].dbo.FillFactSalesPeriodic @date
	EXEC [WWI-DW].dbo.FillFactSalesAcc

END
Go



Go
CREATE OR ALTER PROCEDURE FILL_SALES_MART_FirstLoad(@date date) AS
BEGIN

	EXEC [WWI-Staging].dbo.FillStagingBuyingGroups
	EXEC [WWI-Staging].dbo.FillStagingCities
	EXEC [WWI-Staging].dbo.FillStagingCustomerCategories
	EXEC [WWI-Staging].dbo.FillStagingCustomers
	EXEC [WWI-Staging].dbo.FillStagingCustomerTransactionsFirstLoad
	EXEC [WWI-Staging].dbo.FillStagingDeliveryMethods
	EXEC [WWI-Staging].dbo.FillStagingInvoices
	EXEC [WWI-Staging].dbo.FillStagingInvoiceLineFirstLoad
	EXEC [WWI-Staging].dbo.FillStagingOrdersFirstLoad
	EXEC [WWI-Staging].dbo.FillStagingPaymentMethods
	EXEC [WWI-Staging].dbo.FillStagingPeople
	EXEC [WWI-Staging].dbo.FillStagingStateProvinces


	EXEC [WWI-DW].dbo.FillDimCustomerFirstLoad
	EXEC [WWI-DW].dbo.FillDimInvoiceFirstLoad
	EXEC [WWI-DW].dbo.FillDimPaymentFirstLoad
	EXEC [WWI-DW].dbo.FillDimPeopleFirstLoad


	EXEC [WWI-DW].dbo.FillFactSalesTransactionFirstLoad @date
	EXEC [WWI-DW].dbo.FillFactSalesPeriodicFirstLoad @date
	EXEC [WWI-DW].dbo.FillFactSalesAcc

END
Go


use [WWI-DW]


Go


CREATE OR ALTER PROCEDURE FILL_WAREHOUSE_MART(@DATE date , @FIRSTLOAD BIT = 0) AS
BEGIN
    
    EXEC [WWI-Staging].[dbo].FILL_WAREHOUSE_STAGING_AREA @FIRSTLOAD;
    EXEC WAREHOUSE_DIMENSIONS_SCD_ETL;
    EXEC FILL_WAREHOUSE_FACTS @DATE , @FIRSTLOAD;

END
Go




use [WWI-DW]
Go


CREATE OR ALTER PROCEDURE FILL_DATA_WAREHOUSE(@to_this_date date , @is_it_first_load BIT = 0) AS
BEGIN
    
    EXEC FILL_WAREHOUSE_MART @to_this_date , @is_it_first_load;
    IF @is_it_first_load = 0
        EXEC FILL_SALES_MART @to_this_date;
    ELSE
        EXEC FILL_SALES_MART_FirstLoad @to_this_date;

END
Go