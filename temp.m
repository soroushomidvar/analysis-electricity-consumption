clear;
clc;
load Climate_HourlyWeather.mat
temperature = double(table2array(ClimateHourlyWeather(:,7)));
temp_size=size(temperature);
for i=2:temp_size(1)
    if isnan(temperature(i,1))
        temperature(i,1)=temperature(i-1,1);
    end
end
% Test for NaN:
[row, col] = find(isnan(temperature));

%clustering temrature:



k=5;
%K-Means
[temperature_kmeans_IDX, temperature_kmeans_C]=kmeans(temperature(:,1),k,'Distance','cityblock','Display','iter');

[silh4,h] = silhouette(temperature(:,1),temperature_kmeans_IDX,'cityblock');
h = gca;
h.Children.EdgeColor = [.8 .8 1];
xlabel 'Silhouette Value'
ylabel 'Cluster'

%

% epsilon=0.5;
% MinPts=10;
% IDX=DBSCAN(temperature(:,1),epsilon,MinPts);

%

temperature_MinMax=[-inf(1,k);inf(1,k)];

for i=2:temp_size(1)
    if temperature_MinMax(1,temperature_kmeans_IDX(i))<temperature(i)
        temperature_MinMax(1,temperature_kmeans_IDX(i))=temperature(i);
    end
    if temperature_MinMax(2,temperature_kmeans_IDX(i))>temperature(i)
        temperature_MinMax(2,temperature_kmeans_IDX(i))=temperature(i);
    end
end
%max min centroid
final_temprature_class=[temperature_MinMax; temperature_kmeans_C'];