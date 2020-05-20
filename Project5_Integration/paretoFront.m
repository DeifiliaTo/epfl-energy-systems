function d = paretoFront(file)
%PARETOFRONT Takes a data file and generates a Pareto front plot.
%   The data file is read using readtable; the first two columns of data
%   are used as the x and y values respectively. Any further data supplied
%   is added to a tooltip on the plot.

% load(file)
d = readtable(file);

% plot data
figure
fig = plot(d{:,1},d{:,2},'-o');

% label axes
ax = gca;
ax.XAxis.Label.String = d.Properties.VariableNames{1};
ax.YAxis.Label.String = d.Properties.VariableNames{2};

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

end

