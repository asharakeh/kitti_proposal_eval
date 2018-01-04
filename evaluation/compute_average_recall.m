
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


function [overlap, recall, AR] = compute_average_recall(unsorted_overlaps)
    all_overlaps = sort(unsorted_overlaps(:)', 'ascend');
    num_pos = numel(all_overlaps);
    dx = 0.001;
  
    overlap = 0:dx:1;
    overlap(end) = 1;
    recall = zeros(length(overlap), 1);
    for i = 1:length(overlap)
      recall(i) = sum(all_overlaps >= overlap(i)) / num_pos;
    end

    good_recall = recall(overlap >= 0.5);
    AR = 2 * dx * trapz(good_recall);
  end
