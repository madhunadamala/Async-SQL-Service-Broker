
----BEGIN OF TABLE-------------
--For entire script only once set Table name variable ---
SET @V_Obj_Name = '[dbo].[Trigger_Jobs]';
---------------------------------------------
--Defnie Details for change on table--------
SET @V_Obj_Version = 1.0;
SET @V_Obj_Changes = 'New Table Created for Trigger Jobs';
SET @V_Obj_Rel_Date = '26-Mar-2020'
---------------------------------------------

IF NOT EXISTS (SELECT * FROM [dbo].[OBJ_Insert_Release_Object_List](@V_Obj_Name,@V_Obj_Version))
BEGIN

/****** Object:  Table [dbo].[Trigger_Jobs]    Script Date: 3/16/2020 4:23:29 PM ******/
SET ANSI_NULLS ON


SET QUOTED_IDENTIFIER ON


CREATE TABLE [dbo].[Trigger_Jobs](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Job_Request_From] [nvarchar](100) NOT NULL,
	[HostName] [nvarchar](255) NULL,
	[Exec_Sp_Name] [nvarchar](100) NOT NULL,
	[Job_Query] [nvarchar](max) NOT NULL,
	[Job_Created_Time] [datetime] NULL,
	[Start_Time] [datetime] NULL,
	[End_Time] [datetime] NULL,
	[Status] [nvarchar](50) NOT NULL,
	[Log_Message] [nvarchar](max) NULL,
 CONSTRAINT [PK_Trigger_Jobs] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY]


ALTER TABLE [dbo].[Trigger_Jobs] ADD  CONSTRAINT [DF_Trigger_Jobs_HostName]  DEFAULT (host_name()) FOR [HostName]


ALTER TABLE [dbo].[Trigger_Jobs] ADD  CONSTRAINT [DF_Trigger_Jobs_Job_Created_Time]  DEFAULT (getdate()) FOR [Job_Created_Time]


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Request from the SP or from the Service or Manual' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Trigger_Jobs', @level2type=N'COLUMN',@level2name=N'Job_Request_From'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the SP to be executed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Trigger_Jobs', @level2type=N'COLUMN',@level2name=N'Exec_Sp_Name'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Query String to be executed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Trigger_Jobs', @level2type=N'COLUMN',@level2name=N'Job_Query'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Start Time of the executing of the request Job_Query' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Trigger_Jobs', @level2type=N'COLUMN',@level2name=N'Start_Time'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'End Time of the executing of the request Job_Query' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Trigger_Jobs', @level2type=N'COLUMN',@level2name=N'End_Time'


EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Pending, Started, Complete, Failed, Hold, Reject' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Trigger_Jobs', @level2type=N'COLUMN',@level2name=N'Status'

--Inserting Release information in to OBJ_Release_Object_List Table
	EXEC OBJ_Insert_Rel_Object_List @V_Obj_Name, @V_Obj_Version,@V_Obj_Changes, @V_Obj_Rel_Date

	--Inserting Completed
END
---------------END OF TABLE -----------------
