SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE FUNCTION [amy].[udf_AllCaps] (@String VARCHAR(500)) 
RETURNS bit 
AS 
BEGIN 
   DECLARE @return BIT 
   DECLARE @position INT 

   SET @position = 1 

   WHILE @position <= DATALENGTH(@string) 
   BEGIN 
       IF ASCII(SUBSTRING(@string, @position, 1)) BETWEEN 65 AND 90  
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
