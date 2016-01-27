%%

%% USERS INFORMATION
StartFrame = 1;
EndFrame = 10; 
FrameStep = 2;
ImageFolder = '~/Dropbox/PC9/Well B02/';
SegmentOutName = 'DsRed - Confocal - n';
Type = '.tif';
NumberFormat = '%06d';


%% DEFAULTS

radius              = 50;  
% Filter out background bigger than 50 pixel areas

backgroundThreshold = 0.2; 
% 20% below normalized is off, 80% is real.

fillholes           = 1;   
% Please fill holes

noiseThreshold      = 3;   

%% IMAGE LIST GENERATOR
ImageNameList = [];
for a = StartFrame:EndFrame
Image = [SegmentOutName num2str(a, NumberFormat) Type];
ImageNameList = vertcat(ImageNameList, Image);
Image = [];
end
ImageNameList = ImageNameList(StartFrame:FrameStep:EndFrame);


%% IMAGE PROCESSING
% Image Name
for x = 1:length(ImageNameList)
Image = ImageNameList(x);
image = [ImageFolder Image];
   
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
  
	p = ClassifyFirstPass(p);
    
    
end    
    