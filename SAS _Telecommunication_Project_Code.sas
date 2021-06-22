
*TO TURN ON MACRO PROCESSOR;
PROC OPTIONS OPTION = MACRO;
RUN;

*To Access format from Permanent Library;
Options fmtsearch=(Homework);


TITLE " IMPORTING CRM DATA SET ";

Data SHAHINA.P;
infile 'C:\Users\shahe\Desktop\Adv.SAS\Project\New-Wireless-Fixed.txt' ;
input Acctno  1-13 
@15 Actdt mmddyy10. 
@26 Deactdt mmddyy10. 
Deactreason $ 41-44 
Goodcredit 53
Rateplan $ 62
Dealertype $ 65-66
Age  74-75 
Province $ 80-81
Sales  DOLLAR10.2 
;
format Acctno 13.0 Actdt date9. Deactdt date9. Sales DOLLAR10.2
;
RUN; 

proc print DATA = SHAHINA.P;
run;
TITLE;

*HEAD OF DATASET ;
proc print data = SHAHINA.P (OBS=5);
RUN;
* TAIL OF DATASET ;
proc print DATA = SHAHINA.P (OBS=102255 FIRSTOBS = 102251);
RUN;


*1.1 DESCRIPTIVE SUMMARY OF THE DATASET ;

TITLE " VIEWING DESCRIPTIVE SUMMARY OF DATA ";
PROC CONTENTS DATA = SHAHINA.P;
RUN;

* Descriptive Summary of Numerical Variables;
Proc means data = SHAHINA.P;
RUN;

proc means data=SHAHINA.P  N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
run;
* Descriptive Summary of Categorical Variables;
PROC FREQ DATA = SHAHINA.P;
TABLE Deactreason Dealertype Province RatePlan;
run;
TITLE;

*REMOVING DUPLICATES;
TITLE " REMOVING DUPLICATES ";
PROC SORT DATA = SHAHINA.P
OUT = SHAHINA.P_NO_DUPKEY NODUPKEY;
BY _ALL_;
RUN;
* Zero duplicates found as per the log ;
TITLE;

TITLE " COUNTING DIFFERENT TYPES OF ACCOUNTS";
* COUNTING THE NUMBER OF ACCOUNTS ;
PROC SQL;
SELECT COUNT(Acctno) AS TOTAL_No_Accounts,
		COUNT(DISTINCT Acctno) AS UNIQUE_Acctnumbers,
		COUNT(Deactdt) AS Total_No_Inactive_Accounts, 
		COUNT(Acctno)- COUNT(Deactdt) AS Total_Active_Accounts
	FROM SHAHINA.P
;
QUIT;
TITLE;

*TITLE "LATEST ACTIVATION DATE";
proc SQL OUTOBS=1;
SELECT * FROM SHAHINA.P
WHERE Actdt is not null
order by Actdt DESC;
QUIT;

*TITLE "EARLIEST ACTIVATION DATE";
proc SQL OUTOBS=1;
SELECT * FROM SHAHINA.P
WHERE Actdt is not null
order by Actdt ASC;
QUIT;


*CHECKING DISTINCT (LEVELS) OF DEACTREASON AND THEIR FREQUENCY;
PROC FREQ DATA = SHAHINA.P;
TABLE Deactreason;
run;


* SUBSETTING THE DATA TO INACTIVE & ACTIVE ACCOUNTS;
*DATA STEP FOR INACTIVE ACCOUNTS;
DATA SHAHINA.Inactive_Accounts;
 SET SHAHINA.P;
 WHERE Deactreason IN ("COMP","DEBT","MOVE","NEED","TECH");
 format Age age_segments. Goodcredit credit_report. sales sales_segments.;
 RUN;
 proc print data = SHAHINA.Inactive_Accounts;
 run;

*DATA STEP FOR ACTIVE ACCOUNTS;
DATA SHAHINA.Active_Accounts (drop = Deactdt Deactreason);
	set SHAHINA.P;
	WHERE Deactreason = " ";
	format Age age_segments. Goodcredit credit_report. sales sales_segments.;
	run;
Proc print data = SHAHINA.Active_Accounts;
run;

*UNIVARIATE ANALYSIS OF EACH NUMERICAL VARIABLE;
Proc means data=SHAHINA.P MAXDEC =2  n NMISS MIN MEAN STD CV MAX Q1 MEDIAN Q3 ;
Run;

*UNIVARIATE ANALYSIS OF EACH CATEGORICAL VARIABLE;
PROC FREQ DATA = SHAHINA.P;
table Deactreason Dealertype Rateplan Province Goodcredit;
run;


* 1.2  What is the age and province distributions of active and deactivated customers?;


Title " Province & Age Distribution for Inactive Accounts";
proc freq data= SHAHINA.Inactive_Accounts;
  table Province*Age / NOROW NOCOL;
run;
Title;

Title " Province & Age Distribution for Active Accounts";
proc freq data= SHAHINA.Active_Accounts;
  table Province * Age / NOROW NOCOL ;
run;
Title;
***************************************************************************;

Title " Province Distribution for Inactive Accounts";
proc freq data= SHAHINA.Inactive_Accounts;
  table Province;
run;
%UNI_ANALYSIS_CAT_FORMAT(SHAHINA.Inactive_Accounts,Province,$prov.);
Title;

Title " Province Distribution for Active Accounts";
proc freq data= SHAHINA.Active_Accounts;
  table Province;
run;
%UNI_ANALYSIS_CAT_FORMAT(SHAHINA.Active_Accounts,Province,$prov.);
Title;

%MACRO UNI_ANALYSIS_CAT_FORMAT(DATA,VAR,FORMAT);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
  FORMAT &VAR &FORMAT;
 RUN;

TITLE "THIS IS VERTICAL BARCHART OF &VAR FOR &DATA";
PROC SGPLOT DATA = &DATA;
 VBAR &VAR;
 FORMAT &VAR &FORMAT;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;

TITLE "THIS IS PIECHART OF &VAR FOR &DATA";
PROC GCHART DATA=&DATA;
  PIE3D &VAR/discrete 
             value=inside
             percent=outside
             EXPLODE=ALL
			 SLICE=OUTSIDE
			 RADIUS=20
		
;
  FORMAT &VAR &FORMAT;

RUN;
%MEND;


*1.3 Segment the customers based on age, province and sales amount:
Sales segment: < $100, $100---500, $500-$800, $800 and above.
Age segments: < 20, 21-40, 41-60, 60 and above.
Create analysis report ;

Options fmtsearch=(Homework);


*proc format LIBRARY.SHAHINA; 
proc format;
*Age segments: < 20, 21-40, 41-60, 60 and above;
value age_segments
	low-<20 = '<= 20'
     20-<41 = '20-40'
	41-<60 = '41-60'
	60 -high = 'SENIOR'
	;
*Province format ;
	value $prov
	"AB" = "Alberta"
	"BC" = "British Columbia"
	"NS" = "Nova Scotia"
	"ON" = "Ontario"
	"QC" = "Quebec"
	;
*Sales segment: < $100, $100---500, $500-$800, $800 and above.;
	value sales_segments
	low-<100 = '<100'
	100-<501 = '$100 - $500'
	501-<801 = '$501 - $ 800'
	801- high = '$800 +'
	;
*Good credit or bad segments;
	value credit_report
	 1 = 'Good Credit'
     0 = 'Bad Credit'
	 ;
*Segmentation of Tenure in days;
	value Tenure
	low-<30 = '<30 days' 
	30-<61 = '30 - 60 days'
	61-<366 = 'one year'
	366-high = 'over one year'
	;
run;

Proc print data = SHAHINA.P (obs=5);
FORMAT Age age_segments. Province $prov. Goodcredit credit_report. Sales sales_segments.;
run;

PROC FREQ DATA = SHAHINA.P;
 TABLE Age Province Sales Goodcredit;
 FORMAT Age age_segments. Province $prov. Sales sales_segments. Goodcredit credit_report.;
RUN;


* SEGMENTING THE DATASET BASED ON PROVINCE;
data Alberta_Customers
	 BritishColumbia_Customers
	 NovaScotia_Customers
	 Ontario_Customers
	 Quebec_Customers
     Province_missing;

set SHAHINA.P;
IF Province = "AB" THEN OUTPUT Alberta_Customers;
ELSE IF Province = "BC" THEN OUTPUT BritishColumbia_Customers;
ELSE IF Province = "NS" THEN OUTPUT NovaScotia_Customers;
ELSE IF Province = "ON" THEN OUTPUT Ontario_Customers;
ELSE IF Province = "QC" THEN OUTPUT Quebec_Customers;
ELSE OUTPUT Province_missing;
RUN;

PROC PRINT DATA = Alberta_Customers;
RUN;
PROC FREQ DATA = Alberta_Customers;
 TABLE Age Province Sales Goodcredit;
 FORMAT Age age_segments. Province $prov. Sales sales_segments. Goodcredit credit_report.;
RUN;

PROC FREQ DATA = BritishColumbia_Customers;
 TABLE Age Province Sales Goodcredit;
 FORMAT Age age_segments. Province $prov. Sales sales_segments. Goodcredit credit_report.;
RUN;

PROC FREQ DATA = NovaScotia_Customers;
 TABLE Age Province Sales Goodcredit;
 FORMAT Age age_segments. Province $prov. Sales sales_segments. Goodcredit credit_report.;
RUN;

PROC FREQ DATA = Ontario_Customers;
 TABLE Age Province Sales Goodcredit;
 FORMAT Age age_segments. Province $prov. Sales sales_segments. Goodcredit credit_report.;
RUN;

PROC FREQ DATA =  Quebec_Customers;
 TABLE Age Province Sales Goodcredit;
 FORMAT Age age_segments. Province $prov. Sales sales_segments. Goodcredit credit_report.;
RUN;


*1.4.Statistical Analysis:;
*1) Calculate the tenure in days for each account and give its simple statistics.;

*2) Calculate the number of accounts deactivated for each month.;
*3) Segment the account, first by account status “Active” and “Deactivated”, then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.;
*4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”;
*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?;
*6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?;

*1) Calculate the tenure in days for each account and give its simple statistics.;
data SHAHINA.Tenure_in_Days;
	set Shahina.P;
	If NOT MISSING (Deactdt) then Tenure_days=intck('day',Actdt,Deactdt); 
	else
	Tenure_days=intck('day',Actdt,"20JAN2021");
	format Tenure_days Tenure.
run;

Proc print data = SHAHINA.Tenure_in_Days;
run;

Proc means data = SHAHINA.Tenure_in_Days;
run;

PROC FREQ DATA = SHAHINA.Tenure_in_Days;
 TABLE Tenure_days;
 run;

*2) Calculate the number of accounts deactivated for each month.;

data test1;
	set Shahina.Inactive_Accounts;
	Deact_Month = MONTH(Deactdt);
run;
PROC FREQ DATA = TEST1;
 TABLE Deact_Month;
 run;



*3) Segment the account, first by account status “Active” and “Deactivated”, then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment.;

* SUBSETTING THE DATA TO INACTIVE & ACTIVE ACCOUNTS;
*DATA STEP FOR INACTIVE ACCOUNTS;
DATA SHAHINA.Inactive_Accounts;
 SET SHAHINA.P;
 WHERE Deactreason IN ("COMP","DEBT","MOVE","NEED","TECH");
 RUN;
 proc print data = SHAHINA.Inactive_Accounts;
 run;

*DATA STEP FOR ACTIVE ACCOUNTS;
DATA SHAHINA.Active_Accounts (drop = Deactdt Deactreason);
	set SHAHINA.P;
	WHERE Deactreason = " ";
	run;
Proc print data = SHAHINA.Active_Accounts;
run;

* Segmenting Inactive accounts by Tenure ;

DATA SHAHINA.Tenure_Segment1;
 SET SHAHINA.Inactive_Accounts;
 Tenure_days=intck('day',Actdt,Deactdt);
 format Tenure_days Tenure.;
 RUN;
  PROC FREQ DATA = SHAHINA.Tenure_Segment1;
 TABLE Tenure_Days ;
 run;

* Segmenting Active accounts by Tenure ; 
 Data SHAHINA.Tenure_Segment2;
 	set SHAHINA.Active_Accounts;
	Tenure_days=intck('day',Actdt,"20JAN2021"); 
	format Tenure_days Tenure.;
 RUN;
 PROC FREQ DATA = SHAHINA.Tenure_Segment2;
 TABLE Tenure_Days;
 run;

*4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”;

 *Ho : No relation between Tenure segments and "Goodcredit";
Data A;
	set SHAHINA.Tenure_in_Days ;
	format Goodcredit credit_report. Tenure_days Tenure.;
run;

PROC CORR DATA = A;
 VAR Tenure_days Goodcredit;
RUN;*co-relation <0.0001, so, Null hypothesis is False. we reject the null hypothsis.;

%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN &VAR1 AND &VAR2";
 TABLE &VAR1. * &VAR2 /CHISQ OUT=OUT_&VAR1._&VAR2 ;
Title;
RUN;
%MEND CHSQUARE;

*Ho : No relation between Dealertype and RatePlan;
%CHSQUARE(DSN = shahina.p , VAR1= Dealertype, VAR2 =Rateplan); 
*Chisquare <0.001 that means strongly corelated. Null hypothesis is false.;


*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?;

	data SHAHINA.account_status;
		Set SHAHINA.P;
		if Deactdt =" " then AcctStatus = 'Active   ';
		else                 
		AcctStatus = 'Inactive';
		if Deactdt =" " then Tenure_days=intck('day',Actdt,Deactdt);
		else                 
		Tenure_days=intck('day',Actdt,"20JAN2021");
		format Age age_segments. Goodcredit credit_report. sales sales_segments. Tenure_days Tenure.;
run;

*Test for normality;
proc univariate data=SHAHINA.account_status1 normal;
class AcctStatus;
var Tenure_days;
run;

*Test for equality of variances;
*Levene’s Test for Homogeneity of Variances;
proc glm data=SHAHINA.account_status1;
class AcctStatus;
model Tenure_days = AcctStatus;
means AcctStatus / hovtest=levene(type=abs) welch;
run;



*6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?;

	data SHAHINA.account_status;
		Set SHAHINA.P;
		IF Deactdt =" " then AcctStatus = 'Active';
		else AcctStatus = 'Inactive';
		If Deactdt =" " then Tenure_days=intck('day',Actdt,Deactdt);
		else Tenure_days=intck('day',Actdt,"20JAN2021");
 		format Age age_segments. Goodcredit credit_report. sales sales_segments. Tenure_days Tenure.; 
	run;


	proc tabulate data=SHAHINA.account_status;
	TITLE "Table for Change in Sale amount with Account Status, Age Segments 
                                        and their CreditReportStatus.";
   class AcctStatus Goodcredit Age;
   var Sales;
   table AcctStatus*Goodcredit, Age*Sales /
         rts=20;
run;
Title;


*UNIVARIATE (CATEGORICAL):;

 *Macro for Categorical with format;

 %MACRO UNI_ANALYSIS_CAT_FORMAT(DATA,VAR,FORMAT);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
  FORMAT &VAR &FORMAT;
 RUN;

TITLE "THIS IS VERTICAL BARCHART OF &VAR FOR &DATA";
PROC SGPLOT DATA = &DATA;
 VBAR &VAR;
 FORMAT &VAR &FORMAT;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;

TITLE "THIS IS PIECHART OF &VAR FOR &DATA";
PROC GCHART DATA=&DATA;
  PIE3D &VAR/discrete 
             value=inside
             percent=outside
             EXPLODE=ALL
			 SLICE=OUTSIDE
			 RADIUS=20
		
;
  FORMAT &VAR &FORMAT;

RUN;
%MEND;

%UNI_ANALYSIS_CAT_FORMAT(SHAHINA.P,Province,$prov.);


*Macro for Categorical without format;

%MACRO UNI_ANALYSIS_CAT(DATA,VAR);
 TITLE "THIS IS FREQUENCY OF &VAR FOR &DATA";
  PROC FREQ DATA=&DATA;
  TABLE &VAR;
 RUN;

TITLE "THIS IS VERTICAL BARCHART OF &VAR FOR &DATA";
PROC SGPLOT DATA = &DATA;
 VBAR &VAR;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=TAN
     ;
 RUN;

TITLE "THIS IS PIECHART OF &VAR FOR &DATA";
PROC GCHART DATA=&DATA;
  PIE3D &VAR/discrete 
             value=inside
             percent=outside
             EXPLODE=ALL
			 SLICE=OUTSIDE
			 RADIUS=20
		
;

RUN;
%MEND;

%UNI_ANALYSIS_CAT_FORMAT(SHAHINA.P,DealerType);
%UNI_ANALYSIS_CAT_FORMAT(SHAHINA.P,Deactreason);
%UNI_ANALYSIS_CAT_FORMAT(SHAHINA.P,Rateplan);

*CONTINOUSE DATA : ;
%MACRO UNI_ANALYSIS_NUM(DATA,VAR);
 TITLE "THIS IS HISTOGRAM FOR &VAR";
 PROC SGPLOT DATA=&DATA;
  HISTOGRAM &VAR;
  DENSITY &VAR;
  DENSITY &VAR/type=kernel ;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=LIGHTGREY
     ;
  keylegend / location=inside position=topright;
 RUN;
 QUIT;
 TITLE "THIS IS HORIZONTAL BOXPLOT FOR &VAR";
 PROC SGPLOT DATA=&DATA;
  HBOX &VAR;
    STYLEATTRS 
    BACKCOLOR=DARKGREY 
    WALLCOLOR=LIGHTPINK
     ;
 RUN;
TITLE "THIS IS UNIVARIATE ANALYSIS FOR &VAR IN &DATA";
proc means data=&DATA  N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
var &var;
run;
%MEND;

%UNI_ANALYSIS_NUM(SHAHINA.P,Age);
%UNI_ANALYSIS_NUM(SHAHINA.P,Sales);
%UNI_ANALYSIS_NUM(SHAHINA.P,Goodcredit);

*BIVARIATE ANALYSIS;

 /*
Bivariate Analysis:

  Continouse Vs. Continouse   : For Visulaization scatter plot,...
                                For test of independence: pearson correlation or spearman or  ...
            
  Categorical Vs. Categorical : For summaraization: contingency table (two-way table)
                                For visualization :stacked bar chart,Grouped bar chart,...
                                For test of independence:chi-square test
  Continouse Vs. Categorical  : For summaraization:gropup by categorical column an aggragte for numerical column
                                For visualization: Grouped box plot,...
                                For test of independence :1) if categorical column has only two levels :t-test
                                                          2) if categorical column has more than two levels: ANOVA
*/

*CATEGORICAL VS. CATEGORICAL;

%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN &VAR1 AND &VAR2";
 TABLE &VAR1. * &VAR2 /CHISQ OUT=OUT_&VAR1._&VAR2 ;
Title;
RUN;
%MEND CHSQUARE;

%CHSQUARE(DSN = shahina.p , VAR1= Deactreason , VAR2 =Dealertype);

%CHSQUARE(DSN = shahina.p , VAR1= Province, VAR2 =Dealertype);

%CHSQUARE(DSN = shahina.p , VAR1= Dealertype, VAR2 =Rateplan);

*NUMERICAL VS. CATEGORICAL;

%MACRO BI_ANALYSIS_NUMs_CAT (DSN = ,CLASS= , VAR= );
%LET N = %SYSFUNC(COUNTW(&VAR));
%DO I = 1 %TO &N;
	%LET X = %SCAN(&VAR,&I);
	PROC MEANS DATA = &DSN. N NMISS MIN Q1 MEDIAN MEAN Q3 MAX qrange cv clm maxdec=2 ;
	TITLE " RELATION BETWEEN &X. AND &CLASS.";
	CLASS &CLASS. ;
	VAR &X.;
	OUTPUT OUT= OUT_&CLASS._&X. MIN =   MEAN=  STD = MAX = /AUTONAME ;
RUN;
%END;
%MEND BI_ANALYSIS_NUMs_CAT;

%BI_ANALYSIS_NUMs_CAT (DSN =SHAHINA.P ,CLASS=Province, VAR=Sales Goodcredit Age);

%BI_ANALYSIS_NUMs_CAT (DSN =SHAHINA.Tenure_Segment1 ,CLASS=Province, VAR=Tenure_days);

*NUMERICAL VS. NUMERICAL;


PROC CORR DATA = SHAHINA.P;
 VAR Sales Goodcredit;
RUN;

PROC CORR DATA = SHAHINA.P;
 VAR Age Sales ;
RUN;

*************************************************************************************************************;
*                   ROUGH WORK;
*************************************************************************************************************;
proc tabulate data=SHAHINA.Tenure_Segment1;
   class Province Rateplan Dealertype;
   var Sales;
   table Province*Rateplan, Dealertype*Sales /
         rts=20;
run;

	


proc tabulate data=SHAHINA.Tenure_Segment1;
   class Province Rateplan Dealertype;
   var Tenure_days;
   table Province*Rateplan, Dealertype*Tenure_days /
         rts=20;
run;

proc tabulate data=energy;
   class region division type;
   var expenditures;
   table region*division, type*expenditures /
         rts=20;
run;





*4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”;
%CHSQUARE(DSN = shahina.p , VAR1= Dealertype, VAR2 =Rateplan); *Chisquare <0.001 that means strongly corelated.


*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?;




*6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?;


proc tabulate data=SHAHINA.Active_Accounts;
   class region division type;
   var Sales Age;
   table region*division, type*expenditures /
         rts=20;
run;
	



































*FINDING NUMBER OF MISSING VALUES;

DATA MISSING ;
SET SHAHINA.P;
MISS_val = SUM(NMISS(Acctno,Actdt,Age,Deactdt,Sales));
NON_Miss = SUM(N(Acctno,Actdt,Age,Deactdt,Sales));
run;
proc print data = MISSING;
run;










*SUBSETTING THE DATASET TO MAKE IT EASIER TO HANDLE;
DATA SHAHINA.SUBSET1;
	Set SHAHINA.P (firstobs = 1 obs = 12781);
run;
DATA SHAHINA.SUBSET2;
	Set SHAHINA.P (firstobs = 12782 obs = 25563);
run;
DATA SHAHINA.SUBSET3;
	Set SHAHINA.P (firstobs = 25564 obs = 38345);
run;
DATA SHAHINA.SUBSET4;
	Set SHAHINA.P (firstobs = 38346 obs = 51127);
run;
DATA SHAHINA.SUBSET5;
	Set SHAHINA.P (firstobs = 51128 obs = 63909);
run;
DATA SHAHINA.SUBSET6;
	Set SHAHINA.P (firstobs = 63910 obs = 76691);
run;
DATA SHAHINA.SUBSET7;
	Set SHAHINA.P (firstobs = 76692 obs = 89473);
run;
DATA SHAHINA.SUBSET8;
	Set SHAHINA.P (firstobs = 89474 obs = 102255);
run;

*PRINTING THE SUBSETS;
PROC PRINT DATA = SHAHINA.SUBSET1;
RUN;
PROC PRINT DATA = SHAHINA.SUBSET2;
RUN;
PROC PRINT DATA = SHAHINA.SUBSET3;
RUN;
PROC PRINT DATA = SHAHINA.SUBSET4;
RUN;
PROC PRINT DATA = SHAHINA.SUBSET5;
RUN;
PROC PRINT DATA = SHAHINA.SUBSET6;
RUN;
PROC PRINT DATA = SHAHINA.SUBSET7;
RUN;
PROC PRINT DATA = SHAHINA.SUBSET8;
RUN;
*---------------------------------------------------;
*1.1  Explore and describe the dataset briefly. For example, is the acctno unique? What
is the number of accounts activated and deactivated? When is the earliest and
latest activation/deactivation dates available? And so on….;

proc contents data = SHAHINA.SUBSET1;
RUN;
proc print data = SHAHINA.SUBSET1 (OBS=5); * HEAD OF SUBSET1;
RUN;
proc print data = SHAHINA.SUBSET8 (firstobs = 102251 obs = 102255); * TAIL OF DATA;
RUN;
proc univariate data = SHAHINA.SUBSET1;
var Acctno Age ;
run;
Proc sql;
select count(Acctno) as total_accounts,count(Deactdt) as Accounts_Deactivated 
from SHAHINA.P;
Active_accounts = total_accounts - Accounts_Deactivated;
;
run;
Data Num_Accts;
	set SHAHINA.P;
	Total_Accounts = count(Acctno);
	Total_Deact_accounts = count(Deactdt);
	Total_Active_Acoounts = Total_Accounts - Total_Deact_accounts;
	run;
Proc print data = Num_Accts;
run;
data test1;
  set test;
  AccountsActive=total_accounts-Accounts_Deactivated;
  run;

DATA SHAHINA.SUBSET2;
	Set SHAHINA.P (firstobs = 51128 obs = 102255);
run;
*_______________________________________________________________________;


* TO FIND THE TOTAL NUMBER OF ACCOUNTS AND TOTAL NUMBER OF INACTIVE ACCOUNTS ;
Proc sql;
select count(Acctno) as total_accounts,count(Deactdt) as Accounts_Deactivated 
from SHAHINA.P
;
run; 


* TO FIND DISTINCT VALUES OF INACTIVE DEACTIVATION REASON AND THEIR FREQUENCIES;
Proc freq data = SHAHINA.P;
table Deactreason;

* UNIVARIATE ANALYSIS FOR CONTINOUS VARIABLES (MEAN,MEDIAN,MODE,QUARTILES);
proc univariate data = SHAHINA.P;
var Acctno Age ;
run;

Proc sql;
select count(Acctno) as total_accounts,count(Deactdt) as Accounts_Deactivated 
from SHAHINA.P
;
run;

data Active_accounts;
Active_accounts = 102255 - 19635;
run;
PROC PRINT DATA = Active_accounts;
run;



TITLE " REMOVING DUPLICATES ";
PROC SORT DATA = SHAHINA.P
OUT = SHAHINA.P_NO_DUPKEY NODUPKEY;
BY _ALL_;
RUN;
* Zero duplicates found as per the log ;


*Age segments: < 20, 21-40, 41-60, 60 and above;
proc format library = SHAHINA;
    value agegroup
	low-20 = '<= 20'
     21-40 = '21-40'
	41-59 = '41-59'
	60 -high = 'SENIOR'
	;
*Sales segment: < $100, $100---500, $500-$800, $800 and above.;
	value sales_segments
	low-99 = '<100'
	100-500 = '$100 - $500'
	501-800 = '$501 - $ 800'
	801- high = '$800 +'
	;
*Good credit or bad segments;
	value credit_report
	 1 = 'Good Credit'
     0 = 'Bad Credit'
	 ;
run;

* FINDING NUMBER OF MISSING VALUES;
DATA MISSING ;
SET SHAHINA.P;
MISS_val = SUM(NMISS(Acctno,Actdt,Age,Deactdt,Deactreason,Dealertype,Goodcredit,Province,RatePlan,Sales));
NON_Miss = SUM(N(Acctno,Actdt,Age,Deactdt,Deactreason,Dealertype,Goodcredit,Province,RatePlan,Sales));
run;
proc print data = MISSING;
run; 


DATA TEST_02;
SET test_;
TOTAL_SCORE1=SUM(T1+T2+T3+T4+T5);
TOTAL_SCORE2=SUM(T1,T2,T3,T4,T5);
TOTAL_TEST=N(T1,T2,T3,T4,T5);*Number of non_missing values;
MISS_TEST=NMISS(T1,T2,T3,T4,T5);*Number of  missing values;
RUN;
PROC PRINT DATA=TEST_02;
RUN;
