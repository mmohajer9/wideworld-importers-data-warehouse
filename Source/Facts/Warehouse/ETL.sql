CREATE OR ALTER PROCEDURE FillStockItemTranFact
    (@to_date DATE)
AS
BEGIN
    DECLARE @max_date DATE = ISNULL(
        (SELECT DimTime.FullDateAlternateKey
        FROM DimTime
        WHERE TimeKey = (SELECT max(TimeKey)
        FROM FactTransaction)), '2012-12-31'
    )

    -- CREATE TABLE tmp(
    --     --- fact definition
	-- )

    while(@max_date<@date) begin
        set @max_date = DATEADD(dd,1,@max_date)
        insert into tmp
            (TimeKey,CustomerKey,OrderKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
            AmountExcludingTax,TaxAmount,TransactionAmount)
        select isnull(dimTime.TimeKey,-1), isnull(Transactions.CustomerID,-1), isnull(DimOrder.OrderKey,-1),
            isnull(Transactions.InvoiceID,-1), isnull(DimPeople.PeopleKey,-1), isnull(Transactions.TransactionTypeID,-1), isnull(Transactions.PaymentMethodID,-1),
            Transactions.CustomerTransactionID, Transactions.AmountExcludingTax, Transactions.TaxAmount, Transactions.TransactionAmount
        from StagingCustomerTransactions as Transactions
            join DimTime on FullDateAlternateKey = Transactions.TransactionDate and DimTime.FullDateAlternateKey = @max_date
            left join DimInvoice On DimInvoice.InvoiceKey = Transactions.InvoiceID
            left join DimOrder On DimOrder.OrderKey = DimInvoice.OrderID
            left join DimPeople on DimPeople.PeopleKey = DimOrder.PrimaryContactPersonID
            left join DimPayment on DimPayment.PaymentKey = Transactions.PaymentMethodID

    end

    insert into FactTransaction
        (TimeKey,CustomerKey,OrderKey,InvoiceKey,PeopleKey,TransactionTypeKey,PaymentMethodKey,TransactionID,
        AmountExcludingTax,TaxAmount,TransactionAmount)
    select TimeKey, CustomerKey, OrderKey, InvoiceKey, PeopleKey, TransactionTypeKey, PaymentMethodKey, TransactionID,
        AmountExcludingTax, TaxAmount, TransactionAmount
    from tmp

    insert into LogSales
        (ActionName,TableName,date,RecordId,RecordSurrogateKey)
    select 'insert', 'FactTransaction', getdate(), tmp.TransactionID, null
    from tmp

    drop table tmp

END
GO