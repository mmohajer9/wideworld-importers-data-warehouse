use [WWI-DW]


Go
create or alter procedure FillFactSalesTransaction (@date date) AS
begin

	declare @max_date date = ISNULL(
	(select FullDateAlternateKey From [WWI-DW].dbo.DimTime where TimeKey = (select max(TimeKey) from FactSalesTransaction)), '2012-12-31')

	IF OBJECT_ID('dbo.TMP_Sale_Transaction', 'U') IS NOT NULL
    drop table TMP_Sale_Transaction;

	create table TMP_Sale_Transaction(
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
		profit int,
		AccumulationTransactionAmountAfterThisOne decimal(25,3));

	while(@max_date<@date) begin
	
		set @max_date = DATEADD(dd, 1, @max_date);

		with profit(invoiceID , amount) as(
			select InvoiceID, SUM(InvoiceLine.LineProfit) from [WWI-Staging].dbo.StagingInvoiceLines as InvoiceLine
			group by InvoiceLine.InvoiceID
		),LastTrans(customerKey , id)AS(
			select customerKey,MAX(TransactionID)from FactSalesTransaction
			where TimeKey = (select timeKey From DimTime where CONVERT(date,DimTime.FullDateAlternateKey) = DATEADD(dd, -1, @max_date))
			group by CustomerKey
		)insert into TMP_Sale_Transaction (TimeKey,CustomerKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
			AmountExcludingTax,TaxAmount,TransactionAmount, profit, AccumulationTransactionAmountAfterThisOne )
		select isnull(dimTime.TimeKey,-1) AS TimeKey, isnull(DimCustomer.CustomerKey,-1) AS CustomerKey, 
			isnull(Transactions.InvoiceID,-1)AS InvoiceKey, isnull(DimPeople.PeopleKey,-1)AS PeopleKey, 
			isnull(Transactions.TransactionTypeID,-1) AS TransactionType, isnull(DimPayment.PaymentKey,-1) AS PaymentMethod,
			Transactions.CustomerTransactionID, Transactions.AmountExcludingTax, Transactions.TaxAmount,
			Transactions.TransactionAmount, ISNULL(profit.amount,0),
			sum (TransactionAmount) over (partition by  Transactions.CustomerID order by Transactions.CustomerTransactionID) +
			isNULL(
				(select AccumulationTransactionAmountAfterThisOne from FactSalesTransaction where transactionID = LastTrans.id)
			,0)
			from [WWI-Staging].dbo.StagingCustomerTransactions as Transactions 
				JOIN DimTime on FullDateAlternateKey = Transactions.TransactionDate and CONVERT(date,DimTime.FullDateAlternateKey) = @max_date
				LEFT JOIN DimInvoice On DimInvoice.InvoiceKey = Transactions.InvoiceID
				LEFT JOIN DimPeople on DimPeople.PeopleKey = DimInvoice.PrimaryContactPersonID
				LEFT JOIN DimPayment on DimPayment.PaymentKey = Transactions.PaymentMethodID
				LEFT JOIN DimCustomer on DimCustomer.CustomerID = Transactions.CustomerID and DimCustomer.CurrentFlag = 1
				left JOIN profit On profit.invoiceID = Transactions.InvoiceID
				left join LastTrans on LastTrans.customerKey = DimCustomer.CustomerKey


		insert into FactSalesTransaction(TimeKey,CustomerKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
			AmountExcludingTax,TaxAmount,TransactionAmount,TransactionProfit,AccumulationTransactionAmountAfterThisOne)
			select TimeKey,CustomerKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
				AmountExcludingTax,TaxAmount,TransactionAmount,profit,AccumulationTransactionAmountAfterThisOne from TMP_Sale_Transaction;

		
		insert into LogSales(ActionName,TableName,date,RecordId,RecordSurrogateKey)
			select 'insert', 'FactSalesTransaction',getdate(),TMP_Sale_Transaction.TransactionID,null from TMP_Sale_Transaction;
		
		truncate table TMP_Sale_Transaction;
	end 

	drop table TMP_Sale_Transaction;
	
end
GO

create or alter procedure FillFactSalesTransactionFirstLoad (@date date) AS
begin 
	truncate table FactSalesTransaction
	exec FillFactSalesTransaction @date
end
GO





-----------------------Periodic Fact------------------------------------
Go
create or alter procedure FillFactSalesPeriodic (@date date) AS
begin
	declare @max_date date = ISNULL(
	(select FullDateAlternateKey From [WWI-DW].dbo.DimTime where TimeKey = (select max(TimeKey) from FactSalesPeriodict)), '2012-12-31')

	IF OBJECT_ID('dbo.TMP_Sale_Periodic', 'U') IS NOT NULL
    drop table TMP_Sale_Periodic;

	create table TMP_Sale_Periodic(
		TimeKey int ,
		CustomerKey int ,
		PeopleKey int ,
		TotalpurchasePrice decimal(25,3),
		TotalNumberOfStock int,
		TotalTransactionCount int,
		TotalRetrivedProfit decimal(25,3),
		TotalPurchasedTax decimal(25,3),
		InActiveDayCount int,
		lastBuyDateKey int,
		averageBuyAmountTillNow decimal(25,3)
	)
	

	while(@max_date<@date) begin

		declare @dayBefore int = (select TimeKey From DimTime where CONVERT(DATE,DimTime.FullDateAlternateKey)=  @max_date);
		set @max_date = DATEADD(dd, 1, @max_date);
		declare @timekey int = (select TimeKey From DimTime where CONVERT(DATE,DimTime.FullDateAlternateKey)= @max_date);


		with Transactions (CustomerKey,TotalpurchasePrice,TotalRetrivedProfit,TotalPurchasedTax) AS(
			select CustomerKey, SUM(ISNULL(TransactionAmount,0)), SUM(ISNULL(TransactionProfit,0)),
			SUM(ISNULL(TaxAmount,0))
			from FactSalesTransaction JOIN DimTime ON DimTime.TimeKey = FactSalesTransaction.TimeKey
			AND DimTime.TimeKey = @timekey
			group by FactSalesTransaction.CustomerKey
		),Quantity(CustomerKey , items) AS(
			select DimCustomer.CustomerKey, SUM(ISNULL(Quantity,0)) FROM DimCustomer
			Left Join FactSalesTransaction on FactSalesTransaction.CustomerKey =  DimCustomer.CustomerKey
			left JOIN [WWI-Staging].dbo.StagingInvoiceLines As Line ON FactSalesTransaction.InvoiceKey = Line.InvoiceID
			where DimCustomer.CurrentFlag=1 and  FactSalesTransaction.TimeKey = @timekey 
			group by DimCustomer.CustomerKey
		),AverageBuy(customerID,amount,number)AS(
			select CustomerKey, SUM(TransactionAmount), count(TransactionAmount) from FactSalesTransaction
			 where TimeKey = @timeKey
			 group by CustomerKey
		)
		insert into TMP_Sale_Periodic(TimeKey,CustomerKey,PeopleKey,TotalpurchasePrice,TotalNumberOfStock,TotalRetrivedProfit,
		TotalPurchasedTax,lastBuyDateKey,InActiveDayCount,averageBuyAmountTillNow,TotalTransactionCount)
		select @timekey AS TimeKey, DimCustomer.CustomerKey, DimCustomer.PrimaryContactPersonID, 
		ISNULL(Transactions.TotalpurchasePrice,0), ISNULL(Quantity.items,0), ISNULL(Transactions.TotalRetrivedProfit,0),
		ISNULL(Transactions.TotalPurchasedTax,0),
		ISNULL(
			(select distinct TimeKey from FactSalesTransaction where CustomerKey = DimCustomer.CustomerKey AND TimeKey = @timekey),
			ISNULL(
				(select lastBuyDateKey from FactSalesPeriodict where TimeKey = (select TimeKey FROM DimTime where 
					Convert(DATE,FullDateAlternateKey) = DATEADD(dd, -1, @max_date)) 
						AND FactSalesPeriodict.CustomerKey =DimCustomer.CustomerKey),0)
				),
		ISNULL(
			(select Distinct 0 from FactSalesTransaction where FactSalesTransaction.CustomerKey = DimCustomer.CustomerKey AND TimeKey = @timekey),
			ISNULL(
				(select InActiveDayCountTillNow + 1 from FactSalesPeriodict where TimeKey = (select TimeKey FROM DimTime 
				where Convert(DATE,FullDateAlternateKey) = DATEADD(dd, -1, @max_date)) 
				AND FactSalesPeriodict.CustomerKey=DimCustomer.CustomerKey),1)
			), case when (select FactSalesPeriodict.averageBuyAmountTillNow * FactSalesPeriodict.TotalTransactionCountTillNow
				from FactSalesPeriodict where CustomerKey = DimCustomer.CustomerKey and TimeKey= @dayBefore) IS NULl AND AverageBuy.number IS NULL
					then 0
				when AverageBuy.amount IS NULl then (select FactSalesPeriodict.averageBuyAmountTillNow
					from FactSalesPeriodict where CustomerKey = DimCustomer.CustomerKey and TimeKey= @dayBefore)
				ELSE
				(AverageBuy.amount + ISNULL((select FactSalesPeriodict.averageBuyAmountTillNow * FactSalesPeriodict.TotalTransactionCountTillNow
					from FactSalesPeriodict where CustomerKey =  DimCustomer.CustomerKey and TimeKey= @dayBefore),0)) /
					(AverageBuy.number + ISNULL((select FactSalesPeriodict.TotalTransactionCountTillNow
					from FactSalesPeriodict where CustomerKey = DimCustomer.CustomerKey  and TimeKey= @dayBefore ),0))
				end,
				ISNULL(AverageBuy.number,0) + ISNULL((select FactSalesPeriodict.TotalTransactionCountTillNow
				from FactSalesPeriodict where CustomerKey = DimCustomer.CustomerKey  and TimeKey= @dayBefore ),0)
		from DimCustomer 
		left JOIN Quantity On DimCustomer.CustomerKey = Quantity.CustomerKey
		left JOIN Transactions  ON Transactions.CustomerKey = Quantity.CustomerKey
		left join AverageBuy on AverageBuy.customerID = DimCustomer.CustomerKey
		where DimCustomer.CustomerKey !=-1

		insert FactSalesPeriodict (TimeKey,CustomerKey,PeopleKey,TotalpurchasePrice,TotalNumberOfStock,EstimatedTotalRetrivedProfit,
		TotalPurchasedTax,lastBuyDateKey,InActiveDayCountTillNow,averageBuyAmountTillNow,TotalTransactionCountTillNow)
		select TimeKey,CustomerKey,PeopleKey,TotalpurchasePrice,TotalNumberOfStock,TotalRetrivedProfit,
		TotalPurchasedTax,lastBuyDateKey,InActiveDayCount,averageBuyAmountTillNow,TotalTransactionCount from TMP_Sale_Periodic

		insert into LogSales(ActionName,TableName,date,RecordId,RecordSurrogateKey)
		select 'insert', 'FactSalesPeriodict',getdate(),TMP_Sale_Periodic.CustomerKey,null from TMP_Sale_Periodic;

		truncate table TMP_Sale_Periodic
	end
	drop table TMP_Sale_Periodic
end
GO

create or alter procedure FillFactSalesPeriodicFirstLoad (@date date) AS
begin 
	truncate table FactSalesPeriodict
	exec FillFactSalesPeriodic @date
end
GO


---------------------ACC Fact-----------------------

Go
create or alter procedure FillFactSalesACC AS
begin
	IF OBJECT_ID('dbo.TMP_Sales_Acc', 'U') IS NOT NULL
	drop table TMP_Sales_Acc
	create table TMP_Sales_Acc(
		CustomerKey int ,
		PeopleKey int,
		TotalBuyPrice int,
		NumberOfPurchases int,
		TotalEstimatedProfit int,
		TotalTax int,
		averageBuyAmount int
	);
	declare @lastOne int = (select Max(timeKey) from FactSalesPeriodict);
	with total (customerKey, BuyPrice,Profit,Tax) AS(
		select CustomerKey,SUM(TotalpurchasePrice), SUM(EstimatedTotalRetrivedProfit), SUM(TotalPurchasedTax)
		From FactSalesPeriodict
		group by CustomerKey
	)Insert into TMP_Sales_Acc(CustomerKey,PeopleKey,TotalBuyPrice,NumberOfPurchases,TotalEstimatedProfit,TotalTax,averageBuyAmount)
		select total.customerKey, FactSalesPeriodict.PeopleKey, total.BuyPrice, FactSalesPeriodict.TotalTransactionCountTillNow, total.Profit
		, total.Tax, FactSalesPeriodict.averageBuyAmountTillNow
		from total JOIN FactSalesPeriodict on FactSalesPeriodict.CustomerKey = total.customerKey AND FactSalesPeriodict.TimeKey = @lastOne
	truncate table FactSalesACC
	Insert into FactSalesACC(CustomerKey,PeopleKey,TotalBuyPrice,NumberOfPurchases,TotalEstimatedProfit,TotalTax,averageBuyAmount)
		select  CustomerKey,PeopleKey,TotalBuyPrice,NumberOfPurchases,TotalEstimatedProfit,TotalTax,averageBuyAmount
			From TMP_Sales_Acc
	truncate table TMP_Sales_Acc

end
GO
