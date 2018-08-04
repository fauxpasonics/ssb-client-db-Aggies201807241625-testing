SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create  procedure [amy].[proc_endowed_createnote] (@endowedsetupid int, @note varchar(max), @notetype varchar(50) = 'Notes')
as
begin
insert into  EndowedNotes 
( adnumber, DonorName, NotesDescr, NotesType, CreateDate, CreateUser, UpdateDate, UpdateUser, EndowedSetupID) VALUES
( (select adnumber from EndowedSetup where endowedsetupid = @endowedsetupid) , 
(select accountname from EndowedSetup where endowedsetupid = @endowedsetupid),
@note,
 @notetype,  getdate(), NULL, getdate(), 'admin',@endowedsetupid )
 end
GO
