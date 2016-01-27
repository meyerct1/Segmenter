directory		= '~/Dropbox/New Code Output/Images to Compare';
wellName		= 'Well C04';
imageNameBase 	= 'DsRed - Confocal - n';
fileExt			= '.tif';
digitsForEnum	= 6;
startIndex		= 1;
endIndex		= 100;
framestep		= 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
radius              = 50;  
% Filter out background bigger than 50 pixel areas
	
backgroundThreshold = 0.2; 
% 20% below normalized is off, 80% is real.
	
fillholes           = 1;   
% Please fill holes
	
noiseThreshold      = 3;   
% 3 pixel circles 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
CellCounts = [];
for(imNum=startIndex:endIndex)

	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * framestep);

    image = imread([directory filesep wellName filesep imageNameBase imNumStr fileExt]);

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

    p	= regionprops(l,...
					'Area',				'Centroid',			...
					'MajorAxisLength',	'MinorAxisLength',	...
					'Eccentricity', 	'ConvexArea',		...
					'FilledArea',		'EulerNumber',  	...
					'EquivDiameter',	'Solidity',			...
					'Perimeter',		'PixelIdxList',		...
					'PixelList',		'BoundingBox',		...
					'Orientation');

    [objNum Y] = size(p);
   
    ObjectCount = struct('ImageNumber', imNum, 'CellCount', objNum);
    ObjectCount = struct2dataset(ObjectCount);

    CellCounts = vertcat(CellCounts, ObjectCount);

end

FormatSpreadsheet7 = CellCounts;
DataFileName7 = 'CellCounts_';
Type2 = '.csv';
export(FormatSpreadsheet7, 'File', [directory filesep DataFileName7 wellName Type2],'Delimiter',',');