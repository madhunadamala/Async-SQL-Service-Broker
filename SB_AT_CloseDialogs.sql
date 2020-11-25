-- This procedure is activated to handle each item in the Response queue
CREATE PROCEDURE [dbo].[SB_AT_CloseDialogs]
AS
	SET NOCOUNT ON;
	SET ARITHABORT ON
	DECLARE @MsgType SYSNAME
	DECLARE @msg XML
	DECLARE @DlgId UNIQUEIDENTIFIER
	DECLARE @Info nvarchar(max)
	DECLARE @ErrorsCount int
	SET @ErrorsCount = 0
	
	-- Set whether to log verbose status messages before and after each operation
	DECLARE @Verbose BIT = 0

	-- Allow 10 retries in case of service broker errors
	WHILE @ErrorsCount < 10
	BEGIN
		
		BEGIN TRY
			-- Make sure queue is active
			IF EXISTS (SELECT NULL FROM sys.service_queues 
					   WHERE NAME = 'SB_AT_Response_Queue'
					   AND is_receive_enabled = 0)
				ALTER QUEUE SB_AT_Response_Queue WITH STATUS = ON;

			-- handle one message at a time
			WAITFOR
			(
				RECEIVE TOP(1)
					@msg		= CONVERT(xml, message_body),
					@MsgType	= message_type_name,
					@DlgId		= conversation_handle
				FROM dbo.SB_AT_Response_Queue
			);
			
			-- exit when waiting has been timed out
			IF @@ROWCOUNT = 0
				BREAK;
			
			-- If message type is end dialog or error, end the conversation
			IF (@MsgType = N'http://schemas.microsoft.com/SQL/ServiceBroker/EndDialog' OR
				@MsgType = N'http://schemas.microsoft.com/SQL/ServiceBroker/Error')
			BEGIN
				END CONVERSATION @DlgId;

				IF @Verbose = 1
					INSERT INTO SB_AT_ServiceBrokerLogs(ErrorSeverity,ErrorMessage,ErrorProc,QueueMessage)
					VALUES(0,'Ended Conversation ' + CONVERT(nvarchar(max),@DlgId),OBJECT_NAME(@@PROCID),@msg);
			END
			ELSE IF @Verbose = 1
				INSERT INTO SB_AT_ServiceBrokerLogs(ErrorSeverity,ErrorMessage,ErrorProc,QueueMessage)
				VALUES(0,'Unknown Message from ' + CONVERT(nvarchar(max),@DlgId),OBJECT_NAME(@@PROCID),@msg);

			-- reset variables
			SET @MsgType = NULL;
			SET @msg = NULL;
		END TRY
		BEGIN CATCH
		
			-- log operation fail
			INSERT INTO SB_AT_ServiceBrokerLogs(ErrorSeverity,ErrorMessage,ErrorLine,ErrorProc)
			VALUES(ERROR_SEVERITY(),ERROR_MESSAGE(),ERROR_LINE(),ERROR_PROCEDURE());
			
			-- increase error counter
			SET @ErrorsCount = @ErrorsCount + 1;
			
			-- wait 5 seconds before retrying
			WAITFOR DELAY '00:00:05'
		END CATCH
	
	END

GO


