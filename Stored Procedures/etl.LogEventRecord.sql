SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [etl].[LogEventRecord] 
(
	@BatchId bigint = 0, 
	@EventLevel nvarchar(255) = 'Info', 	
	@EventSource nvarchar(255) = null, 
	@EventCategory nvarchar(255) = null,
	@LogEvent nvarchar(255), 
	@LogMessage nvarchar(2000) = null,
	@ExecutionId uniqueidentifier = NULL
)
AS

BEGIN

SET NOCOUNT ON;

BEGIN TRY

	INSERT INTO etl.EventLog (BatchId, EventLevel, EventSource, EventCategory, LogEvent, LogMessage, EventDate, ExecutionId, UserName, SourceSystem)
	values (@BatchId, @EventLevel, @EventSource, @EventCategory, @LogEvent, @LogMessage, GETDATE(), ISNULL(@ExecutionId, NEWID()), SUSER_NAME(), HOST_NAME())

END TRY
BEGIN CATCH
	
END CATCH

END
GO
