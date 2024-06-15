CREATE TABLE [dbo].[BasicImageGalleryList] (
    [Id]         INT             IDENTITY (1, 1) NOT NULL,
    [IsPrimary]  BIT             NOT NULL,
    [FileName]   VARCHAR (150)   NOT NULL,
    [Attachment] VARBINARY (MAX) NOT NULL,
    [UserId]     INT             NOT NULL,
    [TimeStamp]  DATETIME2 (7)   CONSTRAINT [DF_ImageGalleryList_TimeStamp] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ImageGalleryList] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ImageGalleryList_UserList] FOREIGN KEY ([UserId]) REFERENCES [dbo].[SolutionUserList] ([Id]),
    CONSTRAINT [UX_ImageGalleryList] UNIQUE NONCLUSTERED ([FileName] ASC)
);


GO





CREATE   TRIGGER [dbo].[TR_ImageGalleryList] ON [dbo].[BasicImageGalleryList]
FOR INSERT, UPDATE, DELETE
AS
DECLARE @Operation VARCHAR(15)
 
IF EXISTS (SELECT 0 FROM inserted)
BEGIN
	DECLARE @isPrimary bit;DECLARE @RecId int;DECLARE @HotelId int;
	SET NOCOUNT ON;

    IF EXISTS (SELECT 0 FROM deleted)
    BEGIN --UPDADE
		SELECT @isPrimary = ins.[IsPrimary] from inserted ins;
		SELECT @RecId = ins.Id from inserted ins;

		IF(@isPrimary = 1) BEGIN
			UPDATE [dbo].BasicImageGalleryList SET [IsPrimary] = 0 WHERE Id <> @RecId; 		
		END
	END ELSE
		BEGIN -- INSERT
			SELECT @isPrimary = ins.[IsPrimary] from inserted ins;
			SELECT @RecId = ins.Id from inserted ins;

			IF(@isPrimary = 1) BEGIN
				UPDATE [dbo].BasicImageGalleryList SET [IsPrimary] = 0 WHERE Id <> @RecId; 		
			END
		
		END
END ELSE 
BEGIN --DELETE
	SELECT @isPrimary = ins.[IsPrimary] from deleted ins;
	SELECT @RecId = ins.Id from deleted ins;

	IF(@isPrimary = 1) BEGIN
		UPDATE [dbo].BasicImageGalleryList SET [IsPrimary] = 1  
		WHERE Id IN(SELECT TOP (1) Id FROM [dbo].BasicImageGalleryList WHERE Id <> @RecId)
		;
	END
END

GO

