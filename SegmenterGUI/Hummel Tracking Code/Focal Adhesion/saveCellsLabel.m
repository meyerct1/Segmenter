function output_args=saveCellsLabel(input_args)
% Usage
% This module is used to save a MATLAB label matrix containing cell objects.
% Input Structure Members
% CellsLabel – The label matrix containing cell objects.
% CurFrame – The index of the frame to which the label matrix corresponds.
% FileRoot – String containing the root of the file name to be used when saving the label matrix.
% NumberFormat – String indicating the number format to be used when formatting the current frame number to be concatenated to the file root string. See the MATLAB sprintf help file for example number format strings.
% 
% Output Structure Members
% CellsLabel – The label matrix containing cell objects.


cells_lbl=input_args.CellsLabel.Value;
file_root=input_args.FileRoot.Value;
save_dir_idx=find(file_root=='/',1,'last');
save_dir=file_root(1:(save_dir_idx-1));
if ~isdir(save_dir)
    mkdir(save_dir);
end
save([input_args.FileRoot.Value num2str(input_args.CurFrame.Value,input_args.NumberFormat.Value)],'cells_lbl');
output_args.CellsLabel=cells_lbl;

%end saveCellsLabel
end
