function part3_hpvent_results 
%% 3.1 Reference

Qheating = [12907, 12643, 1307, 1896, 0, 26688];
Edemand = [3092, 3028, 313, 454, 0, 5321];

%% 3.4 Vent HP-minTC

Qheating_venthp = [11329, 11100.6, 1165.83, 1429.42, 0, 24663.9];
E1_venthp = [2713, 2659, 279, 342, 0, 5908];
E2_venthp = [0.207108, 0.207108, 0.0371087, 0.0286885, 0.0259967, 0.207108];
E_ventHP = zeros(6, 1);
%% 3.4 Vent HP-minOP
Qheating_minOP = [10731.5, 11150.2, 1129.31, 1267.97, 0, 24702];
E_minOP = [2570.81, 2671.12, 270.535, 303.751,  0, 5917.56];


%% Electricity consumption

for i = 1:length(E1_venthp)
   E_ventHP(i, 1) = Edemand(i);
   E_ventHP(i, 2) = E1_venthp(i);
   E_ventHP(i, 3) = E_minOP(i);
end


E_venthp_bar= bar(E_ventHP)
xlabel('Time Period')
ylabel('Electricity consumption [kW]')

legend(E_venthp_bar(:), {'Reference', 'minimize: total cost', 'minimize: operational cost'}, q'Location', 'northwest')
figExport(5, 4, 'E_venthp')


%% Qheating demand
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