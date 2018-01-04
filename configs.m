%% Configuration File to run evaluation for both 2d and 3d

% Recall vs Distance curve configs
recall_dist_num_proposals = 2000;
recall_dist_threshold = 0.5;

% Recall vs IOU curve configs, can be a list of numbers [300, 500, 1000,
% 2000, etc...]
recall_iou_num_proposals = 2000;

% Revall vs Num of Proposals configs, can take a list of thresholds
% [0.25,0.5,etc..]
recall_proposal_thresholds = 0.5; 