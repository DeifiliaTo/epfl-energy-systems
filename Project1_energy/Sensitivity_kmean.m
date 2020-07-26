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
%n = 4;
Colours = {'b.', 'r.', 'y.', 'g.', 'm.', 'c.', 'k*'};


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
    
    t_day ( ((i-1)*14 +1):((i-1)*14 +14) ) = ...
        t_hour ( ((i-1)*24 + 8):((i-1)*24 + 21) );
    
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
t_heated = t_day(T_norm_idx);
Weather_norm_select = [Text_norm_heated, Irr_norm_heated];

% Vector containing the temperature and the irradiance not to be clustered
Text_norm_notheated = Text_norm_day (~T_norm_idx);
Irr_norm_notheated = Irr_norm_day (~T_norm_idx);
t_notheated = t_day(~T_norm_idx);
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

DevTot_kmean = NaN(10,1);

for n = 1:10

    % Clustering into 4 typical hour periods
    [idx_C, Weather_norm_C] = kmeans (Weather_norm_select, n);

    % Profile deviation for each typical period of the kmean
    Freq_C = zeros (n,1);
    Dev_C = zeros (n,1);

    for i = 1:n
        Cluster_idx = idx_C == i;
        Period_C_i = Weather_norm_select (Cluster_idx, :);

        % Standard deviation
        Dev_C (i) = sum( sum( (Period_C_i - Weather_norm_C (i,:)).^2 ) );
    end

    % Profile deviation for each typical period of the year
    DevPart_kmean = [Dev_C; Dev_hot; Dev_cold];

    % Profile deviation for the entire year
    DevTot_kmean(n) = sum(DevPart_kmean);

end

%DevTot_kmean = [298.3, 225.0, 204.0, 191.4, 186.4, ...
%    182.1, 179.3, 175.7, 173.5, 172.5];

plot((3:1:12), DevTot_kmean, 'blue')
xlabel 'Number of clusters';
ylabel 'Total squared error';
hold on
scatter((3:1:12), DevTot_kmean, 'filled', 'MarkerFaceColor', 'red')

