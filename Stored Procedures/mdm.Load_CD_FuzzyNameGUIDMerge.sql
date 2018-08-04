SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [mdm].[Load_CD_FuzzyNameGUIDMerge]   
AS    
BEGIN   
 
	DECLARE @processedDate DATETIME = GETDATE() 
 
	UPDATE b 
	SET b.ETL_ProcessedDate = @processedDate 
	FROM src.CD_FuzzyNameGUIDMerge a WITH (NOLOCK) 
	INNER JOIN mdm.CD_FuzzyNameGUIDMerge b ON a.MergeId = b.MergeId 
	WHERE 1=1 
	AND b.ETL_ProcessedDate IS NULL 
 
	SELECT a.MergeId, a.FuzzyNameGUID_Winner, a.FuzzyNameGUID_Loser, a.MergeDate   
	INTO #merges   
	FROM src.CD_FuzzyNameGUIDMerge a WITH (NOLOCK)   
	LEFT JOIN mdm.CD_FuzzyNameGUIDMerge b WITH (NOLOCK) ON a.MergeId = b.MergeId   
	WHERE 1=1   
	AND b.ID IS NULL   
   
	IF (SELECT COUNT(0) FROM #merges) >= 10000   
		EXEC dbo.sp_EnableDisableIndexes @Enable = 0, -- int   
			@TableName = 'mdm.CD_FuzzyNameGUIDMerge', -- varchar(500)   
			@ViewCurrentIndexState = 0 -- bit   
	   
	INSERT INTO mdm.CD_FuzzyNameGUIDMerge (    
		MergeId ,   
		FuzzyNameGUID_Winner ,   
		FuzzyNameGUID_Loser ,   
		MergeDate   
	)   
	SELECT a.MergeId, a.FuzzyNameGUID_Winner, a.FuzzyNameGUID_Loser, a.MergeDate   
	FROM #merges a   
   
	IF (SELECT COUNT(0) FROM #merges) >= 10000   
		EXEC dbo.sp_EnableDisableIndexes @Enable = 1, -- int   
			@TableName = 'mdm.CD_FuzzyNameGUIDMerge', -- varchar(500)   
			@ViewCurrentIndexState = 0 -- bit   
END
GO
