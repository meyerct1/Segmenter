% FOR CELL COUNTING FROM THE CELLAVISTA
% 
CVOutputFile = '13.txt';
ImageFolder= '~/Dropbox/Stain Images for Analysis/20130819 A375 + PLX4720 + TREM plate 6/13/';
OutputFolder='~/Dropbox/Stain Images for Analysis/20130819 A375 + PLX4720 + TREM plate 6/output2/';
CSVRepository = '~/Dropbox/Stain Images for Analysis/20130819 A375 + PLX4720 + TREM plate 6/data2/';

start = 1;
channels = 2; % Set for 2 Channels for Kate's data

% Information required to process the images
IntegerClass='uint8';

ClearBorder=true;
ClearBorderDist=0;
Strel='disk';
StrelSize= 15;
BrightnessThresholdPct=1.05; % 1.15
ClearBorder_intensity=false;
IntensityThresholdPct=0.10;
MinObjectArea=60; % 60
FormatSpreadsheet = [];

% Required Patterned to pull out image names froms the XML file
% DO NOT ALTER
CVOutputFile = fileread([ImageFolder CVOutputFile]);
Pattern = '[0-9_]+-?[0-9_]+-[A-Z_]+[0-9_]+-[A-Z_]+[0-9_]+.jpg';
D = regexp(CVOutputFile, Pattern, 'match');
V = rot90(D);
J = flipud(V);
x = 1;

Pattern2 = '(\w+)?/[0-9_]+?/[0-9_]+? [0-9_]+?:[0-9_]+?:[0-9_]+';
Pattern3 = '<TimeStamp>';
Exp_Time = regexp(CVOutputFile, Pattern2, 'match');
Exp_Time = char(Exp_Time);
% ImageNameProcessList2 = J(2:channels:end);
ImageNameProcessList2 = J(start:channels:end);

RowName = [];

for i = 1:length(ImageNameProcessList2)
   ImageName = [ImageFolder char(ImageNameProcessList2(x))];

     Row = regexp(ImageNameProcessList2(x), '(?<=-R)\d+','match');
     count = length(ImageNameProcessList2(x));
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
     Well = regexp(ImageNameProcessList2(x), '(?<=-C)[0-9_]+','match');
     for k = 1:count
     Well = char(Well{k});
     end
%      Well = char(Well);
     WellName = horzcat([RowName Well]);
  
%% Read the image into the script
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

%% Normalize the image
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
if (ClearBorder)
    clear_border_dist=ClearBorderDist;
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

%% Clear Border Intensity

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

%% Clear small objects based on preset indicated above

Image=bwareaopen(Image,MinObjectArea);

%%
LabelMatrix=bwlabeln(Image);

% nucl_lbl=LabelMatrix;
% nucl_ids_left = unique(nucl_lbl);
% nucl_idx=ismember(nucl_lbl)

%% Saving Data to Spreadsheet
Cell_ID = length(unique(LabelMatrix));

WellName2 = repmat(WellName,[size(Cell_ID),1]);
ImageNumber = repmat(i,[size(Cell_ID),1]);
Experiment_Time = repmat(Exp_Time,[size(Cell_ID),1]);

FormatSpreadsheet_new = struct('WellName',1, 'Image',2, 'Cell_Count',3, 'Experiment_Time',4);

FormatSpreadsheet_new.WellName=WellName2;
FormatSpreadsheet_new.Image=ImageNumber;
FormatSpreadsheet_new.Cell_Count=Cell_ID;
FormatSpreadsheet_new.Experiment_Time=Experiment_Time;

FormatSpreadsheet = vertcat(FormatSpreadsheet, FormatSpreadsheet_new);     
     
x = x + 1;     
end
% Date Time Group (DTG) to be written into the data output file
format shortg
writetime = fix(clock);
writetime = num2str(writetime);
writetime = strrep(writetime,' ','');
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 

FormatSpreadsheet = struct2dataset(FormatSpreadsheet);
DataFileName='CellCount';
DataFileName= [DataFileName writetime];
Type2='.csv';
export(FormatSpreadsheet, 'File', [OutputFolder DataFileName Type2],'Delimiter',',');
export(FormatSpreadsheet, 'File', [CSVRepository DataFileName Type2],'Delimiter',',');

clear all
