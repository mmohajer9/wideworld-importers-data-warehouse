USE msdb ;  
GO  
-- creates a schedule named NightlyETLForDW.   
-- Jobs that use this schedule execute every day when the time on the server is 01:00.   
EXEC sp_add_schedule  
    @schedule_name = N'NightlyETLForDW' ,  
    @freq_type = 4,  
    @freq_interval = 1,  
    @active_start_time = 010000 ;  
GO  
-- attaches the schedule to the job FillDataWarehouse  
EXEC sp_attach_schedule  
   @job_name = N'FillDataWarehouse',  
   @schedule_name = N'NightlyETLForDW' ;  
GO  