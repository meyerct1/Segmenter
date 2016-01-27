directory = '~/Work/Images';
wellName = 'WellF05';
imageNameBase = 'DsRed - Confocal - n';
digitsForEnum = 6;
frameStep = 4;
startIndex = 0;
endIndex = 15;

for(imNum = startIndex:4:endindex)

	imNumStr = sprintf('%%0%dd', digisForEnum);
	imNumStr = sprintf(imNumStr, imNum * frameStep);

	load([	directory filesep ...
			wellName filesep ...
			imageNameBase imNumstr fileExt]);

	objSet = RemoveObjects(objSet, 'nucleus');
	objSet = RemoveObjects(objSet, 'debris');

	save([	

end

