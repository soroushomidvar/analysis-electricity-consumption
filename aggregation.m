function [months,days,hours,minutes] = aggregation(myData)
% Start time:
t= datetime(myData(:,1)-25200,'ConvertFrom','posixtime'); %convert Unix time to date
% -28800: diffrence to greenwich
%busday_minute=isbusday(t); % is business day? 1: yes, 0: no
% End time

myData = myData(:,2:end);

myData = normc(myData);
%
s = size(myData);
myData = [myData;zeros(1,s(2))]; %for avoiding loop problems
s = size(myData);
%
E1 = eomday(2012,4:12);
E2 = eomday(2013,1:12);
E3 = eomday(2014,1:3);
endOfMonths=[E1 E2 E3]; %number of days for each month
endOfMonths_i=1;
endOfMonths_size=size(endOfMonths);
for f=1:endOfMonths_size(2)
    if(f>1)
        endOfMonths(f)=endOfMonths(f)+endOfMonths(f-1);
    end
end
%
step=[60, 60*24,60*24*30]; % = 1 hour / 1 day / 1 month
minutes=zeros(s(1),s(2)+5); % +5: year,month,day,hour,minute
hours=zeros(int64(s(1)/step(1)),s(2)+4); % +4: year,month,day,hour
days= zeros(int64(s(1)/step(2)),s(2)+3); % +3: year,month,day
months=zeros(int64(s(1)/step(3)),s(2)+2);% +2: year,month
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
        %mi = minute(t(i)); 
        %h = hour(t(i));
        %d = day(t(i));
        %mo = month(t(i),'monthofyear');
        %y = year(t(i));
        %minutes(i,:)=[y mo d h mi temp];
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

minutes(:,6:end)=myData;

end

