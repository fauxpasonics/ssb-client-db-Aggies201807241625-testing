SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[transformCriteriaConditionList] 
( 
	@ConditionList NVARCHAR(MAX), 
	@ClientDB VARCHAR(50), 
	@OutputConditionList NVARCHAR(MAX) OUTPUT 
) 
AS  
BEGIN 
 
	SET NOCOUNT ON 
 
	DECLARE @sql NVARCHAR(MAX) = '', @Counter INT = 0, @GroupName VARCHAR(15) = '' 
 
	----DECLARE @ConditionList VARCHAR(MAX) =  'AND GROUP1STARTisnull(MaxSeasonTicketHolder, 0) != 0GROUP1END AND GROUP1STARTisnull(dimcust.SourceSystem,'''') = ''TM''GROUP1END OR GROUP2STARTDATEDIFF(DAY,CAST(trans_dt AS DATE),GETDATE()) <= 60GROUP2END' 
	----DECLARE @ClientDB VARCHAR(50) = 'MDM_CLIENT_DEV.' 
	----DECLARE @OutputConditionList NVARCHAR(MAX) 
 
	SET @sql =  
		+ ' SELECT DISTINCT DENSE_RANK() OVER (ORDER BY GroupID) AS ID, ''GROUP'' + CAST(GroupID AS VARCHAR(5)) AS GroupName, @ConditionList AS ConditionList' + CHAR(13) 
		+ ' INTO #tmp_grouping' + CHAR(13) 
		+ ' FROM ' + @ClientDB + 'mdm.BusinessRules' + CHAR(13) 
		+ ' WHERE GroupID IS NOT NULL' + CHAR(13) 
		+ '' + CHAR(13) 
		+ ' SET @counter = 1' + CHAR(13) 
		+ ' SET @GroupName = ''''' + CHAR(13) 
		+ ' ' + CHAR(13) 
		+ ' WHILE @counter <= (SELECT MAX(ID) FROM #tmp_grouping)' + CHAR(13) 
		+ ' BEGIN' + CHAR(13) 
		+ ' 	SELECT @GroupName = GroupName' + CHAR(13) 
		+ ' 	FROM #tmp_grouping' + CHAR(13) 
		+ ' 	WHERE id = @counter' + CHAR(13) 
		+ ' ' + CHAR(13) 
 
		+ ' 	UPDATE #tmp_grouping' + CHAR(13) 
		+ ' 	SET ConditionList = REPLACE(REPLACE(REPLACE(REPLACE(ConditionList, @GroupName + ''END AND '' + @GroupName + ''START'','' AND ''), @GroupName + ''END OR '' + @GroupName + ''START'','' OR ''), @GroupName+''START'', ''(''),@GroupName+''END'', '')'')' + CHAR(13) 
		+ ' ' + CHAR(13) 
		+ ' 	SET @counter = @counter + 1' + CHAR(13) 
		+ ' END' + CHAR(13) 
		+ '' + CHAR(13) 
		+ 'SELECT DISTINCT @OutputConditionList = STUFF(ConditionList, 1, 4, '''')' + CHAR(13) 
		+ 'FROM #tmp_grouping' + CHAR(13) + CHAR(13) 
 
		+ ' IF (SELECT COUNT(0) FROM #tmp_grouping) = 0' + CHAR(13) 
		+ ' 	SELECT @OutputConditionList = STUFF(@ConditionList, 1, CHARINDEX('' '', @ConditionList), '''')' + CHAR(13) + CHAR(13) 
 
		+ ' IF (LEN(LTRIM(RTRIM(REPLACE(REPLACE(@OutputConditionList,''AND'',''''),''OR'','''')))) = 0)' + CHAR(13) 
		+ ' BEGIN' + CHAR(13) 
		+ '		SET @OutputConditionList = ''''' + CHAR(13) 
		+ ' END' + CHAR(13) 
 
	----SELECT @sql 
	EXEC sp_executesql @sql, N'@ConditionList NVARCHAR(MAX), @Counter INT, @GroupName VARCHAR(15), @OutputConditionList NVARCHAR(MAX) OUTPUT', @ConditionList, @Counter, @GroupName, @OutputConditionList OUTPUT 
 
	----SELECT @OutputConditionList 
END
GO
