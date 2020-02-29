clear all
clc

% Analysis to cluster Text and Irr
% From 7 am to 9 pm (from Monday to Friday)

% Extracting data from Excel sheet
filename = 'P1_weatherdata.csv';
data_w = csvread(filename,1,0);
Text = data_w(:,1);% External temperature [C]
Irr = data_w(:,2); % Global solar irradiation [W/m2]
t_hour = (1:1:8760); % Vector of hour for the year
t_day = (1:1:365); % Vetcor of day for the year


%% Normalization of Text and Irr

% Normalization of Text
Text_min = min (Text);
Text_max = max (Text);
Text_norm = (Text - Text_min)/(Text_max - Text_min);

% Normalization of Irr
Irr_min = min (Irr);
Irr_max = max (Irr);
Irr_norm = (Irr - Irr_min)/(Irr_max - Irr_min);


%% Sorting Text_norm and Irr_norm into Weather_norm

% Weather_norm is a matrix of 365 columns and 48 lines
% The 24 first lines (1 to 24) contain the hourly temperature of the 365
% days
% The 24 last lines (25 to 48) contain the hourly irradiance of the 365
% days

Weather_norm = zeros (48,365);

% Extracting temperature and irradiance at each hour throughout the year
for i = 1:24
    for j = 1:365
        Weather_norm (i,j) = Text_norm(i + (j-1)*24);
        Weather_norm ((24 + i),j) = Irr_norm(i + (j-1)*24);
    end
end


%% kmeans clustering




