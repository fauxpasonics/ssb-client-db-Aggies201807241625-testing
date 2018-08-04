SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


CREATE PROC [mdm].[GetMasterDimCustomerDeltas]
(
	@ClientDB VARCHAR(50)
)
AS
BEGIN

	-- DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV'

	-- For response
	DECLARE @totalCount    INT,
		@xmlDataNode       XML,
		@rootNodeName      NVARCHAR(100),
		@responseInfoNode  NVARCHAR(MAX),
		@finalXml          XML				

	-- For base data
	CREATE TABLE #baseData (
		DimCustomerId  INT,
		SSID           NVARCHAR(100),
		SourceSystem   NVARCHAR(50),
		Element        NVARCHAR(50),
		ElementID      INT,
		Field          NVARCHAR(100),
		FieldDisplay   NVARCHAR(100),
		Source         NVARCHAR(500),
		CD             NVARCHAR(500),
		CD_Status      NVARCHAR(100),
		Master         NVARCHAR(500),
		AcceptedDate   DATETIME,
		DisplayOrder   INT
	)

	IF (SELECT @@VERSION) LIKE '%Azure%'
	BEGIN
	SET @ClientDB = ''
	END
	ELSE
	BEGIN
	SET @ClientDB = @ClientDB + '.'
	END

	DECLARE 
		@sql NVARCHAR(MAX) = '' 

	SET @sql = @sql
		+ ' INSERT INTO #baseData (DimCustomerId, SSID, SourceSystem, Element, ElementID, Field, FieldDisplay, Source, CD, CD_Status, Master, AcceptedDate, DisplayOrder)'
		+ ' SELECT DimCustomerId, SSID, SourceSystem, Element, ElementID, Field, FieldDisplay, Source, CD, CD_Status, Master, AcceptedDate, DisplayOrder' + CHAR(13)
		+ ' FROM ' + @ClientDB + 'dbo.Master_DimCustomer_Deltas' + CHAR(13)
		+ ' WHERE ProcessedDate IS NULL'
		+ ' ORDER BY SSID, SourceSystem, DisplayOrder' + CHAR(13)
	SET @sql = @sql + CHAR(13) + CHAR(13)

	--SELECT @sql

	EXEC sp_executesql @sql

	-- Set count of total records in response
	SELECT @totalCount = COUNT(*) FROM #baseData

	-- Create XML response data node
	SET @xmlDataNode = (
		SELECT DimCustomerId
			, SSID
			, SourceSystem
			, Element
			, ElementID
			, Field
			, FieldDisplay
			, Source as SourceValue
			, CD as CleanDataValue
			, CD_Status as CleanDataStatus
			, Master as MasterValue
		FROM  #baseData
	FOR XML PATH ('Record'), ROOT('Records'))
	
	SET @rootNodeName = 'Records'
	
	-- Create response info node

	SET @responseInfoNode = ('<ResponseInfo>'
		+ '<TotalCount>' + CAST(@totalCount AS NVARCHAR(20)) + '</TotalCount>'
		+ '<RemainingCount>0</RemainingCount>'  -- No paging = remaining count = 0
		+ '<RecordsInResponse>' + CAST(@totalCount AS NVARCHAR(20)) + '</RecordsInResponse>'  -- No paging = remaining count = total count
		+ '<PagedResponse>false</PagedResponse>'
		+ '<RowsPerPage />'
		+ '<PageNumber />'
		+ '<RootNodeName>' + @rootNodeName + '</RootNodeName>'
		+ '</ResponseInfo>')

	
	-- Wrap response info and data, then return
	
	IF @xmlDataNode IS NULL
	BEGIN
		SET @xmlDataNode = '<' + @rootNodeName + ' />' 
	END
		
	SET @finalXml = '<Root>' + @responseInfoNode + CAST(@xmlDataNode AS NVARCHAR(MAX)) + '</Root>'

	SELECT CAST(@finalXml AS XML)

END
GO
