
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


function db = db_from_kitti(root_dir, split)

if ~ismember(split, {'train', 'val', 'trainval'})
    error('The data split should be train, val or trainval.');
end

data_set = 'training';
labels = {'Car', 'Pedestrian', 'Cyclist'};
labelMap = containers.Map(lower(labels), 1:length(labels));

filename = sprintf('data/kitti_detection_%s.mat', data_set);
if exist(filename, 'file')
    db = load(filename);
else
    % get sub-directories
    cam = 2; % 2 = left color camera
    image_dir = fullfile(root_dir,['/object/' data_set '/image_' num2str(cam)]);
    label_dir = fullfile(root_dir,['/object/' data_set '/label_' num2str(cam)]);

    % get number of images for this dataset
    nimages = length(dir(fullfile(image_dir, '*.png')));

    % main loop
    impos = struct;
    for i = 1 : nimages
      tic_toc_print('%d / %d\n', i, nimages);
      impos(i).im = sprintf('%06d', i-1);
      
      % load labels
      objects = readLabels(label_dir,i-1);
      keep = arrayfun(@(x) ismember(objects(x).type, labels), 1 : length(objects));
      objects = objects(keep);
      if isempty(objects)
          continue;
      end

      impos(i).types = zeros(length(objects), 1);
      for j = 1 : length(objects)
          impos(i).types(j) = labelMap(lower(objects(j).type));
      end

      % visualization update for next frame
      im = imread(sprintf('%s/%06d.png',image_dir, i-1));
      
      impos(i).boxes = [[objects.x1]' [objects.y1]' [objects.x2]' [objects.y2]'] + 1;
      impos(i).boxes(:,3) = min(impos(i).boxes(:,3), size(im,2));
      impos(i).boxes(:,4) = min(impos(i).boxes(:,4), size(im,1));
      impos(i).sizes = (impos(i).boxes(:,3)-impos(i).boxes(:,1)+1) .* (impos(i).boxes(:,4)-impos(i).boxes(:,2)+1);
      impos(i).img_area = size(im,1) * size(im,2);
      impos(i).img_size = [size(im,1) size(im,2)];
      impos(i).truncated = [objects.truncation]';
      impos(i).occluded = [objects.occlusion]';
      impos(i).alpha = [objects.alpha]';

      impos(i).sizes3D = [[objects.l]' [objects.h]' [objects.w]']; % length/height/width
      impos(i).t = cat(1, objects.t);
      impos(i).ry = [objects.ry]';
    end

    save(filename, 'impos', 'labelMap');

    db.impos = impos;
    db.labelMap = labelMap;
end

image_ids = data_ids(split);
ids = cellfun(@str2double, image_ids) + 1;
db.impos = db.impos(ids); 

end
