
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



function scores = OBBOverlap_batch(box, boxes)
% Calculates the intersection/union for a pair of oriented (with respect to gravity) bounding boxes.
%
% Args:
%   bb1 - struct containing a 3D bounding box.
%   boxes - [ry, l, h, w, tx, ty, tz]
%
% Returns:
%   scores - the intersection / overlaps

maskRes = 0.01;
if isstruct(box)
    bb1 = zeros(1,7);
    bb1(1) = box.ry;
    bb1(2) = box.l;
    bb1(3) = box.h;
    bb1(4) = box.w;
    bb1(5:7) = box.t;
else
    bb1 = box;
end

  % Overlap in Z
  heightIntersection = get_height_metrics(bb1, boxes(:,6), boxes(:,3));
  
  % Overlap in the XY plane.
  rectIntersection = get_rectangular_metrics(bb1, boxes, maskRes);
  
  intersection = heightIntersection(:) .* rectIntersection(:);
  
  vol1 = prod(bb1(2:4));
  vol2 = prod(boxes(:,2:4), 2); %bb2.l * bb2.h * bb2.w;
  union = vol1 + vol2 - intersection;
  
%   union = heightUnion * rectUnion;
  scores = intersection ./ union;
end

function [heightIsect, heightUnion] = get_height_metrics(bb1, tys, hs)
  maxZ1 = bb1(6);
  minZ1 = bb1(6) - bb1(3);
  
%   maxZ2 = ys;
  minZ2 = tys - hs;
  
  maxOfMins = max(minZ1, minZ2);
  minOfMaxs = min(maxZ1, tys);
  
  offsets = minOfMaxs - maxOfMins;
  heightIsect = max(0, offsets);
  
  if nargout > 1
      heightUnion = max(maxZ1, tys) - min(minZ1, minZ2);
      heightUnion = heightUnion - max(0, -offsets);
  end
end

function rectIsect = get_rectangular_metrics(bb1, boxes, maskRes)
  [X1, Y1] = get_poly(bb1(1), bb1(2), bb1(4), bb1(5), bb1(7));
  minX1 = min(X1);
  maxX1 = max(X1);
  maxY1 = max(Y1);
  minY1 = min(Y1);
  
  % first check the 2D distance
  center_dists = bsxfun(@minus, bb1([5,7]), boxes(:, [5,7]));
  center_dists = sum(center_dists.^2, 2);
  thrs = bsxfun(@plus, sqrt(sum(bb1([2,4]).^2))/2, sqrt(sum(boxes(:,[2,4]).^2, 2))./2);
  nearby_ids = center_dists < thrs;
  bbs = boxes(nearby_ids, :);
  
  isect = zeros(size(bbs, 1), 1);
  
  for i = 1 : size(bbs, 1)
    [X2, Y2] = get_poly(bbs(i,1), bbs(i,2), bbs(i,4), bbs(i,5), bbs(i,7));
     if maxX1 < min(X2) || max(X2) < minX1 || ...
        maxY1 < min(Y2) || max(Y2) < minY1
        continue;
      end

      maxs = max([[X1; X2], [Y1; Y2]], [], 1);
      mins = min([[X1; X2], [Y1; Y2]], [], 1);

      % Create the rectangular image.
      maskDims = ceil((maxs - mins) / maskRes);

      % Create the masks for both bounding boxes.
      mX1 = (X1 - mins(1)) / maskRes;
      mX2 = (X2 - mins(1)) / maskRes;
      mY1 = (Y1 - mins(2)) / maskRes;
      mY2 = (Y2 - mins(2)) / maskRes;

    %   X1 = round(X1);
    %   Y1 = round(Y1);

      mask1 = poly2mask(mX1, mY1, maskDims(2), maskDims(1));
      mask2 = poly2mask(mX2, mY2, maskDims(2), maskDims(1));
      maskIsect = mask1 & mask2;
      isect(i) = nnz(maskIsect) * maskRes^2;
  end
  
  rectIsect = zeros(size(boxes, 1), 1);
  rectIsect(nearby_ids) = isect;
  
end

function [X, Z] = get_poly(ry, l, w, tx, tz)
% X     4x1 
% Z     4x1

  % compute rotational matrix around yaw axis
    R = [+cos(ry), +sin(ry);
         -sin(ry), +cos(ry)];

    % 3D bounding box corners
    x_corners = l/2 .* [1, 1 -1 -1];
    z_corners = w/2  .* [1, -1, -1, 1];

    % rotate
    P = R * [x_corners; z_corners];
    
    X = P(1, :)' + tx;
    Z = P(2, :)' + tz;
end
