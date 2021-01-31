USE [WWI-DW]
GO

IF OBJECT_ID('dbo.DimTime', 'U') IS NOT NULL
DROP TABLE dbo.DimTime
GO
CREATE TABLE [dbo].[DimTime](
  [TimeKey] [nvarchar](255) NULL,
  [FullDateAlternateKey] [nvarchar](255) NULL,
  [PersianFullDateAlternateKey] [nvarchar](255) NULL,
  [DayNumberOfWeek] [nvarchar](255) NULL,
  [PersianDayNumberOfWeek] [nvarchar](255) NULL,
  [EnglishDayNameOfWeek] [nvarchar](255) NULL,
  [PersianDayNameOfWeek] [nvarchar](255) NULL,
  [DayNumberOfMonth] [nvarchar](255) NULL,
  [PersianDayNumberOfMonth] [nvarchar](255) NULL,
  [DayNumberOfYear] [nvarchar](255) NULL,
  [PersianDayNumberOfYear] [nvarchar](255) NULL,
  [WeekNumberOfYear] [nvarchar](255) NULL,
  [PersianWeekNumberOfYear] [nvarchar](255) NULL,
  [EnglishMonthName] [nvarchar](255) NULL,
  [PersianMonthName] [nvarchar](255) NULL,
  [MonthNumberOfYear] [nvarchar](255) NULL,
  [PersianMonthNumberOfYear] [nvarchar](255) NULL,
  [CalendarQuarter] [nvarchar](255) NULL,
  [PersianCalendarQuarter] [nvarchar](255) NULL,
  [CalendarYear] [nvarchar](255) NULL,
  [PersianCalendarYear] [nvarchar](255) NULL,
  [CalendarSemester] [nvarchar](255) NULL,
  [PersianCalendarSemester] [nvarchar](255) NULL
)

GO

ALTER TABLE [WWI-DW].dbo.DimTime 
ALTER COLUMN TimeKey INT NOT NULL;

GO
ALTER TABLE [WWI-DW].dbo.DimTime
ADD CONSTRAINT PK_TimeKey PRIMARY KEY (TimeKey)