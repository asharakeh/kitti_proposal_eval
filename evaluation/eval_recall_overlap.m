
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




function eval_recall_overlap(iou_files, methods, num_candidates, fh, ...
  names_in_plot, legend_location, save_prefix)  
% plot recall-overlap curves.
  
  assert(numel(iou_files) == numel({methods.short_name}));
  n = numel(iou_files);
  labels = cell(n,1);
  
  figure(fh); hold on; grid on;
  for i = 1:n
    data = load(iou_files{i});
    thresh_idx = find( ...
      [data.best_candidates.candidates_threshold] <= num_candidates, 1, 'last');
    experiment = data.best_candidates(thresh_idx);
    % AR for range [0.5, 1.0]
    [overlaps, recall, ar] = compute_average_recall(experiment.best_candidates.iou);
    
    display_ar = ar * 100;
    % round to first decimal
    display_ar = round(display_ar * 10) / 10;    
%     display_num_candidates = mean([experiment.image_statistics.num_candidates]);
%     display_num_candidates = round(display_num_candidates * 10) / 10;
%     number_str = sprintf('%g (%g)', display_ar, display_num_candidates);
    number_str = sprintf('%g', display_ar);
    if names_in_plot
      labels{i} = sprintf('%s %s', methods(i).short_name, number_str);
    else
      labels{i} = number_str;
    end
    color = methods(i).color;

    line_style = '-';
    if methods(i).is_baseline
        line_style = '--';
    end
    plot(overlaps, recall, 'Color', color, 'LineWidth', 2, 'LineStyle', line_style);      
  end  
    
  xlabel('IoU overlap threshold');
  ylabel('recall');
  xlim([0.5, 1]);
  ylim([0, 1]);
  setlegend( labels, legend_location );
  % save to file
   printpdf(sprintf('%s/recall_%d.pdf', save_prefix, num_candidates));
end
