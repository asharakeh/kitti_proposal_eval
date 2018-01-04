

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


function [best_overlap,best_boxes, best_ids] = closest_candidates(gt_boxes, candidates)
% do a matching between gt_boxes and candidates

  gt_boxes = double(gt_boxes);
  candidates = double(candidates);
  
  num_gt_boxes = size(gt_boxes, 1);
  num_candidates = size(candidates, 1);
  
  iou_matrix = zeros(num_gt_boxes, num_candidates);
  for i = 1:num_gt_boxes
    iou = overlap(gt_boxes(i,:), candidates);
    iou_matrix(i,:) = iou';
  end
  
  best_overlap = zeros(num_gt_boxes, 1);
  best_boxes = -ones(num_gt_boxes, 4);

  [best_overlap,best_boxes, best_ids] = greedy_matching(iou_matrix, gt_boxes, candidates);
end

function [best_overlap,best_boxes, best_ids] = greedy_matching(iou_matrix, gt_boxes, candidates)
  [n, m] = size(iou_matrix);
  assert(n == size(gt_boxes, 1));
  assert(m == size(candidates, 1));
  if n > m
    gt_matching = greedy_matching_rowwise(iou_matrix');
    candidate_matching = (1:m)';
  else
    gt_matching = (1:n)';
    candidate_matching = greedy_matching_rowwise(iou_matrix);
  end
  
  best_overlap = zeros(n, 1);
  best_boxes = zeros(n, 4);
  best_ids = zeros(n, 1);
  for pair_idx = 1:numel(gt_matching)
    gt_idx = gt_matching(pair_idx);
    candidate_idx = candidate_matching(pair_idx);
    
    best_overlap(gt_idx) = iou_matrix(gt_idx, candidate_idx);
    best_boxes(gt_idx,:) = candidates(candidate_idx, :);
    best_ids(gt_idx) = candidate_idx;
  end
end

function [matching, objective] = greedy_matching_rowwise(iou_matrix)
  assert(size(iou_matrix, 1) <= size(iou_matrix, 2));
  n = size(iou_matrix, 1);
  matching = zeros(n, 1);
  objective = 0;
  for i = 1:n
    % find max element int matrix
    [max_per_row, max_col_per_row] = max(iou_matrix, [], 2);
    [max_iou,row] = max(max_per_row);
    if max_iou == -inf
      break
    end
    
    objective = objective + max_iou;
    col = max_col_per_row(row);
    matching(row) = col;
    iou_matrix(row,:) = -inf;
    iou_matrix(:,col) = -inf;
  end
end

