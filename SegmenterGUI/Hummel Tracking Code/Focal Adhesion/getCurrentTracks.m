function output_args=getCurrentTracks(input_args)
% Usage
% Module to extract a subset of tracks out of the tracks matrix starting with the current frame.
% Input Structure Members
% CurFrame – The current frame index.
% FrameStep – How many frames to skip when reading the track subset. If every frame is to be read set this value to 1.
% MaxMissingFrames – This value indicates if tracks not present in the current frame should be included in the track subset and if so how many frames away from the current frame a track is allowed to be and still be included in the subset. Setting this value to zero ensures that only tracks present in the current frame are included.
% OffsetFrame – The number of frames from the current frame the subset should include. This value can be a positive or negative integer.
% TimeCol – Index of the time column in the tracks matrix.
% TimeFrame – The amount of time elapsed between each frame.
% TrackIDCol – Index of the track ID column in the tracks matrix.
% Tracks – Matrix containing the set of tracks from which the subset is to be extracted.
% Output Structure Members
% Tracks – The subset of tracks extracted from the tracks matrix.

tracks=input_args.Tracks.Value;
frame_step=input_args.FrameStep.Value;
offset_frame=input_args.OffsetFrame.Value;
startframe=input_args.CurFrame.Value+frame_step*offset_frame;
offset_dir=sign(offset_frame);
timeframe=input_args.TimeFrame.Value;
timeCol=input_args.TimeCol.Value;
max_missing_frames=input_args.MaxMissingFrames.Value;
track_id_col=input_args.TrackIDCol.Value;
cur_tracks=tracks(tracks(:,timeCol)==(startframe-1)*timeframe,:);
track_ids=cur_tracks(:,track_id_col);
min_time=min(tracks(:,timeCol));
if (max_missing_frames<1)
    max_missing_frames=1;
end
for i=frame_step:frame_step:(frame_step*max_missing_frames)
    cur_time=(startframe+offset_dir*i-1)*timeframe;
    if (cur_time<min_time)
        break;
    end
    new_tracks_idx=tracks(:,timeCol)==cur_time;
    new_track_ids=tracks(new_tracks_idx,track_id_col);
    [diff_track_ids diff_track_idx]=setdiff(new_track_ids,track_ids);
    if isempty(diff_track_ids)
        continue;
    end
    new_tracks=tracks(new_tracks_idx,:);
    diff_tracks=new_tracks(diff_track_idx,:);
    cur_tracks=[cur_tracks; diff_tracks];
    track_ids=[track_ids; diff_track_ids];
end
output_args.Tracks=cur_tracks;
%end getCurrentTracks
end
