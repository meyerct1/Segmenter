% The following automation code was developed by Stephen Hummel in the Vito
% Quaranta lab on 05MAY14
%
% This code is designed to study the nuclear local in yeast. The user sets
% the background intensity threshold in order to determine the intensity of
% the cell and then of the nuclear localization.
%% USER INPUTS
FileDirectory = '~/Documents/';
ImageName = 'yeast-20nls-gfp';
ImageType = '.jpg';

Date = '05MAY14';
OutputFileName = 'NLS_Data_';
type = '.csv';

% Key to adjusting the image
backgroundThreshold_1 = 0.12; % Threshold to ID the cell
backgroundThreshold_2 = 0.45; % Threshold to ID the NLS
Min_Obj_Area = 5; % Not used at this time

% Defaults
	radius              = 50;  
	% Filter out background bigger than 50 pixel areas

	fillholes           = 1;   
	% Please fill holes
	
	noiseThreshold      = 3;   
	% 3 pixel circles 


%% Image Analysis Section
FileName = [FileDirectory ImageName ImageType];
image = imread(FileName);

% Subtract background, in pixel radius (default 50) tophat filter
    i	= imtophat(im2double(image), strel('disk', radius));
	j	= i;

% maps the intensity values such that 1% of data is saturated 
% at low and high intensities 
    i = imadjust(i,[],[]);

% To Binary Image    
    i1	= im2bw(i, backgroundThreshold_1);
    i2	= im2bw(i, backgroundThreshold_2);

% Remove Noise
	if noiseThreshold > 0.0
		noise = imtophat(i1, strel('disk', noiseThreshold));
		i1 = i1 - noise;
        noise = imtophat(i2, strel('disk', noiseThreshold));
        i2 = i2 - noise;
    end
  
% Fill Holes    
		i1	= imfill(i1, 'holes');
        i2	= imfill(i2, 'holes');
        
l1	= bwlabel(i1);
l2	= bwlabel(i2);

% Segment properties (with holes filled)
p1	= regionprops(l1,...
					'Area',				'Centroid',			...
					'MajorAxisLength',	'MinorAxisLength',	...
					'Eccentricity', 	'ConvexArea',		...
					'FilledArea',		'EulerNumber',  	...
					'EquivDiameter',	'Solidity',			...
					'Perimeter',		'PixelIdxList',		...
					'PixelList',		'BoundingBox',		...
					'Orientation');

p2	= regionprops(l2,...
					'Area',				'Centroid',			...
					'MajorAxisLength',	'MinorAxisLength',	...
					'Eccentricity', 	'ConvexArea',		...
					'FilledArea',		'EulerNumber',  	...
					'EquivDiameter',	'Solidity',			...
					'Perimeter',		'PixelIdxList',		...
					'PixelList',		'BoundingBox',		...
					'Orientation');

bounds = bwboundaries(i1);
	for obj=1:size(p1,1)		
		p1(obj).label = obj;    
		p1(obj).Intensity =  sum(j(p1(obj).PixelIdxList)); % Sums the pixel 
                % intensities of the object over the original image (j)     
        p1(obj).bound = bounds{obj};
    end
    
bounds = bwboundaries(i2);
	for obj=1:size(p2,1)
		p2(obj).label = obj;    
		p2(obj).Intensity =  sum(j(p2(obj).PixelIdxList)); % Sums the pixel 
                % intensities of the object over the original image (j)
        p2(obj).bound = bounds{obj};
    end 
    
 %% PLOT IMAGE DATA
colors=pmkmp(20, 'IsoL');
newplot
figure1 = imagesc(image);
axis image
colormap gray; 
hold on;

for obj=1:size(p1,1)
color = colors(mod(obj, size(colors,1))+1, :);
    outlines.(['o' int2str(obj)]) = ...
		plot(	p1(obj).bound(:,2),...
				p1(obj).bound(:,1),...,
				'Color', color, ...,
				'LineWidth',1.25);	
        text(p1(obj).Centroid(:,1)+2, p1(obj).Centroid(:,2)+4, num2str(obj), 'Color', 'w');
        
for obj = 1:size(p2,1)
    if isempty(obj)
    else
    outlines.(['o' int2str(obj)]) = ...
		plot(	p2(obj).bound(:,2),...
				p2(obj).bound(:,1),...,
				'Color', color, ...,
				'LineWidth',1.25);
     text(p2(obj).Centroid(:,1)-10, p2(obj).Centroid(:,2)-10, num2str(obj), 'Color', 'c', 'FontSize', 12, 'FontWeight', 'bold');
    end
end          
end 

%% Save and Export Data
obj1 = flipud(rot90(1:length(p1)));
obj2 = flipud(rot90(1:length(p2)));
Set1 = ones(length(p1),1);
Set2 = 2* (ones(length(p1),1));
Data1 = [];
for RT = 1:length(p1)
Data_1 = struct('Set', 1,'ID', obj1(RT), 'CentroidX', p1(RT).Centroid(:,1), 'CentroidY', p1(RT).Centroid(:,2),...
    'Area', p1(RT).Area, 'Intensity', p1(RT).Intensity,'MAL', p1(RT).MajorAxisLength, 'MIL', p1(RT).MinorAxisLength,...
    'Perimeter', p1(RT).Perimeter);
Data_1 = struct2dataset(Data_1);
Data1 = vertcat(Data1, Data_1);
end

Data2 = [];
for RT = 1:length(p2)
Data_2 = struct('Set', 2,'ID', obj2(RT), 'CentroidX', p2(RT).Centroid(:,1), 'CentroidY', p2(RT).Centroid(:,2),...
    'Area', p2(RT).Area, 'Intensity', p2(RT).Intensity,'MAL', p2(RT).MajorAxisLength, 'MIL', p2(RT).MinorAxisLength,...
    'Perimeter', p2(RT).Perimeter);
Data_2 = struct2dataset(Data_2);
Data2 = vertcat(Data2, Data_2);
end

Data = vertcat(Data1,Data2);

export(Data, 'File', [FileDirectory OutputFileName Date type],'Delimiter',',');
