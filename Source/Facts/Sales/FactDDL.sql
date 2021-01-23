use [WWI-DW]



;----------------TransAction Fact table---------------------------
IF OBJECT_ID('dbo.FactSalesTransaction', 'U') IS NOT NULL
drop table FactSalesTransaction
create table FactSalesTransaction(
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
create index factSalesTransIndex ON 
	FactSalesTransaction(TimeKey,CustomerKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey)
create unique index factSalesTransIdIndex ON 
	FactSalesTransaction(TransactionID)



;----------------Acc fact table---------------------------
IF OBJECT_ID('dbo.FactSalesAcc', 'U') IS NOT NULL
drop table FactSalesAcc
create table FactSalesAcc(
	CustomerKey int ,
	PeopleKey int,
	TotalBuyPrice int,
	NumberOfPurchases int,
	TotalEstimatedProfit int,
	TotalTax int,
	averageBuyAmount int
)
Go

create index FactSalesAcc ON 
	FactSalesAcc(CustomerKey,PeopleKey)


;----------------Periodic fact table---------------------------
IF OBJECT_ID('dbo.FactSalesPeriodict', 'U') IS NOT NULL
drop table FactSalesPeriodict
create table FactSalesPeriodict(
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

create index FactSalesPeriodict ON 
	FactSalesPeriodict(TimeKey,CustomerKey,PeopleKey)