directory		= '~/Work/Images/2009-05-01_001';
wellName		= 'WellB02';
imageNameBase	= 'DsRed - Confocal - n';
fileExt			= '.tif';
digitsForEnum	= 6;
startIndex		= 1;
endIndex		= 100;
frameStep		= 1;
outdir			= 'WellB02/naive';
training		= ['~/Work/CellAnimation/segmentation/segment/'...
					'2009-05-01.mat'];

mkdir([directory filesep wellName filesep 'gmm']);

%load training set
load(training);
trainingSet = objSet;
clear objSet;

for(imNum = startIndex:endIndex)

	imNumStr = sprintf('%%0%dd', digitsForEnum);
	imNumStr = sprintf(imNumStr, imNum * frameStep);

	disp(['Image Number: ' imNumStr]);

	im = imread([	directory filesep ...
					wellName filesep ...
					imageNameBase imNumStr fileExt]);

	load([	directory filesep ...
			outdir filesep ...
			imageNameBase imNumStr '.mat']);

	objSet = RemoveObjects(objSet, 'nucleus');
	objSet = RemoveObjects(objSet, 'debris');

	objSet = GMMSegment(im, objSet, trainingSet);

	SetToCSV(objSet, [	directory filesep ...
						wellName filesep ...
						'gmm' filesep ...
						imageNameBase imNumStr '.csv']);

	save([	directory filesep ...
			wellName filesep ...
			'gmm' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');

	imwrite(objSet.labels, [	directory filesep ...
								wellName filesep ...
								'gmm' filesep ...
								imageNameBase imNumStr '.jpg'], ...
			'jpg');


	%combine gmm and naive results
	gmmOS = objSet;
	clear objSet;

	load([	directory filesep ...
			outdir filesep ...
			imageNameBase imNumStr '.mat']);
	naiveOS = objSet;
	naiveOS = RemoveObjects(naiveOS, 'under');
	naiveOS = RemoveObjects(naiveOS, 'debris');
	clear objSet;

	objSet = CombineImages(gmmOS, naiveOS);
	mkdir([directory filesep wellName filesep 'output']);
	save([	directory filesep ...
			wellName filesep ...
			'output' filesep ...
			imageNameBase imNumStr '.mat'], 'objSet');	

	%clean-up
	clear gmmOS;
	clear naiveOS;
	clear objSet;
	clear im;
	clear imNumStr;

end
