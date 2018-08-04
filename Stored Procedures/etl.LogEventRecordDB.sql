SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROCEDURE [etl].[LogEventRecordDB] 
(
	@BatchId BIGINT = 0, 
	@EventLevel NVARCHAR(255) = 'Info', 	
	@EventSource NVARCHAR(255) = NULL, 
	@EventCategory NVARCHAR(255) = NULL,
	@LogEvent NVARCHAR(255), 
	@LogMessage NVARCHAR(2000) = NULL,
	@ExecutionId UNIQUEIDENTIFIER = NULL
)
AS

BEGIN

SET NOCOUNT ON;

BEGIN TRY

	INSERT INTO etl.EventLog (BatchId, EventLevel, EventSource, EventCategory, LogEvent, LogMessage, EventDate, ExecutionId, UserName, SourceSystem)
	VALUES (@BatchId, @EventLevel, @EventSource, @EventCategory, @LogEvent, @LogMessage, GETDATE(), ISNULL(@ExecutionId, NEWID()), SUSER_NAME(), HOST_NAME())

END TRY
BEGIN CATCH
	
END CATCH

END
GO
