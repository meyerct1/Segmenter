function output_args=getCentroids3D(input_args)
% Usage
% This module returns a list of centroids for the objects in a 3D label matrix.
% Input Structure Members
% LabelMatrix – Label matrix from which the object centroids will be calculated.
% Output Structure Members
% Centroids – The list of centroids extracted from the label matrix.

objects_lbl=input_args.LabelMatrix.Value;
objects_props=regionprops(objects_lbl,'Centroid');
objects_centroids=[objects_props.Centroid]';
centr_len=size(objects_centroids,1);
objects_centroids=[objects_centroids(2:3:centr_len) objects_centroids(1:3:centr_len) objects_centroids(3:3:centr_len)];
output_args.Centroids=objects_centroids;

%end getCentroids3D
end