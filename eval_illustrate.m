close all; clear all;

category = 'car';
testset = 'val';
level = 3;

% IoU overlap threshold for correct detection, 0.7 for cars, 0.5 for pedestrians/cyclists
thr = 0.5;
if strcmp(category, 'car')
    thr = 0.7;      
end

% image path
image_dir = fullfile(kitti_dir, '/object/training/image_2');

method = props_config(category, testset, level);
% methods = props_config(category, testset, level, 'generic');

db = db_from_kitti(kitti_dir, testset);
db = dbFilter(db, category, 3);
nimages = length(db.impos);

% main loop
for i = 1 : nimages
    tic_toc_print('%d / %d\n', i, nimages);
    id = db.impos(i).im;
    
    % visualization update for next frame
    im = imread(sprintf('%s/%s.png', image_dir, id));

    [bbs, scores] = get_candidates(method, id, 2000);

    figure(1); clf;
    illustrate(im, db.impos(i).boxes, bbs, thr);
    fprintf('Press any key to continue\n');
    pause;    
end