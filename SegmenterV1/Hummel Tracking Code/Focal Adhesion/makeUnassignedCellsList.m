function output_args=makeUnassignedCellsList(input_args)
% Usage
% This module is used to create a list of IDs for each cell centroid in a list.
% Input Structure Members
% CellsCentroids – List of cell centroids.
% Output Structure Members
% UnassignedCellsIDs – List of IDs.

output_args.UnassignedCellsIDs=[1:size(input_args.CellsCentroids.Value,1)]';

%end makeUnassignedCellsList 
end
