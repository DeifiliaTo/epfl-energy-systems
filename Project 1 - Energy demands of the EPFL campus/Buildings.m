function Build = Buildings(building_name)

%% PREAMBLE
% Course: Modelling and Optimisation of Energy Systems
% Project: Energy demands of the EPFL campus
% Authors: Francesca Belfiore
% Last modified: 18/2-2020
%
% Description: function to CALL to calculate, for A GIVEN building:
% (1) the internal heat gains 
% (2) the building envelope properties (Newton-Raphson)
% (3) the hourly heating demand
% (4) the typical periods (clustering)
%% 

%% DATA MANAGEMENT
%  Do NOT modify

% Initial parameters
h = 8760;                   % Number of hours in a year
T_th = 16;                  % Cut-off temperature of the heating system [�C]
cp_air = 1152;              % Specific heat capacity of the air [J/m3/K] 
T_int = 21;                 % Set point (comfort) temperature [C]
air_new = 2.5;              % Air renewal [m3/m2]
Vent = air_new*cp_air/3600; % Ventilation capacity

% Call of the weather data
filename = 'P1_weatherdata.csv';
data_w = csvread(filename,1,0);
Text = data_w(:,1);         % External temperature [C]
Irr = data_w(:,2);          % Global solar irradiation [W/m2]

% Call of the buildings data
filename = 'P1_buildingsdata.csv';
fid = fopen(filename);
format = '%s%f%f%f%f%f'
data = textscan(fid, format, 'Headerlines', 1, 'delimiter', ',');
name = data{1,1};

% Index and variable definition
index = find(ismember(name, building_name));
Build.ground = data{1,3}(index);    % Building heated surface [m2]
Build.Q = data{1,4}(index);         % Building annual heat load [kWh]
Build.El = data{1,5}(index);        % Building annual electricity consumption [kWh]

%% TASK 1 - Calculation of the internal heat gains (appliances & humans)

% 1.1 - Electronic appliances and lights for each buildings 
Q_el = Build.El*0.8*3654 %[kJ]


% 1.2 - Presence of people (all the buildings are the same)
heat_gain = [5, 35, 23.3, 0]
share         = [0.3, 0.05, 0.35, 0.3]
weight_avg = dot(heat_gain, share)


%% TASK 2 - Calculation of the building thermal properties (kth and ksun)

% First equation - switching ON the heating system

% Second equation - yearly heating demand

% Implementation of the Newton-Raphson method
    
    % Method initialisation
    
    % Resolution

%% TASK 3 - Estimation of the hourly profile    

% Hourly demand (thermal load)

%% TASK 4 - Clustering of the heating demand
% based on the hourly heating demand (typical periods)
