function d = paretoFront(file,dims)
%PARETOFRONT Takes a data file and generates a Pareto front plot.
%   The data file is read using readtable; the first two columns of data
%   are used as the x and y values respectively. Any further data supplied
%   is added to a tooltip on the plot. If dims ([width height] in cm) is
%   supplied, figures are exported.
%   
%   Example usage: paretoFront('multiobjective.dat');

% load(file)
d = readtable(file);

% plot data
figure
fig = plot(d{:,1},d{:,2},'-o');

% label axes
ax = gca;
ax.XAxis.Label.String = d.Properties.VariableNames{1};
ax.XAxis.Label.Interpreter = 'none';
ax.YAxis.Label.String = d.Properties.VariableNames{2};
ax.YAxis.Label.Interpreter = 'none';

% dataTip label
dtt = fig.DataTipTemplate;
% first 2 rows of the dataTip represent the xy coords of the plot
for j = 1:2
    dtt.DataTipRows(j).Label = d.Properties.VariableNames{j};
end
% now add all extra information from the data file (if there is any)
if size(d,2) > 2
    for j = 3:size(d,2)
        dtt.DataTipRows(j) = dataTipTextRow(d.Properties.VariableNames{j},d{:,j});
    end
end

if nargin == 2
    figExport(dims(1),dims(2),sprintf('pareto-front-%s-%s',d.Properties.VariableNames{1:2}));
end

end

