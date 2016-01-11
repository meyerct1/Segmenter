function output_args=makeExcludedTracksList(input_args)
% Usage
% This module wraps its input, a list of cell IDs, in a MATLAB cell array.
% Input Structure Members
% UnassignedCellsIDs – The list of cell IDs.
% Output Structure Members
% ExcludedTracks – The MATLAB cell array.

output_args.ExcludedTracks=cell(size(input_args.UnassignedCellsIDs.Value,1),1);

%end makeExcludedTracksList
end
