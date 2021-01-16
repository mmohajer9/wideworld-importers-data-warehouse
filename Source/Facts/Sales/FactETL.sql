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



-----------------------Periodic Fact------------------------------------
Go
create or alter procedure FillFactPeriodic (@date date) AS
begin
	declare @max_date date = ISNULL(
	(select FullDateAlternateKey From [WWI-DW].dbo.DimTime where TimeKey = (select max(TimeKey) from FactPeriodict)), '2012-12-31')

	IF OBJECT_ID('dbo.TMP', 'U') IS NOT NULL
    drop table TMP;

	create table TMP(
	TimeKey int ,
	CustomerKey int ,
	PeopleKey int ,
	TotalpurchasePrice int,
	TotalNumberOfStock int,
	TotalRetrivedProfit int,
	TotalPurchasedTax int,
	InActiveDayCount int,
	lastBuyDateKey int)

	while(@max_date<@date) begin
		
		set @max_date = DATEADD(dd, 1, @max_date);

		declare @timekey int = (select TimeKey From DimTime where CONVERT(DATE,DimTime.FullDateAlternateKey)= @max_date);

		with Transactions (CustomerKey,TotalpurchasePrice,TotalRetrivedProfit,TotalPurchasedTax) AS(
			select CustomerKey, SUM(TransactionAmount), SUM(TransactionProfit), SUM(TaxAmount)
			from FactTransaction JOIN DimTime ON DimTime.TimeKey = FactTransaction.TimeKey
			AND DimTime.TimeKey = @timekey
			group by FactTransaction.CustomerKey
		),Quantity(CustomerKey , items) AS(
			select DimCustomer.CustomerKey, SUM(Quantity) FROM DimCustomer
			Left Join FactTransaction on FactTransaction.CustomerKey =  DimCustomer.CustomerKey
			left JOIN [WWI-Staging].dbo.StagingInvoiceLines As Line ON FactTransaction.InvoiceKey = Line.InvoiceID
			where DimCustomer.CurrentFlag=1 and  FactTransaction.TimeKey = @timekey 
			group by DimCustomer.CustomerKey
		)insert into TMP(TimeKey,CustomerKey,PeopleKey,TotalpurchasePrice,TotalNumberOfStock,TotalRetrivedProfit,
		TotalPurchasedTax,lastBuyDateKey,InActiveDayCount)
		select @timekey AS TimeKey, DimCustomer.CustomerKey, DimCustomer.PrimaryContactPersonID, 
		ISNULL(Transactions.TotalpurchasePrice,0), ISNULL(Quantity.items,0), ISNULL(Transactions.TotalRetrivedProfit,0),
		ISNULL(Transactions.TotalPurchasedTax,0),
		ISNULL(
			(select distinct TimeKey from FactTransaction where CustomerKey = Quantity.CustomerKey AND TimeKey = @timekey),
			ISNULL(
				(select lastBuyDateKey from FactPeriodict where TimeKey = (select TimeKey FROM DimTime where 
					Convert(DATE,FullDateAlternateKey) = DATEADD(dd, -1, @max_date)) 
						AND FactPeriodict.CustomerKey =Quantity.CustomerKey),0)
				),
		ISNULL(
			(select Distinct 0 from FactTransaction where FactTransaction.CustomerKey = DimCustomer.CustomerKey AND TimeKey = @timekey),
			ISNULL(
				(select InActiveDayCount + 1 from FactPeriodict where TimeKey = (select TimeKey FROM DimTime 
				where Convert(DATE,FullDateAlternateKey) = DATEADD(dd, -1, @max_date)) 
				AND FactPeriodict.CustomerKey=DimCustomer.CustomerKey),0)
			)
		from DimCustomer 
		left JOIN Quantity On DimCustomer.CustomerKey = Quantity.CustomerKey
		left JOIN Transactions  ON Transactions.CustomerKey = Quantity.CustomerKey
		where DimCustomer.CustomerKey !=-1

		insert FactPeriodict (TimeKey,CustomerKey,PeopleKey,TotalpurchasePrice,TotalNumberOfStock,TotalRetrivedProfit,
		TotalPurchasedTax,lastBuyDateKey,InActiveDayCount)
		select TimeKey,CustomerKey,PeopleKey,TotalpurchasePrice,TotalNumberOfStock,TotalRetrivedProfit,
		TotalPurchasedTax,lastBuyDateKey,InActiveDayCount from TMP

		truncate table tmp
	end
	drop table tmp
end
GO
