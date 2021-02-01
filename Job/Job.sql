USE [msdb]
GO

/****** Object:  Job [FillDataWarehouse]    Script Date: 2/1/2021 1:09:13 PM ******/
EXEC msdb.dbo.sp_delete_job @job_id=N'15c998a1-6860-4d9d-afe6-c99e4a0ee995', @delete_unused_schedule=1
GO

/****** Object:  Job [FillDataWarehouse]    Script Date: 2/1/2021 1:09:13 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 2/1/2021 1:09:13 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'FillDataWarehouse', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Running The ETL Main Procedure For Sales and Warehouse Mart', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'DESKTOP-O2IHGHB\MMM', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Running The Main ETL Procedure]    Script Date: 2/1/2021 1:09:13 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Running The Main ETL Procedure', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @CURRENT_DATE DATE = CONVERT(DATE , GETDATE());

SET @CURRENT_DATE = DATEADD(dd, -1, @CURRENT_DATE);

EXECUTE FILL_DATA_WAREHOUSE @CURRENT_DATE , 0', 
		@database_name=N'WWI-DW', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

