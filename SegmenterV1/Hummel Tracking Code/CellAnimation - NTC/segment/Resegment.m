function [s,l] = Resegment(im, properties, labels, objids)  
%
%segments undersegmented objects into smaller objects
%
%INPUTS:
%im          -  the original image                  
%
%properties  -  the properties of the objects in the image
%
%labels      -  the matrix of labeled objects
%
%objids      -  a list of object ids (indexes in the properties 
%				struct) 
%				to be resegmented
%OUTPUTS:
%s           -  properties of all objects in the image after 
%				resegmentation, maintains prior classification of 
%				pre-existing objects
%
%l           -  label matrix of the image after resegmentation
%

	l = labels;
	s = properties;
	size(s)

	blankSlate = zeros(size(im));
	mask = blankSlate;

	for(n=1:size(objids,2))

		%box region containing the object(s) to  be resegmented
		box = s(objids(n)).BoundingBox;
		%allocate space for smaller image of objects in question
		%subImage = zeros(box(4), box(3));
        
		%copy relevant section of the image to smaller image
		bounds = s(objids(n)).bound;
		for(i=1:size(bounds,1))
			blankSlate(bounds(i,1), bounds(i,2)) = ...
				l(bounds(i,1), bounds(i,2));
			mask(bounds(i,1), bounds(i,2)) = ...
				l(bounds(i,1), bounds(i,2));
		end
	end
	
	blankSlate = imfill(blankSlate, 'holes');
	mask = imfill(mask, 'holes');

	%remove object from labels (to be replaced with new segmentation
	l = xor(l, mask);
    
	%perform distance transform
	distTransform = -bwdist(~blankSlate, 'cityblock');
	%calculate a watershed
	waterShed = watershed(distTransform);
	%use watershed to seperate objects
	bw = blankSlate & waterShed;

	%remove noise
	noise = imtophat(bw, strel('disk', 3));
	bw = bw - noise;

	%insert subImage into l
	l = l | bw;

	mask = zeros(size(mask));
	blankSlate = mask;
	
	clear s;
	l = bwlabel(l);
	s = regionprops(logical(l), ...
					'Area',				'Centroid',		'MajorAxisLength',...
					'MinorAxisLength',	'Eccentricity',	'ConvexArea',     ...
					'FilledArea',		'EulerNumber',	'EquivDiameter',  ...
					'Solidity',			'Perimeter',	'PixelIdxList',   ...
					'PixelList',		'BoundingBox'); 

	% Compute intensities from background adjusted image, determine
	% edge condition (yes/no)
	bounds = bwboundaries(l);
	i = imtophat(im2double(im), strel('disk', 50));

	for(obj=1:size(s,1))
		s(obj).label = obj;
		s(obj).Intensity =  sum(i(s(obj).PixelIdxList));

		s(obj).bound = bounds{obj};

		s(obj).edge    = 0;
		if(find(s(obj).PixelList(:,1) == 1))
			s(obj).edge = 1;
		end
		if find(s(obj).PixelList(:,2) == 1)
			s(obj).edge = 1;
		end
		if find(s(obj).PixelList(:,1) == size(i,2) )
			s(obj).edge = 1;
		end
		if find(s(obj).PixelList(:,2) == size(i,1) )
			s(obj).edge = 1;
		end                 
	end

	s = ClassifyFirstPass(s);
	size(s)
  	
end
