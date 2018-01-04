close all
clear

startup;

% proposal type: 
% 'class' - class-dependent proposals
% 'generic' - class-independent proposals
type = 'class';

% category: 'car', 'pedestrian', or 'cyclist',
category = 'car';
% training set: 'train' or 'trainval'
trainset = 'train';
% test set: 'val' or 'test'
testset = 'val';
% difficulty level, 1: easy, 2: moderate, 3: hard
level = 2;

%% evaluation
algorithms.names = ["example"]; % can be a list of names ["3DOP", "Mono3D", "Ours BEV", "Ours BEV + Image"]
algorithms.is_baseline = [0]; % should have the same size as algorithms.name. 1 for baseline method, 0 for our method.

% prepare output to be handled by matlab code
prep_output(algorithms, category)
eval_2D = 0; % flag to evaluate 2D recall
eval_proposals(category, level, testset, kitti_dir, algorithms, eval_2D);