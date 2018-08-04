SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO






CREATE PROCEDURE [etl].[Load_ods_VTXtixeventzoneseats_SoftDelete]
AS 

BEGIN
/**************************************Comments***************************************
**************************************************************************************
Mod #:		1
Name:		svcETL
Date:		01/19/2016
Comments:	Initial creation
*************************************************************************************/

DECLARE @tixeventid		INT = 0;

SET @tixeventid = (SELECT TOP 1 tixeventid FROM src.VTXtixeventzoneseats);

SELECT tixeventid, tixeventzoneid, tixseatgroupid, tixseatid
INTO #SrcData
FROM src.VTXtixeventzoneseats
;

CREATE NONCLUSTERED INDEX IDX_Load_Key ON #SrcData (tixeventid, tixeventzoneid, tixseatgroupid, tixseatid);


UPDATE ODS
SET ETL_IsDeleted = 1,
	ETL_DeletedDate = GETDATE()
--SELECT COUNT(9)
FROM ods.VTXtixeventzoneseats ODS
LEFT JOIN #SrcData SRC
	ON ODS.tixeventid = SRC.tixeventid 
	AND ODS.tixeventzoneid = SRC.tixeventzoneid 
	AND ODS.tixseatid = SRC.tixseatid 
	AND ODS.tixseatgroupid = SRC.tixseatgroupid
WHERE ODS.tixeventid = @tixeventid
AND ODS.ETL_IsDeleted = 0
AND SRC.tixeventid IS NULL
;


UPDATE ODS
SET ETL_IsDeleted = 1,
	ETL_DeletedDate = GETDATE()
FROM ods.VTXtixeventzoneseats ODS
JOIN ods.VTXtixeventzoneseats_CNT CNT
	ON ODS.tixeventid = CNT.tixeventid 
	AND CNT.SRC_rowcnt = 0
	AND ODS.ETL_IsDeleted = 0
;


END
GO
