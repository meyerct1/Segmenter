directory		= '~/Work/Images';
wellName		= 'Well F05';
imageNameBase 	= 'DsRed - Confocal - n';
fileExt			= '.tif';
digitsForEnum	= 6;
startIndex		= 0;
endIndex		= 25;
frameStep		= 4;


for(imNum=startIndex:endIndex)
	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * frameStep);

	load([	directory filesep ...
			wellName filesep ...
			'output' filesep ...
			imageNameBase imNumStr '.mat']);

	im = imread([	directory filesep ...
					wellName filesep ...
					imageNameBase imNumStr fileExt]);

	underSegObjs = find([objSet.props(:).under]);
	[objSet.props, objSet.labels] = ...
		Resegment(im, objSet.props, objSet.labels, underSegObjs);

	SetToCSV(objSet, [	directory filesep ...
						wellName filesep ...
						'output' filesep ...
						imageNameBase imNumStr '.csv']);

	save([	directory filesep ...
			wellName filesep ...
			'output' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');

	clear objSet;
	clear imNumStr;
	clear im;
	clear underSegObj;
end
