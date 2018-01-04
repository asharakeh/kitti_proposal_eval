function prep_output(algorithms, category)
if  strcmp(category,'pedestrian') || strcmp(category, 'cyclist')
    gen_cat = 'people/';
else
    gen_cat = 'car/';
end

for i = 1:length(algorithms.names)
main_dir = 'proposals/'+ algorithms.names(i) +'/';
output_folder = main_dir + 'kitti_format/'+ gen_cat;
save_folder =  main_dir  + category + '/mat/trainval/';
MyFolderInfo = dir(char(strcat(output_folder,'/*.txt')));

for i = 1:size(MyFolderInfo)
   fid = fopen(strcat(output_folder,MyFolderInfo(i).name));
   C   = textscan(fid,'%s %f %d %f %f %f %f %f %f %f %f %f %f %f %f %f','delimiter', ' ');
   fclose(fid);
   
   boxes = [cell2mat(C(5)),cell2mat(C(6)),cell2mat(C(7)),cell2mat(C(8))];
   boxes3D = [cell2mat(C(15)),cell2mat(C(11)),cell2mat(C(9)),cell2mat(C(10)),cell2mat(C(12)),cell2mat(C(13)),cell2mat(C(14))];
   scores = cell2mat(C(16));
   
   nm = MyFolderInfo(i).name;    
   dirpath = strcat(save_folder, nm(1:4),'/');
   save(strcat(dirpath,nm(1:6),'.mat'),'boxes','boxes3D','scores');   
end

end