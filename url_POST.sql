sp_configure 'show advanced options', 1;
GO
RECONFIGURE;
GO
sp_configure 'Ole Automation Procedures', 1;
GO
RECONFIGURE;
GO
sp_configure 'show advanced options', 0;
GO
RECONFIGURE;
GO

declare
@URI varchar(2000),
@methodName varchar(50),
@requestBody varchar(8000),
@responseText varchar(8000),
@proxy varchar(50), 
@proxySettings varchar(50)

select @URI='http://example.com/',
       @methodName='GET',
       @requestBody='/login.asp?user=USER&pass=PASS&path=%2Fdir'


DECLARE @objectID int
DECLARE @hResult int
DECLARE @source varchar(255), @desc varchar(255)

EXEC 	@hResult = sp_OACreate 'WinHttp.WinHttpRequest.5.1', @objectID OUT

IF @hResult <> 0
BEGIN
	EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT 
	SELECT 	hResult = convert(varbinary(4), @hResult), 
			source = @source, 
			description = @desc,
			FailPoint = 'Create failed',
			MedthodName = @methodName
	goto destroy
	return
END

-- open the destination URI with Specified method
EXEC @hResult = sp_OAMethod @objectID, 'open', null, @methodName, @URI, 'false'
IF @hResult <> 0
BEGIN
	EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT 
	SELECT 	hResult = convert(varbinary(4), @hResult), 
		source = @source, 
		description = @desc,
		FailPoint = 'Open failed',
		MedthodName = @methodName
	goto destroy
	return
END

-- set request headers
EXEC @hResult = sp_OAMethod @objectID, 'setRequestHeader', null, 'Content-Type', 'application/x-www-form-urlencoded'
IF @hResult <> 0
BEGIN
	EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT 
	SELECT 	hResult = convert(varbinary(4), @hResult), 
		source = @source, 
		description = @desc,
		FailPoint = 'SetRequestHeader failed: Content-Type',
		MedthodName = @methodName
	goto destroy
	return
END

declare @len int
set @len = len(@requestBody)
EXEC @hResult = sp_OAMethod @objectID, 'setRequestHeader', null, 'Content-Length', @len
IF @hResult <> 0
BEGIN
	EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT 
	SELECT 	hResult = convert(varbinary(4), @hResult), 
		source = @source, 
		description = @desc,
		FailPoint = 'SetRequestHeader failed: Content-Length',
		MedthodName = @methodName
	goto destroy
	return
END
--
--EXEC @hResult = sp_OAMethod @objectID, 'setProxy', NULL,  @proxy, @proxySettings
--IF @hResult <> 0
--BEGIN
--	EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT 
--	SELECT 	hResult = convert(varbinary(4), @hResult), 
--		source = @source, 
--		description = @desc,
--		FailPoint = 'SetProxy'
--	goto destroy
--	return
--END

-- send the request
select 	requestBody = @requestBody
EXEC 	@hResult = sp_OAMethod @objectID, 'send', null, @requestBody
IF 	@hResult <> 0
BEGIN
	EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT 
	SELECT 	hResult = convert(varbinary(4), @hResult), 
		source = @source, 
		description = @desc,
		FailPoint = 'Send failed',
		MedthodName = @methodName
	goto destroy
	return
END

declare @statusText varchar(1000), @status varchar(1000)
-- Get status text
exec sp_OAGetProperty @objectID, 'StatusText', @statusText out 
exec sp_OAGetProperty @objectID, 'Status', @status out 
select hResult=@hResult, status=@status, statusText=@statusText, methodName=@methodName

-- Get response text
exec sp_OAGetProperty @objectID, 'responseText', @responseText out 
select responseText=@responseText

IF @hResult <> 0
BEGIN
	EXEC sp_OAGetErrorInfo @objectID, @source OUT, @desc OUT 
	SELECT 	hResult = convert(varbinary(4), @hResult), 
		source = @source, 
		description = @desc,
		FailPoint = 'ResponseText failed',
		MedthodName = @methodName
	goto destroy
	return
END

destroy:
	exec sp_OADestroy @objectID

SET nocount off

GO