% THIS CODE IS DESIGNED TO PROCESS AN IMAGE STACK AND CALCULATE THE OBJECT
% MORPHOLOGY TO DETERMINE CHANGES IN MORPHOLOGY AS A RESULT OF A DRUG
% TREATMENT. 
% THE OUTPUT DATA WILL BE USED TO GENERATE A DATABASE OF SIGNATURES OF THE
% EFFECTS OF THE DRUGS USING A PRINCIPLE COMPONENT ANALYSIS

%% USER INFORMATION
StartFrame = 1;
EndFrame = 10; % 10;
ImageFolder = '~/Dropbox/PC9/Well C04/';
SegmentOutName = 'DsRed - Confocal - n';
Type = '.tif';
NumberFormat = '%06d';

ClearBorder=true;
ClearBorderDist=0;
Strel='disk';
StrelSize= 15;
BrightnessThresholdPct=1.05; % 1.15
ClearBorder_intensity=false;
IntensityThresholdPct=0.10;
MinObjectArea=60; % 60
GaussStdDev=2.5;
GaussKernSize=5;
FormatSpreadsheet = [];


%% IMAGE PROCESSING & SEGMENTATION
for a = StartFrame:EndFrame
Image = [ImageFolder SegmentOutName num2str(a, NumberFormat) Type];

% Read the image into the script
image_name=Image;
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

% Normalize the image
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

% % % % Guassian Filter
% % % kernel_size=GaussKernSize;
% % % standard_dev=GaussStdDev;
% % % Image=imfilter(Image, fspecial('gaussian',kernel_size,standard_dev), 'symmetric', 'conv');
% % % % Normalizing the Guassian Filtered Image
% % % int_class='uint16';
% % % max_val=double(intmax(int_class));
% % % img_raw=Image;
% % % img_dbl=floor(double((img_raw-min(img_raw(:))))*max_val./double(max(img_raw(:))-min(img_raw(:))));
% % % switch(int_class)
% % %     case 'uint8'
% % %        Image=uint8(img_dbl);
% % %     case 'uint16'
% % %        Image=uint16(img_dbl);
% % %     otherwise
% % %         Image=[];
% % % end
% % % Image1 = Image;


% Clear Border Intensity
max_pixel=max(Image(:));
min_pixel=min(Image(:));
brightnessPct=IntensityThresholdPct;
threshold_intensity=brightnessPct*double(max_pixel-min_pixel)+min_pixel;
img_bw=Image>threshold_intensity;
% img_bw=im2bw(img_to_proc,brightnessPct*graythresh(img_to_proc));
clear_border_dist=ClearBorderDist;
if (ClearBorder_intensity)
    if (clear_border_dist>1)
        img_bw(1:clear_border_dist-1,1:end)=1;
        img_bw(end-clear_border_dist+1:end,1:end)=1;
        img_bw(1:end,1:clear_border_dist-1)=1;
        img_bw(1:end,end-clear_border_dist+1:end)=1;
    end
    Image=imclearborder(img_bw);
else
    Image=img_bw;
end

% Clear small objects based on preset indicated above

Image=bwareaopen(Image,MinObjectArea);

% Generate LabelMatrix
LabelMatrix=bwlabeln(Image);



end


%% CELL MORPHOLOGY - RAW



%% CELL MORPHOLOGY - DIFFERNCE


%% DATA EXPORT