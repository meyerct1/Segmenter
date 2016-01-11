ImageFolder = '/Users/sg_hummel/Dropbox/Peter image stacks/';
SegmentOutName = 'WellR02-C02H2Bstack';
Type = '.tif';
ImageExtension = '.TIF';
NumberFormat = '%06d';
Xmax = 5120;
Ymax = 5120;
% CircleArea = 9000000;
minCloneArea = 500;
minCellArea = 50;

% Defaults
radius              = 50;  
% Filter out background bigger than 50 pixel areas
firstThreshold = 0.1;
backgroundThreshold = 0.45; 
backgroundThreshold_2 = 0.8; 
% 20% below normalized is off, 80% is real.

fillholes           = 1;   
% Please fill holes

noiseThreshold      = 3;   
% 3 pixel circles 

Image = [ImageFolder SegmentOutName Type];
img_info = imfinfo(Image);
nr_images = numel(img_info);
Total_Clones = [];
for t = 1:nr_images
image = imread(Image, t);

% Subtract background, in pixel radius (default 50) tophat filter
i	= imtophat(im2double(image), strel('disk', radius)); 

% maps the intensity values such that 1% of data is saturated 
% at low and high intensities 
i	= imadjust(i);

% To Binary Image (default 30% theshold)
% i	= im2bw(i, firstThreshold);
i	= im2bw(i, backgroundThreshold);

% Remove noise
noise = imtophat(i, strel('disk', noiseThreshold));
i = i - noise;

% Fill holes
i	= imfill(i, 'holes');
% % % % % % % % % % % % % 
i = bwareaopen(i, minCloneArea);
l	= bwlabel(i,8);
bounds = bwboundaries(l);
p	= regionprops(l,'Area','Centroid');
clones_index = true(1,size(p,1));
clones_index = rot90(clones_index);
clone_area = [];

imshow(i)
hold on
xlim([0 Xmax]);
ylim([0 Ymax]);
contour(l, 'Color', 'R')
set(gca,'YDir','Reverse');
    for obj = 1:size(p,1)

        p(obj).label = obj; 
        p(obj).bound = bounds{obj};
        
        label = cellstr(num2str(p(obj).label));
        hold on
        text(p(obj).Centroid(:,1),p(obj).Centroid(:,2),label, 'FontSize', 10, 'Color','G')
    end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % 
% WRITE OUT THE CLONES ON AN IMAGE
% % % % % 
Out_Image = getframe(gca);
Out_Image = frame2im(Out_Image);
OutputImageFile= [ImageFolder SegmentOutName '_outimage' ImageExtension];
imwrite(Out_Image,OutputImageFile,'WriteMode', 'append');
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
i	= imtophat(im2double(image), strel('disk', radius)); 
i	= imadjust(i);
i	= im2bw(i, backgroundThreshold_2);
noise = imtophat(i, strel('disk', noiseThreshold));
i = i - noise;
i	= imfill(i, 'holes');
i = bwareaopen(i, minCellArea);
Clone_Info = [];
    for clone = 1:size(p,1)
        boundaries = p(clone).bound;
        clone_im = i(boundaries,:);
        labels = bwlabel(clone_im);
        clone_prop = regionprops(labels, 'Area', 'Centroid');
        cell_index = true(1, size(clone_prop,1));
        cell_index = rot90(cell_index);
        cell_area = [];
        for RT = 1:size(clone_prop,1)
            area = clone_prop(RT).Area;
            cell_area = vertcat(cell_area, area);
        end
%         cell_index = cell_index & (cell_area >= minCellArea);
%         valid_cells = clone_prop(cell_index,:);
        cell_count = size(clone_prop,1);
        Output = struct('ImageNumber', t, 'CloneID', clone, 'CellCounts', cell_count);
        Output = struct2dataset(Output);
        Clone_Info = vertcat(Clone_Info, Output);
    end
    
Total_Clones = vertcat(Total_Clones, Clone_Info);
end
FormatSpreadsheet = Total_Clones;
DataFileName = 'Cell_CountsByClone_';
Type2 = '.csv';
export(FormatSpreadsheet, 'File', [ImageFolder DataFileName SegmentOutName Type2],'Delimiter',',');
