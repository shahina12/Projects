###########################################################
#   Changing Directory
###########################################################
setwd("C:\\Users\\shahe\\Desktop\\R files\\FinalProject")
getwd()
###########################################################
# Installing the package to read .xlsx file
###########################################################
#install.packages("openxlsx")
library(openxlsx) # activating the library to use it

df1<-read.xlsx("life_Expectency.xlsx",sheet = "Life Expectancy Data", colNames = TRUE, startRow = 1 )

###########################################################
#UNDERSTANDING THE DATA
###########################################################
dim(df1)                       # Checking the shape of the Data set

head(df1,3)                      # Checking  the head of the Data set

tail(df1,3)                      # Checking the tail of the Data set

str(df1)                       # To visualize the structure of DATA 

colnames(df1)

# Changing column names which are not according to R standards.

colnames(df1)[c(12,16,19,20)]<-c("Under.five.deaths","HIV.AIDS","thinness.1_19.years","thinness.5_9.years")

#dropping features as we don't have any knowledge to extract meaning full features from them

df1[,c("thinness.1_19.years","thinness.5_9.years")]<-NULL

str(df1)

#How many duplicated data are there?
sum(duplicated((df1))) # gives total number of duplicate data values, NO DUPLICATES FOUND                   
#r1<-which(duplicated(df1)) # gives row numbers of duplicate values
#df1<-df1[-r1,]   # removing the rows with duplicate values.


levels(as.factor(df1$Country)) # give levels (different values) for column 'Country'
levels(as.factor(df1$Status))  # gives levels for column Status.
levels(as.factor(df1$Year))    # gives levels for column ' Year '

# HANDLING  MISSING VALUES

df1[df1==' ']<-NA              # assigning missing values with 'NA'

sum(is.na(df1))                # To get total number of missing values

colSums(is.na(df1))             # To get the number of missing values column wise

#Percentage of missing values:
round(colMeans(is.na(df1))*100,2)# '2' represents the no. of digits after decimal

sum(!complete.cases(df1))      # number of rows that have at least one missing values

colnames(df1)                  # To view the column names in the Data set

summary(df1)   # To Visualize the descriptive summary of DATA. gives descriptive statistics(min,max,Q1,Q3,mean,median) for numeric data 
               # & length,class and mode for categorical data.

############### Feature Engineering, Segmentation  #######################################
#Adding new column (categorical)

range(df1[,4],na.rm = T)# Getting range( min and max) for Life Expectancy of the entire population

df1$lifeExp.agegroup<-NA
df1

f1=function(x){
  if (is.na(x)) "N/A"  
  else if (x<25)    "< 25"
  else if (x<= 35) "25-35" 
  else if (x<= 45) "36-45" 
  else if (x<= 55) "46-55"
  else if (x<= 65) "56-65"
  else if (x<= 75) "66-75"
  else if (x<= 85) "76-85"
  else if (x<= 95) "86-95"
  else              "95+"
}
# applying the function to 'life expectancy' column using 'sapply'
df1$lifeExp.agegroup<-sapply(df1$Life.expectancy ,f1) 
df1

# Adding Another Categorical column to the Data Set

df1$Year.groups<-NA
str(df1)

f2=function(x)  {
  if (x>=2000 && x<=2003) "2000-2003"
   else if (x >= 2004 && x <= 2007) "2004=2007" 
    else if (x >= 2008 && x <= 2011) "2008-2011" 
     else if (x >= 2012 && x <= 2015) "2012-2015" 
}

df1$Year.groups<-sapply(df1$Year,f2) 
str(df1)
df1
# SINCE IT IS A BIG DATA SET , IAM SEGMENTING IT INTO TWO PARTS 'DEVELOPING' AND 'DEVELOPED'

dim(df1)

sum(with(df1,Status == "Developing"))  #  Total number of observations with status ' Developing'
developing<-subset(df1, Status == "Developing")  # Extracting the Data of "Developing" countries
df2<-developing

summary(df2)                       # To view the Summary of only Developing Countries



sum(with(df1,Status == "Developed"))
developed<-subset(df1, Status == "Developed")  # Extracting the Data of "Developed" countries
df3<-developed

summary(df3)


############################################################################
#UNIVARIATE ANALYSIS FOR CATEGORICAL VARIABLES
############################################################################

df_org1<-df1                   # making a copy of the Data Set

#1.SUMMARIZING Categorical Variables
sum(is.na(df1$Country)) # No missing values found.

levels(as.factor(df1$Country)) # give levels (different values) for column 'Country'
                               # shows Names of 193 countries
tb1<-table(df1$Country) #Viewing the frequency of each 'Country' which should be 16 for all countries 
tb1                     #as we are considering data for 16 years.
                        # But, found frequency of '1' for few (10) countries. 

r1 <- which(tb1 == '1') # Finding row numbers whose frequency is '1'.
r1
df1[df1$Country == 'Cook Islands',] # row no.625
df1[df1$Country == 'Dominica',] # row no.770
df1[df1$Country == 'Marshall Islands',] # row no.1651
df1[df1$Country == 'Monaco',]            # row no.1716
df1[df1$Country == 'Nauru',]    # row no.1813 
df1[df1$Country == 'Niue',]   ## row no.1910
df1[df1$Country == 'Palau',]  # row no.1959
df1[df1$Country == 'Saint Kitts and Nevis',] # row no.2168
df1[df1$Country == 'San Marino',] # row no.2217
df1[df1$Country == 'Tuvalu',] # row no.2714

# Dropping the Rows with frequency '1'.

df1<-df1[-c(625,770,1651,1716,1813,1910,1959,2168,2217,2714), ]  

levels(as.factor(df1$Country))
tb1<-table(df1$Country)
tb1

# UNIVARIATE ANALYSIS FOR CATEGORICAL VARIABLE 'STATUS'

levels(as.factor(df1$Status))  # gives 2 levels for column Status.
                               # shows "Developed" "Developing"

tb2<-table(df1$Status)    #Viewing the frequency of each level of 'Status'
tb2

# To view the levels and frequency      
levels(as.factor(developing$Country))  # names of 161  developing countries found

tb3<-table(developing$Country)
tb3

levels(as.factor(developed$Country))  # names of 32 developed countries found

tb4<-table(developed$Country) 
tb4


#2.VISUALIZING CATEGORICAL VARIABLES by PIE Chart
par(mfrow = c(1,1))

freq1 <- c(161,32)
pct <- round(freq1/sum(freq1)*100)
lbls <- c("Developing", "Developed")
lbls <- paste(lbls, pct) # add percents to labels
lbls <- paste(lbls,"%",sep="") # ad % to labels
pie(pct,labels = lbls, col=rainbow(length(lbls)),#length(lbls) = 5
    main="Pie Chart for Status of Countries")

barplot(tb2,xlab="Status of Country",ylab="Frequency", main="Bar chart for Status of Countries") # Barplot for the 'Status' which is clear


barplot(tb1,xlab="Country") # Barplot for all countries 
paste(sum(with(df1,Status == "Developed")),sum(with(df1,Status == "Developing")))
barplot(tb3,xlab="Developing Country")  # Barplot for developing (161) Countries
barplot(tb4,xlab="Developed Country")   # Barplot for developed (32) countries.

#UNIVARIATE ANALYSIS FOR lifeExp.agegroup categorical VARIABLES

levels(as.factor(df1$lifeExp.agegroup))  # 6 levels are retured
tb5<-table(df1$lifeExp.agegroup)         # frequency of life expectancy of each agegroup
tb5

# 2.VISUALIZATION BY BARCHART
tblag<-table(df1$lifeExp.agegroup)
tblag
barplot(tblag,ylab="lifeExp.agegroup",horiz=T)
barplot(tblag,xlab="LifeExp.agegroup")


# VISUALIZATION BY PIE CHART
par(mfrow = c(1, 1))

freq1 <- c(19,296,549,1240,779,45)
pct <- round(freq1/sum(freq1)*100)
lbls <- c("36-45","46-55","56-65","66-75","76-85","86-95")
lbls <- paste(lbls, pct) # add percents to labels
lbls <- paste(lbls,"%",sep="") # ad % to labels
pie(pct,labels = lbls, col=rainbow(length(lbls)),#length(lbls) = 5
    main="Pie Chart for Life.Expectancy Age Groups")

#UNIVARIATE ANALYSIS FOR Year.groups categorical VARIABLES

levels(as.factor(df1$Year.groups))  # 4 levels are retured
tb6<-table(df1$Year.groups)         # frequency of Years in each group of 4 years.
tb6

# 2.VISUALIZATION BY BARCHART
par(mfrow = c(1, 1))
tblag1<-table(df1$Year.groups)
tblag1
barplot(tblag1,ylab="Year.groups",horiz=T)
barplot(tblag1,xlab="Year.groups")
############################################################################
#UNIVARIATE ANALYSIS FOR NUMERICAL VARIABLES
############################################################################
str(df1)
dataset<-df1[,-c(1,3,21)]         # Removing categorical variables i.e., column 1, 3 and 21.
str(dataset)

summary(dataset)   # Five number summary (Min,Median,Max,25th,75th percentile and Mean) of all numeric variables. 

apply(dataset,2,mean,na.rm=TRUE) # Checking the mean of each  numeric variable
apply(dataset,2,quantile,na.rm=T) # gives quartiles of each   numeric variable

#sappply(dataset,mean,na.rm=TRUE)
                        
dataset1<-df1[ , c(4,5,6,7)] # selected Numerical columns
summary(dataset1)
par(mfrow = c(1, 1))
#excluding missing values finding the Standarad Devaition  of various  Numeric variables.
colnames(dataset)

sd(df1$Life.expectancy, na.rm = TRUE)
sd(df1$Adult.Mortality, na.rm = TRUE)
sd(df1$infant.deaths, na.rm = TRUE)
sd(df1$Alcohol, na.rm = TRUE)
sd(df1$Schooling, na.rm = TRUE)
sd(df1$percentage.expenditure, na.rm = TRUE)

# 1. Problem : What is the distribution of Target (Numerical) variable
# Answer : By seeing the Histogram we can say that it is Normal with positive Kurtosis.
hist(df1$Life.expectancy,br=14,col="pink",xlab="Age",ylab="Frequency",
     freq=TRUE,main="Histogram of Life.Expectancy")  


# Visualizing Numerical Variables by HISTOGRAM

par(mfrow = c(2, 2))

hist(df1$Adult.Mortality,br=14,col="pink",xlab="No. of Adult Deaths",ylab="Frequency",
     freq=TRUE,main="Histogram of Adult.Mortality")        # Right Skewed.

hist(df1$infant.deaths,br=14,col="pink",xlab="No. of infant Deaths",ylab="Frequency", # Right skewed 
     freq=TRUE,main="Histogram of infant.deaths")

hist(df1$percentage.expenditure,br=14,col="pink",xlab="Percentage Expenditure",ylab="Frequency", # Right skewed
     freq=TRUE,main="Histogram of percentage.expenditure")

par(mfrow = c(1, 2))

boxplot(df1$Life.expectancy,
        main=" boxplots for Life Expectancy",
        xlab="Age",
        col="orange",
        border="brown",
        horizontal = TRUE
)
boxplot(df1$Adult.Mortality,
        main=" boxplots for Adult Mortality",
        xlab="No. Of Adult Deaths",
        col="orange",
        border="brown",
        horizontal = TRUE
)

str(df1)


#extracting complete rows
#df1[complete.cases(df1),]

#extract the rows with missing data
#df1[!complete.cases(df1),]


#####################################################################################################
#BIVARIATE ANALYSIS  ###  CATEGORICAL VS. CATEGORICAL
#####################################################################################################

#SUMMARIZING  USING CONTINGENCY TABLE

##2. Problem: is there any relationship between 'lifeExp.agegroup' and 'Status' of the country in this data set

# returns Contingency table(two-way table) with their column names
tbl_ag_S<-xtabs(~ lifeExp.agegroup + Status, data=df1)
tbl_ag_S

tbl_ag_S.t<-t(tbl_ag_S)   # transpose tbl_ag_S
tbl_ag_S.t

# stacked bar plot
par(mfrow = c(1, 1))
barplot(tbl_ag_S.t, main="Life Expectancy age group vs. status",
        xlab="age group", col=c("red","darkblue"),   legend = rownames(tbl_ag_S.t)
        )


# Checking for the relationship 
#library(MASS) It is built-in for R version 4.0.4 which I am currently using

#Chi-Square test is a statistical method which used to determine if 
#two categorical variables have a significant correlation between them.

# HO : NO RELATION BETWEEN 'lifeExp.agegroup' and 'Status'

#Testing the hypothesis whether 'lifeExp.agegroup' is independent of the 'status' at .05 significance level.
## if condition of chi-square are satisfied and p-value is less than significant level(5% here)
#we will reject null hypotheses and  conclude that there is a relationship between them at 5% significant level
tbl_ag_S
chisq.test(tbl_ag_S)

# since p-value is 2.2e-16(0.000000000000000022), p- value should be between 0 and 1),
#which is less than .05 significance level, NULL Hypothesis is false, we reject NULL Hypothesis.

#INTERPRETATION : There is a relationship between 'lifeExp.agegroup' and 'status'

install.packages("vcd")
library(vcd)

#Mosaic plots provide a way to visualize contingency tables.
#A mosaic plot is a visual representation of the association between two variables.
mosaic(tbl_ag_S, shade=TRUE, legend=TRUE)

# or
#Association Plots
assoc(tbl_ag_S, shade=TRUE)


prop.table(table(df1$lifeExp.agegroup, df1$Status))#calculates  probability of frequency

#####################################################################################################
#BIVARIATE ANALYSIS   ###   NUMERICAL VS.  CATEGORICAL
#####################################################################################################
# Problem: 3. Is the mean of groups of Status for 'life.Expectancy  is Statistical Different 
# 3. CHECKING Relationship(independence) USING T-TEST (for 2 levels)OR ANOVA( more than 2 levels)
# Ho : The mean of 2 groups is equal
t.test(Life.expectancy~Status, data = df1, alternative = "less")

# Mean of 2 groups is statistically different from each other.
# The NULL hypothesis is False .
# The 2 groups are independent since p-value is > 0.05 there is no association between them.


# 1.SUMMARIZING USING AGGREGATE FUNCTION OR tapply

# group by 'status' checking the Mean of 'Life expectancy'
tbba1<-aggregate(Life.expectancy~Status, data=df1, FUN=mean)  
tbba1
tbba2<-aggregate(Adult.Mortality~Status, data=df1, FUN=mean)
tbba2
tbba3<-aggregate(Life.expectancy~Country, data=df1, FUN=mean)
tbba3

tbba4<-aggregate(Life.expectancy~Year.groups, data=df1, FUN=mean)
tbba4

# 2. VISUALIZING USING GROUP BOX PLOT

boxplot(Life.expectancy~Status,
        data=df1,
        main="Different boxplots for Different Country type",
        xlab="Country Status",
        ylab="Life.expectancy",
        col="orange",
        border="brown"
)

# t-test
t.test(Life.expectancy~Status, data = df1, alternative = "greater")



# Probelm : 4 . Is there any relation between 'life.Expectancy' and 'Year.groups'
# we need to run ANOVA test we have more than 2 levels in categorical variable.
#SUMMARIZING
tbba4<-aggregate(Life.expectancy~Year.groups, data=df1, FUN=mean)
tbba4
#VISUALIZING
boxplot(Life.expectancy~Year.groups,
        data=df1,
        main="Different boxplots for Year groups",
        xlab="Time Period",
        ylab="Life.expectancy",
        col="orange",
        border="brown"
)
#ANOVA TEST
one.way<-aov(Life.expectancy~Year.groups, data=df1)
summary(one.way)

Adult.M<-aov(Adult.Mortality~Year.groups, data=df1)
summary(Adult.M)

interaction <- aov(Life.expectancy~Year.groups*lifeExp.agegroup, data=df1)
summary(interaction)
str(df1)


# Bivariate Analysis of Target(numerical) and Year.groups & (categorical)
# 1.SUMMARIZING
aggregate(Life.expectancy~Status+Year.groups, data=df1, FUN=mean)  # group by 'Status of country'  and 'Year', apply mean for 'Life expectancy'
str(df1)
# 2. VISUALIZING
boxplot(Life.expectancy~Year.groups+Status,
        data=df1,
        main="Different boxplots for Different Country type & Period",
        xlab=" Country Status  & Years",
        ylab="life.Expectancy",
        col="orange",
        border="brown"
)
#1.SUMMARIZING 
aggregate(Adult.Mortality~lifeExp.agegroup+Status, data=df1, FUN=mean) # group by 'LifeExp.agegroup and 'Status', applying mean to 'Adult.Mortality'.
# 2. VISUALIZING

boxplot(Adult.Mortality~lifeExp.agegroup+Status,
        data=df1,
        main="Different boxplots for Different Country type & Age group",
        xlab="Age Group & Country Status",
        ylab="Adult.Mortality",
        col="orange",
        border="brown"
)

######################################################################################################
# BIVARIATE OR MULTIVARIATE ANALYSIS (CONTINOUS VS. CONTINOUS)
######################################################################################################
colnames(df1)
dataset<-df1[,-c(1,3,21)]         # Removing categorical variables i.e., column 1 ,3 and 21
colnames(dataset)

# Problem :5 what kind of relation does Life Expectancy have with Adult Mortality
# SUMMARIZING

mydata1<-aggregate(Life.expectancy~Adult.Mortality, data=df1, FUN=mean)
mydata1
mydata1.cor<- cor(mydata1)
mydata1.cor
#VISUALIZATION
pairs(df1[,c(4,5)], pch = 19,col="blue", lower.panel = NULL)
# The co-relation is -0.83, That means the above 2 variables are negatively corelated.



#Problem:6 What kind of relation exist between Adult Mortality and Drinking Alcohol
mydata2<-aggregate(Adult.Mortality~Alcohol, data=df1, FUN=mean)
mydata2
mydata2.cor<- cor(mydata2)
mydata2.cor
#VISUALIZATION
pairs(df1[,c(5,7)], pch = 19,col="blue", lower.panel = NULL)


str(df1)
#Show upper panel with scatter plot and lower panel with co-relation,p-value and no.of observations

pairs(df1[,c(4,11,17,19,20)], pch=19, col="blue",lower.panel = panel.cor1)

pairs(df1[,c(4,5,7,16)], pch=19, col="blue", lower.panel = panel.cor1)

pairs(df1[,c(5,7,16)],pch=19, col="blue", lower.panel = panel.cor1)


panel.cor1 <- function(x, y, cex.cor = 0.8, method = "pearson", ...) {
  options(warn = -1)                   # Turn off warnings (e.g. tied ranks)
  usr <- par("usr"); on.exit(par(usr)) # Saves current "usr" and resets on exit
  par(usr = c(0, 1, 0, 1))             # Set plot size to 1 x 1
  r <- cor(x, y, method = method, use = "pair")               # correlation coef
  p <- cor.test(x, y, method = method)$p.val                  # p-value
  n <- sum(complete.cases(x, y))                              # How many data pairs
  txt <- format(r, digits = 3)                                # Format r-value
  txt1 <- format(p, digits = 3)                                 # Format p-value
  txt2 <- paste0("r= ", txt, '\n', "p= ", txt1, '\n', 'n= ', n) # Make panel text
  text(0.5, 0.5, txt2, cex = cex.cor, ...)                      # Place panel text
  options(warn = 0)                                             # Reset warning
}


# 7. What is the relation between Adult.Mortality and HIV.AIDS.
mydata3<-aggregate(Adult.Mortality~HIV.AIDS, data=df1, FUN=mean)
mydata3
mydata3.cor<- cor(mydata3)
mydata3.cor
#VISUALIZATION
pairs(df1[,c(5,16)], pch = 19,col="blue", lower.panel = NULL)



aggregate(Adult.Mortality~lifeExp.agegroup+Status, data=df1, FUN=mean) # group by 'LifeExp.agegroup and 'Status', applying mean to 'Adult.Mortality'.

#8.Does Life Expectancy have positive or negative relationship with drinking alcohol?
mydata <- aggregate(Life.expectancy~Alcohol, data=df1, FUN=mean)
mydata.cor<- cor(mydata)
mydata.cor
# Shows positive corelation which is not explainable.






