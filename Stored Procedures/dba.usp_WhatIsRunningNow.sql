SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
-- =============================================
-- Author:       
-- Create date: 
-- Description:  List queries running at time the SP
--               is executed
-- =============================================
CREATE PROCEDURE [dba].[usp_WhatIsRunningNow]
    
AS
BEGIN
 

SELECT sqltext.TEXT,
req.session_id,
req.status,
req.command,
req.cpu_time,
req.total_elapsed_time
FROM sys.dm_exec_requests req
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sqltext
END
GO
