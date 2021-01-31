use [WWI-DW]
Go


CREATE OR ALTER PROCEDURE FILL_DATA_WAREHOUSE(@to_this_date date , @is_it_first_load BIT = 0) AS
BEGIN
    
    EXEC FILL_WAREHOUSE_MART @to_this_date , @is_it_first_load;
    IF @is_it_first_load = 0
        EXEC FILL_SALES_MART @to_this_date;
    ELSE
        EXEC FILL_SALES_MART_FirstLoad @to_this_date;

END
Go