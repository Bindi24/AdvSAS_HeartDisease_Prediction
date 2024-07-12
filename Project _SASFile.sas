
*****************************************************HEART DATASET****************************************************;
/*

DATASET :
918 Observations 
12 variables 

Age(Num) : age of the patient [years]

Sex(Char): sex of the patient 
					[M: Male, F: Female]
ChestPainType(Char) : 
					chest pain type [TA: Typical Angina, ATA: Atypical Angina, NAP: Non-Anginal Pain, ASY: Asymptomatic]
				
RestingBP (Num) : resting blood pressure [mm Hg]

Cholesterol (Num): serum cholesterol [mm/dl]

FastingBS (Num/Discrete): fasting blood sugar 
				 		  [1: if FastingBS > 120 mg/dl, 0: otherwise](Distinct Numeric variable / Char)
						  0: This can represent a normal or healthy fasting blood sugar level
						  1: This can represent an abnormal or elevated fasting blood sugar level

RestingECG (Char): resting electrocardiogram results 
				  		[Normal: Normal, ST: having ST-T wave abnormality (T wave inversions and/or ST elevation or depression of > 0.05 mV), LVH: showing probable or definite left ventricular hypertrophy by Estes' criteria]
				  		
MaxHR (Num): maximum heart rate achieved [Numeric value between 60 and 202]

ExerciseAngina(Char) : exercise-induced angina [Y: Yes, N: No]

Oldpeak (Num): oldpeak = ST [Numeric value measured in depression]

ST_Slope (Char): the slope of the peak exercise ST segment [Up: upsloping, Flat: flat, Down: downsloping]
				

HeartDisease (Num)(Target Variable) : output class [1: heart disease, 0: Normal]
				1: Heart Disease signifies that the individual is predicted or diagnosed to have heart disease.
				0: Normal indicates that the individual is predicted or diagnosed to be normal without heart disease.
				This output class helps in understanding the prediction or diagnosis made by a model or system regarding the presence or absence of heart disease in an individual.




/*************OBJECTIVES*****************************

To review the current landscape of heart disease prediction: We will examine existing risk assessment tools, clinical guidelines, and predictive models utilized in cardiovascular risk stratification.
To explore predictive analytics methodologies: We will delve into the principles of predictive modeling, including data preprocessing, feature selection, model development, and evaluation techniques specific to heart disease prediction.
To evaluate the performance of predictive models: Through a comparative analysis of various machine learning algorithms and predictive models, we will assess their accuracy, sensitivity, specificity, and clinical utility in predicting heart disease risk.
To discuss implications for clinical practice and future directions: We will discuss the implications of predictive analytics in preventive cardiology, clinical decision support, and population health management, as well as potential avenues for future research and innovation
To generate list of variables impacting target variable./


/**************BUSINESS QUESTIONS********************/
/*
1)What factors (such as age, sex, chest pain type, blood pressure, etc.) are associated with the presence of heart disease (HeartDisease = 1)?
2)Can we predict the likelihood of heart disease based on the given patient characteristics (Age, Sex, ChestPainType, etc.)?
3)How does exercise-induced angina (ExerciseAngina) relate to the presence of heart disease?
4)Is there a correlation between resting electrocardiogram results (RestingECG) and the occurrence of heart disease?
*/


/**************** DATASET IMPORTED *****************/
libname advsas 'C:\Users\16479\Desktop\Data Science\ADV SAS\advsas';

proc import datafile = 'C:\Users\16479\Desktop\Data Science\ADV SAS\advsas\heart_disease_prediction.csv'
	out = advsas.heart
	dbms=csv
	replace;
	getnames = yes;
run;

/*****ANALYSING DESCRIPTIVE AND DATA PORTION****/
proc print data =advsas.heart (obs=10);
run;

proc contents data = advsas.heart;
run;

data heart;
set advsas.heart;
run;


/**************STATISTICAL ANALYSIS*************/

/*MISSING VALUES*/

title 'Missing Values in Numerical Columns';	
proc means data = heart nmiss/* No missing values*/;
var Age Cholesterol MaxHR Oldpeak RestingBP;
run;

title 'Missing Values in Categorical Column';
proc freq data = heart;
table ChestPainType ExerciseAngina RestingECG ST_Slope Sex FastingBS HeartDisease / missing;
run;

proc sort data=heart_sorted nodupkey;
by model;
run;
ods graphics on;

/*DUPLICATE VALUES*/

title'Count of Distinct Values';
proc sql;
select distinct(count(*))as Distinct_values_in_Dataset from heart;
run;


proc standard data=heart   out= heart2 mean=0 std=1;
var age cholesterol restingbp maxhr oldpeak;
run;

proc print data = heart2(obs=10);
run;

/*OBSERVATION IN TERMS OF OUTLIERS BASED ON ABOVE :
Age: There are no extreme values in the age data (28 to 77 years), so there may not be outliers based on this information alone.
Cholesterol: The range of cholesterol levels is from 0 to 603 mg/dL. 
A cholesterol level of 0 mg/dL is unusual and might indicate missing or invalid data, which could be considered an outlier.
MaxHR (Maximum Heart Rate): The range of maximum heart rates is from 60 to 202 beats per minute. 
							Heart rates above 200 bpm are relatively uncommon during exercise testing and may be considered outliers.
Oldpeak: The range of oldpeak values is from -2.6 to 6.2 mm. Negative oldpeak values are possible due to ST segment depression, 
		but very large negative or positive values might indicate unusual responses and could be outliers.
RestingBP (Resting Blood Pressure): The range of resting blood pressures is from 0 to 200 mmHg. A blood pressure of 0 mmHg is unrealistic and likely an outlier.


/**************************************************************************** UNIVARIATE ANALYSIS ********************

A)*************************************************************************** CATEGORICAL ANALYSIS*******************/


%macro freq_table(catvar,title);
proc freq data = heart;
table &catvar;
title "&title";
run;
%mend;

%macro bar_chart(varname, charttitle);
proc sgplot data=heart;
vbar &varname / stat=percent barwidth=0.25;
title "&charttitle";
run;
%mend;

proc sgplot data=heart;
    /* Use the custom format to set the colors for the bars */
    vbar HeartDisease / stat=percent fillattrs=(color=lightblue)barwidth=0.25;
    title "Heart Disease Frequency Distribution";
run;


%freq_table(ChestPainType, Distribution of Chest Pain Types);
%bar_chart(ChestPainType, Bar Chart of Chest Pain Types);
/*
CHESTPAINTYPE:
ASY (Asymptomatic): 496 cases (54.03%), indicating no chest pain symptoms.
ATA (Atypical Angina): 173 cases (18.85%), representing chest pain symptoms not typical of angina.
NAP (Non-Anginal Pain): 203 cases (22.11%), denoting chest pain not related to angina.
TA (Typical Angina): 46 cases (5.01%), showing chest pain typical of angina.*/


%freq_table(ExerciseAngina, Distribution of Exercise-Induced Angina);
%bar_chart(ExerciseAngina, Bar Chart of Exercise-Induced Angina);

/*EXCERCISEANGINA:
N: There are 547 cases (59.59%) where individuals do not experience exercise-induced angina.
Y: 371 cases (40.41%) where individuals experience exercise-induced angina.
	This means that approximately 40.41% of the individuals in the dataset exhibit symptoms of angina specifically triggered by exercise or physical activity.
	This means these individuals experience chest pain or discomfort (symptoms of angina) when they engage in physical activity or exercise. 
	This type of chest pain is often related to the heart's increased demand for oxygen during exertion, which can reveal underlying cardiovascular issues such as coronary artery disease
*/

%freq_table(RestingECG, Distribution of ECG Results);
%bar_chart(RestingECG, Bar Chart of Resting ECG Results);

/*
RESTING ECG:
LVH: There are 188 cases (20.48%) where the ECG shows signs of left ventricular hypertrophy.
Normal: 552 cases (60.13%) where the ECG is normal.
ST: 178 cases (19.39%) where the ECG shows abnormalities related to ST segments.
*/

%freq_table(ST_Slope, Distribution of ST Slope);
%bar_chart(ST_Slope, Bar Chart of ST Slope);

/*
ST_SLOPE:
Down: There are 63 cases (6.86%) where the ST segment slopes downward.
Flat: There are 460 cases (50.11%) where the ST segment remains flat.
Up: There are 395 cases (43.03%) where the ST segment slopes upward.
*/

%freq_table(Sex, Distribution of Sex);
%bar_chart(Sex, Bar Chart of Sex);

/*
SEX:(gender distribution within the population)
F:In this dataset, 193(21.02%) individuals are female
M:725(78.98%) individuals are male
*/

%freq_table(FastingBS, Distribution of Fasting Blood Sugar);
%bar_chart(FastingBS, Bar Chart of Fasting Blood Sugar);

/*
FASTINGBS:
0:Out of the total cases studied (918 cases), there are 704 cases where individuals have a fasting blood sugar level categorized as "0." This group constitutes 76.69% of the total cases.
1:There are 214 cases (23.31%) where individuals have a fasting blood sugar level of 1" */

%freq_table(HeartDisease, Distribution of Heart Disease);
%bar_chart(HeartDisease, Bar Chart of Heart Disease);


/*HeartDisease: This column categorizes individuals into two groups based on their heart disease status.
0: Represents cases where individuals do not have heart disease.
1: Represents cases where individuals have heart disease.

Frequency :
0: There are 410 cases (44.66%) where individuals do not have heart disease.
1: There are 508 cases (55.34%) where individuals have heart disease.*/

/*proc sgplot data=heart;
  vbar ChestPainType / stat=percent;
  title "Distribution of Chest Pain Types";
run;*/

/*B *************************************************************** CONTINUOUS VARIABLES *********************************************************************/

%macro Uni_statistical_summary(convar, title);
proc univariate data=heart normal;
var &convar;
histogram/kernel;
run;
%mend;

%macro summary_statistics(convar, title);
proc means data = heart n nmiss min max mean std ;
var &convar;
Title &title;
run;
%mend;

proc means data = heart ;
var Age Cholesterol FastingBS MaxHR Oldpeak RestingBP;
run;

%macro Histogram_dia(var,title);
proc sgplot data=heart;
histogram &var / binwidth=10;
density &var;c
title &title;
run;
%mend;

%macro Boxplot_dia(var, target, title);
proc sgplot data=heart;
  vbox &var / categoryvar=&target groupdisplay=cluster;
  title "&title";
run;
%mend;


/*Age*/
ODS GRAPHICS ON;
%Uni_statistical_summary(Age,"Univariate Analysis of Age variable")
%Boxplot_dia(Age, HeartDisease, "Box Plot of Age by Heart Disease Status")
%summary_statistics(age,Statistical Summary of Age)
%Histogram_dia(Age,Histogram of Age Variable)
ODS GRAPHICS OFF;

proc sgplot data = heart;
vbox Age;
run;

Title;
proc print data = heart;
where Age<=40 and HeartDisease=1;
run;

/******************Creating Age Segments ***********************************/

data heart;
set heart;
	if Age >=28 and Age <41 then Age_segment = 'youngsters';
	else if Age >=41 and Age <61 then Age_segment = 'middle age';
	else Age_segment = 'seniors';
run;

proc print data = heart(obs=5);
run;

/*OBERVATIONS:
NORMALITY CHECK :As the P VALUE against Shapiro will test is <.05 , we reject null hypothesis at 5% significance level and conclude that the data is not normally distributed ,
but as the observations are more than 30, we rely on CLT theorem and conclude that the data is normally distributed.

STANDARD DEVIATION: A higher standard deviation (9.43 in this case) indicates that the data points are more spread out from the mean

OUTLIERS:The maximum value is 77, which is significantly higher than the upper quartile (Q3) value of 60. This suggests that there may be outliers on the higher end of the data.
Similarly, the 99th percentile value is 74, which is quite high compared to the upper quartile and median values.



/*Cholesterol*/
title;
%Uni_statistical_summary(Cholesterol,Univariate Analysis of Cholesterol)
%Boxplot_dia(Cholesterol, HeartDisease, Box Plot of Cholesterol by Heart Disease Status)
%summary_statistics(Cholesterol,Statistical Summary of Cholesterol)
%Histogram_dia(Cholesterol,Histogram of Cholesterol Variable)

proc sql;
select count(*) as Total_count from heart
where Cholesterol = 0;
run;
/* 172 observations with 0 cholesterol*/

/*************************Cholesterol Segmentation*******************************/

data heart;
set heart;
	if Cholesterol >=0 and Cholesterol < 201 then Chol_segment= 'Normal            ';
	else if Cholesterol >=201 and Cholesterol <239 then Chol_segment = 'Borderline High';
	else Chol_segment = 'High';
run;

proc print data = heart (obs=5);
run;


proc sgplot;
vbar Chol_segment/stat=percent;
run;

/*OBSERVATIONS
NORMALITY CHECK : The p value against Shapiro-Wilk test is <.05, hence we reject null hypothesis and conclude that the data is not normally distributed at 5% significance level, 
but as our observations are more than 30, we rely on CLT theorem and conclude that the data is normally distributed.

OUTLIERS:The minimum value is 0 and maximum 603 with standard deviation of 109.38, which is very high and indicates the there are outliers. The fact has been further supported with 
the boxplot diagram and alse from the bell curve which is rightly skewed, proves our fact. But it needs further analysis through Tukey's test or Z Score. */

proc sgplot data= heart;
vbox Cholesterol;
run;

/*MaxHR*/
title;
%Uni_statistical_summary(MaxHR,"Univariate Analysis of MaxHR")
%Boxplot_dia(MaxHR, HeartDisease, "Box Plot of MaxHR by Heart Disease Status")
%summary_statistics(MaxHR,Statistical Summary of MaxHR)
%Histogram_dia(MaxHR,Histogram of MaxHR Variable)

proc sgplot data = heart;
vbox MaxHR;
run;

/********************************MaxHR Segmentation*********************************/
data heart;
set heart;
	if MaxHR >=60 and MaxHR < 101 then HR_segment = 'Normal';
	else HR_segment= 'High';
run;

proc print data = heart(obs=5);
run;

/*EXPLANATION-
The mean value (location measure) of the dataset is approximately 136.81, indicating the central tendency of the data.
The standard deviation (variability measure) is around 25.46, representing the spread of the data around the mean.
Median, representing the middle value, is slightly higher than the mean at 138, indicating a slight left-skewness.
Variance measures the average squared deviation from the mean, calculated to be approximately 648.23.
The range, the difference between the highest and lowest values, is 142.
Interquartile range (IQR), a measure of statistical dispersion, is 36, indicating the middle 50% of the data
Tests for normality (Shapiro-Wilk, Kolmogorov-Smirnov, Cramer-von Mises, Anderson-Darling) suggest non-normality with small p-values.
Quantiles provide insights into the spread of data at various percentiles.
For instance, the median (50th percentile) is 138, while the 25th percentile (Q1) is 120, and the 75th percentile (Q3) is 156.
The dataset contains extreme observations, with the lowest value recorded at 60 and the highest at 202.


/*Oldpeak*/
title;
%Uni_statistical_summary(Oldpeak,"Univariate Analysis of Oldpeak")
%Boxplot_dia(Oldpeak, HeartDisease, "Box Plot of Oldpeak by Heart Disease Status")
%summary_statistics(Oldpeak,Statistical Summary of Oldpeak)
%Histogram_dia(Oldpeak,Histogram of Oldpeak Variable)

proc sgplot data = heart;
vbox Oldpeak;
run;


/************************************Oldpeak Segmentation*****************************/
data heart;
set heart;
	if Oldpeak < 1 then Oldpeak_segment = 'Low Risk            ';
	else if 1 <= Oldpeak < 2 then Oldpeak_segment = 'Moderate Risk';
	else Oldpeak_segment='High Risk';
run;

proc print data = heart(obs=5);
run;

/*EXPLANATIONS-
The mean value of the dataset is approximately 0.887, serving as a measure of central tendency.
The standard deviation, approximately 1.067, represents the average deviation from the mean, indicating variability within the dataset.
The median, located at 0.6, serves as another measure of central tendency and is slightly less than the mean, suggesting a slight right skew in the data.
Variance, approximately 1.138, quantifies the spread of the data around the mean.
The range, which is 8.8, depicts the difference between the highest and lowest values in the dataset.
Tests for normality (e.g., Shapiro-Wilk test) suggest non-normality of the dataset with small p-values.
Quantiles provide insights into the spread of data at various percentiles.
For instance, the median (50th percentile) is 0.6, while the 25th percentile (Q1) is 0.0, and the 75th percentile (Q3) is 1.5.
The dataset contains extreme observations, with the lowest value recorded at -2.6 and the highest at 6.2.



/*RestingBP*/
title;
%Uni_statistical_summary(RestingBp, "Univariate Analysis of RestingBP")
%Boxplot_dia(RestingBP, HeartDisease, "Box Plot of RestingBP by Heart Disease Status")
%summary_statistics(RestingBP,Statistical Summary of RestingBP)
%Histogram_dia(RestingBP,Histogram of RestingBP Variable)

proc sgplot data = heart;
vbox RestingBP;
run;

proc sql;
select count(*) from heart
where RestingBp = 0;
run;
/* 1 obersvation has 0 value */


/******************************RestingBP Segmentation***************************************/
data heart;
set heart;   
    if Restingbp < 120 then bp_segment = 'Normal                     ';
    else if Restingbp >= 120 and Restingbp < 130 then bp_segment = 'Elevated';
    else if Restingbp >= 130 and Restingbp < 180 then bp_segment = 'Hypertension';
    else bp_segment = 'Hypertensive Crisis';
run;

proc print data = heart(obs=5);
run;

/*OBSERVATION:
The mean value of the dataset is approximately 132.40, indicating the central tendency of the data.
The standard deviation is approximately 18.51, representing the spread of the data around the mean.
The median, located at 130, serves as another measure of central tendency.
Variance, approximately 342.77, quantifies the spread of the data around the mean.
The range, which is 200, depicts the difference between the highest and lowest values in the dataset.
NORMALITY CHECK : We rely on CLT theorem and conclude that the data is normally distributed.
ABNORMALITIES : We need to further analyse Resting BP at 0 value, also maximum RestingBP value of 200 which is abnormal and needs further investigation.
OUTLIERS : The data shows outliers. */


proc freq data = heart ; 
table Sex ChestPainType FastingBS RestingECG ExerciseAngina ST_Slope Age_segment Chol_category HR_category Oldpeak_category bp_segment;
run;

/************************************************************ BIVARIATE ANALYSIS ******************************************************/
/*A)CATEGORICAL V/S CATEGORICAL */

/** CATEGORICAL WITH TARGET VARIABLE **/


%macro Association(d1 ,var, class);
    Proc Freq data=&d1;
        table &var*&class/ chisq expected norow nocol;
    Run;
    proc sgplot data=&d1;
        vbar &var / group=&class groupdisplay=stack;
    Run;
%mend Association;


/*CheatPainType v/s HeartDisease*/
%Association(Heart,ChestPainType, HeartDisease);

proc freq data=heart;
  tables ChestPainType * HeartDisease / chisq;
run;

/*
Weak - 0.1-0.3
Moderate-0.3 to 0.5
High - .5 to 1.00

/*proc logistic data = heart;
class ChestPainType (ref='ATA');
model HeartDisease (event='1')=ChestPainType;
lsmeans ChestPainType / e ilink;
run;*/

/*
The table indicates that individuals with the "ASY" and "TA" types of chest pain have a higher percentage of heart disease compared to "ATA" and "NAP" types. 
Specifically, "ASY" has the highest percentage of individuals with heart disease among the category.

44.66% of individuals did not have heart disease (HeartDisease = 0).
55.34% of individuals had heart disease (HeartDisease = 1).

	ASY (Asymptomatic): Out of 496 individuals with this type of chest pain, 392 (79.03%) have heart disease.
	TA (Typical Angina): Out of 46 individuals with this type of chest pain, 20 (43.48%) have heart disease.

INTERPRETATION: 
(Strong association - 0.5404 Cramer's V )

For the individuals with ASY(Asymptamatic),the chances of getting heart dieases is 4.900 times higher than TA(Typical Angina) and 
An increase of 1.6669 units in ASY corresponds to a proportional increase of 1.6669 in the likelihood of heart disease.

OBSERVATION : 
Chest pain is often a symptom of various heart conditions, including angina and heart attacks, asymptomatic chest pain can occur in some individuals without other 
noticeable signs of heart problems. It's important to note that even though the pain is described as "asymptomatic," it still indicates potential underlying issues and 
should be evaluated by healthcare professionals to determine its cause and appropriate managemen

	 The Chi-Square Probability is <.05, which indicates that we can reject this null hypothesis, 
     and conclude that there is an ASSOCIATION between the ChestPainType and Heart Disease at 5% significance level.*/


title;
title 'Stacked Bar Chart of Sex';
%Association (Heart,Sex,HeartDisease);

/*Interpretation
Chi-Square and Related Tests: The p-values (<.0001) for all chi-square tests (Pearson, Likelihood Ratio, Continuity Adj., and Mantel-Haenszel) indicate that the association between sex and heart disease is statistically significant. This means that the distribution of heart disease is significantly different between males and females.

Phi Coefficient and Cramer's V: These are measures of association strength. The Phi Coefficient and Cramer's V both have a value of 0.3054, indicating a moderate association between sex and heart disease.

Contingency Coefficient: This value (0.2921) also indicates a moderate association.

Conclusion
The statistical analysis shows a significant association between sex and heart disease, with males having a higher observed frequency of heart disease compared to females. 
The association is moderate in strength as indicated by the Phi Coefficient, Cramer's V, and Contingency Coefficient.*/


/*FastingBS v/s Heartdisease*/
%Association(Heart,FastingBS,HeartDisease);

/*
The table provide information on the distribution of fasting blood sugar levels among individuals with and without heart disease, 
as well as statistical tests evaluating the association between fasting blood sugar and heart disease status.

For individuals with normal fasting blood sugar (FastingBS = 0):
366 individuals do not have heart disease (HeartDisease = 0), which makes 39.87% of the total sample. 
338 individuals have heart disease(HeartDisease = 1), which makes 36.82% of the total sample

For individuals with elevated fasting blood sugar (FastingBS = 1):
44 individuals do not have heart disease (HeartDisease = 0), whereas
170 individuals have heart disease.

INTERPRETATION:
(Weak to Moderate association - 0.2673 Cramer's V )

 The p-values for all the Chi-Square statistics are less than 0.0001, indicating that the association between Fasting Blood Sugar and Heart Disease status is statistically significant. 
Therefore, we can conclude that there is a significant relationship between these two variables. 
Normal Fasting Blood Sugar levels may also be an important predictor of Heart Disease risk.

/*proc logistic data = heart;
class FastingBS;
model HeartDisease(event="1")=FastingBS;
lsmeans FastingBS / e ilink;*/

%Association(Heart,RestingECG,HeartDisease);

/*
INTERPRETATION :
(Weak association - 0.1091 Cramer's V )

A p-value less than a significance level (typically 0.05) suggests that the association between the variables is statistically significant.
In this case, the p-values of 0.0042 and 0.0039 indicate that there is a significant association between the variables, as they are smaller than 0.05.
The Mantel-Haenszel Chi-Square has a slightly higher p-value of 0.0823, suggesting a weaker association compared to the other tests.

31.05%(with normal ECG),11.55%(LVH) and 12.75% (ST) of the total individuals category have heart disease. 
65% of the individual within the ST category and 56% of the individuals within LVH category have heart disease

The individuals in ST or LVH catgeory are likely to get heart disease. 


/* ExcerciseAngina v/s HeartDisease */
title;
title 'Stacked bar Chart of Exercise Angina v/s HeartDisease';
%Association(Heart,ExerciseAngina,HeartDisease);

/*
INTERPRETATION:
(Strong association-0.4943 Cramer's V )

 The Chi-Square Probability is <.05, which indicates that we can reject this null hypothesis, 
     and conclude that there is an ASSOCIATION between the ExcerciseAngina and Heart Disease at 5% significance level.

Individuals with ExcerciseAngina are likely to get Heart Disease.
34.42% of the total individuals with ExerciseAngina are having Heart Disease, where as 
38.67% of the individuals with No ExerciseAngina doesnt have Heart Disease*/

title 'Stacked bar chart of ST_Slope v/s HeartDisease';
%Association(Heart,ST_slope,HeartDisease);

/*
INTERPRETATION:
(Strong association - 0.6227 Cramer's V )

 The Chi-Square Probability is <.05, which indicates that we can reject this null hypothesis, 
 and conclude that there is an ASSOCIATION between the ST_slope and Heart Disease at 5% significance level.

Individuals with Flat (41.50% of total individual and 82.82% within the category) and down (5.34% of the total individual and 77.77% within the category) ST_slope are more likely to get heart disease 
as compared to individuals with Up (34.53% of the total individuals and 80.25% within the category are without heart disease)ST Slope.*/

%Association(Heart,Age_segment,HeartDisease);

/*
INTERPRETATION:
(Weak to Moderate association - 0.2248 Cramer's V )

The Chi-Square Probability is <.05, which indicates that we can reject this null hypothesis, 
and conclude that there is an ASSOCIATION between the Age_segment and Heart Disease at 5% significance level.

The Chi-Square statistic measures the strength of association between Age segments and Heart Disease status. The values (46.3874 and 47.7500) are significant, indicating an association between the variables.
The p-values associated with these statistics are less than 0.0001, indicating a highly significant association.
The Phi Coefficient, Contingency Coefficient, and Cramer's V are all 0.2248, indicating a moderate association between the variables.

These findings indicate that age is a significant factor in determining the likelihood of heart disease, with older individuals (seniors of age 60 and above- 72.85% within the category) 
having a higher prevalence compared to middle-aged and younger individuals .*/

%Association(Heart,Chol_category,HeartDisease);

/*
INTERPRETATION:
(Weak association -0.168 Cramer's V )

The Chi-Square Probability is <.05, which indicates that we can reject null hypothesis, 
and conclude that there is an ASSOCIATION between the Chol_category and Heart Disease at 5% significance level.

The statistical tests suggest that cholesterol category is associated with the presence or absence of heart disease.
Specifically, individuals with different cholesterol levels (Borderline High, High, and Normal) appear to have varying prevalence of heart disease.
The association between cholesterol category and heart disease is moderate, as indicated by the values of the Phi Coefficient, Contingency Coefficient, and Cramer's V.*/

%Association(Heart,HR_category,HeartDisease);

/*
INTERPRETATION:
(Weak association -0.1509 Cramer's V)

The Chi-Square Probability is <.05, which indicates that we can reject this null hypothesis, 
and conclude that there is an ASSOCIATION between the Hr_category and Heart Disease at 5% significance level.

The statistical tests suggest that the heart rate category is associated with the presence or absence of heart disease.
Specifically, individuals with a high heart rate appear to have a higher prevalence of heart disease compared to those with a normal heart rate.
While statistically significant, the association between heart rate category and heart disease is relatively weak, as indicated by the modest values of the 
Phi Coefficient, Contingency Coefficient, and Cramer's V.*/


%Association(Heart,Oldpeak_category,HeartDisease);


/*
INTERPRETATION:
(Weak to Moderate association - 0.4382 Cramer's V)

The Chi-Square Probability is <.05, which indicates that we can reject this null hypothesis, 
and conclude that there is an ASSOCIATION between the Oldpeak_category and Heart Disease at 5% significance level.

The statistical tests suggest that the oldpeak category is associated with the presence or absence of heart disease.
Specifically, individuals with different levels of oldpeak (high risk, low risk, and moderate) appear to have varying prevalence of heart disease.
The association between oldpeak category and heart disease is moderate, as indicated by the values of the Phi Coefficient, Contingency Coefficient, and Cramer's V.*/

%Association(Heart,bp_segment,HeartDisease);

/*
INTERPRETATION:

The Chi-Square Probability is >.05, which indicates that we fail to reject null hypothesis, 
and conclude that there is not enough evidence to conclude that there is association between bp_segment and Heart Disease at 5% significance level.

The lack of significance indicates that variations in blood pressure across the different segments do not appear to be strongly related to the presence or absence of heart disease.
This implies that other factors may play a more significant role in determining the likelihood of heart disease in this population.*/


********************************* OTHERS *****************************/

%Association(Heart,Sex,ChestPainType);
/*(Weak Association - 0.2004 Cramer's V )
Male members are likely to fall in ASY chestpain category

The output correctly demonstrates that there is a statistically significant association between sex and chest pain type, with males being more likely to fall into the ASY category. 
The provided statistical values and measures support this conclusion, confirming that the distribution of chest pain types significantly differs between males and females.*/

%Association(Heart,Sex,FastingBS);
/*(Weak Association - 0.1201 Cramer's V 
Contingency Table Analysis:

For females (F), 167 out of 193 (86.53%) have a FastingBS of 0, and 26 out of 193 (13.47%) have a FastingBS of 1.
For males (M), 537 out of 725 (74.07%) have a FastingBS of 0, and 188 out of 725 (25.93%) have a FastingBS of 1.
Overall, 704 out of 918 (76.69%) have a FastingBS of 0, and 214 out of 918 (23.31%) have a FastingBS of 1.

The output indicates a statistically significant association between sex and fasting blood sugar levels. Specifically:

Males (M) are more likely than females (F) to have a FastingBS of 1.
Females are more likely than males to have a FastingBS of 0.
The statistical tests consistently show a significant association, with p-values well below the conventional threshold of 0.05.
The measures of association (Phi and Contingency Coefficients) indicate a small effect size.*/

%Association(Heart,Sex,RestingECG);
/* We fail to reject the null hypothesis at the 5% significance level and conclude that there is not enough evidence to prove an association between Sex and Resting ECG*/


%Association(Heart,Sex,ExerciseAngina);
/*Weak association - 0.1907 Cramer's V 

For females (F), 150 out of 193 (77.72%) do not have exercise-induced angina (ExerciseAngina = N), and 43 out of 193 (22.28%) do.
For males (M), 397 out of 725 (54.76%) do not have exercise-induced angina, and 328 out of 725 (45.24%) do.
Overall, 547 out of 918 (59.59%) do not have exercise-induced angina, and 371 out of 918 (40.41%) do.

The output indicates a statistically significant association between sex and exercise-induced angina:

Males are more likely than females to have exercise-induced angina (45.24% vs. 22.28%).
Females are more likely than males to not have exercise-induced angina (77.72% vs. 54.76%).
The consistent results across various statistical tests (Chi-Square and Fisher's Exact Test) strongly support the conclusion that 
the association between sex and exercise-induced angina is significant.*/


%Association(Heart,Sex,ST_Slope);
/*Weak association - 0.1542 Cramer's V 

For females (F):
7 out of 193 (3.63%) have a Down ST_Slope.
75 out of 193 (38.86%) have a Flat ST_Slope.
111 out of 193 (57.51%) have an Up ST_Slope.
For males (M):
56 out of 725 (7.72%) have a Down ST_Slope.
385 out of 725 (53.1%) have a Flat ST_Slope.
284 out of 725 (39.17%) have an Up ST_Slope.
Overall:
63 out of 918 (6.86%) have a Down ST_Slope.
460 out of 918 (50.11%) have a Flat ST_Slope.
395 out of 918 (43.03%) have an Up ST_Slope.

The output indicates a statistically significant association between sex and ST_Slope:

Females are more likely to have an Up ST_Slope (57.51%) compared to males (39.17%).
Males are more likely to have a Flat ST_Slope (53.1%) compared to females (38.86%).
Males are also slightly more likely to have a Down ST_Slope (7.72%) compared to females (3.63%).
The statistical tests consistently show a significant association, with p-values well below the conventional threshold of 0.05.
The measures of association (Phi and Cramer's V) indicate a moderate effect size.*/


%Association(Heart,Sex,Age_segment);
/*
The output indicates no statistically significant association between sex and age segment*/


%Association(Heart,Sex,HR_category);
/*weak association -0.0910 cramer's V */
%Association(Heart,Sex,Oldpeak_category);
/*weak association - 0.1300 cramer's V*/
%Association(Heart,Sex,bp_segment);
/*weak association - 0.0546 cramer's V*/
%Association(Heart,Sex,Chol_category);
/*weak association - 0.1504 cramer's V*/


%Association(Heart,FastingBS,ChestPainType);
/*weak association -0.1607 cramer's V*/
%Association(Heart,FastingBS,RestingECG);
/*weak association - 0.1288 cramer's V*/
%Association(Heart,FastingBS,ExerciseAngina);
/*No association */
%Association(Heart,FastingBS,ST_Slope);
/*weak association - .1758 cramer's V*/
%Association(Heart,FastingBS,Age_segment);
/*weak association - 0.1462 cramer's V*/
%Association(Heart,FastingBS,HR_category);
/* no association*/
%Association(Heart,FastingBS,Oldpeak_category);
/*weak association - 0.1196 cramer's V*/
%Association(Heart,FastingBS,bp_segment);
/* No association*/
%Association(Heart,FastingBS,Chol_category);
/*weak association - 0.1782 cramer's V*/


%Association(Heart,ChestPainType,RestingECG);
/*weak association - 0.1027 cramer's V*/
%Association(Heart,ChestPainType,ExerciseAngina);
/*Moderate association - 0.4419 cramer's V*/
%Association(Heart,ChestPainType,ST_Slope);
/*moderate association - 0.2923 cramer's V*/
%Association(Heart,ChestPainType,Age_segment);
/*weak association -0.1586 cramer's V*/
%Association(Heart,ChestPainType,HR_category);
/*weak association - 0.1241 cramer's V*/
%Association(Heart,ChestPainType,Oldpeak_category);
/*weak association - 0.2422 cramer's V*/
%Association(Heart,ChestPainType,bp_segment);
/*weak association - 0.0844 cramer's V / Chi-Square 9 19.5990 0.0206 / Mantel-Haenszel Chi-Square 1  0.6184 */
%Association(Heart,ChestPainType,Chol_category);
/* Weak Associaton - 0.1005 Cramer's V / Chi-Square  0.0050 /Mantel-Haenszel Chi-Square  0.0909 */


%Association(Heart,RestingECG,ExerciseAngina);
/* Weak association - 0.1076 Cramer's V */
%Association(Heart,RestingECG,ST_Slope);
/* No Association */
%Association(Heart,RestingECG,Age_segment);
/* Weak association - 0.1363 Cramer's V / MH - .5110*/
%Association(Heart,RestingECG,HR_category);
/* Weak association - 0.0897 Cramer's V */
%Association(Heart,RestingECG,Oldpeak_category);
/* No association*/
%Association(Heart,RestingECG,bp_segment);
/* Weak association - 0.0850 Cramer's V / MH - 0.9309 */
%Association(Heart,RestingECG,Chol_category);
/* Weak association - 0.1382 Cramer's V */


%Association(Heart,ExerciseAngina,ST_Slope);
/* Moderate association - 0.4566 Cramer's V */
%Association(Heart,ExerciseAngina,Age_segment);
/* Weak association - 0.1801 Cramer's V / Ch-Sq MH -0.1763 */
%Association(Heart,ExerciseAngina,HR_category);
/* Weak association - 0.0815 Cramer's V */
%Association(Heart,ExerciseAngina,Oldpeak_category);
/*Moderate association -0.4756 Cramer's V */
%Association(Heart,ExerciseAngina,bp_segment);
/* Weak association - 0.1423 Cramer's V */
%Association(Heart,ExerciseAngina,Chol_category);
/* No association */


%Association(Heart,ST_Slope,Age_segment);
/* Weak association - 0.1711 Cramer's V */
%Association(Heart,ST_Slope,HR_category);
/* Weak association - 0.1486 Cramer's V */
%Association(Heart,ST_Slope,Oldpeak_category);
/* Moderate association - 0.3816 Cramer's V / MH chi sq- 0.1287 */
%Association(Heart,ST_Slope,bp_segment);
/* No association */
%Association(Heart,ST_Slope,Chol_category);
/* No association*/


%Association(Heart,Age_segment,HR_category);
/* Weak association - 0.1137 Cramer's V / Ch sq MH - 0.6485 */
%Association(Heart,Age_segment,Oldpeak_category);
/* Weak association - 0.1520 Cramer's V / Chi sq MH 0.5930*/
%Association(Heart,Age_segment,bp_segment);
/* Weak association - 0.1387 Cramer's V */
%Association(Heart,Age_segment,Chol_category);
/* No association*/



%Association(Heart,HR_category,Oldpeak_category);
/* No association */
%Association(Heart,HR_category,bp_segment);
/* No association */
%Association(Heart,HR_category,Chol_category);
/* Weak association - 0.1038 Cramer's V */



%Association(Heart,Oldpeak_category,bp_segment);
/* Weak association - 0.0969 Cramer's V/ chi- sq Mh -0.1459 */
%Association(Heart,Oldpeak_category,Chol_category);
/* no association*/


%Association(Heart,bp_segment,Chol_category);
/* Weak association - 0.0900 Cramer's V */

proc print data = heart(obs=5);
run;

proc freq data = heart ; 
table Sex*heartdisease / /*ChestPainType FastingBS RestingECG ExerciseAngina ST_Slope Age_segment Chol_category HR_category Oldpeak_category bp_segment*/chisq;
run;


************************************************************** CORRELATION *****************************************************************************************************;

/* CONTINUOUS v/s CONTINUOUS */

PROC CORR DATA = heart   plots=matrix(histogram);
VAR Age RestingBP Cholesterol MaxHR Oldpeak ;
RUN;

ods graphics on;
proc sgplot data=heart;
    heatmap x=Age y=RestingBP ;
    title 'Correlation Heatmap';
run;
ods graphics off;


/* Calculate Pearson correlation coefficients and store results in a dataset */
proc corr data=heart pearson outp=corr_results noprint;
    var Age RestingBP Cholesterol MaxHR Oldpeak;
run;

/* Prepare data for heatmap */
data heatmap_data;
    set corr_results;
    if _TYPE_ = 'CORR';
    array vars[*] Age RestingBP Cholesterol MaxHR Oldpeak;
    do i = 1 to dim(vars);
        varname = vname(vars[i]);
        corr_value = vars[i];
        corr_text = put(corr_value, 5.2);
        output;
    end;
    keep _NAME_ varname corr_value corr_text;
run;

/* Generate heatmap */
ods graphics on;
proc sgplot data=heatmap_data;
    heatmapparm x=_NAME_ y=varname colorresponse=corr_value / colormodel=(lightblue white lightgreen);
	text x=_Name_ y=varname text=corr_text / position=center;
    gradlegend / title="Correlation";
    title 'Correlation Heatmap';
run;
ods graphics off;

/* None of the variables are highly correlated with each other*/


/*C) CATEGORICAL V/S CONTINUOUS VARIABLE */

/*HeartDisease v/s Age*/

TITLE1 ' GROUP BOX PLOT ';
TITLE2 'COMPARISON BETWEEN AGE AND HeartDisease';
PROC SGPLOT DATA = HEART;
VBOX Age / GROUP = HeartDisease;
RUN;


PROC ttest DATA=heart;
  CLASS HeartDisease;
  Var Age ;
RUN;


/*
Here are some short insights from the provided information:

Mean Resting Heart Rate: Individuals with heart disease (1) have a higher mean resting heart rate (55.90 beats per minute) compared to those without heart disease (0) (50.55 beats per minute). This difference in means is statistically significant, as indicated by the t-values and p-values.
Standard Deviation: The standard deviation of resting heart rate is slightly higher for individuals with heart disease (8.73) compared to those without heart disease (9.44). This suggests that there is slightly more variability in resting heart rates among individuals with heart disease.
Difference in Means: The difference in means of resting heart rate between individuals with and without heart disease is approximately 5.35 beats per minute. This difference is statistically significant, indicating that heart disease is associated with higher resting heart rates.
Confidence Intervals: The 95% confidence intervals for the mean resting heart rates of individuals with and without heart disease do not overlap, further supporting the conclusion that there is a significant difference between the two groups.
Test for Equality of Variances: The test for equality of variances suggests that the variances of resting heart rates between individuals with and without heart disease are not significantly different, as the p-value is greater than 0.05.
Overall, these insights suggest that resting heart rate is associated with heart disease, with individuals diagnosed with heart disease tending to have higher resting heart rates compared to those without the disease.*/

/*HeartDisease v/s RestingBP*/

TITLE1 ' GROUP BOX PLOT ';
TITLE2 'COMPARISON BETWEEN RESTINGBP AND HEARTDISEASE';
PROC SGPLOT DATA = HEART;
VBOX RESTINGBP / GROUP = HEARTDISEASE;
RUN;

proc ttest data = heart;
class heartDisease;
var RestingBP;
run;

/*Interpretation
Resting Blood Pressure Difference: There is a statistically significant difference in the mean resting blood pressure between individuals with and without heart disease. The mean resting blood pressure for those with heart disease is higher by approximately 4.0046 mm Hg.
Statistical Significance: Both the pooled t-test and the Satterthwaite t-test show p-values (< 0.05), indicating that the difference in resting blood pressure means between the two groups is statistically significant. Specifically, the p-values are 0.0011 and 0.0009, respectively, which are well below the common alpha level of 0.05.
Confidence Intervals: The 95% confidence intervals for the mean difference do not include zero, further supporting that the difference is significant.
Pooled CI: [-6.4041, -1.6050]
Satterthwaite CI: [-6.3580, -1.6511]
Variance Equality Test: The Folded F test shows a significant p-value (0.0001), indicating that the variances between the two groups are significantly different. This is why both pooled and Satterthwaite methods are used to ensure robustness of results despite unequal variances.
Clinical Relevance: The difference in resting blood pressure, while statistically significant, should also be evaluated for clinical relevance. A difference of about 4 mm Hg might be clinically meaningful, particularly in the context of heart disease risk management.
Outliers: The minimum value of 0 in the heart disease group suggests a potential data entry error or an outlier, which should be investigated as it may affect the analysis.
Conclusion
There is a significant difference in resting blood pressure between individuals with and without heart disease, with those having heart disease showing higher average resting blood pressure. The statistical tests confirm this finding with strong evidence (p-values well below 0.05), and the confidence intervals reinforce the reliability of the observed difference.*/

/* HeartDisease and Cholesterol */

TITLE1 ' GROUP BOX PLOT ';
TITLE2 'COMPARISON BETWEEN Cholesterol AND HEARTDISEASE';
PROC SGPLOT DATA = HEART;
VBOX Cholesterol / GROUP = HEARTDISEASE;
RUN;

proc ttest data = heart;
class heartDisease;
var Cholesterol;
run;

/*Interpretation
Mean Differences: There is a statistically significant difference in the means of the variable between the two groups. Group 0 (no heart disease) has a higher mean (227.1) compared to Group 1 (heart disease) which has a mean of 175.9. The difference in means is 51.1810.
Statistical Significance: The t-test results for both pooled and Satterthwaite methods indicate highly significant p-values (<.0001), suggesting that the difference in means is statistically significant. This indicates strong evidence against the null hypothesis of no difference between the groups.
Confidence Intervals: The 95% confidence intervals for the mean difference do not include zero, further confirming the significance of the observed difference.
Pooled CI: [37.3129, 65.0491]
Satterthwaite CI: [38.0095, 64.3525]
Variability: Group 1 (heart disease) has a much larger standard deviation (126.4) compared to Group 0 (74.6347), indicating greater variability in the variable for the heart disease group.
Equality of Variances: The Folded F test shows a significant p-value (<.0001), indicating that the variances between the two groups are significantly different. This is why both pooled and Satterthwaite methods are reported to handle the unequal variances appropriately.
Clinical or Practical Significance: The difference of 51.1810 units (the specific variable is not named) between the two groups could be clinically significant, suggesting that heart disease status is associated with a substantial difference in this measure.

Conclusion
There is a significant difference in the measured variable between individuals with and without heart disease. The group without heart disease has a higher mean value, and this difference is both statistically and potentially clinically significant. The higher variability in the heart disease group indicates more diverse outcomes within that group. The statistical tests confirm these findings with very strong evidence.*/

/* MaxHR v/s HeartDisease*/
TITLE1 ' GROUP BOX PLOT ';
TITLE2 'COMPARISON BETWEEN MAXHR AND HEARTDISEASE';
PROC SGPLOT DATA = HEART;
VBOX MAXHR / GROUP = HEARTDISEASE;
RUN;

proc ttest data = heart;
class heartDisease;
var maxhr;
run;

/*Interpretation
Mean Differences: There is a statistically significant difference in the means of the variable between the two groups. Group 0 (no heart disease) has a higher mean (148.2) compared to Group 1 (heart disease) which has a mean of 127.7. The difference in means is 20.4957.
Statistical Significance: Both the pooled and Satterthwaite t-tests indicate highly significant p-values (<.0001), suggesting that the difference in means is statistically significant. This indicates strong evidence against the null hypothesis of no difference between the groups.
Confidence Intervals: The 95% confidence intervals for the mean difference do not include zero, further confirming the significance of the observed difference.
Pooled CI: [17.4543, 23.5371]
Satterthwaite CI: [17.4555, 23.5359]
Variability: Both groups have similar standard deviations (Group 0: 23.2881, Group 1: 23.3869), indicating similar variability in the measurements within each group.
Equality of Variances: The Folded F test shows a non-significant p-value (0.9309), indicating that the variances between the two groups are not significantly different. This supports the assumption of equal variances used in the pooled t-test.
Clinical or Practical Significance: The difference of 20.4957 units (the specific variable is not named) between the two groups could be clinically significant, suggesting that heart disease status is associated with a substantial difference in this measure.

Conclusion
There is a significant difference in the measured variable between individuals with and without heart disease. The group without heart disease has a higher mean value, and this difference is both statistically and potentially clinically significant. The variances are not significantly different, supporting the use of the pooled t-test. The statistical tests confirm these findings with very strong evidence.*/

/* OldPeak v/s HeartDisease*/
TITLE1 ' GROUP BOX PLOT ';
TITLE2 'COMPARISON BETWEEN Oldpeak AND HEARTDISEASE';
PROC SGPLOT DATA = HEART;
VBOX OLDPEAK / GROUP = HEARTDISEASE;
RUN;

proc ttest data = heart;
class heartDisease;
var oldpeak;
run;

/*Interpretation
Mean Differences: There is a statistically significant difference in the means of the variable between the two groups. Group 0 (no heart disease) has a mean of 0.4080, while Group 1 (heart disease) has a higher mean of 1.2742. The mean difference is -0.8662, indicating that the value of the measured variable is higher in the heart disease group.
Statistical Significance: Both the pooled and Satterthwaite t-tests show highly significant p-values (<.0001), indicating that the difference in means is statistically significant. This provides strong evidence against the null hypothesis of no difference between the groups.
Confidence Intervals: The 95% confidence intervals for the mean difference do not include zero, further confirming the significance of the observed difference.
Pooled CI: [-0.9934, -0.7390]
Satterthwaite CI: [-0.9873, -0.7451]
Variability: Group 1 (heart disease) has a higher standard deviation (1.1519) compared to Group 0 (0.6997), indicating greater variability in the measurements within the heart disease group.
Equality of Variances: The Folded F test shows a significant p-value (<.0001), indicating that the variances between the two groups are significantly different. Despite this, the Satterthwaite method (which accounts for unequal variances) confirms the significant difference in means.
Clinical or Practical Significance: The difference of -0.8662 units (the specific variable is not named) between the two groups could be clinically significant, suggesting that heart disease status is associated with a substantial difference in this measure.

Conclusion
There is a significant difference in the measured variable between individuals with and without heart disease. The group with heart disease has a higher mean value, and this difference is both statistically and potentially clinically significant. The greater variability in the heart disease group suggests more diverse outcomes within that group. The statistical tests confirm these findings with very strong evidence.*/



/**************************************************************MULTIVARIATE ANALYSIS************************************************/

PROC SGPLOT DATA = heart;
SCATTER X = age  Y= CHOLESTEROL / GROUP= HEARTDISEASE;
KEYLEGEND/ LOCATION = INSIDE POSITION = BOTTOMRIGHT;
INSET " AGE AND CHOLESTEROL" / POSITION = TOPLEFT;
RUN;
QUIT;

proc sgplot data = heart;
scatter X= age Y=RestingBP / Group= HeartDisease;
KEYLEGEND/ LOCATION = INSIDE POSITION = BOTTOMRIGHT;
INSET " AGE AND RESTINGBP" / POSITION = TOPLEFT;
RUN;
QUIT;

proc sgplot data = heart;
scatter X= CHOLESTEROL Y=RestingBP / Group= HeartDisease;
KEYLEGEND/ LOCATION = INSIDE POSITION = BOTTOMRIGHT;
INSET " CHOLESTEROL AND RESTINGBP" / POSITION = TOPLEFT;
RUN;
QUIT;

proc sgplot data = heart;
scatter X= CHOLESTEROL Y=MAXHR / Group= HeartDisease;
KEYLEGEND/ LOCATION = INSIDE POSITION = BOTTOMRIGHT;
INSET " CHOLESTEROL AND MAXHR" / POSITION = TOPLEFT;
RUN;
QUIT;

proc sgplot data = heart;
scatter X= CHOLESTEROL Y=OLDPEAK / Group= HeartDisease;
KEYLEGEND/ LOCATION = INSIDE POSITION = BOTTOMRIGHT;
INSET " CHOLESTEROL AND OLDPEAK" / POSITION = TOPLEFT;
RUN;
QUIT;

proc sgplot data = heart;
scatter X= CHOLESTEROL Y=RestingBP / Group= ST_SLOPE;
KEYLEGEND/ LOCATION = INSIDE POSITION = BOTTOMRIGHT;
INSET " CHOLESTEROL AND RESTINGBP" / POSITION = TOPLEFT;
RUN;
QUIT;

/************************************************************** PROC PLS *********************************************************************************************************/

ODS GRAPHICS ON;
proc pls data=heart plots=all;
class  SEX RESTINGECG FASTINGBS EXERCISEANGINA ST_SLOPE ChestPaintype;
model heartdisease = Age RestingBP Sex ChestPainType FastingBS RestingECG ExerciseAngina/ solution  ;
run;
quit;
ODS GRAPHICS OFF;


/*Age Sex ChestPainType RestingBP Cholesterol FastingBS RestingECG MaxHR ExerciseAngina Oldpeak ST_Slope HeartDisease */
proc print data = heart ( obs=10);
run;

ods html;
proc surveyselect data=heart rate=0.70 outall out=result seed=12345; 
run;
data traindata testdata;
set result;
if selected=1 then output traindata;
else output testdata;
run;

proc print data = traindata (obs=10);
run;


/* Model built after standarization of data */
ods html;
proc surveyselect data=heart2 rate=0.70 outall out=result seed=12345; 
run;
data traindata1 testdata1;
set result;
if selected=1 then output traindata1;
else output testdata1;
run;

ods graphics on; 
proc logistic data=traindata1 plots=(ROC ) ; 
class   Sex(ref = "F") ChestPainType(ref="TA") FastingBS(ref="0") ExerciseAngina(ref="N") ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType Cholesterol FastingBS ExerciseAngina Oldpeak ST_Slope /  details lackfit; 
score data=testdata1 out=testpred outroc=vroc;
roc; roccontrast;
output out=outputedata p=prob_predicted xbeta=linpred;
run; 
quit;
ods graphics off;

ods graphics on; 
proc logistic data=heart2 plots(only)=(effect oddsratio); 
class   Sex(ref = "F") ChestPainType(ref="TA") FastingBS(ref="0") ExerciseAngina(ref="N") ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType Cholesterol FastingBS ExerciseAngina Oldpeak ST_Slope/ /*selection=stepwise slentry=0.3 slstay=0.35*/ details lackfit; 
   output out=pred p=phat lower=lcl upper=ucl
          predprob=(individual crossvalidate);
   ods output Association=Association; 
run; 
quit;
*;

/*Model built with all varibales */
ods graphics on; 
proc logistic data=traindata plots=(ROC ) ; 
class   Sex ChestPainType FastingBS RestingECG ExerciseAngina ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType RestingBP Cholesterol FastingBS RestingECG MaxHR ExerciseAngina Oldpeak ST_Slope /  details lackfit; 
score data=testdata out=testpred outroc=vroc;
roc; roccontrast;
output out=outputedata p=prob_predicted xbeta=linpred;
run; 
quit;
ods graphics off;

/* Based on Coefficient value , removed restingECG*/
ods graphics on; 
proc logistic data=traindata plots=(ROC ) ; 
class   Sex ChestPainType FastingBS ExerciseAngina ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType RestingBP Cholesterol FastingBS MaxHR ExerciseAngina Oldpeak ST_Slope /  details lackfit; 
score data=testdata out=testpred outroc=vroc;
roc; roccontrast;
output out=outputedata p=prob_predicted xbeta=linpred;
run; 
quit;
ods graphics off;

/*Based on Coefficient value, removed resting BP*/
ods graphics on; 
proc logistic data=traindata plots=(ROC ) ; 
class   Sex ChestPainType FastingBS ExerciseAngina ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType Cholesterol FastingBS MaxHR ExerciseAngina Oldpeak ST_Slope /  details lackfit; 
score data=testdata out=testpred outroc=vroc;
roc; roccontrast;
output out=outputedata p=prob_predicted xbeta=linpred;
run; 
quit;
ods graphics off;

/*Based on coeffiient value, removed MaxHR*/
ods graphics on; 
proc logistic data=traindata plots=(ROC ) ; 
class   Sex ChestPainType FastingBS ExerciseAngina ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType Cholesterol FastingBS ExerciseAngina Oldpeak ST_Slope /  details lackfit; 
score data=testdata out=testpred outroc=vroc;
roc; roccontrast;
output out=outputedata p=prob_predicted xbeta=linpred;
run; 
quit;
ods graphics off;

*************************************************************************************************;
ODS GRAPHICS ON;
proc pls data=heart plots=all;
class  SEX RESTINGECG FASTINGBS EXERCISEANGINA ST_SLOPE ChestPaintype;
model heartdisease= Age RestingBP Sex Cholesterol Oldpeak St_Slope ChestPainType FastingBS RestingECG ExerciseAngina/ solution  ;
run;
quit;
ODS GRAPHICS OFF;

/*Chestpain category ref - "ASY"*/
ods graphics on; 
proc logistic data=traindata plots=(ROC ) ; 
class   Sex(ref = "F") ChestPainType(ref="TA") FastingBS(ref="0") ExerciseAngina(ref="N") ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType Cholesterol FastingBS ExerciseAngina Oldpeak ST_Slope /  details lackfit; 
score data=testdata out=testpred outroc=vroc;
roc; roccontrast;
output out=outputedata p=prob_predicted xbeta=linpred;
run; 
quit;
ods graphics off;

proc print data = testpred(obs=10);
run;

ods graphics on; 
proc logistic data=heart plots(only)=(effect oddsratio); 
class   Sex(ref = "F") ChestPainType(ref="TA") FastingBS(ref="0") ExerciseAngina(ref="N") ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType Cholesterol FastingBS ExerciseAngina Oldpeak ST_Slope/ /*selection=stepwise slentry=0.3 slstay=0.35*/ details lackfit; 
   output out=pred p=phat lower=lcl upper=ucl
          predprob=(individual crossvalidate);
   ods output Association=Association; 
run; 
quit;


/* FEATURES impacting  HEART DISEASE 

FEATURES 			
ST_Slope Flat			
ChestPainType ASY        
Sex Male
FastingBS
ExerciseAngina
Cholesterol
Oldpeak
Age
******************************************************************************************************;*/


*  Confusion matrix;
proc sort data=testpred;
by descending F_HeartDisease descending I_HeartDisease;
run;
ods html on style= journal;
proc freq data=testpred  order=data;
        table F_HeartDisease*I_HeartDisease /  out=CellCounts;
        run;
      data CellCounts;
        set CellCounts;
        Match=0;
        if F_HeartDisease=I_HeartDisease then Match=1;
        run;
      proc means data=CellCounts mean;
        freq count;
        var Match;
        run;
quit;
ods html close;


* sensitivity;
ods html on;
ods graphics on; 
proc logistic data=traindata plots=ROC; 
class   Sex(ref = "F") ChestPainType(ref="TA") FastingBS(ref="0") ExerciseAngina(ref="N") ST_Slope  /param=ref ;
model HeartDisease(event="1")= Age Sex ChestPainType Cholesterol FastingBS ExerciseAngina Oldpeak ST_Slope /  details lackfit outroc=troc;
score data=testdata out=testpred outroc=vroc;
roc; roccontrast;
output out=outputedata p=prob_predicted xbeta=linpred;
run; 
quit;
ods graphics off;
ods html close;



*************************************************************** GAM;

ods graphics on; 
proc gam data=traindata plots=all; 
class   Sex ChestPainType FastingBS RestingECG ExerciseAngina ST_Slope ;
model HeartDisease(event="1")= param(Sex ChestPainType FastingBS RestingECG ExerciseAngina ST_Slope)  / dist=binomial ;
score data=testdata  out=outputedata ;
output out=outputedata_gam p=prob_predicted all;
run; 
quit;
ods graphics off;

proc print data = outputedata_gam(obs=10);
run;
* ;
ods graphics on; 
proc gam data=traindata plots=all; 
class    Sex ChestPainType FastingBS RestingECG ExerciseAngina ST_Slope ;
*model survived(event="1")=  spline(age, df=2) loess(logFare2) param(sex Pclass Embarked SibSp); 
*model survived(event="1")=  loess(age) loess(logFare2) param(sex Pclass Embarked SibSp); 
model HeartDisease(event="1")=  /*spline(Age,df=2)*/  param(Sex ChestPainType FastingBS RestingECG ExerciseAngina ST_Slope); 
score data=testdata  out=outputedata_gam2;
   output out=pred p=phat ;
run; 
ods graphics off;

*GAM ROC;
ods graphics on;
proc logistic data=outputedata_gam2;
where phatHeartDisease ne .;
class   Sex ChestPainType FastingBS RestingECG ExerciseAngina ST_Slope;
baseline_model:model HeartDisease(event="1")= ;
 roc 'AUC of the Hold Out Sample for GAM' pred=phatHeartDisease;
*Baseline_model:model survived(event="1")= ;
*roc 'Model predictions of the Hold Out Sample' pred=phat;
*ods select ROCOverlay ROCAssociation;
run; 
ods graphics off;
**************************************;

