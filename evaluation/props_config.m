function method = props_config(category, testset, level, approach,type)

% approach = name of the file required
if nargin < 2
    testset = 'val';
end
if nargin < 3 || isempty(level)
    level = 2;
end
% proposal type: 
% 'class' - class-dependent proposals
% 'generic' - class-independent proposals
if nargin < 5
    type = 'class';
end
if isempty(category)
    category = 'car';
end

if strcmp(testset, 'test')
    suffix = 'test';
else
    suffix = 'trainval';
end

if strcmp(type, 'generic')
    approach = [approach, '-generic'];
    % class-independent proposals
    method.candidate_dir = fullfile('proposals', approach, 'mat', suffix);
elseif strcmp(type, 'class')
    % class-dependent proposals
    method.candidate_dir = fullfile('proposals', approach, category, 'mat', suffix);
end
prefix = fullfile('proposals', approach, category);
method.name = approach;
method.short_name = approach;
method.best_candidates_file = sprintf('%s/l%d/best_candidates.mat', prefix, level);
method.order = 'none';
method.extract = @run_3dop;
method.color = [1, 0, 0];
method.is_baseline = false;
method.best_candidates3D_file = sprintf('%s/l%d/best_candidates3D.mat', prefix, level);
  
end

