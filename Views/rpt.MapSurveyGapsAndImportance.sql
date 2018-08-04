SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [rpt].[MapSurveyGapsAndImportance]
as
SELECT drs.SurveyYear
	   , SchoolName School
	   , '' SchoolColor
	   , drs.SportName Sport
	   , dtii.TicketInfoDescription TicketType
	   , dti.TicketInfoDescription TicketSpan
	   , QuestionType
	   , 'Quadrant' ReportType
	   , QuestionHeader
	   , ISNULL(ReportQuestionSubheader,QuestionSubHeader) QuestionSubHeader
	   , 0 OleMissOnly
	   ,SUM(f1.RespondentCount)*1.0 RespondentCount
	   ,SUM(f1.Points)*1.0 SatisfactionPoints
	   ,SUM(f1.RespondentCount)*1.0 SatisfactionPointsCnt
	   --,sum(f1.QuestionPoints)*1.0/sum(f1.RespondentCount)
	   ,SUM(f2.Points)*1.0 ImportancePoints
	   ,SUM(f2.RespondentCount)*1.0 ImportancePointsCnt
	   ,ISNULL((SUM(f1.Points)*1.0/NULLIF(SUM(f1.RespondentCount),0)-SUM(f2.Points)*1.0/NULLIF(SUM(f2.RespondentCount),0)),0) * 100 AS Gap
	   ,drs.DimSurveyId
	   ,f1.RespondentId
FROM [FactSECSurveyAggies] f1
JOIN DimQuestion dq ON f1.DimQuestionId = dq.DimQuestionId
JOIN DimSchool ds ON f1.DimSchoolId = ds.DimSchoolId
JOIN [dbo].[ReportQuestionMap] qm ON f1.DimQuestionId = qm.DimQuestionId  
JOIN [FactSECSurveyAggies] f2 ON f2.DimQuestionId = qm.[PartnerQuestionId] AND f1.DimSchoolId = f2.DimSchoolId AND f1.DimSurveyId = f2.DimSurveyId AND f1.[DimTicketSpanId] = f2.DimTicketSpanId AND f1.[DimTicketTypeId] = f2.DimTicketTypeId AND f1.Respondentid = f2.RespondentId
JOIN [dbo].[DimSurvey] drs ON f1.DimSurveyId = drs.DimSurveyId
--join [dbo].[DimSurvey] drs2 on f2.DimSurveyId = drs2.DimSurveyId and drs2.surveyyear = drs.surveyyear
JOIN [dbo].[DimTicketInfo] dti ON f1.DimTicketSpanId = dti.DimTicketInfoId
JOIN [dbo].[DimTicketInfo] dtii ON f1.DimTicketTypeId = dtii.DimTicketInfoId
WHERE NOT ds.schoolname = 'UNKNOWN'
GROUP BY 
drs.SurveyYear
	   , SchoolName
	   , drs.SportName
	   , dtii.TicketInfoDescription
	   , dti.TicketInfoDescription
	   , QuestionType	   
	   , QuestionHeader
	   , ISNULL(ReportQuestionSubheader,QuestionSubHeader)
	   ,drs.DimSurveyId
,f1.RespondentId
GO
