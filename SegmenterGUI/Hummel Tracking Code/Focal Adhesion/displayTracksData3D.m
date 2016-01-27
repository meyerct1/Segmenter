function output_args=displayTracksData3D(input_args)
% Usage
% This module is used to overlay cell outlines (using different colors to indicate different cell generations) and cell labels on the original images after tracking and save the resulting image.
% Input Structure Members
% CurFrame – Integer containing the current frame number.
% CurrentTracks – The list of the tracks for the current image.
% FileRoot – The root of the image file name to be used when generating the image file name for the current image in combination with the current frame number.
% Image – The original image which will be used to generate the image with overlayed outlines and labels.
% NumberFormat – A string indicating the number format of the file name to be used when saving the overlayed image.
% ObjectsLabel – The label matrix containing the object outlines for the
% current image.
% ShowIDs - A boolean value indicating whether do display track IDs or not.
% TextSize - Optional value specifying the text size as a percentage of the
% default.
% TracksLayout – Matrix describing the order of the columns in the tracks matrix.
% Output Structure Members
% None.
%module to display and save images showing the object boundaries and object
%of a 3-D stack
img=input_args.Image.Value;
img_class=class(img);
max_pxl=intmax(img_class);
img_sz=size(img);
nr_slices=img_sz(3);
show_ids=input_args.ShowIDs.Value;
cur_tracks=input_args.CurrentTracks.Value;
objects_lbl=input_args.ObjectsLabel.Value;
tracks_layout=input_args.TracksLayout.Value;
centroid1Col=tracks_layout.Centroid1Col;
centroid3Col=tracks_layout.Centroid3Col;
nr_tracks=size(cur_tracks,1);
label_indices=zeros(nr_tracks,1);
temp_args.LabelMatrix.Value=objects_lbl;
temp_out=getCentroids3D(temp_args);
centroid_list=temp_out.Centroids;
FA_IDs_Image=cur_tracks(:,1);
clear temp_args;
clear temp_out;
field_names=fieldnames(input_args);
if (max(strcmp(field_names,'TextSize')))
    text_size=input_args.TextSize.Value;
else
    text_size=0.75;
end
nr_centroids=length(centroid_list);
for i=1:nr_tracks
    %the min distance between the cur_centroid and the centroid list gives the
    %position in the label which in turn provides the id of the object
%     centroid_dist=sqrt(sum((centroid_list-repmat(cur_tracks(i,centroid1Col:centroid3Col),nr_centroids,1)).^2,2));
%     [dummy label_indices(i)]=min(centroid_dist);
    centroid_dist=cur_tracks(:,1);
    [dummy label_indices(i)]=min(centroid_dist);
track_ids=cur_tracks(:,tracks_layout.TrackIDCol);

output_tiff_name=[input_args.FileRoot.Value num2str(input_args.CurFrame.Value,...
    input_args.NumberFormat.Value) '.tiff'];    
%i need to get the outlines of each individual cell since more than one
%cell might be in a blob
avg_filt=fspecial('average',[3 3]);

for i=1:nr_slices
    img_slice=(img(:,:,i));
    red_color=img_slice;
    green_color=img_slice;
    blue_color=img_slice;
    lbl_slice=objects_lbl(:,:,i);
    slice_ids=unique(lbl_slice(:));
    slice_ids(1)=[];
    slice_centroids=getApproximateCentroids(lbl_slice);
    slice_centroids=slice_centroids(slice_ids,:);
    %draw the object outlines in the slice
    lbl_avg=imfilter(lbl_slice,avg_filt,'replicate');
    lbl_avg=double(lbl_avg).*double(lbl_slice>0);
    obj_bounds=abs(double(lbl_slice)-lbl_avg);
    obj_bounds=im2bw(obj_bounds,graythresh(obj_bounds));
    obj_bounds_lin=find(obj_bounds);
    %draw the cell bounds in red
    red_color(obj_bounds_lin)=max_pxl;
    green_color(obj_bounds_lin)=0;
    blue_color(obj_bounds_lin)=0;
    objects_nr=length(slice_ids);
    if (show_ids)
        %add the label ids for each object
        for j=1:objects_nr
            cur_lbl_id=slice_ids(j);
            cur_centroid=slice_centroids(j,:);
            cur_track_id=track_ids(cur_lbl_id);
            %  cur_track_id=track_ids(label_indices==cur_lbl_id);
            %write the label text
            text_img=text2im(num2str(cur_track_id));
            text_img=imresize(text_img,text_size,'nearest');
            text_length=size(text_img,2);
            text_height=size(text_img,1);
            rect_coord_1=round(cur_centroid(1)-text_height/2);
            rect_coord_2=round(cur_centroid(1)+text_height/2);
            rect_coord_3=round(cur_centroid(2)-text_length/2);
            rect_coord_4=round(cur_centroid(2)+text_length/2);
            if ((rect_coord_1<1)||(rect_coord_2>img_sz(1))||(rect_coord_3<1)||(rect_coord_4>img_sz(2)))
                continue;
            end
            [text_coord_1 text_coord_2]=find(text_img==0);
            %offset the text coordinates by the image coordinates in the (low,low)
            %corner of the rectangle
            text_coord_1=text_coord_1+rect_coord_1;
            text_coord_2=text_coord_2+rect_coord_3;
            text_coord_lin=sub2ind(img_sz,text_coord_1,text_coord_2);
            %write the text in green
            red_color(text_coord_lin)=0;
            green_color(text_coord_lin)=max_pxl;
            blue_color(text_coord_lin)=0;
        end
    end
    %save the slice to tiff
    if (i==1)
        imwrite(cat(3,red_color,green_color,blue_color),output_tiff_name,'tif','Compression','none');
    else
        imwrite(cat(3,red_color,green_color,blue_color),output_tiff_name,'tif','WriteMode','append','Compression','none');
    end
end

output_args.slicenumber=nr_slices;
output_args=[];

%end displayTracksData
end
