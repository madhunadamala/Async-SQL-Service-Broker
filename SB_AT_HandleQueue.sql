
-- This procedure is activated to handle each item in the Request queue
CREATE PROCEDURE [dbo].[SB_AT_HandleQueue]
AS
	SET NOCOUNT ON;
	SET ARITHABORT ON
	DECLARE @msg XML
	DECLARE @DlgId UNIQUEIDENTIFIER
	DECLARE @Info nvarchar(max)
	DECLARE @ErrorsCount int
	SET @ErrorsCount = 0

	-- Set whether to log verbose status messages before and after each operation
	DECLARE @Verbose BIT = 1
	
	-- Allow 10 retries in case of service broker errors
	WHILE @ErrorsCount < 10
	BEGIN
		
		BEGIN TRANSACTION
		BEGIN TRY
			-- Make sure queue is active
			IF EXISTS (SELECT NULL FROM sys.service_queues 
					   WHERE NAME = 'SB_AT_Request_Queue'
					   AND is_receive_enabled = 0)
				ALTER QUEUE SB_AT_Request_Queue WITH STATUS = ON;

			-- handle one message at a time
			WAITFOR
			(
				RECEIVE TOP(1)
					@msg		= convert(xml,message_body),
					@DlgId		= conversation_handle
				FROM dbo.SB_AT_Request_Queue
			);
			
			-- exit when waiting has been timed out
			IF @@ROWCOUNT = 0
			BEGIN
				IF @@TRANCOUNT > 0
					ROLLBACK TRANSACTION;
				BREAK;
			END
			
			-- Retreive data from xml message
			DECLARE
				@ProcedureName	VARCHAR(1000),
				@inserted		XML,
				@deleted		XML
			
			SELECT
				@ProcedureName		= x.value('(/Request/ProcedureName)[1]','VARCHAR(1000)'),
				@inserted			= x.query('/Request/inserted/inserted'),
				@deleted			= x.query('/Request/deleted/deleted')
			FROM @msg.nodes('/Request') AS T(x);
			
			-- Log operation start
			IF @Verbose = 1
				INSERT INTO SB_AT_ServiceBrokerLogs(ErrorSeverity,ErrorMessage,QueueMessage)
				VALUES(0,'Starting Process',@msg);
			
			-- Encapsulate execution in TRY..CATCH
			-- to catch errors in the specific request
			BEGIN TRY
			
				-- Execute Request
				EXEC @ProcedureName @inserted, @deleted;
			
			END TRY
			BEGIN CATCH
			
				-- log operation fail
				INSERT INTO SB_AT_ServiceBrokerLogs(ErrorSeverity,ErrorMessage,ErrorLine,ErrorProc,QueueMessage)
				VALUES(ERROR_SEVERITY(),ERROR_MESSAGE(),ERROR_LINE(),ERROR_PROCEDURE(),@msg);
				
			END CATCH
			
			-- commit
			IF @@TRANCOUNT > 0
				COMMIT TRANSACTION;
			
			-- Log operation end
			IF @Verbose = 1
				INSERT INTO SB_AT_ServiceBrokerLogs(ErrorSeverity,ErrorMessage,ErrorProc,QueueMessage)
				VALUES(0,'Finished Process',OBJECT_NAME(@@PROCID),@msg);
			
			-- Close dialogue
			END CONVERSATION @DlgId;

			-- reset xml message
			SET @msg = NULL;
		END TRY
		BEGIN CATCH
		
			-- rollback transaction
			-- this will also rollback the extraction of the message from the queue
			IF @@TRANCOUNT > 0
				ROLLBACK TRANSACTION;
			
			-- log operation fail
			INSERT INTO SB_AT_ServiceBrokerLogs(ErrorSeverity,ErrorMessage,ErrorLine,ErrorProc,QueueMessage)
			VALUES(ERROR_SEVERITY(),ERROR_MESSAGE(),ERROR_LINE(),ERROR_PROCEDURE(),@msg);
			 
			--Send Mail
			EXEC SendEmail  Select 'BDIP-SB JOB Error Notification ' +dbo.GetDatabaseRegion() ,ERROR_MESSAGE() ,'madhusudhanareddy.nadamala@boeing.com, Kiran.Alamuru@Cyient.com'

			-- increase error counter
			SET @ErrorsCount = @ErrorsCount + 1;
			
			-- wait 5 seconds before retrying
			WAITFOR DELAY '00:00:05'
		END CATCH
	
	END

GO


