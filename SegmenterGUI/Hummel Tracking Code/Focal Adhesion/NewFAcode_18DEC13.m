clear all
ImageDirectory='~/Documents/Test/';
Output='~/Documents/Test/';
ImageRoot='Cell 04_w1Live GFP_t0';
StartFrame=1;
FrameCount=2;
TimeFrame=1;
FrameStep=1;
NumberFormat='%2d';
ImageExtension='.TIF';
MaxMissingFrames=3;
OutputDirectory=[Output 'Output/'];
% Adjustable Parameters for processing the images
BrightnessThresholdPct= 1.25; % 1.35; %1.25
GlobalIntensityThresh= 0.01; %0.015; %0.025
MinFAArea= 15; % 5; % 30; % 15
MaxFAArea=500; %500
GaussStdDev=2.5;
GaussKernSize=5;
% ShowIDs=true;

% Creates a bounding box for the FAs
X_min = 150; %130
X_max = 415; % 350; %300
Y_min= 135;
Y_max = 375; %380
% 

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

%% Data in the Images
AllFAAs = [];
FA_data_One = [];
[Q W E] = size(LabelMatrix);

for r = 1:E
cells_lbl=LabelMatrix(:,:,r);
% % cells_props=regionprops(cells_lbl,'Centroid','Area');

cells_props=regionprops(cells_lbl,'Centroid','Area', 'PixelIdxList', 'PixelList');
p = cells_props;
	for obj=1:size(p,1)
		
		p(obj).label = obj;    

		p(obj).Intensity =  sum((p(obj).PixelIdxList));
    end
cell_props = p;
   b_min=true;
   b_max=true;
cells_area=[cells_props.Area];
cells_nr=length(cells_area);
valid_areas_idx=true(1,cells_nr);

%%%%%%
Centroid_X_idx = [];
Centroid_Y_idx = [];
All_Areas = [];
All_Int = [];
Label = [];
for lgt = 1: cells_nr
    CentroidX = [];
    CentroidY = [];
    Area = [];
    Intensity = [];
    Labels = [];
    CentroidX = cells_props(lgt).Centroid(1);
    CentroidY = cells_props(lgt).Centroid(2);
    Area = cells_props(lgt).Area;
    Intensity = p(lgt).Intensity;
    Labels = p(lgt).label;
    Centroid_X_idx = vertcat(Centroid_X_idx, CentroidX);
    Centroid_Y_idx = vertcat(Centroid_Y_idx, CentroidY);
    All_Areas= vertcat(All_Areas, Area);
    All_Int= vertcat(All_Int, Intensity);  
    Label = vertcat(Label, Labels);
end
    Centroid_X_values = rot90(Centroid_X_idx);
    Centroid_Y_values = rot90(Centroid_Y_idx);
    Potential_FAs = horzcat(Label, Centroid_X_idx, Centroid_Y_idx,All_Areas, All_Int);
%%%%%%%%
% Area Filter
valid_area_idx = rot90(valid_areas_idx);
if (b_min)
   valid_area_idx=valid_area_idx & (Potential_FAs(:,4)>=MinFAArea);
end

if (b_max)
   valid_area_idx=valid_area_idx&(Potential_FAs(:,4)<=MaxFAArea);
end
% Bounding Box 
valid_area_idx = valid_area_idx & (Potential_FAs(:,2) >= X_min);
valid_area_idx = valid_area_idx & (Potential_FAs(:,2) <= X_max);
valid_area_idx = valid_area_idx & (Potential_FAs(:,3) >= Y_min);
valid_area_idx = valid_area_idx & (Potential_FAs(:,3) <= Y_max);

% Valid FAs
Valid_FAs = Potential_FAs(valid_area_idx,:);

[O P]=size(Valid_FAs(:,1));
for I = 1:O
    
    FAA_Objects = horzcat(CurrentFrame, r,Valid_FAs(I,1), Valid_FAs(I,2), Valid_FAs(I,3), Valid_FAs(I,4), Valid_FAs(I,5));% IntegratedIntensities(I));
    AllFAAs = vertcat(AllFAAs, FAA_Objects);
    FAA_Objects = [];
end
    
    FA_data_One = vertcat(FA_data_One, AllFAAs);
    AllFAAs = [];

end

%% FA_data_Two = FA_data_One; 
Possible_IDs = 1:length(FA_data_One(:,1));
     IDs = rot90(Possible_IDs);
     IDs = flipud(IDs);
     FA_data_Two = horzcat(IDs, FA_data_One);
     New_subA = [];
% Distnce Search through depth
     for R = 1:length(unique(FA_data_Two(:,3)))
         ARR = unique(FA_data_Two(:,3));
         AR = ARR(R);
     if R == 1
         subset = FA_data_Two(FA_data_Two(:,3) == AR,:);
         Distance = 0;
         Dist_List = repmat(Distance,length(subset(:,1)),1);
         Index = subset(:,1);
         New_sub = horzcat(subset, Index, Dist_List);
     else
         subset_two = FA_data_Two(FA_data_Two(:,3) == AR,:);
         Search_Data = New_sub(New_sub(:,3) == AR-1,:); 
         if isempty(Search_Data)
             Search_Data = New_sub(New_sub(:,3) == AR-2,:);
         end
         
         [Index, Distance] = knnsearch(Search_Data(:,4:5),subset_two(:,4:5));
 %    
         if isempty(Index)
             DistanceA = 0;
             Inde = subset_two(1,1);
             Distance = repmat(DistanceA, length(subset_two(:,1)),1);
             Index = repmat(Inde, length(subset_two(:,1)),1);
         end
  
         New_subA = horzcat(subset_two, Index, Distance);
         
     end
     if isempty(New_subA)
         continue
     else
         New_sub = vertcat(New_sub, New_subA);
     end
   end
    
    All_FA_data = vertcat(All_FA_data, New_sub);

    FA_data_Two = [];
        
%%
% Ends the loop
x = x +1;
end

Data = struct('Counts', All_FA_data(:,1), 'ImageNumber', All_FA_data(:,2), 'Slice', All_FA_data(:,3), ...
    'CentroidX', All_FA_data(:,5), 'CentroidY', All_FA_data(:,6), 'Area', All_FA_data(:,7), ...
    'Intensity', All_FA_data(:,8), 'IndexID', All_FA_data(:,9), 'Distance', All_FA_data(:,10),'Original_Idx', All_FA_data(:,4));

FormatSpreadsheet = struct2dataset(Data);
DataFileName = 'FocalAdhesionDataTESTB_BoxNew';
Type2 = '.csv';
export(FormatSpreadsheet, 'File', [OutputDirectory DataFileName Type2],'Delimiter',',');
%%
%
% PAUSE MUST REFINE DATA BEFORE CONTINUING
%
%%
% % Type3 = 'xlsx';
% % RefinedData= xlsread([OutputDirectory DataFileName Type3]);







%
clear all
