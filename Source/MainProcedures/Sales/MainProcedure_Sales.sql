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