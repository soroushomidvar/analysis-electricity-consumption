function [peakTime_n,peakTime_b] = peak_time(hours)
%peak-time
feature_number = 23;
peakTime_n=zeros(24,feature_number);
peakTime_b=zeros(24,feature_number);
hour_size=size(hours);
hour_size_n=0;
hour_size_b=0;
for i=1:hour_size %hour_size(1)
    date_to_string=[num2str(hours(i,1)) '-' num2str(hours(i,2)) '-' num2str(hours(i,3))];
    date=datetime(date_to_string,'InputFormat','yyyy-MM-dd');
    busday=isbusday(date); % is business day? 1: yes, 0: no
    if busday==1
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
end

