
Go
create or alter procedure FillFactTransaction (@date date) AS
begin

	declare @max_date date = ISNULL(
	(select DimTime.FullDateAlternateKey From DimTime where TimeKey = (select max(TimeKey) from FactTransaction)), '2012-12-31')

	IF OBJECT_ID('dbo.tmp', 'U') IS NOT NULL
    drop table tmp
	create table tmp(
		TimeKey int FOREIGN KEY REFERENCES DimTime(TimeKey),
		CustomerKey int FOREIGN KEY REFERENCES DimCustomer(CustomerKey),
		OrderKey int FOREIGN KEY REFERENCES DimOrder(OrderKey),
		InvoiceKey int FOREIGN KEY REFERENCES DimInvoice(InvoiceKey),
		PeopleKey int FOREIGN KEY REFERENCES DimPeople(PeopleKey),
		TransactionTypeKey int FOREIGN KEY REFERENCES DimTransactionTypes(TransactionTypeID),
		PaymentMethodKey int FOREIGN KEY REFERENCES DimPayment(PaymentKey),
		TransactionID int ,
		AmountExcludingTax decimal(25,3),
		TaxAmount decimal(25,3),
		TransactionAmount decimal(25,3)
	)

	while(@max_date<@date) begin
		set @max_date = DATEADD(dd,1,@max_date)
		insert into tmp(TimeKey,CustomerKey,OrderKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
		AmountExcludingTax,TaxAmount,TransactionAmount)
		select isnull(dimTime.TimeKey,-1), isnull(DimCustomer.CustomerKey,-1), isnull(DimOrder.OrderKey,-1), 
		isnull(Transactions.InvoiceID,-1),isnull(DimPeople.PeopleKey,-1),isnull(Transactions.TransactionTypeID,-1), isnull(Transactions.PaymentMethodID,-1),
		Transactions.CustomerTransactionID,Transactions.AmountExcludingTax, Transactions.TaxAmount, Transactions.TransactionAmount 
		from StagingCustomerTransactions as Transactions 
			join DimTime on FullDateAlternateKey = Transactions.TransactionDate and DimTime.FullDateAlternateKey = @max_date
			left join DimInvoice On DimInvoice.InvoiceKey = Transactions.InvoiceID
			left join DimOrder On DimOrder.OrderKey = DimInvoice.OrderID
			left join DimPeople on DimPeople.PeopleKey = DimOrder.PrimaryContactPersonID
			left join DimPayment on DimPayment.PaymentKey = Transactions.PaymentMethodID
			left join DimCustomer on DimCustomer.CustomerID = Transactions.CustomerID and DimCustomer.CurrentFlag = 1
		
	end

	
	insert into FactTransaction(TimeKey,CustomerKey,OrderKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
		AmountExcludingTax,TaxAmount,TransactionAmount)
		select TimeKey,CustomerKey,OrderKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
		AmountExcludingTax,TaxAmount,TransactionAmount from tmp

		
	insert into LogSales(ActionName,TableName,date,RecordId,RecordSurrogateKey)
		select 'insert', 'FactTransaction',getdate(),tmp.TransactionID,null from tmp
		
	drop table tmp

end
GO


