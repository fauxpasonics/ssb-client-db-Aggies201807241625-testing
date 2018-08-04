SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [amy].[rpt_EndowedDTL_Notes] (@endowedsetupid int)
as
select NotesDescr, NotesType, CreateDate from EndowedNotes where endowedsetupid= @endowedsetupid
GO
