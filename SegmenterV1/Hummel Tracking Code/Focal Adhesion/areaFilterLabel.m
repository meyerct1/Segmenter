function output_args=areaFilterLabel(input_args)
%Usage
%This module is used to remove objects below and/or above a certain area from a label matrix.
%
%Input Structure Members
%MaxArea - Objects with an area larger than this value will be removed.
%MinArea - Objects with an area smaller than this value will be removed.
%ObjectsLabel - The label matrix from which objects will be removed.
%
%Output Structure Members
%LabelMatrix - The filtered label matrix.

cells_lbl=input_args.ObjectsLabel.Value;
cells_props=regionprops(cells_lbl,'Area');
field_names=fieldnames(input_args);
if (max(strcmp(field_names,'MinArea')))
    b_min=true;
else
    b_min=false;
end
if (max(strcmp(field_names,'MaxArea')))
    b_max=true;
else
    b_max=false;
end
cells_area=[cells_props.Area];
cells_nr=length(cells_area);
valid_areas_idx=true(1,cells_nr);
% if (b_min)
%     valid_areas_idx=valid_areas_idx&(cells_area>=input_args.MinArea.Value);
% end
% if (b_max)
%     valid_areas_idx=valid_areas_idx&(cells_area<=input_args.MaxArea.Value);
% end
if (min(valid_areas_idx)==1)
    %no invalid objects return the same label back
    output_args.LabelMatrix=cells_lbl;
else    
    valid_object_numbers=find(valid_areas_idx);
    new_object_numbers=1:length(valid_object_numbers);
    %we will replace valid numbers with new and everything else will be set to
    %zero
    object_idx=cells_lbl>0;
    new_object_index=zeros(max(cells_lbl(object_idx)),1);
    new_object_index(valid_object_numbers)=new_object_numbers;
    new_cells_lbl=cells_lbl;
    %replace the old object numbers to prevent skips in numbering
    object_idx=cells_lbl>0;
    new_cells_lbl(object_idx)=new_object_index(cells_lbl(object_idx));
    output_args.LabelMatrix=new_cells_lbl;
end

%end areaFilterLabel
end
