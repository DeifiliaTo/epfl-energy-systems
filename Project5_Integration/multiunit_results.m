% Generates usage of each technology per time period
% [Geothermal, HP1stgLT1, 2, 3, HP2stage, PV, cogen]
A = [ 0.150294    0.150294   0.150294    0.150294   0       0.150294;
  10          10         0           0          0       10;
  9.86993     9.86993    1.30705     1.97753    0       9.86993 ;
  10          10         0           1.89662    0       10;
  0.637433    0          0           0          0       0.637433;
  2.7728      2.35895    16.7195     3.64188    4.01435 0;
  0           0          0           0          0       11.4858]

Qheatingsupply = [10000 1000 1000 1000 1000 1000 2800.11]';


for i = 1:length(Qheatingsupply)
    % res is in MWth
    res(i, :) = Qheatingsupply(i)*A(i, :)/1000;
end