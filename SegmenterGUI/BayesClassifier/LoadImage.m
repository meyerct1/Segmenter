function [image, wellName, imageName] = LoadImage(imageFileName)
%function to load an image and determine its well and image name
%based on the filename used to locate it
%
%INPUTS
%imageFileName		-	string, the file location of the image to load
%
%OUTPUTS
%image				-	the image matrix
%
%wellName			-	the name of the well from which the image came
%
%imageName			-	the name of the image
%

	tempFileName = imageFileName;
	image = imread(imageFileName);
	
	%remove trailing filesep character
	if(tempFileName(size(tempFileName,2)) == filesep)
		tempFileName = tempFileName(1:size(tempFileName,2)-1);
	end

	%isolate image name
	filesepIdx = find(tempFileName == filesep);
	imageName = tempFileName(filesepIdx(size(filesepIdx,2))  + 1: ...
							 size(tempFileName,2));

	%isolate well name
	wellName = tempFileName(filesepIdx(size(filesepIdx,2)-1) + 1: ...
							filesepIdx(size(filesepIdx,2))   - 1);

end
