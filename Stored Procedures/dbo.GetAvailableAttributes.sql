SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GetAvailableAttributes] 
(@clientdb VARCHAR(50), @attributegroupid INT = 0)

AS
BEGIN
---DECLARE @clientdb VARCHAR(50)= 'MDM_CLIENT_DEV';
---DECLARE @attributegroupid int = 0;



IF (SELECT @@VERSION) LIKE '%Azure%'
BEGIN
SET @ClientDB = ''
END

IF (SELECT @@VERSION) NOT LIKE '%Azure%'
BEGIN
SET @ClientDB = @ClientDB + '.'
END


-- For response
	DECLARE @totalCount    INT,
		@xmlDataNode       XML,
		@rootNodeName      NVARCHAR(100),
		@responseInfoNode  NVARCHAR(MAX),
		@finalXml          XML				


		-- For base data
	CREATE TABLE #baseData (
		attribute VARCHAR(50),
		attributegroupid INT,
		attributegroup VARCHAR(50)
	)

DECLARE @SQL2 NVARCHAR(MAX) = '';

SET @sql2 = @sql2
+ ' SELECT  attribute, a.attributegroupid, attributegroup '+ CHAR(13)
+ ' FROM ' + @clientdb + 'mdm.attributes a' + CHAR(13)
+ ' inner join ' + @clientdb + 'mdm.attributegroup b' + CHAR(13)
+ ' on a.attributegroupid = b.attributegroupid ' + CHAR(13)
IF @attributegroupid > 0
BEGIN
SET @sql2 = @sql2
+ ' where a.attributegroupid = ' + @AttributeGroupID + CHAR(13)
END
SET @sql2 = @sql2
+ 'order by attribute' + CHAR(13)



INSERT INTO #baseData (attribute, attributegroupid, attributegroup)
	EXEC sp_executesql @sql2

	
	-- Set count of total records in response
	SELECT @totalCount = COUNT(*) FROM #baseData

	-- Create XML response data node
	SET @xmlDataNode = (
		SELECT Attribute, AttributeGroupId, AttributeGroup
		FROM  #baseData
		--WHERE 1 = 2
		ORDER BY attribute
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
