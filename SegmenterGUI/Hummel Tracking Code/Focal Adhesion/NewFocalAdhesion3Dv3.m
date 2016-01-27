clear all
ImageDirectory='~/Dropbox/Josh/Cells to analyze/Individual timepoint stacks/Cell 01 110712 GFP-Vinc/';
Output='~/Dropbox/Josh/Cells to analyze/';
ImageRoot='Cell 01_w1Live GFP_t';
StartFrame=1;
FrameCount=7;
TimeFrame=1;
FrameStep=1;
NumberFormat='%02d';
ImageExtension='.TIF';
MaxMissingFrames=3;
OutputDirectory=[Output 'OutputTest/'];
% Adjustable Parameters for processing the images
BrightnessThresholdPct=1.35;
GlobalIntensityThresh=0.015;
MinFAArea=30;
MaxFAArea=500;
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

%% Start of the data Processing from the images
% Looking at using the individual slices for the actual analysis since the
% depth / z-thickness does not change

% Used to determine the z-thickness for the z-location of the focal
% adhesion points
cells_lbl=LabelMatrix;
cells_props=regionprops(cells_lbl,'Area');
   b_min=true;
   b_max=true;
cells_area=[cells_props.Area];
cells_nr=length(cells_area);
valid_areas_idx=true(1,cells_nr);

if (b_min)
   valid_areas_idx=valid_areas_idx&(cells_area>=MinFAArea);
end

if (b_max)
   valid_areas_idx=valid_areas_idx&(cells_area<=MaxFAArea);
end

%if (min(valid_areas_idx)==1)
    %no invalid objects return the same label back
%    LabelMatrix=cells_lbl;
%else   
%     Cell_Area_Slice = bsxfun(@times, valid_areas_idx,cells_area);
%     Area_Slice = Cell_Area_Slice(Cell_Area_Slice~=0);
    valid_object_numbers=find(valid_areas_idx);
    new_object_numbers=1:length(valid_object_numbers);
    %we will replace valid numbers with new and everything else will be set to
    %zero
    object_idx=cells_lbl>0;
    new_object_index=zeros(max(cells_lbl(object_idx)),1);
    new_object_index(valid_object_numbers)=new_object_numbers;
    new_cells_lbl=cells_lbl;
    %replace the old object numbers to prevent skips in numbering
    object_idx=cells_lbl>0;
    new_cells_lbl(object_idx)=new_object_index(cells_lbl(object_idx));
    LabelMatrix=new_cells_lbl;
%end

cells_lbl=LabelMatrix;
objects_props=regionprops(cells_lbl,'Centroid');
objects_centroids=[objects_props.Centroid]';
centr_len=size(objects_centroids,1);
objects_centroids= [objects_centroids(2:3:centr_len) objects_centroids(1:3:centr_len) objects_centroids(3:3:centr_len)];
Centroids3=objects_centroids(:,3);

% % % % % % %  Area Filter Label % % % % % % % 
% Filter runs through each slice of the 3D image since at different layers
% you could have different objects
for z = 1:nr_slices

LabelMatrix2 = LabelMatrix3;    
cells_lbl=LabelMatrix2(:,:,z);
cells_props=regionprops(cells_lbl,'Area');
   b_min=true;
   b_max=true;
cells_area=[cells_props.Area];
cells_nr=length(cells_area);
valid_areas_idx=true(1,cells_nr);

if (b_min)
    valid_areas_idx=valid_areas_idx&(cells_area>=MinFAArea);
end

if (b_max)
    valid_areas_idx=valid_areas_idx&(cells_area<=MaxFAArea);
end

%if (min(valid_areas_idx)==1)
%    %no invalid objects return the same label back
%    LabelMatrix2=cells_lbl;
%else
    % Assigns the Focal Adhesion IDs to the FAs that meet the min and max
    % Area criteria
    clear RRRR
    clear TTTT
    clear YYYY
    clear Area_Slice
    RRRR = find(cells_area >= MinFAArea);
    TTTT = cells_area(1,RRRR);
    YYYY = find(TTTT <= MaxFAArea);
    Area_Slice = TTTT(1,YYYY);
    IDs = 1:length(find(Area_Slice));
% %     Cell_Area_Slice = bsxfun(@times, valid_areas_idx,cells_area);
% %     Area_Slice = Cell_Area_Slice(Cell_Area_Slice~=0);
    % % % % % % % % % % % % % % % % % % % % % % % % 
    valid_object_numbers=find(valid_areas_idx);
    new_object_numbers=1:length(valid_object_numbers);
    % new_object_numbers=1:length(valid_object_numbers);
    %we will replace valid numbers with new and everything else will be set to
    %zero
    object_idx=cells_lbl>0;
    new_object_index=zeros(max(cells_lbl(object_idx)),1);
    new_object_index(valid_object_numbers)=new_object_numbers;
    new_cells_lbl=cells_lbl;
    %replace the old object numbers to prevent skips in numbering
    object_idx=cells_lbl>0;
    new_cells_lbl(object_idx)=new_object_index(cells_lbl(object_idx));
    LabelMatrix2=new_cells_lbl;
%end

% Get the location (x,y) of the centroids in 3D through each slice
    objects_lbl=LabelMatrix2;
    objects_props=regionprops(objects_lbl,'Centroid');
    objects_centroids=[objects_props.Centroid]';
    centr_len=size(objects_centroids,1);
    objects_centroids= [objects_centroids(2:2:centr_len) objects_centroids(1:2:centr_len)];

    Centroids=objects_centroids;
% Get the Intesity of the Focal Adhesion Point Area
    objects_lbl=LabelMatrix2;
    intensity_img=Quotient; % From Flatten Background
    objects_idx=(objects_lbl>0);

IntegratedIntensities=accumarray(objects_lbl(objects_idx),intensity_img(objects_idx));
%% K-Nearest Neighbor Section for Identifing Focal Adhesions
% % % % % Used to generate Nearest Neighbor Information / Tracks for Focal Adhesion % % % % % %
% % % % % K-nearest neighbor is a built in function in MATLAB using
% % % % % knnsearch, default options are using euclidean distance

if x == 1 && z < 3
   
    if z == 1
        CellID_start = flipud(rot90(IDs));
        Area_start = flipud(rot90(Area_Slice));
        Initial_FA_Tracks = [CellID_start repmat(CurrentFrame,[size(CellID_start),1])...
            repmat(z,[size(CellID_start),1]) Centroids(:,1) Centroids(:,2)...
            Area_start IntegratedIntensities];
        [corresponding_tracks, D1] = knnsearch((Initial_FA_Tracks(:,4:5)),(Initial_FA_Tracks(:,4:5)));
        Adjusted_FA_Tracks = [CellID_start corresponding_tracks repmat(CurrentFrame,[size(CellID_start),1])...
            repmat(z,[size(CellID_start),1]) Centroids(:,1) Centroids(:,2)...
            Area_start IntegratedIntensities D1];
        Current_CellID_Adjusted = Adjusted_FA_Tracks(:,2);
    
    else % z == 2
        existing_tracks = vertcat(Initial_FA_Tracks, existing_tracks);
        CellID_current = flipud(rot90(IDs));
        Area_current = flipud(rot90(Area_Slice));
        current_FA_tracks = [CellID_current repmat(CurrentFrame,[size(CellID_current),1])...
            repmat(z,[size(CellID_current),1]) Centroids(:,1) Centroids(:,2)...
            Area_current IntegratedIntensities];
        [corresponding_tracks, DI] = knnsearch((existing_tracks(:,4:5)),(current_FA_tracks(:,4:5)));
   % % % % % % % % % %
        [n, bin] = histc(corresponding_tracks, unique(corresponding_tracks));
        multiple = find(n > 1);
   % % % % % % % % % %
        adjusted_current_FA = [CellID_current corresponding_tracks repmat(CurrentFrame,[size(CellID_current),1])...
            repmat(z,[size(CellID_current),1]) Centroids(:,1) Centroids(:,2)...
            Area_current IntegratedIntensities DI];
        Adjusted_Current_FA2 = vertcat(Adjusted_Current_FA, adjusted_current_FA);
        Current_CellID_Adjusted = adjusted_current_FA(:,2);

    end

else
       Running_Adjusted = [Total_Adjusted_FA(:,2) Total_Adjusted_FA(:,5:6)]; 
       existing_tracks = vertcat(Initial_FA_Tracks, existing_tracks);
       CellID_current = flipud(rot90(IDs));
       Area_current = flipud(rot90(Area_Slice));
       current_FA_tracks = [CellID_current repmat(x,[size(CellID_current),1])...
            repmat(z,[size(CellID_current),1]) Centroids(:,1) Centroids(:,2)...
            Area_current IntegratedIntensities];
       [corresponding_tracks, DI] = knnsearch((Running_Adjusted(:,2:3)),(current_FA_tracks(:,4:5)));

        index = Running_Adjusted(corresponding_tracks,1);
        [n, bin] = histc(index, unique(index));
   % % % % % % % % % %
   % % % % % % % % % %
   % % % % % % % % % %
   % % % % % % % % % %
        if find(n > 1) >= 1
        multiple = find(n > 1);
        indexFATest = find(ismember(bin,multiple));
        valueFA = [indexFATest index(indexFATest,:) DI(indexFATest,:)];
        valueFA2 = max(valueFA(:,3));
        valueFA3 = [indexFATest index(indexFATest,:) (DI(indexFATest,:) - valueFA2)];
        NewRow = ismember(valueFA,max(valueFA(:,3)));
        [row, col] = find(NewRow);
        ideded = valueFA3(row,:);
        newFAId = max(Running_Adjusted(:,1))+1;
        newFAid2 = [ideded(:,1) newFAId ideded(:,3)];
        index(index(newFAid2(:,1),1))= newFAid2(:,2);
        Adjusted_Current_FA = [CellID_current index repmat(CurrentFrame,[size(CellID_current),1])...
            repmat(z,[size(CellID_current),1]) Centroids(:,1) Centroids(:,2)...
            Area_current IntegratedIntensities DI];
       Current_CellID_Adjusted = Adjusted_Current_FA(:,2);
   % % % % % % % % % %
   % % % % % % % % % %
   % % % % % % % % % %      
   % % % % % % % % % %
       % index = Running_Adjusted(corresponding_tracks,1);
        else
       Adjusted_Current_FA = [CellID_current index repmat(CurrentFrame,[size(CellID_current),1])...
            repmat(z,[size(CellID_current),1]) Centroids(:,1) Centroids(:,2)...
            Area_current IntegratedIntensities DI];
       Current_CellID_Adjusted = Adjusted_Current_FA(:,2);
       end
end

    Adjusted_FA2 = vertcat(Adjusted_FA_Tracks, Adjusted_Current_FA2);
    Adjusted_Current_FA_end = vertcat(Adjusted_Current_FA_end, Adjusted_Current_FA);
    Total_Adjusted_FA = vertcat(Adjusted_FA2, Adjusted_Current_FA_end);
    CellID = vertcat(CellID, flipud(rot90(new_object_numbers)));
    SliceID = vertcat(SliceID,repmat(z,[size(flipud(rot90(new_object_numbers))),1]));
    Time = vertcat(Time, repmat((x - 1)*TimeFrame,[size(flipud(rot90(new_object_numbers))),1])); 
    Centroid1= vertcat(Centroid1, Centroids(:,1));
    Centroid2= vertcat(Centroid2, Centroids(:,2));
    Area= vertcat(Area,flipud(rot90(Area_Slice)));
    Intensity = vertcat(Intensity, IntegratedIntensities);

  
FormatSpreadsheet = struct('CellID',1, 'Adjusted_CellID',2, 'Image',3, 'SliceID',4,...
    'Centroid_1',5, 'Centroid_2',6, 'Area', 7, 'Intensity',8, 'Distance',9);

FormatSpreadsheet.CellID=Total_Adjusted_FA(:,1);
FormatSpreadsheet.Adjusted_CellID=Total_Adjusted_FA(:,2);
FormatSpreadsheet.Image=Total_Adjusted_FA(:,3);
FormatSpreadsheet.SliceID=Total_Adjusted_FA(:,4);
FormatSpreadsheet.Centroid_1=Total_Adjusted_FA(:,5);
FormatSpreadsheet.Centroid_2=Total_Adjusted_FA(:,6);
FormatSpreadsheet.Area=Total_Adjusted_FA(:,7);
FormatSpreadsheet.Intensity=Total_Adjusted_FA(:,8);
FormatSpreadsheet.Distance=Total_Adjusted_FA(:,9);


%% PLOTTING / DRAWING THE CENTROIDS ON THE IMAGES
% Plots the adjusted centroid IDs on the cell images as they are being
% processed

cur_img=Image1(:,:,z);
objects_lbl=LabelMatrix2;
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
        [current_x current_y] = find(objects_lbl == cell_id);
%        [current_x current_y] = find(objects_lbl == cell_id);
        total_x = sum(current_x);
        total_y = sum(current_y);
        total_size = size(current_x, 1);
        centroid_x = total_x/total_size;
        centroid_y = total_y/total_size;        
        % add the cell ids
        text_img=text2im(num2str(Current_CellID_Adjusted(j,:)));
        % text_img=text2im(num2str(cell_id));
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
OutputImageFile= [OutputDirectory ImageRoot num2str(CurrentFrame) num2str(z) 'outimage' ImageExtension];
imwrite(cat(3,red_color,green_color,blue_color),OutputImageFile);

end


end

% Ends the loop
x = x +1;
end



% Date Time Group (DTG) to be written into the data output file
format shortg
writetime = fix(clock);
writetime = num2str(writetime);
writetime = strrep(writetime,' ','');
%
FormatSpreadsheet = struct2dataset(FormatSpreadsheet); % struct2dataset is a new function that does not exist in earlier versions than 2012b
DataFileName='FocalAdhesionProperties';
DataFileName = [DataFileName writetime];
Type2='.csv';
export(FormatSpreadsheet, 'File', [OutputDirectory DataFileName Type2],'Delimiter',',');

clear all
