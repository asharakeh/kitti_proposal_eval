function setlegend( labels, location )
%CUSTOMLEGEND Summary of this function goes here
%   Detailed explanation goes here

try
    switch location
        case {'NorthEast', 'ne'}
            anchor = {'ne', 'ne'};
            buffer = [-5 -5];
        case {'NorthWest', 'nw'}
            anchor = {'nw', 'nw'};
            buffer = [5 -5];
        case {'SouthEast', 'se'}
            anchor = {'se', 'se'};
            buffer = [-5 5];
        case {'SouthWest', 'sw'}
            anchor = {'sw', 'sw'};
            buffer = [5 5];
        otherwise
            anchor = {'ne', 'ne'};
            buffer = [-5 -5];
    end
    legendflex(labels, 'xscale', 0.6, 'box', 'off', 'anchor', anchor, 'buffer', buffer, 'fontsize', 9);
catch
    legend(labels, 'Location', location);
%     legendshrink(0.5);
    legend boxoff;
end

