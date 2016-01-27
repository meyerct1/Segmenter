function output_args=saveTracks(input_args)
% Usage
% This module is used to save the tracks matrix.
% Input Structure Members
% Tracks – Matrix containing the tracks to be saved.
% TracksFileName – The desired file name for the saved tracks data.
% Output Structure Members
% None.


tracks=input_args.Tracks.Value;
file_name=input_args.TracksFileName.Value;
save_dir_idx=find(file_name=='/',1,'last');
save_dir=file_name(1:(save_dir_idx-1));
if ~isdir(save_dir)
    mkdir(save_dir);
end
save(file_name,'tracks');
output_args=[];

%end saveTracks
end
