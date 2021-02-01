use [WWI-DW];

GO


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
        from [WWI-Staging].dbo.StagingStockGroups        
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
        from [WWI-Staging].dbo.StagingStockGroups


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
        from [WWI-Staging].dbo.StagingStockGroups


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
        from [WWI-Staging].dbo.StagingPackageTypes        
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
        from [WWI-Staging].dbo.StagingPackageTypes


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
        from [WWI-Staging].dbo.StagingPackageTypes


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
        from [WWI-Staging].dbo.StagingTransactionTypes        
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
        from [WWI-Staging].dbo.StagingTransactionTypes


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
        from [WWI-Staging].dbo.StagingTransactionTypes


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
        from [WWI-Staging].dbo.StagingColors        
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
        from [WWI-Staging].dbo.StagingColors

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
        from [WWI-Staging].dbo.StagingColors

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
    IF OBJECT_ID('dbo.temp_modified', 'U') IS NOT NULL
        DROP TABLE temp_modified;

    IF OBJECT_ID('dbo.temp_origin', 'U') IS NOT NULL
        DROP TABLE temp_origin;
    
    DECLARE @CURRENT_DATETIME DATETIME2 = (select CONVERT(DATETIME2, GETDATE()));

    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimStockItems
    )

    select
        a.StockItemID,
        StockItemName,
        a.SupplierID,
        SupplierName,
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

        --? scd fields
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

    INTO temp_origin
    from [WWI-Staging].dbo.StagingStockItems a
        left outer join [WWI-Staging].dbo.StagingStockItemHoldings b on (a.StockItemID = b.StockItemID)
        left outer join [WWI-Staging].dbo.StagingColors c on (a.ColorID = c.ColorID)
        left outer join [WWI-Staging].dbo.StagingPackageTypes d on (a.UnitPackageID = d.PackageTypeID)
        left outer join [WWI-Staging].dbo.StagingPackageTypes e on (a.OuterPackageID = e.PackageTypeID)
        left outer join [WWI-Staging].dbo.StagingSupplier f on (a.SupplierID = f.SupplierID)


    IF @dim_row_count = 0
    BEGIN
        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        INSERT INTO DimStockItems
        select

            StockItemID,
            StockItemName,

            SupplierID,
            SupplierName,

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

            --? scd 3 fields
            UnitPrice,
            UnitPrice,
            CONVERT(DATE, GETDATE()),

            RecommendedRetailPrice,
            TypicalWeightPerUnit,

            LastCostPrice,
            QuantityOnHand,
            LastStocktakeQuantity,
            TargetStockLevel,
            ReorderLevel,

            --? scd 3 fields
            BinLocation,
            BinLocation,
            CONVERT(DATE, GETDATE())

        from temp_origin

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
            SupplierName,
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

            --? scd 3 fields
            UnitPrice,
            UnitPrice,
            CONVERT(DATE, GETDATE()),

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

        from temp_origin a
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

        --^ track the modified records
        
        --? BinLocation

        select
            a.StockItemID,
            StockItemName,
            SupplierID,
            SupplierName,
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
        INTO temp_modified
        from temp_origin a
        where StockItemID in (
            select StockItemID
        from DimStockItems
        where a.BinLocation <> BinLocation
        )

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        UPDATE DimStockItems
        SET BinLocationEffectiveDate = CONVERT(DATE, GETDATE()),
            OriginalBinLocation = CurrentBinLocation,
            CurrentBinLocation = b.BinLocation
        FROM DimStockItems a inner join temp_modified b
            on a.StockItemID = b.StockItemID
        where a.StockItemID in (
            select StockItemID
        from temp_modified);

        exec [AddDimensionLog] 
        @procedure_name = 'SCD3_DimStockItems',
        @action = 'UPDATE',
        @DimensionName = 'DimStockItems',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT


        --? Unit Price
        DROP TABLE temp_modified;

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
        INTO temp_modified
        from temp_origin a
        where StockItemID in (
            select StockItemID
            from DimStockItems
            where a.UnitPrice <> UnitPrice
        )

        SET @CURRENT_DATETIME = (select CONVERT(DATETIME2, GETDATE()));

        UPDATE DimStockItems
        SET UnitPriceEffectiveDate = CONVERT(DATE, GETDATE()),
            OriginalUnitPrice = OriginalUnitPrice,
            CurrentUnitPrice = b.UnitPrice
        FROM DimStockItems a inner join temp_modified b
            on a.StockItemID = b.StockItemID
        where a.StockItemID in (
            select StockItemID
        from temp_modified);

        exec [AddDimensionLog] 
        @procedure_name = 'SCD3_DimStockItems',
        @action = 'UPDATE',
        @DimensionName = 'DimStockItems',
        @Datetime = @CURRENT_DATETIME,
        @AffectedRowsNumber = @@ROWCOUNT

    END


END


GO



CREATE OR ALTER PROCEDURE WAREHOUSE_DIMENSIONS_SCD_ETL
AS
BEGIN

    EXECUTE SCD1_DimStockGroup;
    EXECUTE SCD1_DimPackageTypes;
    EXECUTE SCD1_DimTransactionTypes;
    EXECUTE SCD1_DimColors;
    EXECUTE SCD3_DimStockItems;

    --? inserting -1
    DECLARE @does_it_have_unknown_record INT = (
        SELECT COUNT(*) FROM DimStockGroup
        WHERE StockGroupID = -1
    )
    IF @does_it_have_unknown_record = 0
    BEGIN
        INSERT INTO DimStockGroup (StockGroupID,StockGroupName)
        VALUES(-1,'UNKNOWN')
    END

    --? inserting -1
    SET @does_it_have_unknown_record = (
        SELECT COUNT(*) FROM DimPackageTypes
        WHERE PackageTypeID = -1
    )
    IF @does_it_have_unknown_record = 0
    BEGIN
        INSERT INTO DimPackageTypes (PackageTypeID,PackageTypeName)
        VALUES(-1,'UNKNOWN')
    END


    --? inserting -1
    SET @does_it_have_unknown_record = (
        SELECT COUNT(*) FROM DimTransactionTypes
        WHERE TransactionTypeID = -1
    )
    IF @does_it_have_unknown_record = 0
    BEGIN
        INSERT INTO DimTransactionTypes (TransactionTypeID,TransactionTypeName)
        VALUES(-1,'UNKNOWN')
    END



    --? inserting -1
    SET @does_it_have_unknown_record = (
        SELECT COUNT(*) FROM DimColors
        WHERE ColorID = -1
    )
    IF @does_it_have_unknown_record = 0
    BEGIN
        INSERT INTO DimColors (ColorID,ColorName)
        VALUES(-1,'UNKNOWN')
    END


    --? inserting -1
    SET @does_it_have_unknown_record = (
        SELECT COUNT(*) FROM DimStockItems
        WHERE StockItemID = -1
    )
    IF @does_it_have_unknown_record = 0
    BEGIN
        INSERT INTO DimStockItems (
            StockItemID,
            StockItemName,
            SupplierID,
            SupplierName,
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

            OriginalUnitPrice,
            CurrentUnitPrice,
            UnitPriceEffectiveDate,

            RecommendedRetailPrice,
            TypicalWeightPerUnit,
            LastCostPrice,
            QuantityOnHand,
            LastStocktakeQuantity,
            TargetStockLevel,
            ReorderLevel,

            OriginalBinLocation,
            CurrentBinLocation,
            BinLocationEffectiveDate
        )
        VALUES(
            -1,
            'UNKNOWN',
            -1,
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            'UNKNOWN',
            -1,
            'UNKNOWN',
            -1,
            'UNKNOWN',
            -1,
            'UNKNOWN',
            0,

            0,
            0,
            '2012-12-31',

            0,
            0,
            0,
            0,
            0,
            0,
            0,

            'UNKNOWN',
            'UNKNOWN',
            '2012-12-31'
        )
    END

END
--------------------------------------------------------------------------------------------------------------
GO
