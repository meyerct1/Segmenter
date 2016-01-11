%%
clear all
%% USERS INFORMATION
StartFrame = 1;
EndFrame = 133; 
FrameStep = 6;
ImageFolder = '~/Dropbox/PC9/Es/Well E11/';
SegmentOutName = 'DsRed - Confocal - n';
Type = '.tif';
                             well = 'E11';

OutPutBase = 'MorphologyData_';
OutPutFileName = [OutPutBase well]; %'MorphologyData_E11';
OutputFolder = '~/Dropbox/PC9/';
NumberFormat = '%06d';

% drug = 'erlotinib'; % 2 & 3 (C 4000, D 1000, E 250, F 62.5, G 15.625, H 3.9)
% drug = 'lapatinib'; % 4 & 5 (C 4000, D 1000, E 250, F 62.5, G 15.625, H 3.9)
% drug = 'PLX-4720'; % 6 & 7 (C 16000, D 4000, E 1000, F 250, G 62.5, H 15.625)
% drug = 'doxorubicin'; % 8 & 9 (C 4000, D 1000, E 250, F 62.5, G 15.625, H 3.9)
drug = 'cycloheximide'; % 10 & 11 (C 2, D 1, E 0.5, F 0.25, G 0.125, H 0.0625)
conc = '0.5';


%% DEFAULTS

radius              = 50;  
% Filter out background bigger than 50 pixel areas

backgroundThreshold = 0.2; 
% 20% below normalized is off, 80% is real.

fillholes           = 1;   
% Please fill holes

noiseThreshold      = 3;   

%% IMAGE LIST GENERATOR
Frames = StartFrame:EndFrame;
Frames = Frames(StartFrame:FrameStep:EndFrame);


ImageNameList = [];
% for a = StartFrame:EndFrame
for b = 1:length(Frames)
a = Frames(b);
Image = [SegmentOutName num2str(a, NumberFormat) Type];
ImageNameList = vertcat(ImageNameList, Image);
Image = [];
end
% ImageNameList2 = ImageNameList(StartFrame:FrameStep:EndFrame);
[m n] = size(ImageNameList);

%% IMAGE PROCESSING
% Image Name
All_data = [];
for x = 1:m
Image = ImageNameList(x,:);
image = [ImageFolder Image];
image = imread(image);   
%
FrameNumber = Frames(x);
%
% Subtract background, in pixel radius (default 50) tophat filter
i	= imtophat(im2double(image), strel('disk', radius));
j	= i; 

% maps the intensity values such that 1% of data is saturated 
% at low and high intensities 
i	= imadjust(i);

% To Binary Image (default 30% theshold)
i	= im2bw(i, backgroundThreshold);

% Remove Noise
if noiseThreshold > 0.0
noise = imtophat(i, strel('disk', noiseThreshold));
i = i - noise;
end

% Fill Holes
if fillholes
i	= imfill(i, 'holes');
end

l	= bwlabel(i);

%% MORPHOLOGY INFORMATION
% Segment properties (with holes filled)
	p	= regionprops(l,...
					'Area',				'Centroid',			...
					'MajorAxisLength',	'MinorAxisLength',	...
					'Eccentricity', 	'ConvexArea',		...
					'FilledArea',		'EulerNumber',  	...
					'EquivDiameter',	'Solidity',			...
					'Perimeter',		'PixelIdxList',		...
					'PixelList',		'BoundingBox',		...
					'Orientation');
   
	% Compute intensities from background adjusted image
	bounds = bwboundaries(i);
	for obj=1:size(p,1)
		
		p(obj).label = obj;    

		p(obj).Intensity =  sum(j(p(obj).PixelIdxList));
    
		p(obj).bound = bounds{obj};
    
		p(obj).edge    = 0;
		if find(p(obj).PixelList(:,1) == 1)
			p(obj).edge = 1;
		end

		if find(p(obj).PixelList(:,2) == 1)
			p(obj).edge = 1;
		end

		if find(p(obj).PixelList(:,1) == size(i,2) )
			p(obj).edge = 1;
		end

		if find(p(obj).PixelList(:,2) == size(i,1) )
			p(obj).edge = 1;
		end

	end
  
	% p = ClassifyFirstPass(p);
p = rmfield(p, 'PixelIdxList');
p = rmfield(p, 'PixelList');
p = rmfield(p, 'bound');
data = struct2dataset(p);
ImageNumber = struct('ImageNumber',repmat(FrameNumber, [size(p),1]));
Well_ID = struct('Well_ID',repmat(well, [size(p),1]));
Drug_ID = struct('Drug_ID',repmat(drug, [size(p),1]));
Conc = struct('Concentration',repmat(conc, [size(p),1]));

ImageNumber = struct2dataset(ImageNumber);
Well_ID = struct2dataset(Well_ID);
Drug_ID = struct2dataset(Drug_ID);
Conc = struct2dataset(Conc);

data_out = horzcat(Well_ID, Drug_ID, Conc, ImageNumber, data);
All_data = vertcat(All_data, data_out);
data_out = [];
p = [];
ImageNumber = [];
Well_ID = [];
Drug_ID = [];
Conc = [];
end    
Type2='.csv';
export(All_data, 'File', [OutputFolder OutPutFileName Type2],'Delimiter',',');
