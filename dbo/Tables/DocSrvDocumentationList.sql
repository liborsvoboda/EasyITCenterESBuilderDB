CREATE TABLE [dbo].[DocSrvDocumentationList] (
    [Id]                   INT           IDENTITY (1, 1) NOT NULL,
    [DocumentationGroupId] INT           NOT NULL,
    [Name]                 VARCHAR (150) NOT NULL,
    [Sequence]             INT           NOT NULL,
    [Description]          TEXT          NULL,
    [MdContent]            TEXT          NOT NULL,
    [HtmlContent]          TEXT          NOT NULL,
    [UserId]               INT           NOT NULL,
    [Active]               BIT           CONSTRAINT [DF_DocumentationList_Active] DEFAULT ((1)) NOT NULL,
    [AutoVersion]          INT           NOT NULL,
    [TimeStamp]            DATETIME2 (7) CONSTRAINT [DF_DocumentationList_TimeStamp] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_DocumentationList] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_DocumentationList_DocumentationGroupList] FOREIGN KEY ([DocumentationGroupId]) REFERENCES [dbo].[DocSrvDocumentationGroupList] ([Id]),
    CONSTRAINT [FK_DocumentationList_UserList] FOREIGN KEY ([UserId]) REFERENCES [dbo].[SolutionUserList] ([Id]),
    CONSTRAINT [IX_DocumentationList] UNIQUE NONCLUSTERED ([Name] ASC, [DocumentationGroupId] ASC, [AutoVersion] ASC, [TimeStamp] ASC)
);


GO

CREATE   TRIGGER [dbo].[TR_DocumentationList] ON [dbo].[DocSrvDocumentationList]
FOR INSERT, UPDATE--, DELETE
AS
DECLARE @Operation VARCHAR(15)
 
IF EXISTS (SELECT 0 FROM inserted)
BEGIN
	DECLARE @setActive bit;DECLARE @autoVersion int;DECLARE @RecId int;DECLARE @GroupId int;DECLARE @RecName varchar(150);
	DECLARE @autoRemoveOld bit; DECLARE @UserId int;
	

	SET @autoVersion = 0;SET @setActive = 1;SET @autoRemoveOld = 0;
	SET NOCOUNT ON;

    IF EXISTS (SELECT 0 FROM deleted)
    BEGIN --UPDADE
		SELECT @setActive = ins.[Active] from inserted ins;
		SELECT @RecId = ins.Id from inserted ins;
		SELECT @UserId = ins.UserId from inserted ins;
		SELECT @GroupId = ins.DocumentationGroupId from inserted ins;
		SELECT @RecName = ins.[Name] from inserted ins;

		--GET AutoRemoveSetting
		SELECT @autoRemoveOld = CAST(CAST(SUBSTRING(ss.[Value],1,10) as varchar(10)) as bit) FROM [dbo].[ServerSettingList] ss WHERE ss.[Key] = 'ServerDocsOldAutoRemoveEnabled';

		IF(@setActive = 1) BEGIN
			UPDATE [dbo].DocSrvDocumentationList SET [Active] = 0 WHERE Id <> @RecId AND [Name] = @RecName AND [DocumentationGroupId] = @GroupId; 		
		END

		--AutoRemove Older versions
		IF(@autoRemoveOld = 1) BEGIN
			DELETE FROM  [dbo].DocSrvDocumentationList WHERE Id <> @RecId AND [Name] = @RecName AND [DocumentationGroupId] = @GroupId; 		
		END

	END ELSE
		BEGIN -- INSERT
			SELECT @setActive = ins.[Active] from inserted ins;
			SELECT @RecId = ins.Id from inserted ins;
			SELECT @UserId = ins.UserId from inserted ins;
			SELECT @GroupId = ins.DocumentationGroupId from inserted ins;
			SELECT @RecName = ins.[Name] from inserted ins;

			--GET AutoRemoveSetting
			SELECT @autoRemoveOld = CAST(CAST(SUBSTRING(ss.[Value],1,10) as varchar(10)) as bit) FROM [dbo].[ServerSettingList] ss WHERE ss.[Key] = 'ServerDocsOldAutoRemoveEnabled';

			--AutoVersioning
			SELECT @autoVersion = MAX(d.[AutoVersion]) + 1 FROM [dbo].DocSrvDocumentationList d WHERE d.[Name] = @RecName AND [DocumentationGroupId] = @GroupId;
			IF (@autoVersion = 0 ) BEGIN SET @autoVersion = 1; END
			UPDATE [dbo].DocSrvDocumentationList SET [AutoVersion] = @autoVersion WHERE Id = @RecId AND [DocumentationGroupId] = @GroupId;

			IF(@setActive = 1) BEGIN
				UPDATE [dbo].DocSrvDocumentationList SET [Active] = 0 WHERE Id <> @RecId AND [Name] = @RecName AND [DocumentationGroupId] = @GroupId; 		
			END
			
			--AutoRemove Older versions
			IF(@autoRemoveOld = 1) BEGIN
				DELETE FROM  [dbo].DocSrvDocumentationList WHERE Id <> @RecId AND [Name] = @RecName AND [DocumentationGroupId] = @GroupId; 		
			END
		END
END

GO

