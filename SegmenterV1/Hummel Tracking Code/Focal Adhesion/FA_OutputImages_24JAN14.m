clear all
ImageDirectory='C:\Users\digginnl\Documents\Cell 02 110112 GFP-Vinc\';
Output='C:\Users\digginnl\Documents\Cell 02 110112 GFP-Vinc\';
ImageRoot='Cell 02_t';
StartFrame=1;
FrameCount=21;
TimeFrame=1;
FrameStep=1;
NumberFormat='%2d';
ImageExtension='.TIF';
MaxMissingFrames=3;
OutputDirectory=[Output 'OutputTest\'];

%%%%%%%%%%%%%%%%%
FINAL_FA_TRACKING = 1; % IF READ PUT 1 IF NOT []
%%%%%%%%%%%%%%%%%

% Adjustable Parameters for processing the images
BrightnessThresholdPct= 1.35; % 1.35; %1.25
GlobalIntensityThresh= 0.01; %0.015; %0.025
MinFAArea= 15; % 5; % 30; % 15
MaxFAArea=500; %500
GaussStdDev=2.5;
GaussKernSize=5;
% ShowIDs=true;

CutOffFreq=10;
FilterOrder=6;
FilterType='LowPass';
MinObjectArea=5000;
% Open place holders that filled later
% Do not alter
CellID = [];
Time = [];
Centroid1 =[];
Centroid2 = [];
Centroid3 = [];
Area=[];
Intensity=[];
SliceID = [];
existing_tracks =[];
Adjusted_Current_FA = [];
Adjusted_Current_FA2 = [];
Adjusted_Current_FA_end = [];
Total_Adjusted_FA = [];
All_FA_data = [];

Type3 = '.xlsx';
DataFileName = 'FocalAdhesionDataTESTB_Box';
FA_Data = xlsread([OutputDirectory DataFileName Type3]);

for x = StartFrame:FrameCount
    
CurrentFrame = x;    
FileName = [ImageDirectory ImageRoot num2str(CurrentFrame,NumberFormat) ImageExtension];

%% Reading 3D Images
image_name=FileName;
img_channel='';
img_info = imfinfo(image_name);
nr_images = numel(img_info);
img_width=img_info.Width;
img_height=img_info.Height;
img_3d=zeros(img_width,img_height,nr_images);
for i=1:nr_images
    cur_img=imread(image_name,i);
    switch img_channel        
        case 'r'
            cur_img=cur_img(:,:,1);
        case 'g'
            cur_img=cur_img(:,:,2);
        case 'b'
            cur_img=cur_img(:,:,3);
    end
    img_3d(:,:,i)=cur_img;
end
Image=img_3d;
img_size(1)=img_width;
img_size(2)=img_height;
img_size(3)=nr_images;
ImageSize=img_size;

% Normalizing Images
int_class='uint16';
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
% Guassian Filter
kernel_size=GaussKernSize;
standard_dev=GaussStdDev;
Image=imfilter(Image, fspecial('gaussian',kernel_size,standard_dev), 'symmetric', 'conv');
% Normalizing the Guassian Filtered Image
int_class='uint16';
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
Image1 = Image;
% Local Average Filter for the 3D Images
Strel='disk';
StrelSize=10;
avg_filter=fspecial(Strel,StrelSize);
img=Image;
img_sz=size(img);
img_bw=zeros(img_sz);
brightness_pct=BrightnessThresholdPct;
for i=1:img_sz(3)
    slice=img(:,:,i);
    slice_avg=imfilter(slice,avg_filter,'replicate');
    img_bw(:,:,i)=slice>(brightness_pct*slice_avg);
end
Image1A=img_bw;
Image=img_bw;

% Frequency Filter
img=Image;
original_img_sz=size(img);
img_sz(1)=2^nextpow2(2*original_img_sz(1)-1);
img_sz(2)=2^nextpow2(2*original_img_sz(2)-1);
%calculate the square distance matrix from the center point
dist_matrix=false(img_sz(1:2));
dist_matrix(floor(img_sz(1)/2)+1,floor(img_sz(2)/2)+1)=true;
dist_matrix=bwdist(dist_matrix).^2;
%arrange it so it's in the proper form for fft2
dist_matrix=ifftshift(rot90(dist_matrix,2));
%setup the filter
cutoff_freq=CutOffFreq;
filter_order=FilterOrder;
filter_type=FilterType;
switch(filter_type)
    case 'LowPass'
        butterworth_filter=1./(1+ (dist_matrix./cutoff_freq).^(2*filter_order));
    case 'HighPass'
        butterworth_filter=1-1./(1+ (dist_matrix./cutoff_freq).^(2*filter_order));
end
%filter the image in the frequency domain
nr_slices=original_img_sz(3);
img_filtered=zeros(original_img_sz);
for i=1:nr_slices
    slice_fft=fft2(double(img(:,:,i)),img_sz(1),img_sz(2));
    filtered_slice=real(ifft2(butterworth_filter.*slice_fft));
    img_filtered(:,:,i)=filtered_slice(1:original_img_sz(1),1:original_img_sz(2));
end
Image2=img_filtered;

% Flatten Image Function
var1=Image1; % Image produced from the Guassian Filter
var2=Image2; % Image produced from the Frequency Filter
ConvertToDouble=true;
if (ConvertToDouble)
    Quotient=double(var1)./double(var2);
else
    Quotient=var1./var2;
end

% Intensity Filter
% Image is from the Normalized Image following the Guassian Filter
img=Image1;
img_sz=size(img);
img_bw=zeros(img_sz);
brightnessPct=GlobalIntensityThresh;
for i=1:img_sz(3)
    slice=img(:,:,i);
    max_pixel=max(slice(:));
    min_pixel=min(slice(:));
    threshold_intensity=brightnessPct*double(max_pixel-min_pixel)+min_pixel;
    img_bw(:,:,i)=slice>threshold_intensity;
end

Image=img_bw;
% Clear non-cells from the image
Image1C=bwareaopen(Image,MinObjectArea);
Image=bwareaopen(Image,MinObjectArea);

% Combine Images
CombineOperation='AND';
switch (CombineOperation)
    case 'AND'
        Image=Image1A&Image1C;
    case 'OR'
        Image=Image1A|Image1C;
end

% Clear Border Slices
img=Image;
img_sz=size(img);
img_output=zeros(img_sz);

for i=1:img_sz(3)
    img_output(:,:,i)=imclearborder(img(:,:,i));    
end

Image=img_output;

% Clear Small Objects
Image=bwareaopen(Image,MinFAArea);

% Begin to identify and Label Objects within the image and slices
LabelMatrix=bwlabeln(Image);
LabelMatrix2=bwlabeln(Image);
LabelMatrix3=bwlabeln(Image);

%
%
%
%%
Current_Data = FA_Data(FA_Data(:,2) == x,:);

for z = 1:nr_slices
%
% Filtered Objects
Object_Data = Current_Data(Current_Data(:,3) == z,:);
[E B] = size(Object_Data);

FA_filter = LabelMatrix2(:,:,z);
cells_lbl= LabelMatrix2(:,:,z);
cells_props=regionprops(FA_filter,'Centroid','Area','PixelIdxList', 'PixelList');
p = cells_props;
	for obj=1:size(p,1)
		
		p(obj).label = obj;    

		p(obj).Intensity =  sum((p(obj).PixelIdxList));
    end
cells_area=[cells_props.Area];
cells_nr=length(cells_area);
valid_areas_idx = true(1,cells_nr);

All_Int = [];
Centroid_X_idx = [];
for lgt = 1: cells_nr
    CentroidX = [];
    Intensity = [];
    CentroidX = cells_props(lgt).Centroid(1);
    Intensity = p(lgt).Intensity;
    Centroid_X_idx = vertcat(Centroid_X_idx, CentroidX);
    All_Int= vertcat(All_Int, Intensity);
end
    cells_centroidX = rot90(Centroid_X_idx);
    All_Int = rot90(All_Int);

if isempty(valid_areas_idx)
else
valid_areas_idx= valid_areas_idx & ismember(int64(cells_area), int64(Object_Data(1:E,6)));
valid_areas_idx= valid_areas_idx & ismember(int64(cells_centroidX), int64(Object_Data(1:E,4)));
valid_areas_idx= valid_areas_idx & ismember(int64(All_Int), int64(Object_Data(1:E,7)));
% valid_areas_idx= valid_areas_idx &(cells_area >= 5); % Object_Data(:,6));

valid_object_numbers=find(valid_areas_idx);
new_object_numbers=1:length(valid_object_numbers);
object_idx=cells_lbl>0;
new_object_index=zeros(max(cells_lbl(object_idx)),1);
new_object_index(valid_object_numbers)=new_object_numbers;
new_cells_lbl=cells_lbl;
object_idx=cells_lbl>0;
new_cells_lbl(object_idx)=new_object_index(cells_lbl(object_idx));
LabelMatrix3=new_cells_lbl;

    
cur_img=Image1(:,:,z);
objects_lbl=LabelMatrix3;
img_sz=size(objects_lbl);
max_pxl=intmax(int_class);

red_color=cur_img;
green_color=cur_img;
blue_color=cur_img;

show_ids=true;

avg_filt=fspecial('average',[3 3]);
lbl_avg=imfilter(objects_lbl,avg_filt,'replicate');
lbl_avg=double(lbl_avg).*double(objects_lbl>0);
img_bounds=abs(double(objects_lbl)-lbl_avg);
img_bounds=im2bw(img_bounds,graythresh(img_bounds));

obj_bounds_lin=find(img_bounds);
green_color(obj_bounds_lin)=max_pxl;
green_color(obj_bounds_lin)=0;
blue_color(obj_bounds_lin)=max_pxl;

label_ids = unique(objects_lbl);
label_ids(label_ids==0) = [];
nr_objects=size(label_ids,1);

if (show_ids)
    for j=1:nr_objects
        cell_id = label_ids(j,:);
        if isempty(cell_id)
            continue
        else
        [current_x current_y] = find(objects_lbl == cell_id);
%        [current_x current_y] = find(objects_lbl == cell_id);
        total_x = sum(current_x);
        total_y = sum(current_y);
        total_size = size(current_x, 1);
        centroid_x = total_x/total_size;
        centroid_y = total_y/total_size;        
        % add the cell ids
% % %         text_img= text2im(num2str(1));
%         text_img=text2im(num2str(Object_Data(j,8)));
        text_img=text2im(num2str(Object_Data(j,1)));
        % text_img=text2im(num2str(cell_id));
        text_img=imresize(text_img,0.45,'nearest');
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
% OutputImageFile= [OutputDirectory ImageRoot num2str(CurrentFrame) num2str(z) 'outimage' ImageExtension];
OutputImageFile= [OutputDirectory ImageRoot num2str(CurrentFrame) 'outimage' '_20JAN14' ImageExtension];
imwrite(cat(3,red_color,green_color,blue_color),OutputImageFile,'WriteMode', 'append');

end

end

end


x = x +1;
end

% FINAL TRACKING SECTION
% CALL THE FUNCTION FinalFATracking
if isempty(FINAL_FA_TRACKING)
else
    Focal_Adhesion_Tracks = FinalFATracking(OutputDirectory, DataFileName, Type3);
    FormatSpreadsheet5 = Focal_Adhesion_Tracks;
    DataFileName5 = 'Focal_Adhesion_Tracks_';
    Date = '24JAN14';
    Type2 = '.csv';
    export(FormatSpreadsheet5, 'File', [OutputDirectory DataFileName5 Date Type2],'Delimiter',',');
end



