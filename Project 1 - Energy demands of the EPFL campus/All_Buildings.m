function All_Buildings


%% PREAMBLE
% Course: Modelling and Optimisation of Energy Systems
% Project: Energy demands of the EPFL campus
% Authors: Francesca Belfiore
% Last modified: 18/2-2020
%
% Description: Global Matlab function to RUN to calculate, 
% for all buildings:
% (1) the internal heat gains 
% (2) the building envelope properties (Newton-Raphson)
% (3) the hourly heating demand
% (4) the typical periods (clustering)
% based on the Buildings.m file
%% 

%% Initialisation
clear all
close all
clc

%% Data import (Buildings.csv)
filename = 'P1_buildingsdata.csv';
fid = fopen(filename);
format = '%s%f%f%f%f%f';
data = textscan(fid,format,'Headerlines',1,'delimiter',',');
name = data{1,1};
n_build = length(name);

%% Function call (Buildings.m)
% The following can be deleted or uncommented depending on the organisation
% of your Buildings.m file.

for i = 1:n_build
    building_name = name{i,1};
    Build = Buildings(building_name);
    format2 = '%s%s%f%s%f\n';
    Build.kth
    fprintf(fid,format2,building_name,',',Build.kth,',',Build.ksun)
    fclose(fid);
end