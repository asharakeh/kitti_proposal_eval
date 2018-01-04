

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


function [iou] = overlap(box, boxes)
% compute intersection over union between a single box and a set of boxes

  n_boxes = size(boxes, 1);
  iou = zeros(n_boxes, 1);

  % intersection bbox
  bi = [max(box(1),boxes(:,1)) max(box(2),boxes(:,2)) ...
    min(box(3),boxes(:,3)) min(box(4),boxes(:,4))];
  
  iw = bi(:,3) - bi(:,1) + 1;
  ih = bi(:,4) - bi(:,2) + 1;
  
  not_empty = iw > 0 & ih > 0;
  if any(not_empty)
    intersection = iw(not_empty) .* ih(not_empty);
    % compute overlap as area of intersection / area of union
    union = (boxes(not_empty,3) - boxes(not_empty,1) + 1) .* ...
         (boxes(not_empty,4) - boxes(not_empty,2) + 1) + ...
         (box(3) - box(1) + 1) * (box(4) - box(2) + 1) - ...
         intersection;
    iou(not_empty) = intersection ./ union;
  end

end
