IF  EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Exec_Trigger_Jobs]') AND type in (N'TR'))
BEGIN	
	DROP TRIGGER [dbo].[Exec_Trigger_Jobs]
END

GO
CREATE TRIGGER [dbo].[Exec_Trigger_Jobs]
ON [dbo].[Trigger_Jobs]
AFTER INSERT
AS
BEGIN
   	DECLARE	@inserted	XML;

    SELECT @inserted =  ( SELECT * FROM inserted FOR XML PATH('row'), ROOT('inserted') );
    EXECUTE SB_AT_Fire_Trigger 'Trigger_Execute_Job', @inserted;
END
GO
