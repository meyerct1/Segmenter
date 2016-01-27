function output_args=continueTracks(input_args)
% continueTracks
% Usage
% This module is used to continue the tracks with the new track assignments as tracking progresses from frame to frame.
% Input Structure Members
% CurFrame – Integer value representing the current frame number.
% TrackAssignments – Matrix containing the new track assignments.
% TimeFrame – Integer value representing the current time frame.
% Output Structure Members
% NewTracks – Matrix containing the new tracks for the current frame.
% Tracks – Matrix containing the tracks including the new track assignments.

trackAssignments=input_args.TrackAssignments.Value;
[dummy tracks_sort_idx]=sort(trackAssignments(:,2));
tracks_ids_sorted=trackAssignments(tracks_sort_idx,1);
cur_time=(input_args.CurFrame.Value-1)*input_args.TimeFrame.Value;
output_args.NewTracks=[tracks_ids_sorted repmat(cur_time,size(tracks_ids_sorted,1),1) input_args.CellsCentroids.Value...
    input_args.ShapeParameters.Value input_args.ShapeParameter_Area.Value];
output_args.Tracks=[input_args.Tracks.Value; output_args.NewTracks];
output_args.FA_IDs=tracks_ids_sorted;
% output_args.NewSliceNumber=[cur_time input_args.SliceNumber.Value];
% output_args.SliceNumber_Total=[input_args.SliceNumber.Value output_args.NewSliceNumber.Value];

%end continueTracks
end