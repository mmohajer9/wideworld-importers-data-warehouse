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


GO
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


use [WWI-DW];
GO


IF OBJECT_ID('dbo.FactLog', 'U') IS NOT NULL
DROP TABLE dbo.FactLog
GO

CREATE TABLE FactLog
(
    [FactLogID] INT IDENTITY(1 , 1) PRIMARY KEY,
    [ProcedureName] NVARCHAR(500),
    [Action] NVARCHAR(500),
    [FactName] NVARCHAR(500),
    [Datetime] DATETIME2(7),
    [AffectedRowsNumber] INT
);
GO


CREATE OR ALTER PROCEDURE AddFactLog

    @procedure_name NVARCHAR(500) = "UNDEFINED",
    @action NVARCHAR(500) = "UNDEFINED",
    @FactName NVARCHAR(500) = "UNDEFINED",
    @Datetime DATETIME2,
    @AffectedRowsNumber INT = 0
AS
BEGIN

    INSERT INTO FactLog
        (
        [ProcedureName],
        [Action],
        [FactName],
        [Datetime],
        [AffectedRowsNumber]
        )
    VALUES
        (
            @procedure_name,
            @action,
            @FactName,
            @Datetime,
            @AffectedRowsNumber        
    );

END
--------------------------------------------------------------------------------------------------------------
GO


use [WWI-DW];
GO


-- Create a new table called 'FactStockItemTran' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.FactStockItemTran', 'U') IS NOT NULL
DROP TABLE dbo.FactStockItemTran
GO
-- Create the table in the specified schema
CREATE TABLE dbo.FactStockItemTran
(
    StockItemTransactionID INT PRIMARY KEY,
    -- primary key column

    --^ FOREIGN KEYS

    StockItemID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimStockItems(StockItemID),

    UnitPackageTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPackageTypes(PackageTypeID),

    OuterPackageTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPackageTypes(PackageTypeID),

    ColorID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimColors(ColorID),

    CustomerKey INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimCustomer(CustomerKey),

    CustomerID INT,

    InvoiceKey INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimInvoice(InvoiceKey),

    SupplierID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimSuplier(SupplierID),

    PurchaseOrderID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimPurchaseOrder(PurchaseOrderID),

    TransactionTypeID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimTransactionTypes(TransactionTypeID),

    TransactionDate INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimTime(TimeKey),

    --^ MEASURES --> transactional

    MovementQuantity [NUMERIC](20 , 3),
    RemainingQuantityAfterThisTransaction [NUMERIC](20 , 3),
);
GO



-- Create a new table called 'FactDailyStockItemTran' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.FactDailyStockItemTran', 'U') IS NOT NULL
DROP TABLE dbo.FactDailyStockItemTran
GO
-- Create the table in the specified schema
CREATE TABLE dbo.FactDailyStockItemTran
(

    --^ FOREIGN KEYS

    StockItemID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimStockItems(StockItemID),

    TimeKey INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimTime(TimeKey),

    --^ MEASURES --> Daily Fact

    TotalMovementQuantityInDay [NUMERIC](20 , 3),
    TotalEntryMovementQuantityInDay [NUMERIC](20 , 3),
    TotalWriteOffMovementQuantityInDay [NUMERIC](20 , 3),


    MaximumMovementQuantityInDay [NUMERIC](20 , 3),
    MinimumMovementQuantityInDay [NUMERIC](20 , 3),

    MaximumRemainingMovementQuantityInDay [NUMERIC](20 , 3), --^ depends on today + previous day
    MinimumRemainingMovementQuantityInDay [NUMERIC](20 , 3), --^ depends on today + previous day
    RemainingMovementQuantityInThisDay [NUMERIC](20 , 3), --^ depends on today + previous day

    TotalDaysOffCountTillToday INT, --^ depends on today + previous day

    AverageMovementQuantityInThisDay [NUMERIC](20 , 3),
    TransactionsCount INT,
    AverageMovementQuantityTillThisDay [NUMERIC](20 , 3) --^ depends on today + previous day
    

);
GO



-- Create a new table called 'FactAccStockItemTran' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.FactAccStockItemTran', 'U') IS NOT NULL
DROP TABLE dbo.FactAccStockItemTran
GO
-- Create the table in the specified schema
CREATE TABLE dbo.FactAccStockItemTran
(


    --^ FOREIGN KEYS

    StockItemID INT, 
    -- FOREIGN KEY 
    -- REFERENCES DimStockItems(StockItemID),

    --^ MEASURES --> Acc Fact

    TotalRemainingMovementQuantity [NUMERIC](20 , 3),
    TotalDaysOffCount INT, --^ kole roozaye bedone amalkard in stockitem dar kole doran
    TransactionsCount INT,
    AverageMovementQuantity [NUMERIC](20 , 3),

);
GO


CREATE INDEX FactStockItemTranIndex ON FactStockItemTran(StockItemID , TransactionDate,CustomerKey,InvoiceKey,TransactionTypeID);
CREATE INDEX FactStockItemDailyIndex ON FactDailyStockItemTran(StockItemID , TimeKey);
CREATE INDEX FactStockItemAccIndex ON FactAccStockItemTran(StockItemID);

GO


use [WWI-DW];
GO

-- Create a new table called 'RemainingStockItemQuantityPerDay' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.RemainingStockItemQuantityPerDay', 'U') IS NOT NULL
DROP TABLE dbo.RemainingStockItemQuantityPerDay
GO
-- Create the table in the specified schema
CREATE TABLE dbo.RemainingStockItemQuantityPerDay
(
    StockItemID INT,
    [Date] DATE,
    RemainingStockItemQuantity [NUMERIC](20 , 3), --* mande akhar har rooz
);
GO

-- Create a new table called 'TotalMovementQuantityForStockItemPerDay' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.TotalMovementQuantityForStockItemPerDay', 'U') IS NOT NULL
DROP TABLE dbo.TotalMovementQuantityForStockItemPerDay
GO
-- Create the table in the specified schema
CREATE TABLE dbo.TotalMovementQuantityForStockItemPerDay
(
    StockItemID INT,
    [Date] DATE,
    TotalMovementQuantityInDay [NUMERIC](20 , 3), --* all
);
GO
-- Create a new table called 'TotalEntryMovementQuantityForStockItemPerDay' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.TotalEntryMovementQuantityForStockItemPerDay', 'U') IS NOT NULL
DROP TABLE dbo.TotalEntryMovementQuantityForStockItemPerDay
GO
-- Create the table in the specified schema
CREATE TABLE dbo.TotalEntryMovementQuantityForStockItemPerDay
(
    StockItemID INT,
    [Date] DATE,
    TotalEntryMovementQuantityInDay [NUMERIC](20 , 3), --* +
);
GO
-- Create a new table called 'TotalWriteOffMovementQuantityForStockItemPerDay' in schema 'dbo'
-- Drop the table if it already exists
IF OBJECT_ID('dbo.TotalWriteOffMovementQuantityForStockItemPerDay', 'U') IS NOT NULL
DROP TABLE dbo.TotalWriteOffMovementQuantityForStockItemPerDay
GO
-- Create the table in the specified schema
CREATE TABLE dbo.TotalWriteOffMovementQuantityForStockItemPerDay
(
    StockItemID INT,
    [Date] DATE,
    TotalWriteOffMovementQuantityInDay [NUMERIC](20 , 3), --* -
);
GO
--*--------------------------------------------------------------------------------------------------------------------*--

CREATE OR ALTER PROCEDURE FillFactTransactionalStockItem
    @to_date DATE
AS
BEGIN

    --? getting the the time key of the latest item that is added to fact
    DECLARE @LastAddedTimeKey INT = (
        SELECT max(TransactionDate)
        FROM FactStockItemTran
    )
    --^ getting the date of the latest item that is added to fact , if it is null --> 2012-12-31 default value
    DECLARE @LastAddedDate DATE = ISNULL(
        (
            SELECT FullDateAlternateKey
            FROM DimTime
            WHERE TimeKey = @LastAddedTimeKey
        )
        , '2012-12-31');

    DECLARE @CURRENT_DATETIME DATETIME2;


    IF OBJECT_ID('temp_fact_stock_item_transactions', 'U') IS NOT NULL
        DROP TABLE temp_fact_stock_item_transactions

    CREATE TABLE temp_fact_stock_item_transactions
    (
        StockItemTransactionID INT PRIMARY KEY,
        StockItemID INT,
        UnitPackageTypeID INT,
        OuterPackageTypeID INT,
        ColorID INT,
        CustomerKey INT,
        CustomerID INT ,
        InvoiceKey INT,
        SupplierID INT,
        PurchaseOrderID INT,
        TransactionTypeID INT,
        TransactionDate INT,
        MovementQuantity [NUMERIC](20 , 3),
        RemainingQuantityAfterThisTransaction [NUMERIC](20 , 3),
    )


    WHILE(@LastAddedDate < @to_date) 
    BEGIN

        TRUNCATE TABLE temp_fact_stock_item_transactions;

        --? go to the next day
        SET @LastAddedDate = DATEADD(dd, 1, @LastAddedDate)
        SET @LastAddedTimeKey = (
            SELECT TimeKey
            FROM DimTime
            WHERE FullDateAlternateKey = @LastAddedDate
        );

        --^ inserting into the temporary table then join then bulk insert into fact
        INSERT INTO temp_fact_stock_item_transactions
            (
            StockItemTransactionID,
            StockItemID,
            UnitPackageTypeID,
            OuterPackageTypeID,
            ColorID,
            CustomerKey,
            CustomerID,
            InvoiceKey,
            SupplierID,
            PurchaseOrderID,
            TransactionTypeID,
            TransactionDate,
            MovementQuantity,
            RemainingQuantityAfterThisTransaction
            )
        SELECT
            StockItemTransactionID,
            a.StockItemID,
            ISNULL(b.UnitPackageTypeID , -1) as UnitPackageTypeID,
            ISNULL(b.OuterPackageTypeID , -1) as OuterPackageTypeID,
            ISNULL(b.ColorID , -1) as ColorID,

            --^ Sales Fields
            ISNULL(CustomerKey , -1) as CustomerKey,
            ISNULL(a.CustomerID , -1) as CustomerID,
            ISNULL(InvoiceID , -1) as InvoiceID,

            -- ^ Purchase Fields
            ISNULL(a.SupplierID , -1) as SupplierID,
            ISNULL(PurchaseOrderID , -1) as PurchaseOrderID,

            TransactionTypeID,
            TimeKey,
            Quantity,

            SUM(Quantity) OVER (PARTITION BY a.StockItemID ORDER BY StockItemTransactionID) + ISNULL(e.RemainingStockItemQuantity,0)

        FROM [WWI-Staging].dbo.StagingStockItemTransactions a
            LEFT OUTER JOIN RemainingStockItemQuantityPerDay e
            on (e.StockItemID = a.StockItemID and e.Date = DATEADD(dd, -1, @LastAddedDate))
            LEFT OUTER JOIN DimStockItems b on (a.StockItemID = b.StockItemID)
            LEFT OUTER JOIN DimTime c on (a.TransactionOccurredWhen = c.FullDateAlternateKey)
            LEFT OUTER JOIN DimCustomer d on (d.CustomerID = a.CustomerID)
        WHERE (TransactionOccurredWhen >= @LastAddedDate AND TransactionOccurredWhen < DATEADD(dd, 1, @LastAddedDate))
            AND (CurrentFlag = 1 or CurrentFlag is NULL)
        
        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO FactStockItemTran
            (
            StockItemTransactionID,
            StockItemID,
            UnitPackageTypeID,
            OuterPackageTypeID,
            ColorID,
            CustomerKey,
            CustomerID,
            InvoiceKey,
            SupplierID,
            PurchaseOrderID,
            TransactionTypeID,
            TransactionDate,
            MovementQuantity,
            RemainingQuantityAfterThisTransaction
            )
        SELECT
            StockItemTransactionID,
            StockItemID,
            UnitPackageTypeID,
            OuterPackageTypeID,
            ColorID,
            CustomerKey,
            CustomerID,
            InvoiceKey,
            SupplierID,
            PurchaseOrderID,
            TransactionTypeID,
            TransactionDate,
            MovementQuantity,
            RemainingQuantityAfterThisTransaction
        FROM temp_fact_stock_item_transactions

        --? LOG
        EXEC AddFactLog
            @procedure_name = 'FillStockItemTranFact',
            @action = 'INSERT',
            @FactName = 'FactStockItemTran',
            @Datetime = @CURRENT_DATETIME,
            @AffectedRowsNumber = @@ROWCOUNT;
        
        WITH T1 (StockItemID,TotalMovementQuantityInDay)
            AS
            (
                SELECT a.StockItemID , SUM(MovementQuantity)
                FROM temp_fact_stock_item_transactions a
                GROUP BY a.StockItemID
            )
            INSERT INTO TotalMovementQuantityForStockItemPerDay
            (
                StockItemID,
                [Date],
                TotalMovementQuantityInDay
            )
            SELECT StockItemID , @LastAddedDate , TotalMovementQuantityInDay
            FROM T1;


        WITH T2 (StockItemID,TotalEntryMovementQuantityInDay)
            AS
            (
                SELECT a.StockItemID , SUM(MovementQuantity)
                FROM temp_fact_stock_item_transactions a
                WHERE MovementQuantity > 0
                GROUP BY a.StockItemID
            )
            INSERT INTO TotalEntryMovementQuantityForStockItemPerDay
            (
                StockItemID,
                [Date],
                TotalEntryMovementQuantityInDay
            )
            SELECT StockItemID , @LastAddedDate , TotalEntryMovementQuantityInDay
            FROM T2;

        WITH T3 (StockItemID,TotalWriteOffMovementQuantityInDay)
            AS
            (
                SELECT a.StockItemID , SUM(MovementQuantity)
                FROM temp_fact_stock_item_transactions a
                WHERE MovementQuantity < 0
                GROUP BY a.StockItemID
            )
            INSERT INTO TotalWriteOffMovementQuantityForStockItemPerDay
            (
                StockItemID,
                [Date],
                TotalWriteOffMovementQuantityInDay
            )
            SELECT StockItemID , @LastAddedDate , TotalWriteOffMovementQuantityInDay
            FROM T3;


        --? inserting the remaining quantity to RemainingStockItemQuantityPerDay
        WITH T4 (StockItemID,TotalMovementQuantityInDay)
            AS
            (
                SELECT a.StockItemID , SUM(MovementQuantity)
                FROM temp_fact_stock_item_transactions a
                GROUP BY a.StockItemID
            )
            INSERT INTO RemainingStockItemQuantityPerDay
            SELECT 
                a.StockItemID,
                @LastAddedDate,
                ISNULL(TotalMovementQuantityInDay,0) + ISNULL(
                    c.RemainingStockItemQuantity
                ,0)
            FROM DimStockItems a 
            LEFT OUTER JOIN T4 b on (a.StockItemID = b.StockItemID)  
            LEFT OUTER JOIN RemainingStockItemQuantityPerDay c on (a.StockItemID = c.StockItemID and c.Date = DATEADD(dd, -1, @LastAddedDate))
            WHERE a.StockItemID != -1;
    
    END


END

GO

--*--------------------------------------------------------------------------------------------------------------------*--

CREATE OR ALTER PROCEDURE FillFactDailyStockItem
    @to_date DATE
AS
BEGIN

    -- DECLARE @LastAddedTimeKeyInTransactionalFact INT = (
    --     SELECT max(TransactionDate)
    --     FROM FactStockItemTran
    -- )

    -- DECLARE @LastAddedDateInTransactionalFact DATE = ISNULL(
    --     (
    --         SELECT FullDateAlternateKey
    --         FROM DimTime
    --         WHERE TimeKey = @LastAddedTimeKeyInTransactionalFact
    --     )
    --     , '2012-12-31');

    -- --? exit the proceu
    -- IF @to_date > @LastAddedDateInTransactionalFact
    -- BEGIN
    --     PRINT 'First Fill The Transactional Fact Till The Given Date Then Run This Procedure for Periodic Daily Snapshot';
    --     RETURN;
    -- END

    --? getting the the time key of the latest item that is added to fact
    DECLARE @LastAddedTimeKey INT = (
        SELECT max(TimeKey)
        FROM FactDailyStockItemTran
    )

    --^ getting the date of the latest item that is added to fact , if it is null --> 2012-12-31 default value
    DECLARE @LastAddedDate DATE = ISNULL((SELECT FullDateAlternateKey
    FROM DimTime
    WHERE TimeKey = @LastAddedTimeKey), '2012-12-31');

    DECLARE @CURRENT_DATETIME DATETIME2;
    

    -- Create a new table called 'current_day_transactions' in schema 'dbo'
    -- Drop the table if it already exists
    IF OBJECT_ID('dbo.current_day_transactions', 'U') IS NOT NULL
    DROP TABLE dbo.current_day_transactions;
    -- Create the table in the specified schema
    CREATE TABLE current_day_transactions
    (
        StockItemTransactionID INT,
        StockItemID INT,
        TransactionDate INT,
        MovementQuantity [NUMERIC](20 , 3),
        RemainingQuantityAfterThisTransaction [NUMERIC](20 , 3),
    );

    -- Create a new table called 'temp1_fact_daily' in schema 'dbo'
    -- Drop the table if it already exists
    IF OBJECT_ID('dbo.temp1_fact_daily', 'U') IS NOT NULL
    DROP TABLE temp1_fact_daily;

    -- Create the table in the specified schema
    CREATE TABLE temp1_fact_daily
    (
        --^ FOREIGN KEYS

        StockItemID INT, 
        TimeKey INT, 

        --^ MEASURES --> Daily Fact

        TotalMovementQuantityInDay [NUMERIC](20 , 3),
        TotalEntryMovementQuantityInDay [NUMERIC](20 , 3),
        TotalWriteOffMovementQuantityInDay [NUMERIC](20 , 3),
    );


    -- Create a new table called 'temp2_fact_daily' in schema 'dbo'
    -- Drop the table if it already exists
    IF OBJECT_ID('dbo.temp2_fact_daily', 'U') IS NOT NULL
    DROP TABLE temp2_fact_daily;

    -- Create the table in the specified schema
    CREATE TABLE temp2_fact_daily
    (
        --^ FOREIGN KEYS

        StockItemID INT, 
        TimeKey INT, 

        --^ MEASURES --> Daily Fact

        MaximumMovementQuantityInDay [NUMERIC](20 , 3),
        MinimumMovementQuantityInDay [NUMERIC](20 , 3),
    );


    -- Create a new table called 'temp3_fact_daily' in schema 'dbo'
    -- Drop the table if it already exists
    IF OBJECT_ID('dbo.temp3_fact_daily', 'U') IS NOT NULL
    DROP TABLE temp3_fact_daily;

    -- Create the table in the specified schema
    CREATE TABLE temp3_fact_daily
    (
        --^ FOREIGN KEYS

        StockItemID INT, 
        TimeKey INT, 

        --^ MEASURES --> Daily Fact

        MaximumRemainingMovementQuantityInDay [NUMERIC](20 , 3), --^ depends on today + previous day
        MinimumRemainingMovementQuantityInDay [NUMERIC](20 , 3), --^ depends on today + previous day
        RemainingMovementQuantityInThisDay [NUMERIC](20 , 3), --^ depends on today + previous day
    );


    -- Create a new table called 'temp4_fact_daily' in schema 'dbo'
    -- Drop the table if it already exists
    IF OBJECT_ID('dbo.temp4_fact_daily', 'U') IS NOT NULL
    DROP TABLE temp4_fact_daily;

    -- Create the table in the specified schema
    CREATE TABLE temp4_fact_daily
    (
        --^ FOREIGN KEYS

        StockItemID INT, 
        TimeKey INT, 

        --^ MEASURES --> Daily Fact

        TotalDaysOffCountTillToday INT, --^ depends on today + previous day
    );

    -- Create a new table called 'temp5_fact_daily' in schema 'dbo'
    -- Drop the table if it already exists
    IF OBJECT_ID('dbo.temp5_fact_daily', 'U') IS NOT NULL
    DROP TABLE temp5_fact_daily;

    -- Create the table in the specified schema
    CREATE TABLE temp5_fact_daily
    (
        --^ FOREIGN KEYS

        StockItemID INT, 
        TimeKey INT, 

        --^ MEASURES --> Daily Fact
        TransactionsCount INT,
        AverageMovementQuantityTillThisDay [NUMERIC](20 , 3) --^ depends on today + previous day
    );

    -- Create a new table called 'temp6_fact_daily' in schema 'dbo'
    -- Drop the table if it already exists
    IF OBJECT_ID('dbo.temp6_fact_daily', 'U') IS NOT NULL
    DROP TABLE temp6_fact_daily;

    -- Create the table in the specified schema
    CREATE TABLE temp6_fact_daily
    (
        --^ FOREIGN KEYS

        StockItemID INT, 
        TimeKey INT, 

        --^ MEASURES --> Daily Fact

        AverageMovementQuantityInThisDay [NUMERIC](20 , 3) --^ depends on today
    );

    --^-- starting the process --^--
    
    WHILE(@LastAddedDate < @to_date) 
    BEGIN


        

        --? first truncating the temp tables for each measure group
        TRUNCATE TABLE current_day_transactions;
        TRUNCATE TABLE temp1_fact_daily;
        TRUNCATE TABLE temp2_fact_daily;
        TRUNCATE TABLE temp3_fact_daily;
        TRUNCATE TABLE temp4_fact_daily;
        TRUNCATE TABLE temp5_fact_daily;
        TRUNCATE TABLE temp6_fact_daily;

        --? go to the next day
        SET @LastAddedDate = DATEADD(dd, 1, @LastAddedDate)
        SET @LastAddedTimeKey = (
            SELECT TimeKey
            FROM DimTime
            WHERE FullDateAlternateKey = @LastAddedDate
        );

        --^ inserting into the temporary table then join then bulk insert into fact


        --*---------------------------------------------* filling the temp0 here *------------------------------------------------------------------*--
        WITH CTE as
            (
                select 
                    StockItemTransactionID,
                    StockItemID,
                    TransactionDate,
                    MovementQuantity,
                    RemainingQuantityAfterThisTransaction
                from FactStockItemTran
                where TransactionDate = @LastAddedTimeKey
            )
            INSERT INTO current_day_transactions
            SELECT 
                    StockItemTransactionID,
                    StockItemID,
                    TransactionDate,
                    MovementQuantity,
                    RemainingQuantityAfterThisTransaction
            FROM CTE;
        --*---------------------------------------------* filling the temp1 here *------------------------------------------------------------------*--
        WITH CTE (StockItemID , EffectiveDate , TotalMovementQuantityInDay , TotalEntryMovementQuantityInDay , TotalWriteOffMovementQuantityInDay)
            AS
            (
                select a.StockItemID , a.Date as Date,
                TotalMovementQuantityInDay , TotalEntryMovementQuantityInDay , TotalWriteOffMovementQuantityInDay
                from [dbo].[TotalMovementQuantityForStockItemPerDay] a
                LEFT OUTER join TotalEntryMovementQuantityForStockItemPerDay b on (a.StockItemID = b.StockItemID and a.Date = b.Date)
                LEFT OUTER join TotalWriteOffMovementQuantityForStockItemPerDay c on (a.StockItemID = c.StockItemID and a.Date = c.Date)
                where a.Date = @LastAddedDate
            ),
            Final
            AS
            (
                SELECT	d.StockItemID as StockItemID,
                        ISNULL(EffectiveDate,@LastAddedDate) as EffectiveDate,
                        ISNULL(TotalMovementQuantityInDay,0) as TotalMovementQuantityInDay,
                        ISNULL(TotalEntryMovementQuantityInDay,0) as TotalEntryMovementQuantityInDay,
                        ISNULL(TotalWriteOffMovementQuantityInDay,0) as TotalWriteOffMovementQuantityInDay
                FROM DimStockItems d LEFT OUTER JOIN CTE on (d.StockItemID = CTE.StockItemID)
                where d.StockItemID != -1
            )
            INSERT INTO temp1_fact_daily
            select 
                StockItemID , TimeKey,
                TotalMovementQuantityInDay,
                TotalEntryMovementQuantityInDay,
                TotalWriteOffMovementQuantityInDay
            from Final a left outer join DimTime b 
            on (a.EffectiveDate = b.FullDateAlternateKey)        
        --*---------------------------------------------* filling the temp2 here *------------------------------------------------------------------*--
        INSERT INTO temp2_fact_daily
        SELECT 
            a.StockItemID as StockItemID, 
            ISNULL(TransactionDate , @LastAddedTimeKey) AS TimeKey, 
            ISNULL(MAX(MovementQuantity) , 0) AS MaximumMovementQuantityInDay,
            ISNULL(MIN(MovementQuantity) , 0) AS MinimumMovementQuantityInDay
        FROM DimStockItems a LEFT OUTER JOIN current_day_transactions b on (a.StockItemID = b.StockItemID)
        where a.StockItemID != -1
        GROUP BY a.StockItemID , TransactionDate;
        --*---------------------------------------------* filling the temp3 here *------------------------------------------------------------------*--
        WITH CTE as
            (
                SELECT 
                    a.StockItemID, 
                    ISNULL(TransactionDate , @LastAddedTimeKey) AS TimeKey, 
                    MAX(RemainingQuantityAfterThisTransaction) as MaximumRemainingMovementQuantityInDay,
                    MIN(RemainingQuantityAfterThisTransaction) as MinimumRemainingMovementQuantityInDay
                FROM DimStockItems a 
                LEFT OUTER JOIN current_day_transactions b on (a.StockItemID = b.StockItemID)
                WHERE a.StockItemID != -1
                GROUP BY a.StockItemID, TransactionDate
            )
        INSERT INTO temp3_fact_daily
        select 
            a.StockItemID,
            TimeKey,
            ISNULL(MaximumRemainingMovementQuantityInDay,c.RemainingStockItemQuantity) as MaximumRemainingMovementQuantityInDay,
            ISNULL(MinimumRemainingMovementQuantityInDay,c.RemainingStockItemQuantity) as MinimumRemainingMovementQuantityInDay,
            RemainingStockItemQuantity
        FROM CTE a LEFT OUTER JOIN RemainingStockItemQuantityPerDay c 
        ON (a.StockItemID = c.StockItemID AND c.Date = @LastAddedDate);      
        --*---------------------------------------------* filling the temp4 here *------------------------------------------------------------------*--
        WITH CTE1 as
            (
                SELECT 
                    a.StockItemID,
                    ISNULL(TransactionDate , @LastAddedTimeKey) as TimeKey,
                    MovementQuantity
                FROM DimStockItems a 
                LEFT OUTER JOIN current_day_transactions b on (a.StockItemID = b.StockItemID)
                where a.StockItemID != -1
            ),
            CTE2 as
            (
                SELECT StockItemID , TimeKey , 
                COUNT(MovementQuantity) as TransactionCount,
                CASE COUNT(MovementQuantity)
                    WHEN 0 then 'No' 
                    else 'Yes' 
                END as DoesItHaveTransactions
                FROM CTE1
                GROUP BY StockItemID , TimeKey
            )
        INSERT INTO temp4_fact_daily
        SELECT 
            a.StockItemID,
            a.TimeKey,
            CASE a.DoesItHaveTransactions
                WHEN 'Yes' then 0
                else ISNULL(B.TotalDaysOffCountTillToday + 1,1)
            END as TotalDaysOffCountTillToday
            FROM CTE2 a LEFT OUTER JOIN FactDailyStockItemTran b
            ON (a.StockItemID = b.StockItemID and
            b.TimeKey = (SELECT TimeKey From DimTime WHERE FullDateAlternateKey = DATEADD(dd, -1, @LastAddedDate)));
        --*---------------------------------------------* filling the temp5 here *------------------------------------------------------------------*--
        WITH CTE as
        (
            select 
                StockItemID,
                TransactionDate as TimeKey,
                COUNT(MovementQuantity) as TransactionsCount
            from FactStockItemTran
            where TransactionDate = @LastAddedTimeKey
            GROUP BY StockItemID , TransactionDate
        ),
        T1 as
        (
            Select a.StockItemID,
            ISNULL(b.TimeKey,@LastAddedTimeKey) as TimeKey , 
            ISNULL(b.TransactionsCount , 0) + ISNULL(c.TransactionsCount ,0) as TransactionsCount,
            c.AverageMovementQuantityTillThisDay as AverageMovementQuantityTillThisDay
            FROM DimStockItems a 
            LEFT OUTER JOIN CTE b on (a.StockItemID = b.StockItemID)
            LEFT OUTER JOIN FactDailyStockItemTran c on (a.StockItemID = c.StockItemID and c.TimeKey = (SELECT TimeKey From DimTime WHERE FullDateAlternateKey = DATEADD(dd, -1, @LastAddedDate)))
            WHERE a.StockItemID != -1
        )
        INSERT INTO temp5_fact_daily
        select 
            a.StockItemID , 
            TimeKey , 
            TransactionsCount , 
            CASE TransactionsCount
                WHEN 0 then ISNULL(AverageMovementQuantityTillThisDay , ISNULL(a.AverageMovementQuantityTillThisDay , 0))
                else (RemainingStockItemQuantity / TransactionsCount)
            END as AverageMovementQuantityTillThisDay
        from T1 a LEFT OUTER JOIN RemainingStockItemQuantityPerDay b 
        on (a.StockItemID = b.StockItemID and a.TimeKey = (SELECT TimeKey FROM DimTime WHERE FullDateAlternateKey = b.Date));
        --*---------------------------------------------* filling the temp6 here *------------------------------------------------------------------*--
        WITH CTE as
            (
                select 
                    StockItemID,
                    TransactionDate,
                    MovementQuantity,
                    RemainingQuantityAfterThisTransaction
                from FactStockItemTran
                where TransactionDate = @LastAddedTimeKey
            )
            INSERT INTO temp6_fact_daily
            SELECT 
                    a.StockItemID,
                    ISNULL(TransactionDate , @LastAddedTimeKey) AS TimeKey,
                    ISNULL(AVG(MovementQuantity),0) as AverageMovementQuantityInThisDay
            FROM DimStockItems a LEFT OUTER JOIN CTE b on (a.StockItemID = b.StockItemID)
            where a.StockItemID != -1 
        Group by a.StockItemID , TransactionDate;
        --^---------------------------- joining the temp1,2,3,4,5 and bulk insert into the fact table ----------------------------------------------^--
        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO FactDailyStockItemTran
            (
                StockItemID,
                TimeKey,
                TotalMovementQuantityInDay,
                TotalEntryMovementQuantityInDay,
                TotalWriteOffMovementQuantityInDay,
                MaximumMovementQuantityInDay,
                MinimumMovementQuantityInDay,
                MaximumRemainingMovementQuantityInDay,
                MinimumRemainingMovementQuantityInDay,
                RemainingMovementQuantityInThisDay,
                TotalDaysOffCountTillToday,
                AverageMovementQuantityInThisDay,
                TransactionsCount,
                AverageMovementQuantityTillThisDay
            )
        SELECT
                a.StockItemID,
                a.TimeKey,

                a.TotalMovementQuantityInDay,
                a.TotalEntryMovementQuantityInDay,
                a.TotalWriteOffMovementQuantityInDay,

                b.MaximumMovementQuantityInDay,
                b.MinimumMovementQuantityInDay,

                c.MaximumRemainingMovementQuantityInDay,
                c.MinimumRemainingMovementQuantityInDay,
                c.RemainingMovementQuantityInThisDay,

                d.TotalDaysOffCountTillToday,

                f.AverageMovementQuantityInThisDay,

                e.TransactionsCount,
                e.AverageMovementQuantityTillThisDay
        FROM 
            temp1_fact_daily a 
            inner join temp2_fact_daily b on (a.StockItemID = b.StockItemID and a.TimeKey = b.TimeKey)
            inner join temp3_fact_daily c on (a.StockItemID = c.StockItemID and a.TimeKey = c.TimeKey)
            inner join temp4_fact_daily d on (a.StockItemID = d.StockItemID and a.TimeKey = d.TimeKey)
            inner join temp5_fact_daily e on (a.StockItemID = e.StockItemID and a.TimeKey = e.TimeKey)
            inner join temp6_fact_daily f on (a.StockItemID = f.StockItemID and a.TimeKey = f.TimeKey)

        --? LOG
        EXEC AddFactLog
            @procedure_name = 'FillFactDailyStockItem',
            @action = 'INSERT',
            @FactName = 'FactDailyStockItemTran',
            @Datetime = @CURRENT_DATETIME,
            @AffectedRowsNumber = @@ROWCOUNT;

    END


END

GO

--*--------------------------------------------------------------------------------------------------------------------*--

CREATE OR ALTER PROCEDURE FillFactAccStockItem
AS
BEGIN

    --? getting the the time key of the latest item that is added to fact
    DECLARE @LastAddedTimeKey INT = (
        SELECT max(TimeKey)
        FROM FactDailyStockItemTran
    )

    --^ getting the date of the latest item that is added to fact , if it is null --> 2012-12-31 default value
    DECLARE @LastAddedDate DATE = ISNULL((SELECT FullDateAlternateKey
    FROM DimTime
    WHERE TimeKey = @LastAddedTimeKey), '2012-12-31');

    DECLARE @CURRENT_DATETIME DATETIME2;

    --^-- starting the process --^--

    --^ inserting into the temporary table then join then bulk insert into fact


    -- Create a new table called 'temp_fact_stock_item_acc' in schema 'dbo'
    -- Drop the table if it already exists
    IF OBJECT_ID('dbo.temp_fact_stock_item_acc', 'U') IS NOT NULL
    DROP TABLE dbo.temp_fact_stock_item_acc;
    -- Create the table in the specified schema
    CREATE TABLE temp_fact_stock_item_acc
    (
        StockItemID INT, 
        TotalRemainingMovementQuantity [NUMERIC](20 , 3),
        TotalDaysOffCount INT,
        TransactionsCount INT,
        AverageMovementQuantity [NUMERIC](20 , 3),
    );


    INSERT INTO temp_fact_stock_item_acc
    SELECT
        StockItemID,
        RemainingMovementQuantityInThisDay,
        TotalDaysOffCountTillToday,
        TransactionsCount,
        AverageMovementQuantityTillThisDay
    FROM FactDailyStockItemTran
    WHERE TimeKey = @LastAddedTimeKey;

    
    SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));


    TRUNCATE TABLE FactAccStockItemTran;

    INSERT INTO FactAccStockItemTran
    SELECT
        StockItemID,
        TotalRemainingMovementQuantity,
        TotalDaysOffCount,
        TransactionsCount,
        AverageMovementQuantity

    FROM temp_fact_stock_item_acc;

    --? LOG
    EXEC AddFactLog
        @procedure_name = 'FillFactAccStockItem',
        @action = 'INSERT',
        @FactName = 'FactAccStockItemTran',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT;




END

GO

--*--------------------------------------------------------------------------------------------------------------------*--



CREATE OR ALTER PROCEDURE FILL_WAREHOUSE_FACTS
    @to_date DATE,
    @FirstLoad BIT = 0
AS
BEGIN

    IF @FirstLoad = 1
    BEGIN
        TRUNCATE TABLE RemainingStockItemQuantityPerDay;
        TRUNCATE TABLE TotalMovementQuantityForStockItemPerDay;
        TRUNCATE TABLE TotalEntryMovementQuantityForStockItemPerDay;
        TRUNCATE TABLE TotalWriteOffMovementQuantityForStockItemPerDay;
        TRUNCATE TABLE FactStockItemTran;
        TRUNCATE TABLE FactDailyStockItemTran;
        TRUNCATE TABLE FactAccStockItemTran;
    END

    EXECUTE FillFactTransactionalStockItem @to_date = @to_date;
    EXECUTE FillFactDailyStockItem @to_date = @to_date;
    EXECUTE FillFactAccStockItem;

END
--------------------------------------------------------------------------------------------------------------
GO
