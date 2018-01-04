
% 
% Copyright (C) 2015  Xiaozhi Chen, Kaustav Kundu, Yukun Zhu, Andrew Berneshawi, Huimin Ma, Sanja Fidler, Raquel Urtasun
% Website: http://www.cs.toronto.edu/objprop3d/
% 
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.


function [ db_filtered, sel_ids ] = dbFilter(db, categories, level, rm_empty)

cls = 0;
if ischar(categories) && ~isempty(categories)
    cls = db.labelMap(categories);
else
    for i = 1 : length(categories)
        cls(i) = db.labelMap(categories{i});
    end
end

if nargin < 4
    rm_empty = true;
end

db_filtered = db;
he = [40 25 25];
oc = [0 1 2];
tr = [0.15 0.3 0.5];
sel_ids = true(length(db.impos),1);
for i = 1 : length(db.impos)
    if cls == 0
        keep = true(length(db.impos(i).types), 1);
    else
        keep = ismember(db.impos(i).types, cls);
    end
    
    if nargin > 2 && ~isempty(keep)
        height = db.impos(i).boxes(:,4) - db.impos(i).boxes(:,2) + 1;
        level_filter = height >= he(level) & db.impos(i).occluded <= oc(level) & db.impos(i).truncated <= tr(level);
        keep = keep & level_filter;
    end
    
    db_filtered.impos(i).types = db.impos(i).types(keep);
    db_filtered.impos(i).boxes = db.impos(i).boxes(keep, :);
    db_filtered.impos(i).sizes = db.impos(i).sizes(keep, :);
    db_filtered.impos(i).truncated = db.impos(i).truncated(keep, :);
    db_filtered.impos(i).occluded = db.impos(i).occluded(keep, :);
    db_filtered.impos(i).alpha = db.impos(i).alpha(keep, :);
    db_filtered.impos(i).sizes3D = db.impos(i).sizes3D(keep, :);
    db_filtered.impos(i).t = db.impos(i).t(keep,:);
    db_filtered.impos(i).ry = db.impos(i).ry(keep);
    if nnz(keep) == 0
        sel_ids(i) = false;
    end
end

if rm_empty
    db_filtered.impos = db_filtered.impos(sel_ids);
end
sel_ids = find(sel_ids);

end

