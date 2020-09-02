
-- at first create a profile for emails
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'mail', 
    @recipients = 'list@emails.to send;',
    @copy_recipients = 'CC', 
    @body ='Body' ,
    @subject = 'Subject' 