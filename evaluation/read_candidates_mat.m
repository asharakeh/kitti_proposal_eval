
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



function [boxes, scores, num_candidates, boxes3D] = read_candidates_mat(dirname, img_id, subdirlen)
  if nargin < 3
    subdirlen = 4;
  end
  subdir = img_id(1:subdirlen);
  matfile = fullfile(dirname, subdir, sprintf('%s.mat', img_id));
  
  % default value
  num_candidates = 10000;
  
  load(matfile);
end
