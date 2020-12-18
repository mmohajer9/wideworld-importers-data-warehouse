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
	TransactionID int primary key ,
	AmountExcludingTax decimal(25,3),
	TaxAmount decimal(25,3),
	TransactionAmount decimal(25,3)
)
GO


;----------------Acc fact table---------------------------
IF OBJECT_ID('dbo.FactAcc', 'U') IS NOT NULL
drop table FactAcc
create table FactAcc(
	AccKey int IDENTITY(1,1) primary key,
	CustomerKey int FOREIGN KEY REFERENCES DimCustomer(CustomerKey),
	OrderKey int FOREIGN KEY REFERENCES DimOrder(OrderKey),
	InvoiceKey int FOREIGN KEY REFERENCES DimInvoice(InvoiceKey),
	PeopleKey int FOREIGN KEY REFERENCES DimPeople(PeopleKey),
	TransactionTypeKey int FOREIGN KEY REFERENCES DimTransactionTypes(TransactionTypeID),
	PaymentMethodKey int FOREIGN KEY REFERENCES DimPayment(PaymentKey),
	TotalBuyPrice int,
	NumberOfPurchases int,
	MostFrequentBuy nvarchar(256),
	TotalDelivaredLaterThatExpected int,
	TotalProfit int
)
Go


;----------------Periodic fact table---------------------------
IF OBJECT_ID('dbo.FactPeriodict', 'U') IS NOT NULL
drop table FactPeriodict
create table FactPeriodict(
	FactPeriodicKey int IDENTITY(1,1) primary key,
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
Go