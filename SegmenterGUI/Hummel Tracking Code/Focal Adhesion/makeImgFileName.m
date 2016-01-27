function output_args=makeImgFileName(input_args)
% Usage
% This module is used to build the filename of a frame from a time-lapse movie using the root file name, current frame number and a specified number format and file extension.
% Input Structure Members
% CurFrame – The index of the current frame.
% FileBase – The root of the image file name.
% FileExt – The file extension.
% NumberFmt – The number format to be used. See MATLAB sprintf documentation for format documentation.
% Output Structure Members
% FileName – String containing the resulting file name.


file_base=input_args.FileBase.Value;
cur_frame=input_args.CurFrame.Value;
number_fmt=input_args.NumberFmt.Value;
file_ext=input_args.FileExt.Value;
output_args.FileName=[file_base num2str(cur_frame,number_fmt) file_ext];

%end makeImgFileName
end
