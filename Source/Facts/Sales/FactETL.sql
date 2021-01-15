use [WWI-DW]


Go
create or alter procedure FillFactTransaction (@date date) AS
begin

	declare @max_date date = ISNULL(
	(select FullDateAlternateKey From [WWI-DW].dbo.DimTime where TimeKey = (select max(TimeKey) from FactTransaction)), '2012-12-31')

	IF OBJECT_ID('dbo.TMP', 'U') IS NOT NULL
    drop table TMP;

	create table TMP(
		TimeKey int ,
		CustomerKey int ,
		InvoiceKey int,
		PeopleKey int,
		TransactionTypeKey int,
		PaymentMethodKey int,
		TransactionID int ,
		AmountExcludingTax decimal(25,3),
		TaxAmount decimal(25,3),
		TransactionAmount decimal(25,3),
		profit int);

	while(@max_date<@date) begin

		set @max_date = DATEADD(dd, 1, @max_date);

		with profit(invoiceID , amount) as(
			select InvoiceID, SUM(InvoiceLine.LineProfit) from [WWI-Staging].dbo.StagingInvoiceLines as InvoiceLine
			group by InvoiceLine.InvoiceID
		) insert into TMP (TimeKey,CustomerKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
			AmountExcludingTax,TaxAmount,TransactionAmount, profit )
		select isnull(dimTime.TimeKey,-1) AS TimeKey, isnull(DimCustomer.CustomerKey,-1) AS CustomerKey, 
			isnull(Transactions.InvoiceID,-1)AS InvoiceKey, isnull(DimPeople.PeopleKey,-1)AS PeopleKey, 
			isnull(Transactions.TransactionTypeID,-1)AS TransactionType, isnull(DimPayment.PaymentKey,-1) AS PaymentMethod,
			Transactions.CustomerTransactionID, Transactions.AmountExcludingTax, Transactions.TaxAmount,
			Transactions.TransactionAmount,ISNULL(profit.amount,0)
			from [WWI-Staging].dbo.StagingCustomerTransactions as Transactions 
				JOIN DimTime on FullDateAlternateKey = Transactions.TransactionDate and CONVERT(date,DimTime.FullDateAlternateKey) =@max_date
				LEFT JOIN DimInvoice On DimInvoice.InvoiceKey = Transactions.InvoiceID
				LEFT JOIN DimPeople on DimPeople.PeopleKey = DimInvoice.PrimaryContactPersonID
				LEFT JOIN DimPayment on DimPayment.PaymentKey = Transactions.PaymentMethodID
				LEFT JOIN DimCustomer on DimCustomer.CustomerID = Transactions.CustomerID and DimCustomer.CurrentFlag = 1
				left JOIN profit On profit.invoiceID = Transactions.InvoiceID


		insert into FactTransaction(TimeKey,CustomerKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
			AmountExcludingTax,TaxAmount,TransactionAmount,TransactionProfit)
			select TimeKey,CustomerKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
				AmountExcludingTax,TaxAmount,TransactionAmount,profit from TMP;

		
		insert into [WWI-Staging].dbo.LogSales(ActionName,TableName,date,RecordId,RecordSurrogateKey)
			select 'insert', 'FactTransaction',getdate(),tmp.TransactionID,null from TMP;
		
		truncate table TMP;
	end 

	drop table TMP;
	
end
GO
