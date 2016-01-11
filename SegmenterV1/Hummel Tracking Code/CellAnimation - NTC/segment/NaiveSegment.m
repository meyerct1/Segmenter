function [p,l] = NaiveSegment(image, varargin)

	%Defaults
    noise_disk = varargin{1};
    NucSegHeight = varargin{1};
	%%Now segment the nucleus
    % To Binarize Image with otsu's threshold
    num = multithresh(image,2);
    SegIm_array	= imquantize(image, num);
    SegIm_array(SegIm_array == 1) = 0; %Background
    SegIm_array(SegIm_array == 2) = 1; %slightly out of focus Nuclei
    SegIm_array(SegIm_array == 3) = 1; %Bright nuclei

    % Remove Noise using the noise_disk
    noise = imtophat(SegIm_array, strel('disk', noise_disk));
    SegIm_array = SegIm_array - noise;

    % Fill Holes
    SegIm_array = imfill(SegIm_array, 'holes');

    %To separate touching nuclei, compute the distance of the binary 
    %transformed image using the bright areas of the image as the basins 
    %by inverse of the distance measure
    D = -bwdist(~SegIm_array);
    D = -imhmax(-D,NucSegHeight);  %Suppress values below 3. To prevent oversegmentation...  Make variable in image segmentation in future?
    Nuc_label = watershed(D);
    Nuc_label(SegIm_array == 0) = 0; %Write all the background to zero.
    %imshow(label2rgb(Nuc_label),[])
    l = Nuc_label;
    i = Nuc_label;
    i(Nuc_label>0) = 1;
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

		p(obj).Intensity =  sum(image(p(obj).PixelIdxList));
    
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
  
	clear i;
	clear j;
	clear bounds;
	clear noise;
 
end % NaiveSegment
