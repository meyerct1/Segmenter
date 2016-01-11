function output_args=getFileInfo(input_args)
% Usage
% This module is used to extract the file name, extension and directory from the absolute path.
% Input Structure Members
% PathName – Absolute path name from which file name, extension and directory will be extracted.
% Output Structure Members
% DirName – The extracted directory name.
% FileName – The extracted file name.
% ExtName – The extracted extension name.

path_name=input_args.PathName.Value;
dir_idx=strfind(path_name,'\');
dir_idx=[dir_idx strfind(path_name,'/')];
dir_idx=sort(dir_idx);
dir_idx=dir_idx(end);
ext_idx=strfind(path_name,'.');
ext_idx=ext_idx(end);

output_args.DirName=path_name(1:dir_idx);
output_args.FileName=path_name((dir_idx+1):(ext_idx-1));
output_args.ExtName=path_name(ext_idx:end);

%end getFileInfo
end
