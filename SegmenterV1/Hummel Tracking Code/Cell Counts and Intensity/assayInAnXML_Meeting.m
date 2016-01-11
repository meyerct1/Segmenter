% Stain Intensity Analysis for Images Acquired on the CellaVista
%
% Current Set up is for 3 Channels and reads the information from the XML
% file generated from the CV. The XML must be in txt format. User input is
% limited but can be used to provide better segmentation. Segmentation
% struggles at times to confluency and artifacts in the image that appear
% once the processing begins. 
%
CVOutputFile = '1.txt'; % This is the XML converted to a txt file for input to MATLAB
ImageFolder= '~/Dropbox/Stain Images for Analysis/20121109 A375 Series/pRb/20130206 96h pRb/1/';
OutputFolder='~/Dropbox/Stephen and Darren Shared/20121109 A375 Series/pRb/Test Code/';
CSVRepository = '~/Dropbox/Stephen and Darren Shared/Data Repository/Test Code/';
channels = 3; 
%
% User information for the output file
ExperimentDate = '20121109';
Time = '0';
CellType = 'A375'; % A375 or skmel5
%
% THESE CAN BE ALTERED FOR BETTER SEGMENTATION; USER DISCRETION
Strel='disk';
StrelSize= 18; %15 
BrightnessThresholdPct=1.35; 
ClearBorder_intensity=false;
IntensityThresholdPct=0.10; 
MinObjectArea=200;
%
% % % % % % % % DO NOT ALTER % % % % % % % % % % % % 
IntegerClass='uint8';
ClearBorder=true;
ClearBorderDist=0;
FormatSpreadsheet = [];
ShowIDs=true;
NameChannel1='Overlay_ChannelTwo';
NameChannel2='Overlay_ChannelThree';
DataFile='ImageProperties';
Type='.jpg';
% Type='.tif';
ID = [];
Area = [];
One_Intensity = [];
Two_Intensity = [];
Three_Intensity = [];
image_number = [];
date =[];
well = [];
timeX = [];
cellX =[];
RowName = [];
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% Required Patterned to pull out image names froms the XML/txt file
% DO NOT ALTER
CVOutputFile = fileread([ImageFolder CVOutputFile]);
Pattern = '[0-9_]+-?[0-9_]+-[A-Z_]+[0-9_]+-[A-Z_]+[0-9_]+.tiff';
D = regexp(CVOutputFile, Pattern, 'match');
V = rot90(D);
J = flipud(V);
x = 1;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
%% This loop extracts the necessary information out of the XML file
% for i = 1:length(J)
%      ImageName1 = J(i,:);
% % This is used to determine the Row Name for the WellName Output. This works its way through all names    
% end     
 ImageNameProcessList = J(1:channels:end);
 ImageNameProcessList2 = J(2:channels:end);
 ImageNameProcessList3 = J(3:channels:end);

    
 %% This is the critical iteration loop now that all the Image Names have been extracted from the file
 for channel1 = 1:length(ImageNameProcessList)

     ImageName = [ImageFolder char(ImageNameProcessList(x))];
     ImageName2 = [ImageFolder char(ImageNameProcessList2(x))];
     ImageName3 = [ImageFolder char(ImageNameProcessList3(x))];
 
 % This section is used to determine the Well Name based on the Row and
 % Column currently being processed
     Row = regexp(ImageNameProcessList(x), '(?<=-R)\d+','match');
     count = length(ImageNameProcessList(x));
     for k = 1:count
     Row = char(Row{k});
     end
     
     if Row == '02'
         RowName = 'B';
     elseif Row == '03'
         RowName = 'C';
     elseif Row == '04'
         RowName = 'D';
     elseif Row == '05'
         RowName = 'E';
     elseif Row == '06'
         RowName = 'F';
     elseif Row == '07'
         RowName = 'G';
     elseif Row == '08'
         RowName = 'H';
     end
% This is the end of the Row Name and provides data to the WellName     
     Well = regexp(ImageNameProcessList(x), '(?<=-C)[0-9_]+','match');
     for k = 1:count
     Well = char(Well{k});
     end
%      Well = char(Well);
     WellName = horzcat([RowName Well]);
    
     %% Read the image into the script - Channel 1
image_name=ImageName;
img_channel='r';
img_to_proc=imread(image_name);
switch img_channel
    case 'r'
        img_to_proc=img_to_proc(:,:,1);
    case 'g'
        img_to_proc=img_to_proc(:,:,2);
    case 'b'
        img_to_proc=img_to_proc(:,:,3);
end
Image=img_to_proc;
ImageA=Image;

%% Normalize the image - Channel 1
int_class=IntegerClass;
max_val=double(intmax(int_class));
img_raw=Image;
img_dbl=floor(double((img_raw-min(img_raw(:))))*max_val./double(max(img_raw(:))-min(img_raw(:))));
switch(int_class)
    case 'uint8'
       Image=uint8(img_dbl);
    case 'uint16'
       Image=uint16(img_dbl);
    otherwise
        Image=[];
end

%% Threshold the Image
avg_filter=fspecial(Strel,StrelSize);
img_avg=imfilter(Image,avg_filter,'replicate');
img_bw=Image>(BrightnessThresholdPct*img_avg);
% if (ClearBorder)
%     clear_border_dist=ClearBorderDist;
%     if (clear_border_dist>1)
%         img_bw(1:clear_border_dist-1,1:end)=1;
%         img_bw(end-clear_border_dist+1:end,1:end)=1;
%         img_bw(1:end,1:clear_border_dist-1)=1;
%         img_bw(1:end,end-clear_border_dist+1:end)=1;
%     end
%     Image=imclearborder(img_bw);
% else
    Image=img_bw;
% end

%% Clear Border Intensity
max_pixel=max(Image(:));
min_pixel=min(Image(:));
brightnessPct=IntensityThresholdPct;
threshold_intensity=brightnessPct*double(max_pixel-min_pixel)+min_pixel;
img_bw=Image>threshold_intensity;
% img_bw=im2bw(img_to_proc,brightnessPct*graythresh(img_to_proc));
% clear_border_dist=ClearBorderDist;
% if (ClearBorder_intensity)
%     if (clear_border_dist>1)
%         img_bw(1:clear_border_dist-1,1:end)=1;
%         img_bw(end-clear_border_dist+1:end,1:end)=1;
%         img_bw(1:end,1:clear_border_dist-1)=1;
%         img_bw(1:end,end-clear_border_dist+1:end)=1;
%     end
%     Image=imclearborder(img_bw);
% else
    Image=img_bw;
% end

%% Clear small objects based on preset indicated above
Image=bwareaopen(Image,MinObjectArea);
Image1AA = Image;
LabelMatrix=bwlabeln(Image);
LabelMatrixNuclei=LabelMatrix;
objects_idx=LabelMatrixNuclei>0;

%% Channel 2 - IAMGE PROCESSING
%
% Read Image from Channel 2
image_name2=ImageName2;
img_channel='r';
img_to_proc2=imread(image_name2);
switch img_channel
    case 'r'
        img_to_proc2=img_to_proc2(:,:,1);
    case 'g'
        img_to_proc2=img_to_proc2(:,:,2);
    case 'b'
        img_to_proc2=img_to_proc2(:,:,3);
end
Image2=img_to_proc2;
Image2a=Image2;
%
int_class=IntegerClass;
max_val=double(intmax(int_class));
img_raw2=Image2;
img_dbl2=floor(double((img_raw-min(img_raw2(:))))*max_val./double(max(img_raw2(:))-min(img_raw2(:))));
switch(int_class)
    case 'uint8'
       Image2=uint8(img_dbl2);
    case 'uint16'
       Image2=uint16(img_dbl2);
    otherwise
        Image2=[];
end
Image2b=Image2;
%
avg_filter=fspecial(Strel,StrelSize);
img_avg=imfilter(Image2,avg_filter,'replicate');
img_bw2=Image2>(BrightnessThresholdPct*img_avg);
if (ClearBorder)
    clear_border_dist=ClearBorderDist;
    if (clear_border_dist>1)
        img_bw2(1:clear_border_dist-1,1:end)=1;
        img_bw2(end-clear_border_dist+1:end,1:end)=1;
        img_bw2(1:end,1:clear_border_dist-1)=1;
        img_bw2(1:end,end-clear_border_dist+1:end)=1;
    end
    Image2=imclearborder(img_bw2);
else
    Image2=img_bw2;
end
%
max_pixel2=max(Image2(:));
min_pixel2=min(Image2(:));
brightnessPct=IntensityThresholdPct;
threshold_intensity2=brightnessPct*double(max_pixel2-min_pixel2)+min_pixel2;
img_bw2=Image2>threshold_intensity2;
clear_border_dist=ClearBorderDist;
if (ClearBorder_intensity)
    if (clear_border_dist>1)
        img_bw2(1:clear_border_dist-1,1:end)=1;
        img_bw2(end-clear_border_dist+1:end,1:end)=1;
        img_bw2(1:end,1:clear_border_dist-1)=1;
        img_bw2(1:end,end-clear_border_dist+1:end)=1;
    end
    Image2=imclearborder(img_bw2);
else
    Image2=img_bw2;
end
%
Image2=bwareaopen(Image2,MinObjectArea);
Image2clear=Image2;
LabelMatrix2=bwlabeln(Image2);


%% Channel 3 - IMAGE PROCESSING
%
% Read Image
image_name3=ImageName3;
img_channel='r';
img_to_proc3=imread(image_name3);
switch img_channel
    case 'r'
        img_to_proc3=img_to_proc3(:,:,1);
    case 'g'
        img_to_proc3=img_to_proc3(:,:,2);
    case 'b'
        img_to_proc3=img_to_proc3(:,:,3);
end
Image3=img_to_proc3;
Image3a=Image3;
%
int_class=IntegerClass;
max_val=double(intmax(int_class));
img_raw3=Image3;
img_dbl3=floor(double((img_raw-min(img_raw3(:))))*max_val./double(max(img_raw3(:))-min(img_raw3(:))));
switch(int_class)
    case 'uint8'
       Image3=uint8(img_dbl3);
    case 'uint16'
       Image3=uint16(img_dbl3);
    otherwise
        Image3=[];
end
Image3b=Image3;
%
avg_filter=fspecial(Strel,StrelSize);
img_avg=imfilter(Image3,avg_filter,'replicate');
img_bw3=Image3>(BrightnessThresholdPct*img_avg);
if (ClearBorder)
    clear_border_dist=ClearBorderDist;
    if (clear_border_dist>1)
        img_bw3(1:clear_border_dist-1,1:end)=1;
        img_bw3(end-clear_border_dist+1:end,1:end)=1;
        img_bw3(1:end,1:clear_border_dist-1)=1;
        img_bw3(1:end,end-clear_border_dist+1:end)=1;
    end
    Image3=imclearborder(img_bw3);
else
    Image3=img_bw3;
end
%
max_pixel3=max(Image3(:));
min_pixel3=min(Image3(:));
brightnessPct=IntensityThresholdPct;
threshold_intensity3=brightnessPct*double(max_pixel3-min_pixel3)+min_pixel3;
img_bw3=Image3>threshold_intensity3;
clear_border_dist=ClearBorderDist;
if (ClearBorder_intensity)
    if (clear_border_dist>1)
        img_bw3(1:clear_border_dist-1,1:end)=1;
        img_bw3(end-clear_border_dist+1:end,1:end)=1;
        img_bw3(1:end,1:clear_border_dist-1)=1;
        img_bw3(1:end,end-clear_border_dist+1:end)=1;
    end
    Image3=imclearborder(img_bw3);
else
    Image3=img_bw3;
end
%
Image3=bwareaopen(Image3,MinObjectArea);
Image3clear=Image3;
LabelMatrix3=bwlabeln(Image3);

%%
% Segment Channel 2 Image
img_cyto=Image2clear;
nucl_lbl=LabelMatrix;
cyto_lbl=bwlabeln(img_cyto);
new_lbl=zeros(size(cyto_lbl));
nr_clusters=max(cyto_lbl(:));
nucl_ids_left = unique(nucl_lbl);
nucl_ids_left(nucl_ids_left==0) = [];
for i=1:nr_clusters
    cur_cluster=(cyto_lbl==i);
    %get the nuclei ids present in the cluster
    nucl_ids=nucl_lbl(cur_cluster);   
    nucl_ids=unique(nucl_ids);
    %remove the background id
    nucl_ids(nucl_ids==0)=[];
    if isempty(nucl_ids)
        %don't add objects without nuclei
        continue;
    end
    if (length(nucl_ids)==1)
        %only one nucleus - assign the entire cluster to that id
        new_lbl(cur_cluster)=nucl_ids;
        %delete the nucleus that have already been processed
        nucl_ids_left(nucl_ids_left==nucl_ids)=[];
        continue; 
    end
    %get an index to only the nuclei
    nucl_idx=ismember(nucl_lbl,nucl_ids);
    %get the x-y coordinates
    [nucl_x nucl_y]=find(nucl_idx);
    [cluster_x cluster_y]=find(cur_cluster);
    group_data=nucl_lbl(nucl_idx);
    %classify each pixel in the cluster
    pixel_class=knnclassify([cluster_x cluster_y],[nucl_x(1:10:end) nucl_y(1:10:end)],group_data(1:10:end));
    new_lbl(cur_cluster)=pixel_class;
    %delete the nucleus that have already been processed
    for elm = nucl_ids'   % why is there an ' ?
        nucl_ids_left(nucl_ids_left==elm)=[];
    end
end
LabelMatrix2=new_lbl;
LabelMatrixLeft=nucl_lbl;
%
ObjectsLabelTwo=LabelMatrix2;
objects_lbl=LabelMatrixLeft;
objects_lbl2=LabelMatrixLeft;


%% Segment Channel 3 Image
img_c3=Image3clear;
nucl_lbl=LabelMatrix;

%do preliminary segmentation of cytoplasm
c3_lbl=bwlabeln(img_c3);
new_lbl3=zeros(size(c3_lbl));
%segmenting the clusters into individual cells

%get the nuclei ids present in the cluster
nr_clusters3=max(c3_lbl(:));

%keep track of a list of nucl_ids
nucl_ids_left = unique(nucl_lbl);
nucl_ids_left(nucl_ids_left==0) = [];

for i=1:nr_clusters3
    cur_cluster3=(c3_lbl==i);
    %get the nuclei ids present in the cluster
    nucl_ids3=nucl_lbl(cur_cluster3);   
    nucl_ids3=unique(nucl_ids3);
    %remove the background id
    nucl_ids3(nucl_ids3==0)=[];
    if isempty(nucl_ids3)
        %don't add objects without nuclei
        continue;
    end
    if (length(nucl_ids3)==1)
        %only one nucleus - assign the entire cluster to that id
        new_lbl3(cur_cluster3)=nucl_ids3;
        %delete the nucleus that have already been processed
        nucl_ids_left(nucl_ids_left==nucl_ids3)=[];
        continue; 
    end
    %get an index to only the nuclei
    nucl_idx3=ismember(nucl_lbl,nucl_ids3);
    %get the x-y coordinates
    [nucl_x3 nucl_y3]=find(nucl_idx3);
    [cluster_x3 cluster_y3]=find(cur_cluster3);
    group_data3=nucl_lbl(nucl_idx3);
    %classify each pixel in the cluster
    pixel_class3=knnclassify([cluster_x3 cluster_y3],[nucl_x3(1:10:end) nucl_y3(1:10:end)],group_data3(1:10:end));
    new_lbl3(cur_cluster3)=pixel_class3;
    
    %delete the nucleus that have already been processed
    for elm3 = nucl_ids3'   % why is there an ' ?
        nucl_ids_left(nucl_ids_left==elm3)=[];
    end
    
end

ObjectsLabelThree=new_lbl3;
LabelMatrix3=new_lbl3;
LabelMatrixLeft3=nucl_lbl;
objects_lbl3=LabelMatrixLeft3;

%% Functions of the module
cells_props=regionprops(LabelMatrixNuclei,ImageA,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Perimeter','Solidity','ConvexArea', 'PixelIdxList', 'PixelList','MeanIntensity','PixelValues');
shape_params=[[cells_props.Area]'];

cells_props_two=regionprops(LabelMatrixNuclei,Image2a,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Perimeter','Solidity','ConvexArea', 'PixelIdxList', 'PixelList','MeanIntensity','PixelValues');

cells_props_three=regionprops(LabelMatrixNuclei,Image3a,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Perimeter','Solidity','ConvexArea', 'PixelIdxList', 'PixelList','MeanIntensity','PixelValues');

objects_intensities_one=accumarray(LabelMatrixNuclei(objects_idx),ImageA(objects_idx));
objects_intensities_two=accumarray(LabelMatrixNuclei(objects_idx),Image2a(objects_idx));
objects_intensities_three=accumarray(LabelMatrixNuclei(objects_idx),Image3a(objects_idx));

%% Save Outlines for Channel 2
cur_img=Image2b;
objects_lbl=LabelMatrix;
img_sz=size(objects_lbl);
max_pxl=intmax(int_class);

red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;
% blue_color = Image1AA;
% field_names=fieldnames(input_args);
% if (max(strcmp(field_names,'ShowIDs')))
%     b_show_ids=input_args.ShowIDs.Value;
% else
    b_show_ids=true;
% end

%i need to get the outlines of each individual cell since more than one
%cell might be in a blob
avg_filt=fspecial('average',[3 3]);
lbl_avg=imfilter(objects_lbl,avg_filt,'replicate');
lbl_avg=double(lbl_avg).*double(objects_lbl>0);
img_bounds=abs(double(objects_lbl)-lbl_avg);
img_bounds=im2bw(img_bounds,graythresh(img_bounds));

% This section draws the nuclei for stain in red over the image before
% using the subsequent label matrix to draw the stain. This way there is a
% comparative overlap in the images drawn. 
obj_bounds_lin=find(img_bounds);
green_color(obj_bounds_lin)=max_pxl;
% green_color(obj_bounds_lin)=0;
% blue_color(obj_bounds_lin)=max_pxl;
%
% For Channel 2 
%
% 
% objects_lbl_2=ObjectsLabelTwo; % Labels are from the segmented stained image channel
% objects_lbl_2=Testing;
% objects_lbl_2 = objects_idx;
objects_lbl_2=LabelMatrix2;
img_sz=size(objects_lbl_2);

avg_filt=fspecial('average',[3 3]);
lbl_avg_2=imfilter(objects_lbl_2,avg_filt,'replicate');
lbl_avg_2=double(lbl_avg_2).*double(objects_lbl_2>0);
img_bounds_2=abs(double(objects_lbl_2)-lbl_avg_2);
img_bounds_2=im2bw(img_bounds_2,graythresh(img_bounds_2));

obj_bounds_lin_2=find(img_bounds_2);
% red_color(obj_bounds_lin_2)=0;
% green_color(obj_bounds_lin_2)=max_pxl;
blue_color(obj_bounds_lin_2)=max_pxl;
%
objects_lbl_2b=objects_lbl2;
avg_filt=fspecial('average',[3 3]);
lbl_avg_2b=imfilter(objects_lbl_2b,avg_filt,'replicate');
lbl_avg_2b=double(lbl_avg_2b).*double(objects_lbl_2b>0);
img_bounds_2b=abs(double(objects_lbl_2b)-lbl_avg_2b);
img_bounds_2b=im2bw(img_bounds_2b,graythresh(img_bounds_2b));
obj_bounds_lin_2b=find(img_bounds_2b);
% End addition
%
% get the centroids for the text label uses the nuclei stain label matrix
label_ids = unique(objects_lbl);
label_ids(label_ids==0) = [];
nr_objects=size(label_ids,1);

if (b_show_ids)
    for j=1:nr_objects
        cell_id = label_ids(j,:);
        [current_x current_y] = find(objects_lbl == cell_id);
%        [current_x current_y] = find(objects_lbl == cell_id);
        total_x = sum(current_x);
        total_y = sum(current_y);
        total_size = size(current_x, 1);
        centroid_x = total_x/total_size;
        centroid_y = total_y/total_size;        
        %add the cell ids
        text_img=text2im(num2str(cell_id));
        text_img=imresize(text_img,0.75,'nearest');
        text_length=size(text_img,2);
        text_height=size(text_img,1);
        rect_coord_1=round(centroid_x-text_height/2);
        rect_coord_2=round(centroid_x+text_height/2);
        rect_coord_3=round(centroid_y-text_length/2);
        rect_coord_4=round(centroid_y+text_length/2);
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
        red_color(text_coord_lin)=max_pxl;
        green_color(text_coord_lin)=0;
        blue_color(text_coord_lin)=0;
    end
    

    
end

% Generates an RGB image with the outlines
FileName = [OutputFolder NameChannel1 WellName num2str(x) Type];
imwrite(cat(3,red_color,green_color,blue_color),FileName);

%% Save Outlines for Channel 3
cur_img=Image3b;
objects_lbl=LabelMatrix;
img_sz=size(objects_lbl);
max_pxl=intmax(int_class);

red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;

% field_names=fieldnames(input_args);
% if (max(strcmp(field_names,'ShowIDs')))
%     b_show_ids=input_args.ShowIDs.Value;
% else
    b_show_ids=true;
% end

%i need to get the outlines of each individual cell since more than one
%cell might be in a blob
avg_filt=fspecial('average',[3 3]);
lbl_avg=imfilter(objects_lbl,avg_filt,'replicate');
lbl_avg=double(lbl_avg).*double(objects_lbl>0);
img_bounds=abs(double(objects_lbl)-lbl_avg);
img_bounds=im2bw(img_bounds,graythresh(img_bounds));

% This section draws the nuclei for stain in red over the image before
% using the subsequent label matrix to draw the stain. This way there is a
% comparative overlap in the images drawn. 
obj_bounds_lin=find(img_bounds);
green_color(obj_bounds_lin)=max_pxl;
red_color(obj_bounds_lin)=0;
blue_color(obj_bounds_lin)=0;
%
% For Channel 3 stain
%
objects_lbl_2=LabelMatrix3;
img_sz=size(objects_lbl_2);

avg_filt=fspecial('average',[3 3]);
lbl_avg_2=imfilter(objects_lbl_2,avg_filt,'replicate');
lbl_avg_2=double(lbl_avg_2).*double(objects_lbl_2>0);
img_bounds_2=abs(double(objects_lbl_2)-lbl_avg_2);
img_bounds_2=im2bw(img_bounds_2,graythresh(img_bounds_2));

obj_bounds_lin_2=find(img_bounds_2);
% green_color(obj_bounds_lin_2)=max_pxl;
% red_color(obj_bounds_lin_2)=max_pxl;
blue_color(obj_bounds_lin_2)=max_pxl;

%
objects_lbl_2b=objects_lbl3;
avg_filt=fspecial('average',[3 3]);
lbl_avg_2b=imfilter(objects_lbl_2b,avg_filt,'replicate');
lbl_avg_2b=double(lbl_avg_2b).*double(objects_lbl_2b>0);
img_bounds_2b=abs(double(objects_lbl_2b)-lbl_avg_2b);
img_bounds_2b=im2bw(img_bounds_2b,graythresh(img_bounds_2b));
obj_bounds_lin_2b=find(img_bounds_2b);

% red_color(obj_bounds_lin_2b)=0;
% green_color(obj_bounds_lin_2b)=0;
green_color(obj_bounds_lin_2b)=max_pxl;
%
% End addition
%
% %get the centroids
% obj_centroids=getApproximateCentroids(objects_lbl);
% obj_centroids(isnan(obj_centroids(:,1)),:)=[];
% nr_objects=size(obj_centroids,1);
label_ids = unique(objects_lbl);
label_ids(label_ids==0) = [];
nr_objects=size(label_ids,1);

if (b_show_ids)
    for j=1:nr_objects
        cell_id = label_ids(j,:);
        [current_x current_y] = find(objects_lbl == cell_id);
%        [current_x current_y] = find(objects_lbl == cell_id);
        total_x = sum(current_x);
        total_y = sum(current_y);
        total_size = size(current_x, 1);
        centroid_x = total_x/total_size;
        centroid_y = total_y/total_size;        
        %add the cell ids
        text_img=text2im(num2str(cell_id));
        text_img=imresize(text_img,0.75,'nearest');
        text_length=size(text_img,2);
        text_height=size(text_img,1);
        rect_coord_1=round(centroid_x-text_height/2);
        rect_coord_2=round(centroid_x+text_height/2);
        rect_coord_3=round(centroid_y-text_length/2);
        rect_coord_4=round(centroid_y+text_length/2);
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
        red_color(text_coord_lin)=max_pxl;
        green_color(text_coord_lin)=0;
        blue_color(text_coord_lin)=0;
    end
end
% Generates an RGB image with the outlines
FileName = [OutputFolder NameChannel2 WellName num2str(x) Type];
imwrite(cat(3,red_color,green_color,blue_color),FileName);
%% SAVING THE DATA
% this section generates the data output format by saving each iteration
% set into a larger data set that adds to itself with each iteration
date = vertcat(date, repmat(ExperimentDate,[size(label_ids),1]));
well = vertcat(well, repmat(WellName,[size(label_ids),1]));
timeX = vertcat(timeX, repmat(Time,[size(label_ids),1]));
cellX = vertcat(cellX, repmat(CellType,[size(label_ids),1]));
image_number = vertcat(image_number, repmat(x,[size(label_ids),1]));
ID = vertcat(ID, label_ids);
Area = vertcat(Area, shape_params);
One_Intensity = vertcat(One_Intensity, objects_intensities_one);
Two_Intensity = vertcat(Two_Intensity, objects_intensities_two);
Three_Intensity = vertcat(Three_Intensity, objects_intensities_three);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
x = x + 1;
 end
FormatSpreadsheet = struct('ExperimentDate',1, 'WellName',2, 'Time',3, 'CellType',4, 'Image',5, ... 
      'CellID', 6, 'Area',7, 'One_Intensity',8, 'Two_Intensity',9, 'Three_Intensity',10);

FormatSpreadsheet.ExperimentDate=date;
FormatSpreadsheet.WellName=well;
FormatSpreadsheet.Time=timeX;
FormatSpreadsheet.CellType=cellX;
FormatSpreadsheet.Image=image_number;
FormatSpreadsheet.CellID=ID;
FormatSpreadsheet.Area=Area;
FormatSpreadsheet.One_Intensity=One_Intensity;
FormatSpreadsheet.Two_Intensity=Two_Intensity;
FormatSpreadsheet.Three_Intensity=Three_Intensity;
% Date Time Group (DTG) to be written into the data output file
format shortg
writetime = fix(clock);
writetime = num2str(writetime);
writetime = strrep(writetime,' ','');
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
FormatSpreadsheet = struct2dataset(FormatSpreadsheet); % struct2dataset is a new function that does not exist in earlier versions than 2012b
DataFileName='ImageProperties';
DataFileName = [DataFileName writetime];
Type2='.csv';
export(FormatSpreadsheet, 'File', [OutputFolder DataFileName Type2],'Delimiter',',');
export(FormatSpreadsheet, 'File', [CSVRepository DataFileName Type2],'Delimiter',',');

clear all;