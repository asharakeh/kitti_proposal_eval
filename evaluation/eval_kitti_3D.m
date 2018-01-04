function eval_kitti_3D(db, methods, level, category)
% This function requires the proposals to already be saved to disk. It will
% compute a matching between ground truth and proposals (if the result is not
% yet found on disk) and then plot all curves. The plots are saved to
% figures/.

compute_best_proposals_3D(db, methods);
plot_results(methods, level, category, db);

end

%% plot all curves
function plot_results(methods, level, category, db) 

configs

save_prefix = sprintf('figures/3D/%s_l%d_%s', category, level, ...
    sprintf('%s_', methods.short_name));
save_prefix = save_prefix(1:end-1);
if ~exist(save_prefix, 'dir')
    mkdir(save_prefix);
end

% 3D Recall-Distance curves using 2000 proposals at IoU of 0.25
fh = figure;
eval_recall_dist(db, {methods.best_candidates3D_file}, methods, recall_dist_num_proposals, ...
    recall_dist_threshold, fh, true, 'SouthWest', save_prefix);

% 3D Recall-Overlap curves using 2000 proposals
fh = figure;
eval_recall_overlap_3D({methods.best_candidates3D_file}, methods,recall_iou_num_proposals, ...
    fh, true, 'SouthWest', save_prefix);

% 3D Recall-Proposal curves
eval_recall_3D({methods.best_candidates3D_file}, methods, save_prefix, recall_proposal_thresholds);

fprintf('figures save to ''%s''\n', save_prefix);
end

%% compute the closest proposals
function compute_best_proposals_3D(testset, methods)
  num_annotations = size(cat(1, testset.impos.boxes), 1);
  candidates_thresholds = [1,3,10,32,100,316,500,1000,2000,3162,5000,10000];
  num_candidates_thresholds = numel(candidates_thresholds);
  
  
  for method_idx = 1:numel(methods)
    method = methods(method_idx);
    try
      load(method.best_candidates3D_file, 'best_candidates');
     continue
    catch
    end
    
    % preallocate
    best_candidates = [];
    best_candidates(num_candidates_thresholds).candidates_threshold = [];
    best_candidates(num_candidates_thresholds).best_candidates = [];
    for i = 1:num_candidates_thresholds
      best_candidates(i).candidates_threshold = candidates_thresholds(i);
      best_candidates(i).best_candidates.candidates = zeros(num_annotations, 7);
      best_candidates(i).best_candidates.iou = zeros(num_annotations, 1);
      best_candidates(i).image_statistics(numel(testset.impos)).num_candidates = 0;
    end
    
    pos_range_start = 1;
    candidates = cell(numel(testset.impos), num_candidates_thresholds);
    impos_best_ious = candidates;
    impos_best_boxes = candidates;
    parfor j = 1:numel(testset.impos)
      tic_toc_print('evalutating %s: %d/%d\n', method.name, j, numel(testset.impos));
    
      tic_toc_print('sampling candidates for image %d/%d\n', j, numel(testset.impos));
      [~,img_id,~] = fileparts(testset.impos(j).im);

      gt = [testset.impos(j).ry, testset.impos(j).sizes3D, testset.impos(j).t];
      for i = 1:num_candidates_thresholds
        [candidates{j,i}, scores] = get_candidates3D(method, img_id, ...
          candidates_thresholds(i));
        if isempty(candidates{j,i})
          impos_best_ious{j,i} = zeros(size(testset.impos(j).boxes, 1), 1);
          impos_best_boxes{j,i} = zeros(size(testset.impos(j).boxes, 1), 7);
        else
          [impos_best_ious{j,i}, impos_best_boxes{j,i}] = closest_OBB(gt, candidates{j,i});
        end
      end
    end
    
    for j = 1:numel(testset.impos)
      tic_toc_print('evalutating %s: %d/%d\n', method.name, j, numel(testset.impos));
      pos_range_end = pos_range_start + size(testset.impos(j).boxes, 1) - 1;
      assert(pos_range_end <= num_annotations);
      for i = 1:num_candidates_thresholds
        best_candidates(i).best_candidates.candidates(pos_range_start:pos_range_end,:) = impos_best_boxes{j,i};
        best_candidates(i).best_candidates.iou(pos_range_start:pos_range_end) = impos_best_ious{j,i};
        best_candidates(i).image_statistics(j).num_candidates = size(candidates{j,i}, 1);
      end
      
      pos_range_start = pos_range_end + 1;
    end
    
    save(method.best_candidates3D_file, 'best_candidates');
  end
end

%%
function eval_recall_overlap_3D(iou_files, methods, num_candidates, fh, ...
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
      
    % compute recall
    all_overlaps = sort(experiment.best_candidates.iou(:)', 'ascend');
    num_pos = numel(all_overlaps);
    dx = 0.001;  
    overlaps = 0:dx:1;
    overlaps(end) = 1;
    recall = zeros(length(overlaps), 1);
    for ii = 1:length(overlaps)
      recall(ii) = sum(all_overlaps >= overlaps(ii)) / num_pos;
    end
    
    if names_in_plot
      labels{i} = sprintf('%s', methods(i).short_name);
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
  xlim([0, 1]);
  ylim([0, 1]);
  if names_in_plot
    setlegend( labels, legend_location );
  end
  % save to file
   printpdf(sprintf('%s/recall_%d.pdf', save_prefix, num_candidates));
end

%%
function results = eval_recall_3D(iou_files, methods, save_prefix, thresholds)
% Plot recall-proposal curves
 
  assert(numel(iou_files) == numel({methods.short_name}));
  n = numel(iou_files);
  
  legend_loc = {'SouthEast'};
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
    if mod(threshold*10,1) == 0
        xlabel('# candidates'); ylabel(sprintf('recall at IoU threshold %.1f', threshold));
    else
        xlabel('# candidates'); ylabel(sprintf('recall at IoU threshold %.2f', threshold));
    end
    setlegend(labels, legend_loc{threshold_i});
    % save to file
    printpdf(sprintf('%s/recall_proposal_%.0f.pdf', save_prefix, threshold*10));
  end
end

