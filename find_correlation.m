function [cor_minute,cor_hour,cor_day,cor_month] = find_correlation(months,days,hours,minutes)
%correlation
feature_number = 23;
cor_minute=zeros(feature_number,feature_number);
cor_hour=zeros(feature_number,feature_number);
cor_day=zeros(feature_number,feature_number);
cor_month=zeros(feature_number,feature_number);
for i=1:feature_number
    for j=1:feature_number
        if(i~=j)
            R_minute = corrcoef(minutes(:,i+5),minutes(:,j+5)); 
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
end

