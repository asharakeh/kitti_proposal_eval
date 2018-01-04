
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



function eval_recall_dist(db, iou_files, methods, num_candidates, iou_thr, fh, ...
  names_in_plot, legend_location, save_prefix)  
% plot recall vs distance curves
  
  assert(numel(iou_files) == numel({methods.short_name}));
  n = numel(iou_files);
  labels = cell(n,1);
  
  ts  = cat(1, db.impos.t);
  dist = sqrt(sum(ts.^2, 2));
  
  figure(fh); hold on; grid on;
  for i = 1:n
    data = load(iou_files{i});
    thresh_idx = find([data.best_candidates.candidates_threshold] <= num_candidates, 1, 'last');
    experiment = data.best_candidates(thresh_idx);    
    [D, recall] = compute_recall_dist(experiment.best_candidates.iou, dist, iou_thr);
    
    if names_in_plot
      labels{i} = sprintf('%s', methods(i).short_name);
    end
    color = methods(i).color;

    line_style = '-';
    if methods(i).is_baseline
        line_style = '--';
    end
    plot(D, recall, 'Color', color, 'LineWidth', 2, 'LineStyle', line_style);      
  end  
    
    xlabel('distance from ego-car (meters)');
    if mod(iou_thr*10,1) == 0
        ylabel(sprintf('recall at IoU threshold %.1f', iou_thr));
    else
        ylabel(sprintf('recall at IoU threshold %.2f', iou_thr));
    end
    ylim([0, 1]);
    setlegend( labels, legend_location );
    % save to file
    printpdf(sprintf('%s/recall_dist_%d_%.0f.pdf', save_prefix, num_candidates, iou_thr*10));
end

%%
function [dist_rank, recall] = compute_recall_dist(unsorted_overlaps, dist, thr)
    [dist_rank, ids] = sort(dist(:), 'ascend');
    all_overlaps = unsorted_overlaps(ids);
    
    tp = all_overlaps >= thr;
    recall = cumsum(tp);
    recall = recall ./ (1 : length(tp))';
    
    % compute recall starting from 8m to avoid noise caused by very few
    % data points
    sel = dist_rank > 8;
    dist_rank = dist_rank(sel);
    recall = recall(sel);
end
