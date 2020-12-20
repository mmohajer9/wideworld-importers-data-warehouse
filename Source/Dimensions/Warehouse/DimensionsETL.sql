CREATE OR ALTER PROCEDURE SCD1_DimStockGroup
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN
    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimStockGroup
    )

    DECLARE @CURRENT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    IF @dim_row_count <> 0
    BEGIN
        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        DELETE FROM DimStockGroup
        WHERE StockGroupID in (
        select
            StockGroupID
        from StagingStockGroups        
        );


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimStockGroup',
        @action = 'DELETE',
        @DimensionName = 'DimStockGroup',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimStockGroup
        select
            StockGroupID,
            StockGroupName
        from StagingStockGroups


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimStockGroup',
        @action = 'INSERT',
        @DimensionName = 'DimStockGroup',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT
    END
    ---
    ELSE
    BEGIN


        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimStockGroup
        select
            StockGroupID,
            StockGroupName
        from StagingStockGroups


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimStockGroup',
        @action = 'INSERT',
        @DimensionName = 'DimStockGroup',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT
    END

END
GO

CREATE OR ALTER PROCEDURE SCD1_DimPackageTypes
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN

    DECLARE @CURRENT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimPackageTypes
    )

    IF @dim_row_count <> 0
    BEGIN

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        DELETE FROM DimPackageTypes
        WHERE PackageTypeID in (
        select
            PackageTypeID
        from StagingPackageTypes        
        );


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimPackageTypes',
        @action = 'DELETE',
        @DimensionName = 'DimPackageTypes',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT


        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimPackageTypes
        select
            PackageTypeID,
            PackageTypeName
        from StagingPackageTypes


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimPackageTypes',
        @action = 'INSERT',
        @DimensionName = 'DimPackageTypes',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT
    END
    ---
    ELSE
    BEGIN

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimPackageTypes
        select
            PackageTypeID,
            PackageTypeName
        from StagingPackageTypes


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimPackageTypes',
        @action = 'INSERT',
        @DimensionName = 'DimPackageTypes',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT
    END

END
GO


CREATE OR ALTER PROCEDURE SCD1_DimTransactionTypes
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN

    DECLARE @CURRENT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimTransactionTypes
    )

    IF @dim_row_count <> 0
    BEGIN
        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        DELETE FROM DimTransactionTypes
        WHERE TransactionTypeID in (
        select
            TransactionTypeID
        from StagingTransactionTypes        
        );


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimTransactionTypes',
        @action = 'DELETE',
        @DimensionName = 'DimTransactionTypes',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimTransactionTypes
        select
            TransactionTypeID,
            TransactionTypeName
        from StagingTransactionTypes


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimTransactionTypes',
        @action = 'INSERT',
        @DimensionName = 'DimTransactionTypes',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT
    END
    ---
    ELSE
    BEGIN

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimTransactionTypes
        select
            TransactionTypeID,
            TransactionTypeName
        from StagingTransactionTypes


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimTransactionTypes',
        @action = 'INSERT',
        @DimensionName = 'DimTransactionTypes',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT
    END

END
GO


CREATE OR ALTER PROCEDURE SCD1_DimColors
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN

    DECLARE @CURRENT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimColors
    )

    IF @dim_row_count <> 0
    BEGIN

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        DELETE FROM DimColors
        WHERE ColorID in (
        select
            ColorID
        from StagingColors        
        );


        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimColors',
        @action = 'DELETE',
        @DimensionName = 'DimColors',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimColors
        select
            ColorID,
            ColorName
        from StagingColors

        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimColors',
        @action = 'INSERT',
        @DimensionName = 'DimColors',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT
    END
    ---
    ELSE
    BEGIN

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimColors
        select
            ColorID,
            ColorName
        from StagingColors

        exec [AddDimensionLog] 
        @procedure_name = 'SCD1_DimColors',
        @action = 'INSERT',
        @DimensionName = 'DimColors',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT
    END

END
GO





CREATE OR ALTER PROCEDURE SCD3_DimStockItems
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN

    DECLARE @CURRENT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimStockItems
    )

    select
        a.StockItemID,
        StockItemName,
        SupplierID,
        Brand,
        Size,
        IsChillerStock,
        Barcode,
        a.ColorID,
        ColorName,
        d.PackageTypeID as UnitPackageID,
        d.PackageTypeName as UnitPackageName,
        e.PackageTypeID as OuterPackageID,
        e.PackageTypeName as OuterPackageName,
        TaxRate,
        UnitPrice,
        RecommendedRetailPrice,
        TypicalWeightPerUnit,

        LastCostPrice,
        QuantityOnHand,
        LastStocktakeQuantity,
        TargetStockLevel,
        ReorderLevel,
        --? scd fields
        BinLocation

    INTO #temp_origin
    from StagingStockItems a
        left outer join StagingStockItemHoldings b on (a.StockItemID = b.StockItemID)
        left outer join StagingColors c on (a.ColorID = c.ColorID)
        left outer join StagingPackageTypes d on (a.UnitPackageID = d.PackageTypeID)
        left outer join StagingPackageTypes e on (a.OuterPackageID = e.PackageTypeID)



    IF @dim_row_count = 0
    BEGIN
        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimStockItems
        select

            StockItemID,
            StockItemName,
            SupplierID,
            Brand,
            Size,
            IsChillerStock,
            Barcode,
            ColorID,
            ColorName,
            UnitPackageID,
            UnitPackageName,
            OuterPackageID,
            OuterPackageName,
            TaxRate,
            UnitPrice,
            RecommendedRetailPrice,
            TypicalWeightPerUnit,

            LastCostPrice,
            QuantityOnHand,
            LastStocktakeQuantity,
            TargetStockLevel,
            ReorderLevel,

            --? scd fields
            BinLocation,
            BinLocation,
            CONVERT(DATE, GETDATE())

        from #temp_origin

        exec [AddDimensionLog] 
        @procedure_name = 'SCD3_DimStockItems',
        @action = 'INSERT',
        @DimensionName = 'DimStockItems',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT

    END
    ---
    ELSE
    BEGIN

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimStockItems
        select

            a.StockItemID,
            StockItemName,
            SupplierID,
            Brand,
            Size,
            IsChillerStock,
            Barcode,
            ColorID,
            ColorName,
            UnitPackageID,
            UnitPackageName,
            OuterPackageID,
            OuterPackageName,
            TaxRate,
            UnitPrice,
            RecommendedRetailPrice,
            TypicalWeightPerUnit,

            LastCostPrice,
            QuantityOnHand,
            LastStocktakeQuantity,
            TargetStockLevel,
            ReorderLevel,

            --? scd fields
            BinLocation,
            BinLocation,
            CONVERT(DATE, GETDATE())

        from #temp_origin a
        where StockItemID not in (
            select StockItemID
        from DimStockItems
        )



        exec [AddDimensionLog] 
        @procedure_name = 'SCD3_DimStockItems',
        @action = 'INSERT',
        @DimensionName = 'DimStockItems',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT

        -- track the modified records

        select
            a.StockItemID,
            StockItemName,
            SupplierID,
            Brand,
            Size,
            IsChillerStock,
            Barcode,
            ColorID,
            ColorName,
            UnitPackageID,
            UnitPackageName,
            OuterPackageID,
            OuterPackageName,
            TaxRate,
            UnitPrice,
            RecommendedRetailPrice,
            TypicalWeightPerUnit,

            LastCostPrice,
            QuantityOnHand,
            LastStocktakeQuantity,
            TargetStockLevel,
            ReorderLevel,

            --? scd fields
            BinLocation
        INTO #temp_modified
        from #temp_origin a
        where StockItemID in (
            select StockItemID
        from DimStockItems
        where a.BinLocation <> BinLocation
        )

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        UPDATE DimStockItems
        SET EffectiveDate = CONVERT(DATE, GETDATE()),
            OriginalBinLocation = CurrentBinLocation,
            CurrentBinLocation = b.BinLocation
        FROM DimStockItems a inner join #temp_modified b
            on a.StockItemID = b.StockItemID
        where a.StockItemID in (
            select StockItemID
        from #temp_modified);

        exec [AddDimensionLog] 
        @procedure_name = 'SCD3_DimStockItems',
        @action = 'UPDATE',
        @DimensionName = 'DimStockItems',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT

        DROP TABLE #temp_modified;
        DROP TABLE #temp_origin;
    END

END


GO



CREATE OR ALTER PROCEDURE ALL_DIMENSIONS_SCD_ETL
AS
BEGIN

    EXECUTE SCD1_DimStockGroup;
    EXECUTE SCD1_DimPackageTypes;
    EXECUTE SCD1_DimTransactionTypes;
    EXECUTE SCD1_DimColors;
    EXECUTE SCD3_DimStockItems;

    INSERT INTO DimStockGroup (StockGroupID,StockGroupName)
    VALUES(
        -1,'UNKNOWN'
    )

    INSERT INTO DimPackageTypes (PackageTypeID,PackageTypeName)
    VALUES(
        -1,'UNKNOWN'
    )

    INSERT INTO DimTransactionTypes (TransactionTypeID,TransactionTypeName)
    VALUES(
        -1,'UNKNOWN'
    )

    INSERT INTO DimColors (ColorID,ColorName)
    VALUES(
        -1,'UNKNOWN'
    )

    INSERT INTO DimStockItems (
        StockItemID,
        StockItemName,
        SupplierID,
        Brand,
        Size,
        IsChillerStock,
        Barcode,
        ColorID,
        ColorName,
        UnitPackageTypeID,
        UnitPackageTypeName,
        OuterPackageTypeID,
        OuterPackageTypeName,
        TaxRate,
        UnitPrice,
        RecommendedRetailPrice,
        TypicalWeightPerUnit,
        LastCostPrice,
        QuantityOnHand,
        LastStocktakeQuantity,
        TargetStockLevel,
        ReorderLevel,
        OriginalBinLocation,
        CurrentBinLocation,
        EffectiveDate
    )
    VALUES(
        -1,
        'UNKNOWN',
        -1,
        NULL,
        NULL,
        0,
        NULL,
        -1,
        'UNKNOWN',
        -1,
        'UNKNOWN',
        -1,
        'UNKNOWN',
        0,      
        0,  
        0,
        0,
        0,
        -1,
        -1,
        -1,
        -1,
        'UNKNOWN',
        'UNKNOWN',
        '2012-12-31'
    )

END
--------------------------------------------------------------------------------------------------------------
GO
