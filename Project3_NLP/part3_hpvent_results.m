function part3_hpvent_results
%% 3.1 Reference

Qheating = [12907, 12643, 1307, 1896, 0, 26688];
Edemand = [3092, 3028, 313, 454, 0, 6393];

%% 3.2 DC
Qrad_DC = [309.78, 309.731, 287.793, 295.593, 0, 311];
Qheating_DC = zeros(6, 1);
for i = 1:6
    Qheating_DC(i) = Qheating(i) - Qrad_DC(i);
end
E_DC = [3040.76, 2977.5, 257.096, 400.202, 0, 6342.34];

%% 3.3 Vent-minTC
E_Vent = [3091.88, 3028.63, 313.102, 454.312, 0, 6393.13];
Qheating_Vent = [12906.6, 12642.6, 1307, 1896.46, 0, 26687.2];

%% 3.3 Vent-minOP
E_Vent_minOP = [2548.08, 2497.71, 270.927, 308.515, 0, 5731.57];
Qheating_Vent_minOP = [10636.6, 10426.3, 1130.95, 1287.85, 0, 23925.6];

%% 3.4 Vent HP-minTC
Qheating_venthp = [11329, 11100.6, 1165.83, 1429.42, 0, 24663.9];
E1_venthp = [2713, 2659, 279, 342, 0, 5908];
E2_venthp = [0.207108, 0.207108, 0.0371087, 0.0286885, 0.0259967, 0.207108];
E_ventHP = zeros(6, 1);

%% 3.4 Vent HP-minOP
Qheating_minOP = [10731.5, 11150.2, 1129.31, 1267.97, 0, 24702];
E_minOP = [2570.81, 2671.12, 270.535, 303.751,  0, 5917.56];

%% 3.2 Electricity consumption

E_DC_ref = zeros(1,1);
for i = 1:length(E1_venthp)
    E_DC_ref(i, 1) = Edemand(i);
    E_DC_ref(i, 2) = E_DC(i);
end

E_DC_bar = bar(E_DC_ref)
xlabel('Time Period')
ylabel('Electricity Consumption [kW]')

legend(E_DC_bar(:), {'Reference', 'DC'}, 'Location', 'northwest')
figExport(5, 4, 'E_DC')

%% 3.3 Electricity consumption

E_Vent_ref = zeros(6,3);
for i = 1:length(Edemand)
    E_Vent_ref(i, 1) = Edemand(i);
    E_Vent_ref(i, 2) = E_Vent(i);
    E_Vent_ref(i, 3) = E_Vent_minOP(i);
end

E_Vent_bar = bar(E_Vent_ref)
xlabel('Time Period')
ylabel('Electricity Consumption [kW]')

legend(E_Vent_bar(:), {'Reference', 'minimize: total cost', 'minimize: operational cost'}, 'Location', 'northwest')
figExport(5, 4, 'E_Vent')

%% 3.4 Electricity consumption

for i = 1:length(E1_venthp)
    E_ventHP(i, 1) = Edemand(i);
    E_ventHP(i, 2) = E1_venthp(i);
    E_ventHP(i, 3) = E_minOP(i);
end

E_venthp_bar= bar(E_ventHP)
xlabel('Time Period')
ylabel('Electricity consumption [kW]')

legend(E_venthp_bar(:), {'Reference', 'minimize: total cost', 'minimize: operational cost'}, 'Location', 'northwest')
figExport(5, 4, 'E_venthp')

%% 3.2 Qheating demand

Q_DC_ref = zeros(1,1);
for i = 1:length(E1_venthp)
    Q_DC_ref(i, 1) = Qheating(i);
    Q_DC_ref(i, 2) = Qheating_DC(i);
end

Q_DC_bar = bar(Q_DC_ref)
xlabel('Time Period')
ylabel('Heating demand [kW]')

legend(Q_DC_bar(:), {'Reference', 'DC'}, 'Location', 'northwest')
figExport(5, 4, 'Q_DC')

%% 3.3 Qheating demand

Q_Vent_ref = zeros(6,3);
for i = 1:length(E1_venthp)
    Q_Vent_ref(i, 1) = Qheating(i);
    Q_Vent_ref(i, 2) = Qheating_Vent(i);
    Q_Vent_ref(i, 3) = Qheating_Vent_minOP(i);
end

Q_Vent_bar = bar(Q_Vent_ref)
xlabel('Time Period')
ylabel('Heating demand [kW]')

legend(Q_Vent_bar(:), {'Reference', 'minimize: total cost', 'minimize: operational cost'}, 'Location', 'northwest')
figExport(5, 4, 'Q_Vent')

%% 3.4 Qheating demand

Q_consolidate = zeros(1,1);
for i = 1:length(E1_venthp)
    Q_consolidate(i, 1) = Qheating(i);
    Q_consolidate(i, 2) = Qheating_venthp(i);
    Q_consolidate(i, 3) = Qheating_minOP(i);
end

Q_bar = bar(Q_consolidate)
xlabel('Time Period')
ylabel('Heating demand [kW]')

legend(Q_bar(:), {'Reference', 'minimize: total cost', 'minimize: operational cost'}, 'Location', 'northwest')
figExport(5, 4, 'Q_venthp')

end

function figExport(w,h,name)
fig = gcf;
fig.PaperOrientation = 'landscape';
fig.PaperSize = [w h];
fig.PaperPosition = [0 0 w h];
% fig.Renderer = 'Painters'; % for 3D plots
print(gcf, '-dpdf', [pwd '/figures/' name '.pdf']);
end