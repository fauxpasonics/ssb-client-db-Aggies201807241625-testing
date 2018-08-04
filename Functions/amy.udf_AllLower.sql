SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [amy].[udf_AllLower] (@String VARCHAR(500)) 
RETURNS bit 
AS 
BEGIN 
   DECLARE @return BIT 
   DECLARE @position INT 

   SET @position = 1 

   WHILE @position <= DATALENGTH(@string) 
   BEGIN 
       IF ASCII(SUBSTRING(@string, @position, 1)) BETWEEN 97 AND 122  
           SELECT @return = 0 
       ELSE 
           SELECT @return = 1 

       IF @Return <> 1 
           SET @position = @position + 1 
       ELSE 
           GOTO ExitUDF 
END 


ExitUDF: 
RETURN @return 

END
GO
