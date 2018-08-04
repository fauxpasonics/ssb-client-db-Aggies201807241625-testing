SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
 
CREATE FUNCTION [dbo].[fn_Mask] (@Text VARCHAR(1000), @DataType varchar(50) = '')   
 
RETURNS VARCHAR(1000)  
 
AS   
 
BEGIN  
 
DECLARE @Mask AS VARCHAR(1000) 
 
SET @Mask= '' 
 
IF @DataType = 'Date'  
Begin 
SET @Mask = null 
ENd 
 
ELSE 
 
 
 Begin 
 
DECLARE @Char AS CHAR(3) 
 
DECLARE @Counter AS INT =1 
 
DECLARE @CharReplace AS CHAR(1) 
 
  
 
WHILE @Counter <= len(@Text) 
 
BEGIN 
 
SET @Char=Ascii(SUBSTRING(@Text,@Counter,1)) 
 
SELECT @CharReplace =MaskText FROM mdm.DataMask WHERE PositionNumber = @Counter AND OriginalText=@Char 
 
  
 
SET @Mask=@Mask+ ISNULL(@CharReplace,@Char) 
 
  
 
SET @Counter=@Counter + 1 
 
SET @Char=NULL 
 
SET @CharReplace=NULL 
 
END 
 END 
  
 
RETURN (@Mask) 
 
END
GO
