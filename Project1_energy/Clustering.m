clear all;
close all;
clc;

% Analysis to cluster Text and Irr
% From 7 am to 9 pm (from Monday to Friday)

% Extracting data from Excel sheet
filename = 'P1_weatherdata.csv';
data_w = csvread(filename,1,0);
Text = data_w(:,1);% External temperature [C]
Irr = data_w(:,2); % Global solar irradiation [W/m2]
t_hour = (1:1:8760); % Vector of hour for the year
t_day = (1:1:365); % Vetcor of day for the year


% % Normalization of Text and Irr

% Normalization of Text
Text_min = min (Text);
Text_max = max (Text);
Text_norm = (Text - Text_min)/(Text_max - Text_min);

% Normalization of Irr
Irr_min = min (Irr);
Irr_max = max (Irr);
Irr_norm = (Irr - Irr_min)/(Irr_max - Irr_min);


% % Sorting Text_norm and Irr_norm into Weather_norm

% Weather_norm is a matrix of 365 lines and 28 columns
% The 14 first columns (1 to 14) contain the normalized hourly temperature
% of the 365 days
% The 14 last columns (15 to 28) contain the normalized hourly irradiance
% of the 365 days

Weather_norm = zeros (365,28);

% Extracting temperature and irradiance at each hour throughout the year
for i = 1:14
    for j = 1:365
        Weather_norm (j,i) = Text_norm(7 + i + (j-1)*24);
        Weather_norm (j,(14 + i)) = Irr_norm(7 + i + (j-1)*24);
    end
end

% From the experimental data, the heating is off from day 151 to 250: 100
% days of summer
Weather_norm_select = [Weather_norm(1:150,:); Weather_norm(251:365,:)];


% % kmeans clustering and indicators

% Clustering into 4 typical days
% idx contains the index refering to one of the 4 typical days
% C contains the 28 Text_norm and Irr_norm of the 4 typical days
[idx, C_4, Dev_4] = kmeans (Weather_norm_select, 4);

% Profile deviation for each typical period of the kmean

Freq_4 = zeros (max(idx),1);
Dev_std_4 = zeros (max(idx),1);

for i = 1:max(idx)
    Cluster_idx = idx == i;
    Days_i = Weather_norm_select (Cluster_idx, :);
    
    % Frequency of typical day
    Freq_4 (i) = sum (Cluster_idx);
    
    % Standard deviation
    Dev_std_4 (i) = sum( sum( (Days_i - C_4 (i,:)).^2));
end

% Typical summer day
SummerDay = mean (Weather_norm (151:250,:),1);
Freq_summer = 250 - 150;
Dev_summer = sum( sum( (Weather_norm (151:250,:) - SummerDay).^2));

% Extreme: coldest day
Cool_idx = find (min(Weather_norm(:,1:14),[],2) == min(min(Weather_norm(:,1:14),[],2)));
CoolDay = Weather_norm (Cool_idx,:);

% Typical days
TypDays_norm_kmean = [C_4; SummerDay; CoolDay];
TypText_kmean = TypDays_norm_kmean (:,1:14)*(Text_max - Text_min) + Text_min;
TypIrr_kmean = TypDays_norm_kmean (:,15:28)*(Irr_max - Irr_min) + Irr_min;

% Frequency for each typical period of the year
Freq_kmean = [Freq_4; Freq_summer; 1];

% Profile deviation for each typical period of the year
DevPart_kmean = [Dev_4; Dev_summer; 0];

% Profile deviation for the entire year
DevTot_kmean = sum(DevPart_kmean);

% Maximum load duration curve difference



%% Clustering without kmeans

% Clustering into 6 period

% January-February
for j=1:1460
    Text_season(j,1) = Text(j);
    Irr_season(j,1) = Irr(j);
end

% March-April
for j=1461:2920
    Text_season(j-1460,2) = Text(j);
    Irr_season(j-1460,2) = Irr(j);
end

% May-June
for j=2921:4380
    Text_season(j-2920,3) = Text(j);
    Irr_season(j-2920,3) = Irr(j);
end

% July-August
for j=4381:5840
    Text_season(j-4380,4) = Text(j);
    Irr_season(j-4380,4) = Irr(j);
end

% September-October
for j=5841:7300
    Text_season(j-5840,5) = Text(j);
    Irr_season(j-5840,5) = Irr(j);
end

% November-December
for j=7301:8760
    Text_season(j-7300,6) = Text(j);
    Irr_season(j-7300,6) = Irr(j);
end

%We calculate the average for each season
Text_mean = mean(Text_season);
Irr_mean = mean(Irr_season);

% Create new vectors which are the average of the temperature and 
% the irradiation in hours 
for j=1:1460
    Text_season_avg(j,1) = Text_mean(1);
    Irr_season_avg(j,1) = Irr_mean(1);
end

for j=1461:2920
    Text_season_avg(j,1) = Text_mean(2);
    Irr_season_avg(j,1) = Irr_mean(2);
end

for j=2921:4380
    Text_season_avg(j,1) = Text_mean(3);
    Irr_season_avg(j,1) = Irr_mean(3);
end

for j=4381:5840
    Text_season_avg(j,1) = Text_mean(4);
    Irr_season_avg(j,1) = Irr_mean(4);
end

for j=5841:7300
    Text_season_avg(j,1) = Text_mean(5);
    Irr_season_avg(j,1) = Irr_mean(5);
end

for j=7301:8760
    Text_season_avg(j,1) = Text_mean(6);
    Irr_season_avg(j,1) = Irr_mean(6);
end

% % Indicator

Dev_Average = sum( sum( ( (Text - Text_season_avg)/(Text_max - Text_min) ).^2 + ...
    ( (Irr - Irr_season_avg)/(Irr_max - Irr_min) ).^2 ) );

% Tenir compte de la température extérieure
k = 1;
for i = 1:8760
    u = mod(i,168);
    if mod(u,24)>20 && Text(i)<=16||mod(u,24)<8 && Text(i)<=16
        Tzero(k,1) = i;
        Tzero(k,2) = Text(i);
        Tzero(k,3) = Irr(i);
        k = k+1;
    elseif u>127 && u<141 && Text(i)<=16||u>151 && u<165 && Text(i)<=16
        Tzero(k,1) = i;
        Tzero(k,2) = Text(i);
        Tzero(k,3) = Irr(i);
        k=k+1;
    elseif Text(i)>16
        Tzero(k,1) = i;
        Tzero(k,2) = Text(i);
        Tzero(k,3) = Irr(i);
        k = k+1;
    end
end

% Plot of the temperature
figure(1)
plot(t_hour,Text,'b.');              %in blue the real data
hold on;
plot(Tzero(:,1),Tzero(:,2),'c.')
hold on;
plot(t_hour,Text_season_avg,'r.');       %in red the mean value over a season
xlabel 'Time [hours]';
ylabel 'Text [°C]'; 
legend('Text','zero','Mean');
hold off;

% Plot of the irradiation
figure(2)
plot(t_hour,Irr,'b.');              %in blue the real data
hold on;
plot(Tzero(:,1),Tzero(:,3),'c.')
hold on;
plot(t_hour,Irr_season_avg,'r.');   %in red the mean value over a season
xlabel 'Time [hours]';
ylabel 'Irradiation [W/m2]'; 
legend('Irr','zero','Mean');
hold off;

% % Normalization of Text_season and Irr-season

% Normalization of Text
Text_min = min (Text);
Text_max = max (Text);
Text_norm_season = (Text_season - Text_min)/(Text_max - Text_min);

% Normalization of Irr
Irr_min = min (Irr);
Irr_max = max (Irr);
Irr_norm_season = (Irr_season - Irr_min)/(Irr_max - Irr_min);

%Plot Clustering without kmeans
figure(3)
plot(Text_norm_season(:,1),Irr_norm_season(:,1),'b.');
hold on;
plot(Text_norm_season(:,2),Irr_norm_season(:,2),'r.');
hold on;
plot(Text_norm_season(:,3),Irr_norm_season(:,3),'y.');
hold on;
plot(Text_norm_season(:,4),Irr_norm_season(:,4),'g.');
hold on;
plot(Text_norm_season(:,5),Irr_norm_season(:,5),'m.');
hold on;
plot(Text_norm_season(:,6),Irr_norm_season(:,6),'k.');
hold on;
xlabel 'Temperature normalized';
ylabel 'Irradiation normalized'; 
legend('Jan-Feb','Mar-Apr','May-Jun','Jul-Aug','Sep-Oct','Nov-Dec');
hold off;