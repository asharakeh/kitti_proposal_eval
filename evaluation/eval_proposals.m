%% Evaluate Proposal Recall

function eval_proposals(category, level, testset, kitti_dir, algorithms, eval_2D)
% INPUT
%   category    'car', 'pedestrian' or 'cyclist'
%   level       difficulty level, 1: easy, 2: moderate, 3: hard
%   testset     'val' or 'test'
%
disp('======= Evaluating Proposals =======');

db = db_from_kitti(kitti_dir, testset);
db = dbFilter(db, category, level);
cols = lines;

%% Perpare Methods
for i=1:length(algorithms.names)
methods(i) = props_config(category, testset, level, char(algorithms.names(i)));
methods(i).color = cols(i, :);
methods(i).is_baseline=algorithms.is_baseline(i);
end

%% Evaluate 2D box recall
if eval_2D
eval_kitti(db, methods, level, category);
end

%% Evaluate 3D box recall
eval_kitti_3D(db, methods, level, category);
