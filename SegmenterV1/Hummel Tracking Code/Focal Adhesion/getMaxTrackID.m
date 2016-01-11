function output_args=getMaxTrackID(input_args)
% Usage
% This module is used to return the current maximum track ID from a track matrix.
% Input Structure Members
% TrackIDCol – Index of the track ID column in the tracks matrix.
% Tracks – Matrix containing the set of tracks.
% Output Structure Members
% MaxTrackID – The maximum track ID.

output_args.MaxTrackID=max(input_args.Tracks.Value(:,input_args.TrackIDCol.Value));

%end getMaxTrackID
end
