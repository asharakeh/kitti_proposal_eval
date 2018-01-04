

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


function [candidates, scores] = get_candidates3D(method_config, img_id, num_candidates, ...
  allow_filtering, subdirlen, candidate_dir)

  if nargin < 4
    allow_filtering = true;
  end
  if nargin < 5
    subdirlen = 4;
  end
  if nargin < 6
    candidate_dir = method_config.candidate_dir;
  end
  
  % !!! temperal change
%   allow_filtering = false;

  [candidates2D, scores, rerun_num_candidates, candidates] = read_candidates_mat(candidate_dir, img_id, subdirlen);
  scores = scores(:);
  if iscell(candidates) && iscell(scores)
%     error('this shouldn''t be used');
    % we have candidates from multiple runs, with different num_candidates
    % parameters
%     assert(numel(rerun_num_candidates) == numel(candidates));
%     assert(numel(scores) == numel(candidates));
%     assert(all(rerun_num_candidates(1:(end-1)) <= rerun_num_candidates(2:end)));
%     idx = find(rerun_num_candidates <= num_candidates, 1, 'last');
    [~,idx] = min(abs(rerun_num_candidates - num_candidates));
    candidates = candidates{idx};
    scores = scores{idx};
  end
  
  if allow_filtering
    if strcmp(method_config.order, 'none')
      % nothing to do
    elseif strcmp(method_config.order, 'biggest')
      w = candidates(:,3) - candidates(:,1) + 1;
      h = candidates(:,4) - candidates(:,2) + 1;
      areas = w .* h;
      [~,order] = sort(areas, 'descend');
      candidates = candidates(order,:);
      scores = scores(order,:);
    elseif strcmp(method_config.order, 'smallest')
      w = candidates(:,3) - candidates(:,1) + 1;
      h = candidates(:,4) - candidates(:,2) + 1;
      areas = w .* h;
      [~,order] = sort(areas, 'ascend');
      candidates = candidates(order,:);
      scores = scores(order,:);
    elseif strcmp(method_config.order, 'random')
      s = RandStream('mt19937ar','Seed',0);
      perm = randperm(s, size(candidates,1));
      candidates = candidates(perm,:);
      if numel(scores) > 0
        scores = scores(perm);
      end
    else
      [scores, argsort] = sort(scores, method_config.order);
      candidates = candidates(argsort,:);
    end
    
    num_candidates = min(num_candidates, size(candidates, 1));
    candidates = candidates(1:num_candidates,:);
    if numel(scores) > 0
      scores = scores(1:num_candidates,:);
    end
  else
    error('this shouldn''t be used');
  end
end
