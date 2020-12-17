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

    IF @dim_row_count <> 0
    BEGIN

        DELETE FROM DimStockGroup
        WHERE StockGroupID in (
        select
            StockGroupID
        from StagingStockGroups        
        );

        INSERT INTO DimStockGroup
        select
            StockGroupID,
            StockGroupName
        from StagingStockGroups
    END
    ---
    ELSE
    BEGIN
        INSERT INTO DimStockGroup
        select
            StockGroupID,
            StockGroupName
        from StagingStockGroups
    END

END
GO

CREATE OR ALTER PROCEDURE SCD1_DimPackageTypes
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN
    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimPackageTypes
    )

    IF @dim_row_count <> 0
    BEGIN

        DELETE FROM DimPackageTypes
        WHERE PackageTypeID in (
        select
            PackageTypeID
        from StagingPackageTypes        
        );

        INSERT INTO DimPackageTypes
        select
            PackageTypeID,
            PackageTypeName
        from StagingPackageTypes
    END
    ---
    ELSE
    BEGIN
        INSERT INTO DimPackageTypes
        select
            PackageTypeID,
            PackageTypeName
        from StagingPackageTypes
    END

END
GO


CREATE OR ALTER PROCEDURE SCD1_DimTransactionTypes
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN
    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimTransactionTypes
    )

    IF @dim_row_count <> 0
    BEGIN

        DELETE FROM DimTransactionTypes
        WHERE TransactionTypeID in (
        select
            TransactionTypeID
        from StagingTransactionTypes        
        );

        INSERT INTO DimTransactionTypes
        select
            TransactionTypeID,
            TransactionTypeName
        from StagingTransactionTypes
    END
    ---
    ELSE
    BEGIN
        INSERT INTO DimTransactionTypes
        select
            TransactionTypeID,
            TransactionTypeName
        from StagingTransactionTypes
    END

END
GO


CREATE OR ALTER PROCEDURE SCD1_DimColors
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN
    DECLARE @dim_row_count INT;
    SET @dim_row_count = (
        SELECT COUNT(*)
    FROM DimColors
    )

    IF @dim_row_count <> 0
    BEGIN

        DELETE FROM DimColors
        WHERE ColorID in (
        select
            ColorID
        from StagingColors        
        );

        INSERT INTO DimColors
        select
            ColorID,
            ColorName
        from StagingColors
    END
    ---
    ELSE
    BEGIN
        INSERT INTO DimColors
        select
            ColorID,
            ColorName
        from StagingColors
    END

END
GO





CREATE OR ALTER PROCEDURE SCD3_DimStockItems
-- @param1 int = 0,
-- @param2 int = 0
AS
BEGIN
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

    END
    ---
    ELSE
    BEGIN
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

        UPDATE DimStockItems
        SET EffectiveDate = CONVERT(DATE, GETDATE()),
            OriginalBinLocation = CurrentBinLocation,
            CurrentBinLocation = b.BinLocation
        FROM DimStockItems a inner join #temp_modified b
            on a.StockItemID = b.StockItemID
        where a.StockItemID in (
            select StockItemID
        from #temp_modified);



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

END
--------------------------------------------------------------------------------------------------------------
GO

