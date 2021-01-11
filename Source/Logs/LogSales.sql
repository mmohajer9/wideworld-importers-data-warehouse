use [WWI-DW];
GO

IF OBJECT_ID('dbo.LogSales', 'U') IS NOT NULL
drop table LogSales
create table LogSales
(
	Id bigint IDENTITY(1,1) primary key,
	ActionName nvarchar(30),
	TableName nvarchar(100),
	date date,
	RecordId int,
	RecordSurrogateKey int null
)

Go
