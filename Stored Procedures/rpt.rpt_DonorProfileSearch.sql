SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROC [rpt].[rpt_DonorProfileSearch] (@SearchCriteria VARCHAR(200))
AS
BEGIN

	-- Init for response
	DECLARE @totalCount    INT,
		@xmlDataNode       XML,
		@rootNodeName      NVARCHAR(100),
		@responseInfoNode  NVARCHAR(MAX),
		@finalXml          XML
		
	-- Init for data
	DECLARE @returnData TABLE(
		SourceSystem           NVARCHAR(50),
		FirstName              NVARCHAR(100),
		MiddleName             NVARCHAR(100),
		LastName               NVARCHAR(100),
		AddressPrimaryStreet   NVARCHAR(500),
		AddressPrimaryCity     NVARCHAR(200),
		AddressPrimaryState    NVARCHAR(100),
		AddressPrimaryZip      NVARCHAR(25),
		[DimCustomerId]  VARCHAR(50),
		SSID NVARCHAR(100)
	)
	--DECLARE @searchcriteria VARCHAR(100)
	--SET @searchcriteria = 'Brian'
	--single name search
	--first and last name search
	--SSID search
	DECLARE @searchpart1 VARCHAR(100)
	DECLARE @searchpart2 VARCHAR(100)
	DECLARE @ResultsCount INT
	DECLARE @IsIdSearch BIT    

	SELECT @IsIdSearch = CASE WHEN @SearchCriteria LIKE '%[0-9]%' THEN 1 ELSE 0 END

	SET @SearchCriteria = replace(replace(replace(REPLACE(REPLACE(REPLACE(@SearchCriteria,',',''),'.',''),'!',''),' & ',''),' &',''),'& ','')

	IF (CHARINDEX(' ',@SearchCriteria,0) > 0)
	BEGIN
		SELECT @searchpart1 = SUBSTRING(@SearchCriteria,1,CHARINDEX(' ',@SearchCriteria,0)-1),@searchpart2 = SUBSTRING(@SearchCriteria,CHARINDEX(' ',@SearchCriteria,0)+1,1000) 
	END

	
	IF (LEN(@SearchCriteria) > 0 AND @searchpart2 IS NULL AND @IsIdSearch = 0)
	BEGIN
		
	-- Main query - insert results into the @returnData variable
	INSERT INTO @returnData (SourceSystem, FirstName, MiddleName, LastName, AddressPrimaryStreet, AddressPrimaryCity, AddressPrimaryState, AddressPrimaryZip,DimCustomerId,SSID)
	SELECT TOP 100 'Advantage' AS SourceSystem, c.FirstName AS FirstName, '' AS MiddleName, c.LastName AS LastName, ca.Address1 AS AddressPrimaryStreet, ca.City AS AddressPrimaryCity, ca.State AS AddressPrimaryState, ca.zip AS AddressPrimaryZip, c.ContactID AS DimCustomerID, c.ADNumber AS SSID
	FROM dbo.ADVContact c
	LEFT JOIN dbo.ADVContactAddresses ca 
		ON (c.ContactID = ca.ContactID AND ca.PrimaryAddress = 1)
	LEFT JOIN ods.VTXcustomers vc
		ON CAST(c.ADNumber AS VARCHAR(200)) = CAST(vc.accountnumber AS VARCHAR(200))
	WHERE c.LastName LIKE @SearchCriteria + '%'
	ORDER BY c.FirstName, c.LastName

	SELECT @ResultsCount = COUNT(*) FROM @returnData

	IF (@ResultsCount<100 AND @IsIdSearch = 0) 
	BEGIN
		INSERT INTO @returnData (SourceSystem, FirstName, MiddleName, LastName, AddressPrimaryStreet, AddressPrimaryCity, AddressPrimaryState, AddressPrimaryZip,DimCustomerId,SSID)
		SELECT TOP 100 'Advantage' AS SourceSystem, c.FirstName AS FirstName, '' AS MiddleName, c.LastName AS LastName, ca.Address1 AS AddressPrimaryStreet, ca.City AS AddressPrimaryCity, ca.State AS AddressPrimaryState, ca.zip AS AddressPrimaryZip, c.ContactID AS DimCustomerID, c.ADNumber AS SSID
		FROM dbo.ADVContact c
		LEFT JOIN dbo.ADVContactAddresses ca 
			ON (c.ContactID = ca.ContactID AND ca.PrimaryAddress = 1)
		LEFT JOIN ods.VTXcustomers vc
			ON CAST(c.ADNumber AS VARCHAR(200)) = CAST(vc.accountnumber AS VARCHAR(200))
		WHERE replace(replace(replace(c.FirstName,' & ',''),' &',''),'& ','') LIKE @SearchCriteria + '%'
		ORDER BY c.FirstName, c.LastName

	END

	END

	IF (LEN(@SearchCriteria) > 0 AND @searchpart2 IS NOT NULL AND @IsIdSearch = 0)
	begin
	
	
	-- Main query - insert results into the @returnData variable
	INSERT INTO @returnData (SourceSystem, FirstName, MiddleName, LastName, AddressPrimaryStreet, AddressPrimaryCity, AddressPrimaryState, AddressPrimaryZip,DimCustomerId,SSID)
	SELECT TOP 100 'Advantage' as SourceSystem, c.FirstName as FirstName, '' as MiddleName, c.LastName as LastName, ca.Address1 as AddressPrimaryStreet, ca.City as AddressPrimaryCity, ca.State as AddressPrimaryState, ca.zip as AddressPrimaryZip, c.ContactID as DimCustomerID, c.ADNumber as SSID
		FROM dbo.ADVContact c
		LEFT JOIN dbo.ADVContactAddresses ca 
			ON (c.ContactID = ca.ContactID and ca.PrimaryAddress = 1)
		LEFT JOIN ods.VTXcustomers vc
			ON CAST(c.ADNumber AS VARCHAR(200)) = CAST(vc.accountnumber AS VARCHAR(200))
		WHERE replace(replace(replace(c.FirstName,' & ',''),' &',''),'& ','') LIKE @SearchPart1 + '%' AND c.lastname LIKE @searchpart2 + '%'
		ORDER BY c.FirstName, c.LastName
	
	INSERT INTO @returnData (SourceSystem, FirstName, MiddleName, LastName, AddressPrimaryStreet, AddressPrimaryCity, AddressPrimaryState, AddressPrimaryZip,DimCustomerId,SSID)
	SELECT TOP 100 'Advantage' AS SourceSystem, c.FirstName AS FirstName, '' AS MiddleName, c.LastName AS LastName, ca.Address1 AS AddressPrimaryStreet, ca.City AS AddressPrimaryCity, ca.State AS AddressPrimaryState, ca.zip AS AddressPrimaryZip, c.ContactID AS DimCustomerID, c.ADNumber AS SSID
		FROM dbo.ADVContact c
		LEFT JOIN dbo.ADVContactAddresses ca 
			ON (c.ContactID = ca.ContactID AND ca.PrimaryAddress = 1)
		LEFT JOIN ods.VTXcustomers vc
			ON CAST(c.ADNumber AS VARCHAR(200)) = CAST(vc.accountnumber AS VARCHAR(200))
		WHERE c.lastName LIKE @SearchPart1 + '%' AND replace(replace(replace(c.FirstName,' & ',''),' &',''),'& ','') LIKE @searchpart2 + '%'
		ORDER BY c.FirstName, c.LastName


	END


	IF (@IsIdSearch = 1)
	BEGIN
	INSERT INTO @returnData (SourceSystem, FirstName, MiddleName, LastName, AddressPrimaryStreet, AddressPrimaryCity, AddressPrimaryState, AddressPrimaryZip,DimCustomerId,SSID)
	SELECT TOP 100 'Advantage' AS SourceSystem, c.FirstName AS FirstName, '' AS MiddleName, c.LastName AS LastName, ca.Address1 AS AddressPrimaryStreet, ca.City AS AddressPrimaryCity, ca.State AS AddressPrimaryState, ca.zip AS AddressPrimaryZip, c.ContactID AS DimCustomerID, c.ADNumber AS SSID
		FROM dbo.ADVContact c
		LEFT JOIN dbo.ADVContactAddresses ca 
			ON (c.ContactID = ca.ContactID AND ca.PrimaryAddress = 1)
		LEFT JOIN ods.VTXcustomers vc
			ON CAST(c.ADNumber AS VARCHAR(200)) = CAST(vc.accountnumber AS VARCHAR(200))
		WHERE c.ADNumber LIKE @SearchCriteria+'%'  
		ORDER BY c.ADNumber ,c.FirstName, c.LastName
	END
		

	-- Set total count
	SELECT @totalCount = COUNT(*) FROM @returnData

	-- Format data for output
	SET @xmlDataNode = (
		SELECT SourceSystem, FirstName AS FirstName, MiddleName, LastName, AddressPrimaryStreet, AddressPrimaryCity, AddressPrimaryState, AddressPrimaryZip,[DimCustomerId],SSID
			FROM @returnData
			--ORDER BY FirstName, LastName
			FOR XML PATH ('Customer'), ROOT ('Customers'))
	
	-- Track the root node name
	SET @rootNodeName = 'Customers'
	
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
		SET @xmlDataNode = '<' + @rootNodeName + ' />'  -- Handle if no data
	END		
	SET @finalXml = '<Root>' + @responseInfoNode + CAST(@xmlDataNode AS NVARCHAR(MAX)) + '</Root>'
	SELECT CAST(@finalXml AS XML)

END
GO
