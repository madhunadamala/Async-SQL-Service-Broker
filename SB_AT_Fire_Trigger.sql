-- This procedure sends items to the queue for asynchronous triggers
CREATE PROCEDURE [dbo].[SB_AT_Fire_Trigger]
	@ProcedureName	VARCHAR(1000),
	@inserted		XML = NULL,
	@deleted		XML = NULL
AS
	SET NOCOUNT ON;

	DECLARE @msg XML
	
	-- build the XML message
	SET @msg = (SELECT
					ProcedureName	= @ProcedureName,
					inserted		= @inserted,
					deleted			= @deleted
				FOR XML PATH('Request'))
	
	DECLARE @DlgId UNIQUEIDENTIFIER
	
	BEGIN DIALOG @DlgId
		FROM SERVICE [//SB_AT/ProcessStartingService]
		TO SERVICE '//SB_AT/ProcessReceivingService',
		'CURRENT DATABASE'
		ON CONTRACT [//SB_AT/Contract]
	WITH ENCRYPTION = OFF;
	
	-- send the message
	SEND ON CONVERSATION @DlgId
	MESSAGE TYPE [//SB_AT/Message] (@msg);
	
	PRINT N'Started SB_AT process on dialogId ' + ISNULL(convert(varchar(100),@DlgId),'(null)');
	

GO


