function InitNewImage(handles)
  
    directory = '~/Documents/Test Images/Frick Images';
    
    
	imagefile						= uigetfile('*.*','Select an image: ', directory);
    image  = imread([directory filesep imagefile]);	


    % [imagefile, ...
	% path]						= uigetfile('*.*', ...
	% 										'Select an image: ', ...
	%										handles.directory);
	% handles.imagefile			= [path imagefile];
	% [handles.image,     ...
	% handles.wellName,  ...
	% handles.imageName] 			= LoadImage(handles.imagefile);
  

    % Additional 02OCT12
    %
    % directory = handles.directory;
    % imageName = handles.imageName;
	% set(handles.CurImage, 'String', handles.imageName);
    
    imageNameBase = 'DsRed - Confocal - n';
    digitsForEnum = 6;
    fileExt = '.tif';
    
    imNumStr = sprintf('%%0%dd', digitsForEnum);
    name = [imageNameBase digitsForEnum fileExt];
    CurrID = [imagefile];
    [token,remain] = strtok([imagefile], [name]);
    
    imNumStr = sprintf(token);
    image = str2num(token);
  
    prevImgN = sprintf('%06d',(image -1))
    nextImgN = sprintf('%06d',(image +1))
    prevImg = [imageNameBase prevImgN fileExt]
    nextImg = [imageNameBase nextImgN fileExt]
    
    prevImgFile = [directory filesep prevImg];
    nextImgFile = [directory filesep nextImg];
    
    handles.prevImgI        = imread(prevImgFile);
    handles.nextImgI        = imread(nextImgFile);
    % End Additional 02OCT12
    %
    %
    % Test Location
    figure();
    imagesc(flipud(handles.prevImgI));
    title('Previous Image in Series');
    colormap(gray);
    
    figure();
    imagesc(flipud(handles.nextImgI));
    title('Next Image in Series');
    colormap(gray);
    %
    %
 

end %InitNewImage
