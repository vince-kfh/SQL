
/*
  Need To be able to search by Year - 1/5/10
*/
DECLARE @Database VARCHAR(15) = 'RadarKFH'

DECLARE @RunDate DATETIME = GETDATE()
DECLARE @DaysWarning INT = 3650


DECLARE @pTenancyChk BIT = 0
IF (@pTenancyChk = 0)
BEGIN
SELECT  top 10 *
FROM Extract_EPCDIVReport
WHERE pcpld_End BETWEEN GETDATE() AND DATEADD(DAY,3560,GETDATE())
AND  [Tenancy Status] != 'Terminated'
END
ELSE
BEGIN
SELECT  top 10 *
FROM Extract_EPCDIVReport
WHERE pcpld_End BETWEEN GETDATE() AND DATEADD(DAY,3560,GETDATE())
AND  [Tenancy Status]  = 'Terminated'

END




