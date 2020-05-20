function paretoFront(file)
%MULTIOBJECTIVE Summary of this function goes here
%   Detailed explanation goes here

% load(file)
d = readtable(file);

fig = plot(d.CO2,d.TIC);

TC_row = dataTipTextRow('TC',d.TC);
alpha_row = dataTipTextRow('alpha',d.alpha);
fig.DataTipTemplate.DataTipRows(end+1) = TC_row;
fig.DataTipTemplate.DataTipRows(end+1) = alpha_row;
end

