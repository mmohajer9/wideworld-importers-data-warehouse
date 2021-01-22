use [WWI-DW]



;----------------TransAction Fact table---------------------------
IF OBJECT_ID('dbo.FactTransaction', 'U') IS NOT NULL
drop table FactTransaction
create table FactTransaction(
	TimeKey int ,
	CustomerKey int,
	InvoiceKey int ,
	PeopleKey int ,
	TransactionTypeKey int ,
	PaymentMethodKey int ,
	TransactionID int,
	AmountExcludingTax decimal(25,3),
	TaxAmount decimal(25,3),
	TransactionAmount decimal(25,3),
	TransactionProfit int,
	AccumulationTransactionAmountAfterThisOne decimal(25,3)
)
GO
create index factTransIndex ON 
	FactTransaction(TimeKey,CustomerKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey)
create unique index factTransIdIndex ON 
	FactTransaction(TransactionID)



;----------------Acc fact table---------------------------
IF OBJECT_ID('dbo.FactAcc', 'U') IS NOT NULL
drop table FactAcc
create table FactAcc(
	CustomerKey int ,
	PeopleKey int,
	TotalBuyPrice int,
	NumberOfPurchases int,
	MostFrequentBuy nvarchar(256),
	TotalDelivaredLaterThatExpected int,
	TotalProfit int
)
Go

create index FactAcc ON 
	FactAcc(CustomerKey,PeopleKey)


;----------------Periodic fact table---------------------------
IF OBJECT_ID('dbo.FactPeriodict', 'U') IS NOT NULL
drop table FactPeriodict
create table FactPeriodict(
	TimeKey int ,
	CustomerKey int ,
	PeopleKey int ,
	TotalpurchasePrice decimal(25,3),
	TotalNumberOfStock int,
	TotalTransactionCountTillNow int,
	EstimatedTotalRetrivedProfit decimal(25,3),
	TotalPurchasedTax decimal(25,3),
	InActiveDayCountTillNow int,
	lastBuyDateKey int,
	averageBuyAmountTillNow decimal(25,3)
)
Go

create index FactPeriodict ON 
	FactPeriodict(TimeKey,CustomerKey,PeopleKey)