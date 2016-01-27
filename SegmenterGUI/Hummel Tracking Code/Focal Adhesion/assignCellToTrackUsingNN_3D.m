function output_args=assignCellToTrackUsingNN_3D(input_args)
%Usage
%This module tracks objects in a time-lapse sequence of 3D label matrices using a nearest-neighbor
%algorithm.
%
%Input Structure Members
%CellsCentroids - Current object centroids.
%CurrentTracks - Matrix containing the track assignments for the objects in the previous frame.
%MaxTrackID - Current maximum track ID.
%TrackAssignments - List of track assignments that have already been completed.
%TracksLayout - Matrix describing the order of the columns in the tracks matrix.
%UnassignedCells - List of object IDs currently unassigned.
%
%Output Structure Members
%ExcludedTracks - Returns empty value. Included for compatibility only.
%GroupIndex - Returns zero. Included for compatibility only.
%MatchingGroups - Returns empty value. Included for compatibility only.
%TrackAssignments - List of track assignments that have already been completed.
%UnassignedIDs - List of object IDs currently unassigned.

unassignedIDs=input_args.UnassignedCells.Value;
cells_centroids=input_args.CellsCentroids.Value;
cur_tracks=input_args.CurrentTracks.Value;
trackAssignments=input_args.TrackAssignments.Value;
tracks_layout=input_args.TracksLayout.Value;
max_tracks=input_args.MaxTrackID.Value;
centroid1Col=tracks_layout.Centroid1Col;
centroid3Col=tracks_layout.Centroid3Col;
nr_tracks=size(cur_tracks,1);

trackIDCol=tracks_layout.TrackIDCol;

%assign current cell to a track
cur_id=unassignedIDs(1);
unassignedIDs(1)=[];
cur_cell_centroid=cells_centroids(cur_id,:);
dist_to_existing_tracks=sqrt(sum((cur_tracks(:,centroid1Col:centroid3Col)-repmat(cur_cell_centroid,nr_tracks,1)).^2,2));
[min_dist nearest_track_idx]=min(dist_to_existing_tracks);
nearest_track_id=cur_tracks(nearest_track_idx,trackIDCol);
if (isempty(trackAssignments))
    track_idx=[];
    competing_id=[];
else
    track_idx=find(trackAssignments(:,1)==nearest_track_id,1);
    competing_id=trackAssignments(track_idx,2);
end
%is the track this cell wants claimed?
if (isempty(track_idx))
    %track is not claimed-assign it to this cell
    trackAssignments=[trackAssignments; [nearest_track_id cur_id]];    
else
    if isempty(trackAssignments)
        max_track_id=max([cur_tracks(:,trackIDCol);max_tracks]);
    else
        max_track_id=max([cur_tracks(:,trackIDCol); trackAssignments(:,1); max_tracks]);
    end
    %which cell is the better match?
    track_centroid=cur_tracks(nearest_track_idx,centroid1Col:centroid3Col);
    competing_centroid=cells_centroids(competing_id,:);
    competing_dist=sqrt(sum((track_centroid-competing_centroid).^2));    
    if (competing_dist<min_dist)
        %the competing cell is preferred 
        trackAssignments=[trackAssignments; [max_track_id+1 cur_id]];        
    else
        %this cell is preferred by the track
        trackAssignments(track_idx,2)=cur_id;
        trackAssignments=[trackAssignments; [max_track_id+1 competing_id]];        
    end
end

output_args.UnassignedIDs=unassignedIDs;
output_args.TrackAssignments=trackAssignments;
output_args.MatchingGroups=[];
output_args.GroupIndex=0;
output_args.ExcludedTracks=[];

%end assignCellToTracksUsingNN
end