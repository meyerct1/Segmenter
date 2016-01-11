function output_args=getCentroids(input_args)
% Usage
% This module returns a list of centroids for the objects in a label matrix.
% Input Structure Members
% LabelMatrix – Label matrix from which the object centroids will be calculated.
% Output Structure Members
% Centroids – The list of centroids extracted from the label matrix.

objects_lbl=input_args.LabelMatrix.Value;
objects_idx=objects_lbl>0;
[objects_1 objects_2]=find(objects_idx);
object_coords_1=accumarray(objects_lbl(objects_idx),objects_1);
object_coords_2=accumarray(objects_lbl(objects_idx),objects_2);
object_areas=accumarray(objects_lbl(objects_idx),1);
objects_centroids=[object_coords_1 object_coords_2]./[object_areas object_areas];
output_args.Centroids=objects_centroids;

%end getCentroids
end