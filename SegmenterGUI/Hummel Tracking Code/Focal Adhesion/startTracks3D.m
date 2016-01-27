function output_args=startTracks3D(input_args)
% Usage
% This module is used to start a tracks matrix.
% Input Structure Members
% ObjectCentroids – The centroids of the objects in the label matrix.
% CurFrame – The index value of the current frame.
% ShapeParameters – Any additional parameters to be added to the tracks
% matrix
% TimeFrame – The time interval between consecutive frames in the time-lapse.
% Output Structure Members
% Tracks – The new tracks matrix.

object_centroids=input_args.ObjectCentroids.Value;
cur_time=repmat((input_args.CurFrame.Value-1)*input_args.TimeFrame.Value,size(object_centroids,1),1);
track_ids=[1:size(object_centroids,1)]';
output_args.Tracks=[track_ids cur_time object_centroids input_args.ShapeParameters.Value input_args.ShapeParameter_Area.Value];
output_args.SliceNumber=[input_args.CurFrame.Value input_args.SliceNumber.Value];
output_args.First_IDs=track_ids;

%end startTracks
end
