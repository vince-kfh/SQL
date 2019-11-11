
/*
   SQL HR Benefix Script

   -- Stored Procedure 
*/

alter PROCEDURE GetBenefexMonthlyData
  @taxPeriod int,
  @taxYear  int 
AS
/*
      execute GetBenefexMonthlyData 7,2019

*/
	BEGIN

		
-- 1 -- Reference Data:


-- Pension Details

	--use [PAY_5d0ea206cd724ec88e2d035577fd8291_KINLive]

	IF OBJECT_ID('tempdb..#AEPensionKINLive') IS NOT NULL
		   drop table #AEPensionKINLive

	SELECT [Employee Code], [AE Pension Member] = (SELECT CASE WHEN [EP_OPT_OUT_DATE] IS NOT NULL OR [EP_CEASE_DATE] IS NOT NULL THEN 'Opt Out'
																  ELSE 'Y'
																  END
							   )
	Into #AEPensionKINLive
			 FROM  [PAY_5d0ea206cd724ec88e2d035577fd8291_KINLive].AA_ARW_R.AA_ARW_EMPLOYEE_DETAILS_VIEW emprec
		   inner join  [PAY_5d0ea206cd724ec88e2d035577fd8291_KINLive]..EMP_PENSION pens on emprec.EMP_ID=pens.EP_EMP_ID


	---- select * from #AEPensionKINLive
	--use [PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive]--KFHLive
	 
	IF OBJECT_ID('tempdb..#AEPensionKFHLive') IS NOT NULL
		   drop table #AEPensionKFHLive
	   

	SELECT [Employee Code],   
					 [AE Pension Member] = (SELECT CASE WHEN [EP_OPT_OUT_DATE] IS NOT NULL OR [EP_CEASE_DATE] IS NOT NULL THEN 'Opt Out'
																  ELSE 'Y'
																  END
							   )
	Into #AEPensionKFHLive
			 FROM  [PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive].AA_ARW_R.AA_ARW_EMPLOYEE_DETAILS_VIEW emprec
		   inner join  [PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive]..EMP_PENSION pens on emprec.EMP_ID=pens.EP_EMP_ID


	---- select * from #AEPensionKFHLive


	-- select * from #AEPensionKFSLive
	--  use [PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive]--KFSLive
	   
	IF OBJECT_ID('tempdb..#AEPensionKFSLive') IS NOT NULL
	   drop table #AEPensionKFSLive

	SELECT [Employee Code],   
					 [AE Pension Member] = (SELECT CASE WHEN [EP_OPT_OUT_DATE] IS NOT NULL OR [EP_CEASE_DATE] IS NOT NULL THEN 'Opt Out'
																  ELSE 'Y'
																  END
								)
	Into #AEPensionKFSLive
			 FROM  [PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive].AA_ARW_R.AA_ARW_EMPLOYEE_DETAILS_VIEW emprec
		   inner join  [PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive]..EMP_PENSION pens on emprec.EMP_ID=pens.EP_EMP_ID



 --USE [HR_5d0ea206_cd72_4ec8_8e2d_035577fd8291_HR]--SelectHR
 
IF OBJECT_ID('tempdb..#AEPension') IS NOT NULL
       drop table #AEPension

        SELECT *
       INTO #AEPension
       from
       (
              select * from #AEPensionKFSLive
              UNION
              select * from #AEPensionKINLive
              UNION
              select * from #AEPensionKFHLive
       )src


IF OBJECT_ID('tempdb..#PensionAEStatus') IS NOT NULL
       drop table     #PensionAEStatus                                         
       
       SELECT DISTINCT [EmployeeCode],AEStatus,PensionAEStatus
       into #PensionAEStatus
       
       from(
              SELECT [EmployeeCode],Case 
                           when PensionAEStatus = 1 then 'EJH'
                           when PensionAEStatus = 2 then 'NEJH'
                           when PensionAEStatus = 3 then 'EW'
                           ELSE 'Unknown'
                     end AEStatus,PensionAEStatus
              from [PAY_5d0ea206cd724ec88e2d035577fd8291_KINLive].dbo.AA_WEB_AE_PENSION_VIEW
              --WHERE KINLive.dbo.AA_WEB_AE_PENSION_VIEW.[EmployeeCode] = 316092
              UNION
              SELECT [EmployeeCode],Case 
                           when PensionAEStatus = 1 then 'EJH'
                           when PensionAEStatus = 2 then 'NEJH'
                           when PensionAEStatus = 3 then 'EW'
                           ELSE 'Unknown'
                     end AEStatus,PensionAEStatus
              from [PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive].dbo.AA_WEB_AE_PENSION_VIEW
              --WHERE KINLive.dbo.AA_WEB_AE_PENSION_VIEW.[EmployeeCode] = 316092
              UNION

              SELECT [EmployeeCode],Case 
                           when PensionAEStatus = 1 then 'EJH'
                           when PensionAEStatus = 2 then 'NEJH'
                           when PensionAEStatus = 3 then 'EW'
                           ELSE 'Unknown'
                     end AEStatus,PensionAEStatus
              from [PAY_5d0ea206cd724ec88e2d035577fd8291_KFHLive].dbo.AA_WEB_AE_PENSION_VIEW
       )src


----     Select * from  #PensionAEStatus  
IF OBJECT_ID('tempdb..#QualifiedEarnings') IS NOT NULL
       drop table     #QualifiedEarnings             
                                         
       select DISTINCT rnum,EMP_NIC_Number,[Qualifying Earnings],HIST_YEAR --src.*
       into #QualifiedEarnings
       from (
       SELECT  row_number() over(Partition by EMP_NIC_Number  order by   EMP_NIC_Number,HIST_YEAR desc) as rnum,
                     EMP_NIC_Number,[Qualifying Earnings] = max("AA_REP_PAYE_PENSION_DETAIL_VIEWVH"."HIST_MULVAL"),HIST_YEAR
       FROM   "PAY_5d0ea206cd724ec88e2d035577fd8291_KINLive"."dbo"."AA_REP_PAYE_PENSION_DETAIL_VIEWVH" "AA_REP_PAYE_PENSION_DETAIL_VIEWVH"
         group by EMP_NIC_Number,HIST_YEAR
       UNION
         SELECT row_number() over(Partition by EMP_NIC_Number  order by   EMP_NIC_Number,HIST_YEAR desc) as rnum,
                     EMP_NIC_Number,[Qualifying Earnings] = max("AA_REP_PAYE_PENSION_DETAIL_VIEWVH"."HIST_MULVAL"),HIST_YEAR
       FROM   "PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive"."dbo"."AA_REP_PAYE_PENSION_DETAIL_VIEWVH" "AA_REP_PAYE_PENSION_DETAIL_VIEWVH"
       group by EMP_NIC_Number,HIST_YEAR
         UNION
         SELECT row_number() over(Partition by EMP_NIC_Number  order by   EMP_NIC_Number,HIST_YEAR desc) as rnum,
                     EMP_NIC_Number,[Qualifying Earnings] = max("AA_REP_PAYE_PENSION_DETAIL_VIEWVH"."HIST_MULVAL"),HIST_YEAR
       FROM   "PAY_5d0ea206cd724ec88e2d035577fd8291_KFHLive"."dbo"."AA_REP_PAYE_PENSION_DETAIL_VIEWVH" "AA_REP_PAYE_PENSION_DETAIL_VIEWVH"
       group by EMP_NIC_Number,HIST_YEAR

       )src
       where src.rnum = 1
       ORDER BY EMP_NIC_Number,HIST_YEAR desc


-- 2 -- Generate Reporting Data:

IF OBJECT_ID('tempdb..#LatestData') IS NOT NULL
       drop table     #LatestData 

-- USE [HR_5d0ea206_cd72_4ec8_8e2d_035577fd8291_HR]
 
select 
            -- Personal Details
                       Person.Snapshot.[Payroll Number] As [Additional EmployeeKey (Payroll Number)],
              Person.Snapshot.[Person Number] As [EmployeeKey (Person Number)],
              --        Person.Snapshot.[Appointment Number] As [EmployeeKey (Appointment Number)],
                       ISNULL(Replace(Person.Snapshot.Title,',',' | ') ,'')As [Title (Title)], 
                       ISNULL(Replace(Person.Snapshot.[First Name] ,',',' | '),'')As [Forename (First Name)], 
                       ISNULL(Replace(Person.Snapshot.Surname,',',' | ') ,'')As [Surname (Surname)], 
                       ISNULL(Replace(Person.Snapshot.[Known As],',',' | ') ,'')As [PreferredName (Known As)],
                     -- Address Details
                     ISNULL(Replace([Person].[Address] .[Address Line 1],',',' | '),'') As [Address1 (Address Line 1)],
                       ISNULL(Replace( [Person].[Address] .[Address Line 2],',',' | '),'') As [Address2 (Address Line 2)], '' As [Address3 (no equiv in HR)], 
                       ISNULL(Replace( [Person].[Address] .[Address Line 3],',',' | '),'') As [Address4 (Address Line 3/town)], 
                       ISNULL(Replace( [Person].[Address] .[Address Line 4],',',' | '),'') As [Address5 (Address Line 4/county)], 
                       ISNULL(Replace( [Person].[Address] .[Post Code],',',' | '),'') As [Postcode (Post code)], 
                       ISNULL(Replace( [Person].[Address] .[Address Line 5] ,',',' | '),'')As [Country (Address Line 5/not used)],
                       ISNULL(Person.Snapshot.[E-Mail],'') As [Email Address (E-mail)], 
               -- Date of Birth
            Convert(Varchar(20),Person.Details.[Birth Date],103) As [DateofBirth (Birth Date)],
                     -- Gender field Sorted 
                     CASE WHEN Person.Snapshot.Gender  = 'Male' Then 'M' ELSE 'F' END As [Gender (Gender)],
                       '' As [Taxcode (not required)], 
                     Replace(Person.Details.[NI Letter],',',' | ') As [NICate ry (NI Letter)], 
                     Replace(Person.Details.[NI Number],',',' | ') As [NINumber (NI Number)], 
                      Convert(Varchar(20),Person.Snapshot.[Start Date],103) As [Start date (Start Date)],
                     Convert(Varchar(20),Person.Snapshot.[Continuous Service Date],103)  As [Original start date (Cont. Service Date)], 
             Convert(Varchar(20),Person.Snapshot.[Probation Review Date],103) As [Probation passed date (Pr Review Date)],
                     '' As [Apprentice start date (no equiv in HR)],
             Convert(Varchar(20),Person.Snapshot.[End Date],103) As [Leave date (End Date)],
                     Replace(  Person.Snapshot.[Post Name],',',' | ') As [Jobtitle (Post Name)], 
            -- SnapShot Status
               case
                     when Person.Snapshot.Status IN('Permanent','Full Time') THEN 'Full Time'
                     when Person.Snapshot.Status IN('Part Time') THEN 'Part Time'
                     when Person.Snapshot.Status IN('Temporary / Fixed term') THEN 'Temporary Contract'
                     when Person.Snapshot.Status IN('Zero Hours') THEN 'Zero Hours contract'
                     else Null
                     end As [ContractType (Snapshot Status)],
                     Person.Snapshot.[Effective Status] As [Status (Effective Status)],
    -- Amount Details
          ISNULL(Employee.[Current Basic Pay].[Pay Amount],1) As [Salary (Current Basic Pay Amount)],
          '' As [Grade],
              Replace(Person.Snapshot.[Key Unit Name 4],',',' | ') As [Division (Key Unit Name 4)], 
              Replace(Person.Snapshot.[Key Unit Name 2],',',' | ') As [Location (Key Unit Name 2)], 
              Replace(Person.Snapshot.[Location Code],',',' | ') As [Costcentre (Location Code)], 
              Replace(Organisation.Locations.[Post Code],',',' | ') As [WorkPostcode (Orgn.Locns.Post Code)],
       -- Hours Per Week
          Employee.[Career History].[Hours Per Week] As [Hours per week],
          Person.Snapshot.FTE As [FTEHours (Empl. Career Hist. FTE)], 
          Employee.[Career History].[Days Per Week] As [Daysperweek (Days Per Week)],
          Absence.[Holiday History].[Basic Holiday Entitlement] As [Abs.Hol.Hist.Basic Hol],
              'To Be Defined' As [Holidayhours],
              -- Qualifying Earnings column
       [Qualifying Earnings] = ISNULL(( SELECT TOP 1 [Qualifying Earnings]
                                                       FROM   #QualifiedEarnings
                                                       WHERE  #QualifiedEarnings.Emp_NIC_Number = [HR_5d0ea206_cd72_4ec8_8e2d_035577fd8291_HR].Person.Details.[NI Number] 
                                                        ),1), 
              'To Be Defined' As [OTE],
              -- AE Status Will be one of only = EJH, NEJH, EW, NEW
              [AE Status] = (  SELECT AEStatus FROM  #PensionAEStatus  WHERE #PensionAEStatus.[EmployeeCode] =  Person.Snapshot.[Payroll Number]
              ),
              [AE Pension Member] = (SELECT [AE Pension Member] 
                                         From #AEPension
                                                       where  #AEPension.[Employee Code] = Person.Snapshot.[Payroll Number]              
                                                       ),
              -- mandatory with ‘1500024’ showing for all employees
              -- New Column 
              case
                     when Person.Snapshot.[Post Name] = 'Lettings Ne tiator' THEN 'Y'
                     when Person.Snapshot.[Probation Review Date] IS NULL  AND Convert(varchar(20),Person.Snapshot.[Probation Review Date],112) > GETDATE() THEN 'Y' 
                     end As [Non Sal Sacr],
        '1500024' As [File_URN (no equiv in HR)]
              into #LatestData
from Person.Snapshot
Inner Join Person.Details On Person.Snapshot.[Person Number] = Person.Details.[Person Number] 
inner join [Person].[Address] On Person.Snapshot.[Person Number] = [Person].[Address] .[Person Number] 
left Join Employee.[Current Basic Pay ] On Person.Snapshot.[Appointment Number] = Employee.[Current Basic Pay ].[Appointment Number] 
-- Career Link
Inner Join Employee.[Career History] On Person.Snapshot.[Career Number] = Employee.[Career History].[Career Number]
-- Absence History
Inner Join Absence.[Holiday History] On Person.Snapshot.[Person Number] = Absence.[Holiday History].[Person Number]                                                                                                                 
and Absence.[Holiday History].Year = Year(GetDate()) 
-- Location
Left Join Organisation.Locations On Person.Snapshot.[Location Number] = Organisation.Locations.[Location Number] 
 Where (Person.Snapshot.[Effective Status] = 'Current' 
        And Employee.[Current Basic Pay ].[Pay Element Type] IS NULL OR Employee.[Current Basic Pay ].[Pay Element Type] in('Basic Pay','Basic Pay- Hourly Paid')
              )
and [Person].[Address].[Effective Date] in(select MAX([Effective Date]) From [Person].[Address] where [Person Number] =  Person.Snapshot.[Person Number])


-- /*************************** **************************************/

-- 3. Apply Commission Details


--1. KFSLive
IF OBJECT_ID('tempdb..#RvdSalariesKFS') IS NOT NULL
       drop table #RvdSalariesKFS
SELECT [EMP_CODE],BasicSalaryAgg = SUM(Total)
into #RvdSalariesKFS
FROM(
       SELECT [EMP_CODE]
                ,[EMP_SURNAME]
                ,[Initials]
                ,[EPT_CODE]
                ,Total =  sum([Gross])
         FROM PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive.[dbo].[udef_CommAnalysisByPos_db_view]
         WHERE TaxYear = @taxYear
         and TaxPeriod = @taxPeriod
         and EMP_CODE IN (SELECT DISTINCT([Additional EmployeeKey (Payroll Number)]) FROM #LatestData)
         and EPT_CODE IN( SELECT DISTINCT [EMP_CODE_DESC] FROM PAY_5d0ea206cd724ec88e2d035577fd8291_KFSLive.[dbo].[EMP_COMMISSION_CODES])
       group  by EMP_CODE,EMP_SURNAME,[Initials],[EPT_CODE]
)src
group by [EMP_CODE]

-- SELECT * FROM #RvdSalariesKFS where emp_code = 314466

-- update 
        UPDATE #LatestData SET [Salary (Current Basic Pay Amount)] = #RvdSalariesKFS.BasicSalaryAgg
              FROM #LatestData
              INNER JOIN #RvdSalariesKFS ON #LatestData.[Additional EmployeeKey (Payroll Number)] = #RvdSalariesKFS.EMP_CODE

--1. KFHLive

 -- DROP  TABLE #RvdSalariesKFH
  IF OBJECT_ID('tempdb..#RvdSalariesKFH') IS NOT NULL
       drop table #RvdSalariesKFH
SELECT [EMP_CODE],BasicSalaryAgg = SUM(Total)
into #RvdSalariesKFH
FROM(
       SELECT [EMP_CODE]
                ,[EMP_SURNAME]
                ,[Initials]
                ,[EPT_CODE]
                ,Total =  sum([Gross])
         FROM PAY_5d0ea206cd724ec88e2d035577fd8291_KFHLive.[dbo].[udef_CommAnalysisByPos_db_view]
         WHERE TaxYear = @taxYear
         and TaxPeriod = @taxPeriod
                and EMP_CODE IN (SELECT DISTINCT([Additional EmployeeKey (Payroll Number)]) FROM #LatestData)
         and EPT_CODE IN( SELECT DISTINCT [EMP_CODE_DESC] FROM PAY_5d0ea206cd724ec88e2d035577fd8291_KFHLive.[dbo].[EMP_COMMISSION_CODES])
       group  by EMP_CODE,EMP_SURNAME,[Initials],[EPT_CODE]
)src
group by [EMP_CODE]

-- update 
        UPDATE #LatestData SET [Salary (Current Basic Pay Amount)] = #RvdSalariesKFH.BasicSalaryAgg
              FROM #LatestData
              INNER JOIN #RvdSalariesKFH ON #LatestData.[Additional EmployeeKey (Payroll Number)] = #RvdSalariesKFH.EMP_CODE

--1. KINLive

 -- DROP TABLE #RvdSalariesKIN
 IF OBJECT_ID('tempdb..#RvdSalariesKIN') IS NOT NULL
       drop table #RvdSalariesKIN
SELECT [EMP_CODE],BasicSalaryAgg = SUM(Total)
into #RvdSalariesKIN
FROM(
       SELECT [EMP_CODE]
                ,[EMP_SURNAME]
                ,[Initials]
                ,[EPT_CODE]
                ,Total =  sum([Gross])
         FROM PAY_5d0ea206cd724ec88e2d035577fd8291_KINLive.[dbo].[udef_CommAnalysisByPos_db_view]
         WHERE TaxYear = @taxYear
         and TaxPeriod = @taxPeriod
              and EMP_CODE IN ( SELECT DISTINCT([Additional EmployeeKey (Payroll Number)]) FROM #LatestData )-- where [Additional EmployeeKey (Payroll Number) ] = 314466
         and EPT_CODE IN( SELECT DISTINCT [EMP_CODE_DESC] FROM PAY_5d0ea206cd724ec88e2d035577fd8291_KINLive.[dbo].[EMP_COMMISSION_CODES])
              --emp_Code
              --and 
       group  by EMP_CODE,EMP_SURNAME,[Initials],[EPT_CODE]
)src
group by [EMP_CODE]

  
-- update 
        UPDATE #LatestData SET [Salary (Current Basic Pay Amount)] = #RvdSalariesKIN.BasicSalaryAgg
              FROM #LatestData
              INNER JOIN #RvdSalariesKIN ON #LatestData.[Additional EmployeeKey (Payroll Number)]= #RvdSalariesKIN.EMP_CODE

/*****************       Aggegated Section Over      **************************/





-- 3 -- Amend Captured Data:

    
	-- Update the Basic Pay and Qualified Earning by 12 -- Confirm 

	UPDATE #LatestData SET [Salary (Current Basic Pay Amount)] = ([Salary (Current Basic Pay Amount)]*12),
                                         [Qualifying Earnings] = ([Qualifying Earnings]*12)        
    FROM #LatestData


	-- Earnings Updated:
              UPDATE #LatestData SET [Qualifying Earnings] = 1
              FROM #LatestData WHERE [Qualifying Earnings] = 0

 
    -- AE Status
              UPDATE #LatestData SET  [AE Status] = 'NEW' 
              FROM #LatestData 
              WHERE [AE Status] = 'Unknown' OR [AE Status] IS NULL

              UPDATE #LatestData SET  [Non Sal Sacr]  = '' 
              FROM #LatestData 
              WHERE [Non Sal Sacr]  IS NULL 

              UPDATE #LatestData SET  [OTE]  = '' 
              FROM #LatestData 
              WHERE [OTE]  IS NULL

              UPDATE #LatestData SET  [AE Pension Member]  = '' 
              FROM #LatestData 
              WHERE [AE Pension Member]   IS NULL

              UPDATE #LatestData SET   [Leave date (End Date)] = '' 
              FROM #LatestData 
              WHERE [Leave date (End Date)]  IS NULL


              UPDATE #LatestData SET [OTE]  = '' 
              FROM #LatestData 
              WHERE [OTE] IS NULL


              UPDATE #LatestData SET [NICate ry (NI Letter)]  = '' 
              FROM #LatestData 
              WHERE [NICate ry (NI Letter)]  IS NULL


              UPDATE #LatestData SET [Costcentre (Location Code)]  = '' 
              FROM #LatestData 
              WHERE [Costcentre (Location Code)] IS NULL

              UPDATE #LatestData SET [Probation passed date (Pr Review Date)]  = '' 
              FROM #LatestData 
              WHERE [Probation passed date (Pr Review Date)] IS NULL


              UPDATE #LatestData SET [WorkPostcode (Orgn.Locns.Post Code)]  = '' 
              FROM #LatestData 
              WHERE [WorkPostcode (Orgn.Locns.Post Code)]  IS NULL

  
              UPDATE #LatestData SET [Holidayhours]  = '' 
              FROM #LatestData 

  
              UPDATE #LatestData SET [NINumber (NI Number)]  = '' 
              FROM #LatestData 
              WHERE [NINumber (NI Number)] IS NULL

              UPDATE #LatestData SET OTE = '' 
              FROM #LatestData
              where OTE = 'To Be Defined'

              UPDATE #LatestData SET [Email Address (E-mail)] = 'test@test.com<mailto:test@test.com'
              from #LatestData
              where [Email Address (E-mail)] = ''

 -- Set OTE Value:

               UPDATE #LatestData SET  OTE = ''
              FROM #LatestData 
              WHERE  [ContractType (Snapshot Status)] = 'Zero Hours contract' 
                     or [Salary (Current Basic Pay Amount)] < 12500


			  UPDATE #LatestData SET  OTE = 'B'
              FROM #LatestData 
              WHERE [Salary (Current Basic Pay Amount)] > 30000



			      UPDATE #LatestData SET  OTE = 'B'
              FROM #LatestData 
              WHERE  [Jobtitle (Post Name)]in(
                                                                     'Chartered Surveyor',
                                                                     'Commercial Chartered Surveyor',
                                                                     'Land & New Homes Assistant Manager',
                                                                     'Lettings Assistant Manager',
                                                                     'New Business Account Manager',
                                                                     'Sales Assistant Manager',
                                                                     'Sales Manager',
                                                                     'Senior Relocation Account Manager'
                                                              )


             
      -- 
	              UPDATE #LatestData SET  OTE = 'A'
                     FROM #LatestData 
                     WHERE  [Jobtitle (Post Name)]in(
                                  'Accounts Administrator',
                                  'Accounts Assistant',
                                  'Administrator',
                                  'Administrator-KN',
                                  'Assistant Property Manager',
                                  'Branch Administrator',
                                  'Change of Sharer Administrator',
                                  'Change of Sharer Ne tiator',
                                  'Client Accounts Assistant',
                                  'Client Services Consultant',
                                  'Commercial Administrator',
                                  'Credit Control Administrator',
                                  'Customer Services Coordinator',
                                  'Design & Production Executive',
                                  'Facilities and Fleet Systems Supervisor',
                                  'Facilities Coordinator',
                                  'Finance Graduate',
                                  'Fleet Coordinator',
                                  'General Practice Administrator',
                                  'Graduate Surveyor',
                                   'Group Insurance Claims Handler',
                                  'HR Administrator',
                                  'Insurance & Subletting Administrator',
                                  'IT Helpdesk Support',
                                  'IT Support Analyst',
                                  'Junior Fleet Administrator',
                                  'Land & New Homes Ne tiator',
                                  'Learning and Development Coordinator'
                                  ,'Lettings Administrator'
                                  ,'Lettings Ne tiator'
                                  ,'Lettings Senior Ne tiator'
                                  ,'LNH Divisional Administrator'
                                  ,'Marketing Coordinator'
                                  ,'Operations Administrator'
                                  ,'PR and Content Executive'
                                  ,'Property Assistant'
                                  ,'Property Assistant (S)'
                                  ,'Property Assistant*'
                                  ,'Property Inspector'
                                  ,'Property Management Administrator'
                                  ,'Property Manager'
                                  ,'Property Risk Analyst'
                                  ,'Purchase Ledger Clerk'
                                  ,'Receptionist'
                                  ,'Renewals Administrator'
                                  ,'Renewals Ne tiator'
                                  ,'Resourcing Specialist'
                                  ,'Sales Administrator'
                                  ,'Sales Ledger Clerk'
                                  ,'Sales Ne tiator'
                                  ,'Senior Client Services Consultant'
                                  ,'Senior Facilities Administrator'
                                  ,'Senior Renewals Ne tiator'
                                  ,'Site Sales Ne tiator'
                                  ,'Team Administrator'
                                  ,'Trainee Account Manager'
                                  ,'Trainee Accountant'
                                  ,'Trainee Commercial Agent'
                                  ,'Treasury Clerk'
                                  ,'Second Line Support Engineer'
       ,'Talent Acquisition Partner'
       ,'Fleet Administrator'
       ,'Talent Development Co-ordinator'
       ,'Payroll Co-Ordinator'
       ,'Facilities Administrator'
       ,'Talent Acquisition Coordinator'
       ,'Client Accountant'
       ,'Service Charge Controller'
                                  )


	
/*
    4    Final Reporting Data 
*/


       select * from #LatestData

	END
