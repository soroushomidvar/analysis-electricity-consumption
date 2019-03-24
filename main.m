clear;
clc;
load ElectricityP.mat;
myData = ElectricityP;
[months,days,hours,minutes] = aggregation(myData);
[cor_minute,cor_hour,cor_day,cor_month] = find_correlation(months,days,hours,minutes);
peak_time(hours);