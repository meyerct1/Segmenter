function output_args=displayTracksData(input_args)
% Usage
% This module is used to overlay cell outlines (using different colors to indicate different cell generations) and cell labels on the original images after tracking and save the resulting image.
% Input Structure Members
% CellsLabel – The label matrix containing the cell outlines for the current image.
% CurFrame – Integer containing the current frame number.
% CurrentTracks – The list of the tracks for the current image.
% FileRoot – The root of the image file name to be used when generating the image file name for the current image in combination with the current frame number.
% Image – The original image which will be used to generate the image with overlayed outlines and labels.
% NumberFormat – A string indicating the number format of the file name to be used when saving the overlayed image.
% TracksLayout – Matrix describing the order of the columns in the tracks matrix.
% Output Structure Members
% None.


normalize_args.RawImage.Value=input_args.Image.Value;
int_class='uint8';
normalize_args.IntegerClass.Value=int_class;
normalize_output=imNorm(normalize_args);
cur_img=normalize_output.Image;
cur_tracks=input_args.CurrentTracks.Value;
img_sz=size(cur_img);

field_names=fieldnames(input_args);
if (max(strcmp(field_names,'CellsLabel')))
    cells_lbl=input_args.CellsLabel.Value;    
    show_lbl=true;
else
    show_lbl=false;
end

if (max(strcmp(field_names,'LabelColorRGB')))
    lbl_color=input_args.LabelColorRGB.Value;    
else
    lbl_color=[0 255 0];
end

max_pxl=intmax(int_class);
tracks_layout=input_args.TracksLayout.Value;

red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;

if (max(strcmp(field_names,'ShowIDs')))
    b_show_ids=input_args.ShowIDs.Value;
else
    b_show_ids=true;
end
if (max(strcmp(field_names,'IDList')))
    id_list=input_args.IDList.Value;
else
    id_list=[];
end
cur_cell_number=size(cur_tracks,1);

if (show_lbl)
    %i need to get the outlines of each individual cell since more than one
    %cell might be in a blob
    avg_filt=fspecial('average',[3 3]);
    lbl_avg=imfilter(cells_lbl,avg_filt,'replicate');
    lbl_avg=double(lbl_avg).*double(cells_lbl>0);
    img_bounds=abs(double(cells_lbl)-lbl_avg);
    img_bounds=im2bw(img_bounds,graythresh(img_bounds));

    cell_bounds_lin=find(img_bounds);
    %draw the cell bounds in red
    red_color(cell_bounds_lin)=max_pxl;
    green_color(cell_bounds_lin)=0;
    blue_color(cell_bounds_lin)=0;
end

if (b_show_ids)
    centroid1Col=tracks_layout.Centroid1Col;
    centroid2Col=tracks_layout.Centroid2Col;
    trackIDCol=tracks_layout.TrackIDCol;
    for j=1:cur_cell_number
        cur_centroid=cur_tracks(j,centroid1Col:centroid2Col);
        cell_id=cur_tracks(j,trackIDCol);
        if (~isempty(id_list))
            if (max(id_list==cell_id)==0)
                continue;
            end
        end

        %add the cell ids
        text_img=text2im(num2str(cell_id));
        text_img=imresize(text_img,0.75,'nearest');
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
        red_color(text_coord_lin)=lbl_color(1);
        green_color(text_coord_lin)=lbl_color(2);
        blue_color(text_coord_lin)=lbl_color(3);
    end
end

%write the combined channels as an rgb image
imwrite(cat(3,red_color,green_color,blue_color),[input_args.FileRoot.Value num2str(input_args.CurFrame.Value,...
    input_args.NumberFormat.Value) '.jpg'],'jpg');
output_args=[];

%end displayTracksData
end
