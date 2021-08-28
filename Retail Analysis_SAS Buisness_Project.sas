

PROC OPTIONS OPTION = MACRO;
RUN;

Options fmtsearch=(Homework);

PROC FORMAT;
	VALUE $Prov
	"AB" = "Alberta"
	"BC" = "British Columbia"
	"MB" = "Manitoba"
	"NB" = "New Brunswick"
	"NL" = "NewfoundLand & Labrador"
	"NS" = "Nova Scotia"
	"ON" = "Ontario"
	"QC" = "Quebec"
	"SK" = "Saskatchewan"
	"YT" = "Yukon"
	;
	VALUE Sales_Segments
	low-<500 = '<$500'
	500-high = '$500 +'
	;
	VALUE Sales_Segmentsv
	low-<500 = '<$500'
	500-<1000 = '<$1000'
	1000-<1500 = '<$1500'
	1500-<2000 = '<$2000'
	2000-<2500 = '<$2500'
	2500-<3000 = '<$3000'
	3000-high = '$3000+'
	;
	VALUE Quantity_Segments
	0-<15 = '<15'
	15-<31 = '15-30'
	31-<50 = '31-50'
	;
RUN;
***************************************************************************************************************;
* NOT USING LIBNAME AS I CREATED PERMANENT LIBRARY USING GUI;
***************************************************************************************************************;
*IMPORTING TRANSACTION HISTORY FILE;

PROC IMPORT OUT= test.E1
            DATAFILE= "C:\Users\shahe\Desktop\SASProject\MyProject
\6.Retail Sales Analysis\transactionhistoryforcurrentcustomers.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
GuessinGrows=10000;
	
RUN;

PROC CONTENTS DATA = TEST.E1;
RUN;
PROC PRINT DATA = TEST.E1;
RUN;

PROC FREQ DATA = TEST.E1;
TABLE SOURCE;
RUN;

PROC SQL;
DELETE FROM TEST.E1 WHERE SOURCE IN ('ADJUSTED','TAPEMACS');
QUIT;

PROC FREQ DATA = TEST.E1;
TABLE SOURCE;
RUN;

PROC FREQ DATA = TEST.E1;
TABLE Category;
RUN;

PROC SQL ;
DELETE FROM TEST.E1 WHERE CATEGORY IN ('Y','G','D','N');
QUIT;

PROC FREQ DATA = TEST.E1;
TABLE CATEGORY;
RUN;

TITLE " REMOVING DUPLICATES ";
PROC SORT DATA = TEST.E1
OUT = TEST.E1 NODUPKEY;
BY _ALL_;
RUN;
TITLE;



*FEATURE ENGINEERING, CREATING SALES AMOUNTs IN TRANSACTION HISTORY;

 DATA TEST.E1;
 	SET TEST.E1;
	Sales_amounts = 0;
	IF Category IN ('B','C','E','F','H','J','K','M','X','Z')then Sales_amounts = Price * Quantity ;
	
	ELSE                                                 	      Sales_amounts = Sales_amounts ;
RUN;

PROC SQL ;
DELETE FROM TEST.E1 WHERE Sales_amounts = 0;
QUIT;

DATA TEST.E2;
SET TEST.E1;
Order_Date=DATEPART(Order_Date);
	INFORMAT Category $4. Sales_amounts BEST32. Order_Date DATE9.;
  FORMAT Category $4. Sales_amounts BEST12. Order_Date DATE9.;
  DROP Price;
RUN;
*CHANGING THE VARIABLE CATEGORY LENGTH FROM 1 TO 4 ;
proc sql;
alter table TEST.E2
  modify Category char(4) ;
quit;

PROC CONTENTS DATA = TEST.E2;
RUN;

**********************************************************************************************************************************;
*IMPORTING EC90 FILE;
PROC IMPORT OUT=TEST.E3
            DATAFILE= "C:\Users\shahe\Desktop\SASProject\MyProject
\6.Retail Sales Analysis\ec90 data.csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
GuessinGrows=10000;
RUN;

PROC CONTENTS DATA = TEST.E3;
RUN;

PROC FREQ DATA = TEST.E3;
TABLE Prov;
RUN;

PROC SQL ;
DELETE FROM TEST.E3 WHERE Prov IN ('NT','NU','PE');
QUIT;
PROC CONTENTS DATA = TEST.E3;
RUN;


DATA TEST.E4;
	SET TEST.E3;
	RENAME Category_code=Category Customer_Number=Customer_ID Order_Number=Item_Code ;
	Sales_amounts=INPUT(Sales_amount,DOLLAR10.2);
    Province=PUT(Prov,$30.);
	informat Item_Description $55. Sales_amounts BEST32. Province $30.;
	format Item_Description $55. Sales_amounts BEST12. Province $30.;
	DROP Postal_Code Order_First_Time Item_Num ;
RUN;


PROC CONTENTS DATA = TEST.E4;
RUN;
DATA TEST.E4;
	SET TEST.E4;
	FORMAT Province Prov.;
	DROP Sales_amount Prov;
RUN;
* CHANGING THE VARIABLE LENGTH FROM 47 TO 55;
proc sql;
alter table TEST.E4
  modify Item_Description char(55) ;
quit;

PROC CONTENTS DATA = TEST.E4;
RUN;
********************************************************************;


PROC SORT DATA = TEST.E4
OUT = TEST.E4 NODUPKEY;
BY _ALL_;
RUN;
*13 ROWS WERE DELETED;

PROC CONTENTS DATA = TEST.E4;
RUN;
*******************************************************************************************************************************;
*INNER JOIN;
********************************************************************************************************************************;
 PROC SQL;
 CREATE TABLE TEST.E5 AS
 SELECT A.*,
 		B.*
 FROM TEST.E2 AS A INNER JOIN  TEST.E4 AS B
 ON A.Customer_ID = B.Customer_ID
 ;
 QUIT;

  PROC CONTENTS DATA=TEST.E5;
RUN;
  PROC PRINT DATA=TEST.E5(OBS=5);
RUN;

PROC FREQ DATA = TEST.E5;
TABLE Category;
run;
************************************************************************************;
* UNION;
***************************************************************************************;
PROC SQL;
	 CREATE TABLE TEST.E6 AS
	 SELECT * 
	 FROM TEST.E5
	 Outer Union Corr /*corr=Corresponding*/
	 SELECT *
	 FROM TEST.E4
	 ;
 QUIT;

  TITLE " REMOVING DUPLICATES ";
PROC SORT DATA = TEST.E6
OUT = TEST.E6 NODUPKEY;
BY _ALL_;
RUN;
TITLE;   

PROC PRINT DATA=TEST.E6 (OBS=5) ;
RUN;

PROC FREQ DATA = TEST.E6;
TABLE Category;
RUN;

PROC CONTENTS DATA = TEST.E6;
RUN;
*****************************************************************************************************************;
PROC CONTENTS DATA = TEST.E6 OUT = TEST.VAR_NAMES;
RUN;
PROC PRINT DATA = TEST.VAR_NAMES NOOBS;
VAR NAME;
WHERE TYPE = 1; * For displaying Numeric variables (Quantity,Customer_ID,Sales_amounts);
RUN;

PROC PRINT DATA = TEST.VAR_NAMES NOOBS;
VAR NAME;
WHERE TYPE = 2; * For displaying categorical variables(Category,City,Item_Code,Item_Description,Prov,Sales_amount,Source);
RUN;

*****************************************************************************************************************;
* CHECKING MISSING VALUES;

PROC MEANS DATA= TEST.E6 N NMISS MIN MEAN MEDIAN STD MAX MAXDEC=2;
RUN;
* 300 missing values in Sales amount;
 * 1271 missing values in Order_Date , which is 4%  , REPLACED WITH MEAN 18NOV2007.;


PROC FREQ DATA = TEST.E6;
 TABLE Category Province Source Item_Code City Item_Description;
 RUN;
* 0 missing values in Category are found.
* no missing in Prov, Source, Item code amd Item description.; 

PROC SGPLOT DATA = TEST.E6;
VBOX Sales_amounts;
RUN;
QUIT;

 *REPLACING MISSING VALUES IN NUMERIC COLUMNS;
 PROC STDIZE DATA = TEST.E6 OUT= TEST.E6 METHOD = MEDIAN REPONLY;
  VAR Sales_amounts;
RUN;

 PROC STDIZE DATA = TEST.E6 OUT= TEST.E6 METHOD = MEAN REPONLY;
  VAR  Order_Date;
RUN;


PROC MEANS DATA= TEST.E6 N NMISS MIN MEAN MEDIAN STD MAX MAXDEC=2;
RUN;



*******************************************************************************************************************;
*VISUALIZATION  UNIVARIATE ANALYSIS;

%MACRO UNI_ANALYSIS_CAT(DATA,VAR);
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
%UNI_ANALYSIS_CAT(TEST.E6,Source)

*UNIVARIATE ANALYSIS OF CATEGORICAL VARIABLES;

PROC FREQ DATA = TEST.E6;
 TABLE Category Province Source ;*Item_Code City Item_Description;
 RUN;

 PROC FREQ DATA = TEST.E6;
 TABLE City;
 RUN;

PROC SGPLOT DATA = TEST.E6;
 VBAR Category ;
RUN;
QUIT;

PROC SGPLOT DATA = TEST.E6;
 VBAR Province ;
RUN;
QUIT;

PROC SGPLOT DATA = TEST.E6;
 VBAR City ;
RUN;
QUIT;

*UNIVARIATE ANALYSIS OF NUMERICAL VARIABLES;
PROC UNIVARIATE DATA = TEST.E6 NORMAL;
VAR  Quantity Sales_amounts Order_Date;
HISTOGRAM/NORMAL;
RUN;


*SEGEMNTATION;
*CONVERTING NUMERICAL VARIABLES TO CATEGORICAL VARIABLES USING FORMAT;
DATA TEST.NEW_SALES_DATA;
 SET TEST.E6;
 format Sales_amounts Sales_Segments. Quantity Quantity_Segments.;
 RUN;


*BIVARIATE ANALYSIS;
*BIVARIATE ANALYSIS , DESCRIPTIVE SUMMARY BY CONTINGENCY TABLE;
TITLE "BIVARIATE DESCRIPTIVE ANALYSIS:Sales_amounts AND Quantity";
PROC FREQ DATA=TEST.NEW_SALES_DATA;
TABLE  Sales_amounts * Quantity /NOROW NOCOL;/* it gives us contingency table(two-way table) here rows=Sales_amounts  and columns=Quantity*/
RUN;
TITLE;

TITLE "BIVARIATE DESCRIPTIVE ANALYSIS:Sales_amounts AND Province";
PROC FREQ DATA=TEST.NEW_SALES_DATA ORDER=DATA;
TABLE  Sales_amounts * Province /NOROW NOCOL;/* it gives us contingency table(two-way table) here rows=Sales_amounts  and columns=Province*/
RUN;
TITLE;

TITLE "BIVARIATE DESCRIPTIVE ANALYSIS:Sales_amounts AND N_Category";
PROC FREQ DATA=TEST.NEW_SALES_DATA ;
TABLE  Sales_amounts * Category /NOROW NOCOL;/* it gives us contingency table(two-way table) here rows=Sales_amounts  and columns=Category*/
RUN;
TITLE;

TITLE "BIVARIATE DESCRIPTIVE ANALYSIS:Sales_amounts AND Source";
PROC FREQ DATA=TEST.NEW_SALES_DATA;
TABLE  Sales_amounts * Source /NOROW NOCOL;/* it gives us contingency table(two-way table) here rows=Sales_amounts  and columns=Source*/
RUN;
TITLE;

*CONTINOUS VS. CONTINOUS ;
* Y- SALES _AMOUNTS X-ORDER_DATE : PROC CORR;
PROC CORR DATA =TEST.E6 PEARSON SPEARMAN;
VAR Order_Date Sales_amounts;
run;

* CONTINOUS VS. CATEGORICAL ;
*Y- SALES_AMOUNTS X-CATEGORY :(ANOVA) Since more than 2 levels;

PROC ANOVA DATA = TEST.E6;
CLASS Category;
MODEL Sales_amounts  = Category;
MEANS Category/SCHEFFE;
RUN;

*Y- SALES_AMOUNTS X-Prov :(ANOVA) Since more than 2 levels;
PROC ANOVA DATA = TEST.E6;
CLASS Province;
MODEL Sales_amounts  = Province;
MEANS Province/SCHEFFE;
RUN;

*Y- SALES_AMOUNTS X-Source :(ANOVA) Since more than 2 levels;
PROC ANOVA DATA = TEST.E6;
CLASS Source;
MODEL Sales_amounts  = Source;
MEANS Source/SCHEFFE;
RUN;

*Y- SALES_AMOUNTS X-City :(ANOVA) Since more than 2 levels;
PROC ANOVA DATA = TEST.E6;
CLASS City;
MODEL Sales_amounts  = City;
MEANS City/SCHEFFE;
RUN;
********************************************************************************************;

*PROC TABULATE "TO CHECK SALES AMOUNT IN 2 WAY HIERARCHY";
PROC TABULATE DATA = TEST.E6 ;
	CLASS Source Province Category;
	VAR Sales_amounts;
	TABLE Category*Province, Source*Sales_amounts/
		RTS = 20;
RUN;

PROC SGPLOT DATA =TEST.E6;
 VBAR Province/GROUP =  Sales_amounts ;
RUN;
QUIT;

**********************************************************************************************;
*HYPOTHESIS TESTING FOR 2 X VARIABLES;
***********************************************************************************************;
*H0 : NO RELATION;
PROC OPTIONS OPTION = MACRO;
RUN;

%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN 2 CATEGORICAL VARIABLES";
 TABLE &VAR1. * &VAR2 /CHISQ OUT=OUT_&VAR1._&VAR2 ;
RUN;
%MEND CHSQUARE;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Province , VAR2 =Source);

*CHISQUARE < 0.0001 (O.O5 % SIGNIFICANCE LEVEL) REJECT NULL HYPOTHESIS;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Province , VAR2 =City);
*CHISQUARE < 0.0001 (O.O5 % SIGNIFICANCE LEVEL) REJECT NULL HYPOTHESIS;

TITLE;

************************************************************************************************;
*CHECKING THE Y-VARIABLE(SALES AMOUNT) IS NORMALLY DISTRIBUTION;
PROC UNIVARIATE DATA = TEST.E6 NORMAL;
 VAR Sales_amounts;
 HISTOGRAM/NORMAL;
RUN;
*IT IS NOT NORMALLY DISTRIBUTED;

*STANDARDIZING THE DATA;
PROC STANDARD DATA=TEST.E6 MEAN=0 STD=1 OUT=TEST.E7;
  VAR Sales_amounts Quantity ;
RUN;

PROC UNIVARIATE DATA = TEST.E7 NORMAL;
 VAR Sales_amounts Quantity;
 HISTOGRAM/NORMAL;
RUN;
*HYPOTHESIS TESTING ;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Sales_amounts , VAR2 = Province);*Chisquare  < 0.0001, REJECT NULL HYPOTHESIS;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Sales_amounts , VAR2 = Quantity);* Chisquare < 0.0001, REJECT NULL HYPOTHESIS;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Sales_amounts , VAR2 = Category); * Chisquare <0.0001, REJECT NULL HYPOTHESIS;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Sales_amounts , VAR2 = Item_Code);*Chisquare =1 > 0.05 FAIL TO REJECT NULL HYPOTHESIS;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Sales_amounts , VAR2 = Item_Description);* NO DATA IS DISPLAYED DUE TO HIGH VOLUME;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Sales_amounts , VAR2 = City); *Chisquare <0.0001, REJECT NULL HYPOTHESIS;

%CHSQUARE(DSN = TEST.NEW_SALES_DATA , VAR1= Source , VAR2 = Sales_amounts); *Chisquare <0.0001, REJECT NULL HYPOTHESIS;
TITLE;
PROC CORR DATA =TEST.E6 PEARSON SPEARMAN;
VAR Order_Date Sales_amounts;
run;
* p-value <0.05, REJECT NULL HYPOTHESIS;
PROC SGPLOT DATA = TEST.E6;
SCATTER X = Order_Date Y=Sales_amounts;
RUN;
QUIT;

*INFERENCE :
Sales_amounts shows STATISTICALLY SIGNIFICANT RELATION with Province, Source, Quantity, Category, City and Order_Date.;

DATA  TEST.NEW_SALES_DATA_01;
	SET TEST.NEW_SALES_DATA;
	FORMAT Sales_amounts Sales_Segmentsv.;
RUN;

*VISUALIZATION USING GROUPED BARPLOT;

TITLE "Sales amount by Province and Category";
proc sgplot data=TEST.NEW_SALES_DATA_01(where=(Category NOT IN ('EC90','M','Z')));
  vbar Province / response=Sales_amounts group=Category groupdisplay=cluster 
    stat=mean dataskin=gloss;
  xaxis display=(nolabel noticks);
  yaxis grid;
 run;
TITLE;

TITLE "Sales amount by Province and Quantity";
proc sgplot data=TEST.NEW_SALES_DATA_01;
  vbar Province / response=Sales_amounts group=Quantity groupdisplay=cluster 
    stat=mean dataskin=gloss;
  xaxis display=(nolabel noticks);
  yaxis grid;
run;
TITLE;


*BUCKET BINNING;

PROC HPBIN DATA = TEST.E6 OUTPUT = TEST.E8 ;
  INPUT Sales_amounts/NUMBIN=3;
  INPUT Category/NUMBIN=3;
RUN;

PROC CONTENTS DATA = TEST.E8;
RUN;

PROC PRINT DATA = TEST.E8;
RUN;
**********************************************************************************************************************;
*PREDICTIVE MODELLING;
*CHECKING THE Y-VARIABLE(SALES AMOUNT) IS NORMALLY DISTRIBUTION;
PROC UNIVARIATE DATA = TEST.E6 NORMAL;
 VAR Sales_amounts;
 HISTOGRAM/NORMAL;
RUN;
*IT IS NOT NORMALLY DISTRIBUTED;


*STANDARDIZING THE DATA;
PROC STANDARD DATA=TEST.E6 MEAN=0 STD=1 OUT=TEST.E7;
  VAR Sales_amounts Quantity ;
RUN;

PROC UNIVARIATE DATA = TEST.E7 NORMAL;
 VAR Sales_amounts Quantity;
 HISTOGRAM/NORMAL;
RUN;

*MODEL BUILDING;
ODS GRAPHICS ON;
PROC GLMSELECT DATA=TEST.E7 PLOTS=ALL;
	CLASS Province Source Category;
	MODEL Sales_amounts = Quantity Province Source Category Order_Date
							/ DETAILS = ALL STATS = ALL;
ODS GRAPHICS OFF;
******************************************************************************************************************************;
*SOLVING THE BUISNESS QUESTION;

TITLE " COUNTING TOTAL NUMBER OF ORDERS,UNIQUE CUSTOMERS AND TOTAL SALES AMOUNT";
* COUNTING THE NUMBER OF ORDERS,UNIQUE CUSTOMERS AND TOTAL SALES AMOUNT FROM JAN 2007 TO DEC 2008  ;
PROC SQL;
SELECT COUNT(Customer_ID) AS TOTAL_ORDERS,
		COUNT(DISTINCT Customer_ID) AS UNIQUE_CUSTOMERS,
		SUM(Sales_amounts) AS TOTAL_SALES_AMOUNT
FROM TEST.E6
;
QUIT;
TITLE;




*TOP 3 CUSTOMERS with MAX Sales Amount;
PROC SORT DATA = TEST.E6 OUT= TEST.SALES_DATA_TOP;
 BY DESCENDING Sales_amounts;
RUN;

PROC PRINT DATA = TEST.SALES_DATA_TOP;
RUN;

*TOP CUSTOMERS WITH MAX QUANTITY ORDERED ;
PROC SORT DATA = TEST.E6 OUT= TEST.SALES_DATA_MAXQUA;
 BY DESCENDING Quantity;
RUN;

PROC PRINT DATA = TEST.SALES_DATA_MAXQUA;
RUN;






PROC SQL;
SELECT Category, SUM(Sales_amounts) AS TOTAL_SALES_BY_CATEGORY, Count(Customer_ID) AS No_OF_ORDERS,
		SUM(QUANTITY) AS TOTAL_QUANTITY
FROM TEST.E6
WHERE Category IS NOT MISSING
GROUP BY Category
ORDER BY TOTAL_SALES_BY_CATEGORY DESC
;
QUIT;
*F-1st, EC90-2nd ARE THE CATEGORIES WITH HIGH SALES AMOUNT;
 
PROC SQL;
SELECT Source, SUM(Sales_amounts) AS TOTAL_SALES_BY_SOURCE
FROM TEST.E6
WHERE Source IS NOT MISSING
GROUP BY Source
ORDER BY TOTAL_SALES_BY_SOURCE DESC
;
QUIT;
*REGULAR-1st, WEB-2nd AND IVR-3rd ARE THE SOURCES WITH HIGH SALES AMOUNT.;

PROC SQL;
SELECT DISTINCT(Province), SUM(Sales_amounts) AS TOTAL_SALES_BY_PROVINCE,Count(Customer_ID) AS No_OF_ORDERS,
		SUM(QUANTITY) AS TOTAL_QUANTITY
FROM TEST.E6
WHERE Province IS NOT MISSING
GROUP BY Province
ORDER BY TOTAL_SALES_BY_PROVINCE DESC
;
QUIT;
* ONTATIO ,BC AND ALBERTA ARE THE PROVINCES WITH HIGH SALES AMOUNT.;

PROC SQL;
SELECT DISTINCT(Item_Description), SUM(Sales_amounts) AS TOTAL_SALES_BY_DESCRIPTION,Count(Customer_ID) AS No_OF_ORDERS,
		SUM(QUANTITY) AS TOTAL_QUANTITY
FROM TEST.E6
WHERE Province IS NOT MISSING
GROUP BY Province
ORDER BY TOTAL_SALES_BY_DESCRIPTION DESC
;
QUIT;

PROC SQL;
SELECT Item_Code, Item_Description, SUM(Sales_amounts) AS TOTAL_SALES_BY_Item_Code
FROM TEST.E6
WHERE Category IS NOT MISSING
GROUP BY Category
ORDER BY TOTAL_SALES_BY_Item_Code DESC
;
QUIT;


