directory		= '~/Documents/Test Images';
wellName		= 'Well C04';
imageNameBase 	= 'DsRed - Confocal - n';
fileExt			= '.tif';
digitsForEnum	= 6;
startIndex		= 1;
endIndex		= 10;
framestep		= 1;
outdir			= 'Well C04';

mkdir([directory filesep wellName filesep 'naive']);

%export each object set as a csv file for interfacing with R
for(imNum=startIndex:endIndex)

	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * framestep)

	%Load Image
	[im, objSet.wellName, objSet.imageName] = ...
		LoadImage([	directory filesep ...
					wellName filesep ...
					imageNameBase imNumStr fileExt]);

	%segment
	[objSet.props, objSet.labels] = ...
		NaiveSegment(im, 'BackgroundThreshold', .1);

	%export to CSV file for classification
	SetToCSV(objSet, [	directory filesep ...
						wellName filesep ...
						'naive' filesep ...
						imageNameBase imNumStr '.csv']);

	%save output
	save([	directory filesep ...
			wellName filesep ...
			'naive' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');

	clear objSet;
	clear imNumStr;
	clear im;
	
end
