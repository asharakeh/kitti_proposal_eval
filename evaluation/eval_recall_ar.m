
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




function results = eval_recall_ar(iou_files, methods, save_prefix, thresholds)
% Plot recall-proposal curves and AR-proposal curves.

  assert(numel(iou_files) == numel({methods.short_name}));
  n = numel(iou_files);
  labels = cell(n,1);
  
  figure;
  for i = 1:n
    data = load(iou_files{i});
    num_experiments = numel(data.best_candidates);
    x = zeros(num_experiments, 1);
    y = zeros(num_experiments, 1);
    for exp_idx = 1:num_experiments
      experiment = data.best_candidates(exp_idx);
      [~, ~, ar] = compute_average_recall(experiment.best_candidates.iou);
      x(exp_idx) = mean([experiment.image_statistics.num_candidates]);
      y(exp_idx) = ar;
    end
    labels{i} = methods(i).short_name;
    color = methods(i).color;
    line_style = '-';
    if methods(i).is_baseline
        line_style = '--';
    end
    
    semilogx(x, y, 'Color', color, 'LineWidth', 2, 'LineStyle', line_style);
    hold on; grid on;    

    results(i).ar = y;
    results(i).wins = x;
  end  
  
  xlim([10, 10000]);
  ylim([0 1]);
  xlabel('# candidates'); ylabel('average recall');
  setlegend( labels, 'NorthWest');
  % save to file
  printpdf(sprintf('%s/ar_proposal.pdf', save_prefix));

  %% recall-proposals curves
  if nargin < 4
%       legend_locations = {'NorthWest', 'NorthWest', 'NorthWest'};
      legend_locations = {'SouthEast', 'SouthEast', 'SouthEast'};
      thresholds = [0.5 0.7];
  end
  for threshold_i = 1:numel(thresholds)
    threshold = thresholds(threshold_i);
    labels = cell(n,1);
    figure;
    for i = 1:n
      data = load(iou_files{i});
      num_experiments = numel(data.best_candidates);
      x = zeros(num_experiments, 1);
      y = zeros(num_experiments, 1);
      for exp_idx = 1:num_experiments
        experiment = data.best_candidates(exp_idx);
        recall = sum(experiment.best_candidates.iou >= threshold) / numel(experiment.best_candidates.iou);
        x(exp_idx) = mean([experiment.image_statistics.num_candidates]);
        y(exp_idx) = recall;
      end
        labels{i} = methods(i).short_name;
        color = methods(i).color;
        line_style = '-';
        if methods(i).is_baseline
            line_style = '--';
        end
        
        semilogx(x, y, 'Color', color, 'LineWidth', 2, 'LineStyle', line_style);
        hold on; grid on;
        
        results(i).recall(threshold_i, :) = y;
    end
    
    xlim([10, 10000]);
    ylim([0 1]);
    xlabel('# candidates'); ylabel(sprintf('recall at IoU threshold %.1f', threshold));
    setlegend( labels, legend_locations{threshold_i} );
    % save to file
    printpdf(sprintf('%s/recall_proposal_%.0f.pdf', save_prefix, threshold*10));
  end
end
