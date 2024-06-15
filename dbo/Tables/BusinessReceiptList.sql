CREATE TABLE [dbo].[BusinessReceiptList] (
    [Id]                INT             IDENTITY (1, 1) NOT NULL,
    [DocumentNumber]    VARCHAR (20)    NOT NULL,
    [InvoiceNumber]     VARCHAR (20)    NULL,
    [Supplier]          VARCHAR (512)   NOT NULL,
    [Customer]          VARCHAR (512)   NOT NULL,
    [IssueDate]         DATETIME2 (7)   NOT NULL,
    [Storned]           BIT             NOT NULL,
    [TotalCurrencyId]   INT             NOT NULL,
    [Description]       TEXT            NULL,
    [TotalPriceWithVat] NUMERIC (10, 2) NOT NULL,
    [UserId]            INT             NOT NULL,
    [TimeStamp]         DATETIME2 (7)   CONSTRAINT [DF_ReceiptList_TimeStamp] DEFAULT (getdate()) NOT NULL,
    CONSTRAINT [PK_ReceiptList] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [FK_ReceiptList_CurrencyList] FOREIGN KEY ([TotalCurrencyId]) REFERENCES [dbo].[BasicCurrencyList] ([Id]),
    CONSTRAINT [FK_ReceiptList_OutgoingInvoiceList] FOREIGN KEY ([InvoiceNumber]) REFERENCES [dbo].[BusinessOutgoingInvoiceList] ([DocumentNumber]) ON DELETE SET NULL,
    CONSTRAINT [FK_ReceiptList_UserList] FOREIGN KEY ([UserId]) REFERENCES [dbo].[SolutionUserList] ([Id]),
    CONSTRAINT [IX_ReceiptList] UNIQUE NONCLUSTERED ([DocumentNumber] ASC)
);


GO

