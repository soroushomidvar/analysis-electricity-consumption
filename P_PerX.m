clear;
clc;
load ElectricityP.mat;
load temperature_IDX.mat;
load('temperature_IDX.mat', 'temperature_kmeans_IDX');
% temperature
tempToMinute = repelem(temperature_kmeans_IDX(:,1),60);
%
% Start time:
t= datetime(ElectricityP(:,1)-25200,'ConvertFrom','posixtime'); %convert Unix time to date
% -28800: diffrence to greenwich
busday_minute=isbusday(t); % is business day? 1: yes, 0: no
% End time

%myData = [year(t),month(t),day(t),hour(t),minute(t),busday,tempToMinute,ElectricityP(:,2:end)];
myData = ElectricityP(:,2:end);
%
myData = normc(myData);
%
s = size(myData);
myData = [myData;zeros(1,s(2))];
s = size(myData);
E1 = eomday(2012,4:12);
E2 = eomday(2013,1:12);
E3 = eomday(2014,1:3);
endOfMonths=[E1 E2 E3];
endOfMonths_i=1;
endOfMonths_size=size(endOfMonths);
for f=1:endOfMonths_size(2)
    if(f>1)
        endOfMonths(f)=endOfMonths(f)+endOfMonths(f-1);
    end
end
%
step=[60, 60*24,60*24*30]; % = 1 hour / 1 day / 1 month
hours=zeros(int64(s(1)/step(1)),s(2)+4);
%size(hours)
days= zeros(int64(s(1)/step(2)),s(2)+3);
months=zeros(int64(s(1)/step(3)),s(2)+2);
stateNumber=size(step);
%

%
hour_i=1;
day_i=1;
month_i=1;
%
busday_hour=zeros(int64(s(1)/step(1)),1);
busday_day=zeros(int64(s(1)/step(2)),1);
%
temp=zeros(1,s(2));
minuteCounter=1;
hourCounter=1;
dayCounter=1;
for i=1:s(1)
    temp=temp+myData(i,:);
    if (minuteCounter==61)
        h = hour(t(i-step(1)/2));
        d = day(t(i-step(1)/2));
        m = month(t(i-step(1)/2),'monthofyear');
        y = year(t(i-step(1)/2));
        busday_hour(hour_i,1)=isbusday(t(i-step(1)/2));
        %         isbusday=myData(i-step(1)/2,6);
        %         temperature=myData(i-step(1)/2,7);
        hours(hour_i,:)=[y m d h temp];
        days(day_i,4:end)=days(day_i,4:end)+temp;
        months(month_i,3:end)=months(month_i,3:end)+temp;
        minuteCounter=1;
        hour_i=hour_i+1;
        hourCounter=hourCounter+1;
        if (hourCounter==25)
            d = day(t(i-step(2)/2));
            m = month(t(i-step(2)/2),'monthofyear');
            y = year(t(i-step(2)/2));
            busday_day(day_i,1)=isbusday(t(i-step(2)/2));
            days(day_i,1:3)=[y m d];
            hourCounter=1;
            dayCounter=dayCounter+1;
            day_i=day_i+1;
            if(dayCounter==endOfMonths(endOfMonths_i)+1)
                m = month(t(i-step(3)/2),'monthofyear');
                y = year(t(i-step(3)/2));
                months(month_i,1:2)=[y m];
                month_i=month_i+1;
                endOfMonths_i=endOfMonths_i+1;
            end
        end
        temp=zeros(1,s(2));
    end
    minuteCounter=minuteCounter+1;
end

% for k=1:stateNumber(2)
%     j=1;
%     step_i=1;
%     %final= zeros(int64(s(1)/step),s(2));
%     temp=zeros(1,s(2));
%     for i=1:s(1)
%         temp=temp+myData(i,:);
%         if (j==step(k)+1)
%             j=1;
%             %final(step_i,:)=temp;
%             switch k
%                 case 1
%                     h = hour(t(i-step(k)/2));
%                     d = day(t(i-step(k)/2));
%                     m = month(t(i-step(k)/2),'monthofyear');
%                     y = year(t(i-step(k)/2));
%                     hours(step_i,:)=[y m d h temp];
%                 case 2
%                     d = day(t(i-step(k)/2));
%                     m = month(t(i-step(k)/2),'monthofyear');
%                     y = year(t(i-step(k)/2));
%                     days(step_i,:)=[y m d temp];
%                 case 3
%                     m = month(t(i-step(k)/2),'monthofyear');
%                     y = year(t(i-step(k)/2));
%                     months(step_i,:)=[y m temp];
%             endmin
%             temp=zeros(1,s(2));
%             step_i=step_i+1;
%         end
%         j=j+1;
%     end
% end

k=3;
%K-Means
[kmeans_IDX, kmeans_C]=kmeans(days(:,4:end)',k);

%FCM
% [fcm_c, fcm_u, fcm_o]=fcm(days(:,4:end)',k);
% colors=hsv(k);

%correlation
cor_minute=zeros(s(2),s(2));
cor_hour=zeros(s(2),s(2));
cor_day=zeros(s(2),s(2));
cor_month=zeros(s(2),s(2));
for i=1:s(2)
    for j=1:s(2)
        if(i~=j)
            R_minute = corrcoef(myData(:,i),myData(:,j)); % :D HPE=HTE 0.89 :| WOE=CWE 78%
            R_hour = corrcoef(hours(:,i+4),hours(:,j+4));
            R_day = corrcoef(days(:,i+3),days(:,j+3));
            R_month = corrcoef(months(:,i+2),months(:,j+2));
            cor_minute(i,j)=R_minute(1,2);
            cor_hour(i,j)=R_hour(1,2);
            cor_day(i,j)=R_day(1,2);
            cor_month(i,j)=R_month(1,2);
        end
    end
end






%peak-time
peakTime_n=zeros(24,s(2));
peakTime_b=zeros(24,s(2));

hour_size=size(hours);
hour_size_n=0;
hour_size_b=0;
for i=1:hour_size %hour_size(1)
    if busday_hour(i,1)==1
        position=hours(i,4)+1;
        peakTime_b(position,:)=peakTime_b(position,:)+hours(i,5:end);
        hour_size_b=hour_size_b+1;
    else
        position=hours(i,4)+1;
        peakTime_n(position,:)=peakTime_n(position,:)+hours(i,5:end);
        hour_size_n=hour_size_n+1;
    end
end
peakTime_n=peakTime_n/hour_size_n;
peakTime_b=peakTime_b/hour_size_b;

plot(peakTime_n(:,1)','-.b')
hold on;
plot(peakTime_b(:,1)','-m')
