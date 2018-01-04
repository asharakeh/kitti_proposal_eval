function eval_kitti(db, methods, level, category)
% This function requires the proposals to already be saved to disk. It will
% compute a matching between ground truth and proposals (if the result is not
% yet found on disk) and then plot all curves. The plots are saved to
% figures/.

compute_best_proposals(db, methods);
plot_results(methods, level, category, db);

end

%% plot all curves
function plot_results(methods, level, category, db)    
configs
save_prefix = sprintf('figures/2D/%s_l%d_%s', category, level, ...
    sprintf('%s_', methods.short_name));
save_prefix = save_prefix(1:end-1);
if ~exist(save_prefix, 'dir')
    mkdir(save_prefix);
end

% Recall-Distance curves using 2000 proposals
for i = 1 : length(recall_dist_threshold)
    fh = figure;
    eval_recall_dist(db, {methods.best_candidates_file}, methods, ...
        recall_dist_num_proposals, recall_dist_threshold(i), fh, true, 'SouthWest', save_prefix);
end

% Recall-Overlap curves using 500, 1000, 2000 proposals
names_in_plot = true;
for i = 1 : length(recall_iou_num_proposals)    
    fh = figure;
    eval_recall_overlap({methods.best_candidates_file}, methods, ...
        recall_iou_num_proposals(i), fh, names_in_plot, 'NorthEast', save_prefix);
end

% Recall-Proposal curves and AR-Proposal curves
eval_recall_ar({methods.best_candidates_file}, methods, save_prefix);

fprintf('figures save to ''%s''\n', save_prefix);
end

%% compute the closest proposals
function compute_best_proposals(testset, methods)
  num_annotations = size(cat(1, testset.impos.boxes), 1);
  candidates_thresholds = [1,3,10,32,100,316,500,1000,2000,3162,5000,10000];
  num_candidates_thresholds = numel(candidates_thresholds);
  
  
  for method_idx = 1:numel(methods)
    method = methods(method_idx);
    try
      load(method.best_candidates_file, 'best_candidates');
     continue
    catch
    end
    
    % preallocate
    best_candidates = [];
    best_candidates(num_candidates_thresholds).candidates_threshold = [];
    best_candidates(num_candidates_thresholds).best_candidates = [];
    for i = 1:num_candidates_thresholds
      best_candidates(i).candidates_threshold = candidates_thresholds(i);
      best_candidates(i).best_candidates.candidates = zeros(num_annotations, 4);
      best_candidates(i).best_candidates.iou = zeros(num_annotations, 1);
      best_candidates(i).image_statistics(numel(testset.impos)).num_candidates = 0;
    end
    
    candidates = cell(numel(testset.impos), num_candidates_thresholds);
    impos_best_ious = candidates;
    impos_best_boxes = candidates;
    parfor j = 1:numel(testset.impos)
      tic_toc_print('evalutating %s: %d/%d\n', method.name, j, numel(testset.impos));
      [~,img_id,~] = fileparts(testset.impos(j).im);

      for i = 1:num_candidates_thresholds
        [candidates{j,i}, scores] = get_candidates(method, img_id, ...
          candidates_thresholds(i));
        if isempty(candidates{j,i})
          impos_best_ious{j,i} = zeros(size(testset.impos(j).boxes, 1), 1);
          impos_best_boxes{j,i} = zeros(size(testset.impos(j).boxes, 1), 4);
        else
          [impos_best_ious{j,i}, impos_best_boxes{j,i}] = closest_candidates(...
            testset.impos(j).boxes, candidates{j,i});
        end
      end
    end
    
    pos_range_start = 1;
    for j = 1:numel(testset.impos)
      pos_range_end = pos_range_start + size(testset.impos(j).boxes, 1) - 1;
      assert(pos_range_end <= num_annotations);
      for i = 1:num_candidates_thresholds
        best_candidates(i).best_candidates.candidates(pos_range_start:pos_range_end,:) = impos_best_boxes{j,i};
        best_candidates(i).best_candidates.iou(pos_range_start:pos_range_end) = impos_best_ious{j,i};
        best_candidates(i).image_statistics(j).num_candidates = size(candidates{j,i}, 1);
      end
      
      pos_range_start = pos_range_end + 1;
    end
    
    folder = fileparts(method.best_candidates_file);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    save(method.best_candidates_file, 'best_candidates');
  end
end

