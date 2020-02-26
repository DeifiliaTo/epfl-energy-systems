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
    format = '%s%f%f%f%f';
    data = textscan(fid, format, 'Headerlines', 1, 'delimiter', ',');
    name = data{1,1};
    
    % Index and variable definition
    index = find(ismember(name, building_name));
    Build.ground = data{1,3}(index);    % Building heated surface [m2]
    Build.Q = data{1,4}(index);         % Building annual heat load [kWh]
    Build.El = data{1,5}(index);        % Building annual electricity consumption [kWh]
    
    %% TASK 1 - Calculation of the internal heat gains (appliances & humans)
    
    % 1.1 - Electronic appliances and lights for each buildings
    
    % fractional profiles
    p.electric.day.f = [0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1 1 1 1 1 0 0 0 0];
    p.electric.week.f = [repmat(p.electric.day.f,5,1);zeros(2,24)];
    p.electric.year.f = [repmat(p.electric.week.f,52,1);p.electric.day.f];
    
    % total hours (should equal 3654, �1.2.1)
    p.electric.totalHours = sum(p.electric.year.f,'all');
    
    % fraction of electricity demand converted to heat (�1.1)
    f_el = 0.8; %[-]
    
    % hourly heating power of electricals
    Q_el = Build.El * f_el / p.electric.totalHours; %[kW]
    
    % electrical heating profiles
    p.electric.day.v = p.electric.day.f * Q_el;
    p.electric.week.v = p.electric.week.f * Q_el;
    p.electric.year.v = p.electric.year.f * Q_el;
    
    % 1.2 - Presence of people (all the buildings are the same)
    Heat_gain = [5, 35, 23.3, 0];       %[W/m^2]
    Share     = [0.3, 0.05, 0.35, 0.3]; %[-]
    
    % Occupation profile for office, restaurant and classroom from 1 am to 12 pm
    OccProf_Office = [0 0 0 0 0 0 0 0.2 0.4 0.6 0.8 0.8 0.4 0.6 0.8 0.8 0.4 0.2 0 0 0 0 0 0]; %[-]
    OccProf_Rest   = [0 0 0 0 0 0 0 0 0.4 0.2 0.4 1 0.4 0.2 0.4 0 0 0 0 0 0 0 0 0];           %[-]
    OccProf_Class  = [0 0 0 0 0 0 0 0.4 0.6 1 1 0.8 0.2 0.6 1 0.8 0.8 0.4 0 0 0 0 0 0];       %[-]
    
    % Matrix of occupation profile for office, restaurant, classroom and other
    OccProf = [OccProf_Office; OccProf_Rest; OccProf_Class; zeros(1,24)]; %[-]
    
    % Specific heat gain by people for a building from 1 am to 12 pm
    Q_people = sum ((OccProf' .* (Heat_gain .* Share))'); %[W/m^2]
    
    %% TASK 2 - Calculation of the building thermal properties (kth and ksun)
    m_air  = 2.5 % m3/m2h
    
    % First equation - switching ON the heating system
    
        
        % Resolution
        index = 1;
        k0 = [2, 2];
        [k,fval] = fsolve(@(k) q_objective(1, Build.ground, k(1), T_int, Text, k(2), Irr, Q_gain, f_el, Q_el, Build.Q), k0)
    
    
    %% TASK 3 - Estimation of the hourly profile    
    
    % Hourly demand (thermal load)
    
    %% TASK 4 - Clustering of the heating demand
    % based on the hourly heating demand (typical periods)
    
    end
    
