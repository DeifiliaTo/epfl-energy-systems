function d = sensitivityPlot(file,dims)
%SENSITIVITYPLOT Takes a data file and generates a sensitivity plot
%   Data file is read using readtable. Columns / variables are interpreted
%   as follows
%       Col     Usage
%       1       category string (name of variable being changed)
%       2       multiplication factor of dependent variable (plot: X2)
%       3       adjusted value of dependent variable (plot: X1)
%       4       dependent variable value
%   If dims ([width height] in cm) is supplied, figures are exported.
%
%   Example usage: sensitivityPlot('sensitivity_TC_c_spec.dat');


% load(file)
d = readtable(file);

% find unique varnames from column 1
uniqueVars = unique(d{:,1});

for j = 1:numel(uniqueVars)
    var = string(uniqueVars{j});
    
    % filter table for this varname
    d_ = d(string(d{:,1})==var,:);
    % sort by ascending var value
    d_ = sortrows(d_,3);
    
    % make the plot
    figure
    plot(d_{:,3},d_{:,4},'-o');
    
    % format
    ax1 = gca;
    ax1.Box = 'off';
    
    % ax1.XTick = d_{:,3};
    ax1.XAxis.Label.String = sprintf('%s : %s',d.Properties.VariableNames{3},var);
    ax1.XAxis.Label.Interpreter = 'none';
    
    ax1.YAxis.Label.String = d.Properties.VariableNames{4};
    ax1.YAxis.Label.Interpreter = 'none';
    
    
    % add extra axes
    ax2 = axes('Position',ax1.Position,...
        'XAxisLocation','top',...
        'YAxisLocation','right',...
        'Color','none');
    
    % X2: add ticks for alpha
    ax2.XTick = d_{1:2:end,3};
    ax2.XTickLabel = d_{1:2:end,2};
    ax2.XLim = ax1.XLim;
    % ax2.XAxis.Label.String = d.Properties.VariableNames{2};
    % ax2.XAxis.Label.Interpreter = 'none';
    
    % Y2: sync lims
    ax2.YLim = ax1.YLim;
    ax2.YTick = {};
    
    % link both sets of axes together
    linkaxes([ax1 ax2],'xy');

    % export
    if nargin == 2
        figExport(dims(1),dims(2),sprintf('sensitivity-%s-%s',d.Properties.VariableNames{3},var));
    end
end


end

