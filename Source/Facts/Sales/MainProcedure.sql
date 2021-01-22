use [WWI-DW]


Go
CREATE OR ALTER PROCEDURE MAIN(@date date) AS
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


	EXEC [WWI-DW].dbo.FillFactTransaction @date
	EXEC [WWI-DW].dbo.FillFactPeriodic @date
	EXEC [WWI-DW].dbo.FillFactAcc

END
Go



Go
CREATE OR ALTER PROCEDURE MAIN_FirstLoad(@date date) AS
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


	EXEC [WWI-DW].dbo.FillFactTransactionFirstLoad @date
	EXEC [WWI-DW].dbo.FillFactPeriodicFirstLoad @date
	EXEC [WWI-DW].dbo.FillFactAcc

END
Go


exec MAIN '2013-01-05'