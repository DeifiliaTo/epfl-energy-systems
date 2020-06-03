clearvars;
close all;
clc;

% Analysis to cluster Text and Irr
% From 7 am to 9 pm (from Monday to Friday)

%% Data extraction

% Extracting data from Excel sheet
filename = 'P1_weatherdata.csv';
data_w = csvread(filename,1,0);
Text = data_w(:,1);% External temperature [C]
Irr = data_w(:,2); % Global solar irradiation [W/m2]
t_hour = (1:1:length(Text)); % Vector of hour for the year
T_th = 16;
n = 4;
Colours = {'b.', 'r.', 'y.', 'g.', 'm.', 'c.', 'k*'};

% Graph of temperature and irradiance
figure(1)
plot(t_hour,Text);
xlabel 'Time [hours]';
ylabel 'Text [�C]'; 
saveas(figure(1),"plots/text_year.png")

figure(2)
plot(t_hour,Irr);             
hold on;
xlabel 'Time [hours]';
ylabel 'Irradiation [W/m2]';
saveas(figure(2),"plots/irr_year.png")


%% Normalization of Text and Irr

% Normalization of Text
Text_min = min (Text);
Text_max = max (Text);
Text_norm = (Text - Text_min)/(Text_max - Text_min);

% Normalization of Irr
Irr_min = min (Irr);
Irr_max = max (Irr);
Irr_norm = (Irr - Irr_min)/(Irr_max - Irr_min);


%% Hours selection

% Extraction of data corresponding to daylight hours (from 7 am to 9 pm)

Text_norm_day = zeros (365*14, 1);
Irr_norm_day = zeros (365*14, 1);

for i = 1:365
    
    % Extraction of temperature
    Text_norm_day ( ((i-1)*14 +1):((i-1)*14 +14) ) = ...
        Text_norm ( ((i-1)*24 + 8):((i-1)*24 + 21) );
    
    % Extraction of irradiance
    Irr_norm_day ( ((i-1)*14 +1):((i-1)*14 +14) ) = ...
        Irr_norm ( ((i-1)*24 + 8):((i-1)*24 + 21) );

end

% Identification of data corresponding to heated daylight hours (Text < 16)
% and not heated daylight hours
T_th_norm = (T_th - Text_min)/(Text_max - Text_min);
T_norm_idx = Text_norm_day < T_th_norm;

% Vector containing the temperature and the irradiance to be clustered
Text_norm_heated = Text_norm_day (T_norm_idx);
Irr_norm_heated = Irr_norm_day (T_norm_idx);
Weather_norm_select = [Text_norm_heated, Irr_norm_heated];

% Vector containing the temperature and the irradiance not to be clustered
Text_norm_notheated = Text_norm_day (~T_norm_idx);
Irr_norm_notheated = Irr_norm_day (~T_norm_idx);
Weather_norm_nonselect = [Text_norm_notheated, Irr_norm_notheated];


%% Typical hot period (Text > 16)

Weather_norm_hot = mean (Weather_norm_nonselect);
Freq_hot = length (Text_norm_notheated);
Dev_hot = sum( sum( (Weather_norm_nonselect - Weather_norm_hot).^2 ) );


%% Typical coldest period (extreme)

Cool_idx = find (Text_norm_heated == min(Text_norm_heated));
Weather_norm_cold = Weather_norm_select(Cool_idx,:);
Freq_cold = 1;
Dev_cold = 0;


%% Clustering by kmeans

% Clustering into 4 typical hour periods
[idx_C, Weather_norm_C] = kmeans (Weather_norm_select, n);

% Profile deviation for each typical period of the kmean
Freq_C = zeros (n,1);
Dev_C = zeros (n,1);

for i = 1:n
    Cluster_idx = idx_C == i;
    Period_C_i = Weather_norm_select (Cluster_idx, :);
    
    % Frequency of typical day
    Freq_C (i) = sum (Cluster_idx);
    
    % Standard deviation
    Dev_C (i) = sum( sum( (Period_C_i - Weather_norm_C (i,:)).^2 ) );
end

% Typical periods
TypWeather_norm_kmean = [Weather_norm_C; Weather_norm_hot; Weather_norm_cold];
TypText_kmean = TypWeather_norm_kmean (:,1)*(Text_max - Text_min) + Text_min;
TypIrr_kmean = TypWeather_norm_kmean (:,2)*(Irr_max - Irr_min) + Irr_min;
TypWeather_kmean = [TypText_kmean, TypIrr_kmean];

% Frequency for each typical period of the year
Freq_kmean = [Freq_C; Freq_hot; Freq_cold];

% Profile deviation for each typical period of the year
DevPart_kmean = [Dev_C; Dev_hot; Dev_cold];

% Profile deviation for the entire year
DevTot_kmean = sum(DevPart_kmean);

% Maximum load duration curve difference
% t_select = (1:1:length(Text_norm_day));
% Tt_sort = sort ([TypText_kmean,Freq_kmean],'descend');
% 
% figure(3)
% plot (t_select, sort(Text_norm_day,'descend')*(Text_max - Text_min) + Text_min, 'k.')
% hold on


%% Graph kmean clustering

figure(4)
for i = 1:n
    
    % Identification of periods relative to cluster i
    Cluster_idx = idx_C == i;
    
    % Plot of the periods
    plot (Weather_norm_select(Cluster_idx,1), Weather_norm_select(Cluster_idx,2), Colours{i});
    hold on
end

% Plot hot periods
plot (Weather_norm_nonselect(:,1), Weather_norm_nonselect(:,2), Colours {n + 1})
hold on

% Plot cold period
plot (Weather_norm_cold (1), Weather_norm_cold(2), Colours {n + 2})
hold on

% Plot typical periods
plot (TypWeather_norm_kmean(:,1), TypWeather_norm_kmean(:,2), Colours {n + 3}, 'LineWidth', 1.5)

xlabel 'Temperature normalized';
ylabel 'Irradiance normalized'; 
legend('Kmean cluster 1','Kmean cluster 2','Kmean cluster 3','Kmean cluster 4','Hot period','Cold period', 'Centroids',...
    'FontSize', 12, 'Location', 'northwest');
hold off;
saveas(figure(4),"plots/Cluster_k.png")


%% Clustering by average

Weather_norm_Av = zeros (n,2);
Dev_Av = zeros (n,1);

Delta = floor( (length (Text_norm_heated))/n);
Freq_Av = [repmat(Delta, (n-1), 1); (length (Text_norm_heated) - Delta*(n-1))];

for i = 1:n
    
    % Upper and lower limit of the period
    Lim_l = sum(Freq_Av(1:i)) - Freq_Av(i) + 1;
    Lim_u = sum(Freq_Av(1:i));
    
    % Extraction of the data from the period and average
    Period_Av_i = Weather_norm_select((Lim_l:Lim_u),:);
    Weather_norm_Av (i,:) = mean (Period_Av_i);
    
    % Standard deviation
    Dev_Av (i) = sum( sum( (Period_Av_i - Weather_norm_Av (i,:)).^2 ) );
    
end

% Typical periods
TypWeather_norm_Av = [Weather_norm_Av; Weather_norm_hot; Weather_norm_cold];
TypText_Av = TypWeather_norm_Av (:,1)*(Text_max - Text_min) + Text_min;
TypIrr_Av = TypWeather_norm_Av (:,2)*(Irr_max - Irr_min) + Irr_min;
TypWeather_Av = [TypText_Av, TypIrr_Av];

% Frequency for each typical period of the year
Freq_Av = [Freq_Av; Freq_hot; Freq_cold];

% Profile deviation for each typical period of the year
DevPart_Av = [Dev_Av; Dev_hot; Dev_cold];

% Profile deviation for the entire year
DevTot_Av = sum(DevPart_Av);

% Maximum load duration curve difference


%% Graph average clustering

figure(5)
for i = 1:n
    
    % Upper and lower limit of the period
    Lim_l = sum(Freq_Av(1:i)) - Freq_Av(i) + 1;
    Lim_u = sum(Freq_Av(1:i));
    
    % Plot of the periods
    plot (Weather_norm_select((Lim_l:Lim_u),1), Weather_norm_select((Lim_l:Lim_u),2), Colours{i});
    hold on
end

% Plot hot periods
plot (Weather_norm_nonselect (:,1), Weather_norm_nonselect(:,2), Colours {n + 1})
hold on

% Plot cold period
plot (Weather_norm_cold (1), Weather_norm_cold(2), Colours {n + 2})
hold on

% Plot typical periods
plot (TypWeather_norm_Av (:,1), TypWeather_norm_Av (:,2), Colours {n + 3}, 'LineWidth', 1.5)

xlabel 'Temperature normalized';
ylabel 'Irradiance normalized'; 
legend('Average cluster 1','Average cluster 2','Average cluster 3','Average cluster 4','Hot period','Cold period', 'Centroids',...
    'FontSize', 12, 'Location', 'northwest');
hold off;
saveas(figure(5),"plots/Cluster_av.png")



