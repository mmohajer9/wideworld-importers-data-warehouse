use WideWorldImporters



 





;----------------TransAction Fact table---------------------------
IF OBJECT_ID('dbo.FactTransaction', 'U') IS NOT NULL
drop table FactTransaction
create table FactTransaction(
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
GO
;----------------Procedure---------------------------
create or alter procedure FillFactTransaction (@date date) AS
begin
	declare @max_date date = ISNULL(
	(select DimTime.FullDateAlternateKey From DimTime where TimeKey = (select max(TimeKey) from FactTransaction)), '2012-12-31')

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
		insert into tmp(TimeKey,CustomerKey,OrderKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
		AmountExcludingTax,TaxAmount,TransactionAmount)
		select isnull(dimTime.TimeKey,-1), isnull(Transactions.CustomerID,-1), isnull(DimOrder.OrderKey,-1), 
		isnull(Transactions.InvoiceID,-1),isnull(DimPeople.PeopleKey,-1),isnull(Transactions.TransactionTypeID,-1), isnull(Transactions.PaymentMethodID,-1),
		Transactions.CustomerTransactionID,Transactions.AmountExcludingTax, Transactions.TaxAmount, Transactions.TransactionAmount 
		from StagingCustomerTransactions as Transactions 
			join DimTime on FullDateAlternateKey = Transactions.TransactionDate and DimTime.FullDateAlternateKey = @max_date
			left join DimInvoice On DimInvoice.InvoiceKey = Transactions.InvoiceID
			left join DimOrder On DimOrder.OrderKey = DimInvoice.OrderID
			left join DimPeople on DimPeople.PeopleKey = DimOrder.PrimaryContactPersonID
			left join DimPayment on DimPayment.PaymentKey = Transactions.PaymentMethodID
		set @max_date = DATEADD(dd,1,@max_date)
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
;----------------Procedure---------------------------
declare @today date = '2013-10-10'--(select getdate())
exec FillFactTransaction @date = @today
select * from FactTransaction
;----------------TransAction Fact table---------------------------






















;----------------Acc fact table---------------------------
drop table acc_fact
create table acc_fact(
	acc_fact_id int IDENTITY(1,1) primary key,
	customer_id int FOREIGN KEY REFERENCES dbo.customer_dim(customer_id),
	order_id int FOREIGN KEY REFERENCES dbo.order_dim(order_dim_id),
	invoice_id int FOREIGN KEY REFERENCES dbo.invoice_dim(invoice_id),
	total_buy_price int,
	number_of_purchases int,
	most_frequent_buy nvarchar(256),
	total_delivared_later_that_expected int
)


;----------------Periodic fact table---------------------------
drop table FactPeriodict
create table FactPeriodict(
	TimeKey int FOREIGN KEY REFERENCES DimTime(TimeKey),
	CustomerKey int FOREIGN KEY REFERENCES DimCustomer(CustomerKey),
	OrderKey int FOREIGN KEY REFERENCES DimOrder(OrderKey),
	InvoiceKey int FOREIGN KEY REFERENCES DimInvoice(InvoiceKey),
	PeopleKey int FOREIGN KEY REFERENCES DimPeople(PeopleKey),
	TransactionTypeKey int FOREIGN KEY REFERENCES DimTransactionTypes(TransactionTypeID),
	PaymentMethodKey int FOREIGN KEY REFERENCES DimPayment(PaymentKey),
	TotalpurchasePrice int,
	TotalNumberOfStock int,
	MaxRepeatedPurchasedGoodsName nvarchar(200) null,
	MaxRepeatedNumberPurchasedGoods int null,
	TotalRetrivedProfit int,
	TotalPurchasedTax int,
	InActiveDayCount int
)
;----------------Procedure---------------------------