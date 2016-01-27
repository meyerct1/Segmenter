function [p,l] = NaiveSegment_firstpass(imagename, imExt, directory)
    imagename
    filnms = dir([directory '/Nuc/*' imExt])
    idx = find(strcmp(imagename,{filnms.name}))
    filnms = dir([directory '/Segmented/*_' num2str(idx) '.mat'])
    temp = load([directory '/Segmented/' filnms.name]);
    CO = temp.CO;
    l = CO.Nuc_label;
	% Segment properties (with holes filled)
	p	= regionprops(CO.Nuc_label,...
					'Area',				'Centroid',			...
					'MajorAxisLength',	'MinorAxisLength',	...
					'Eccentricity', 	'ConvexArea',		...
					'FilledArea',		'EulerNumber',  	...
					'EquivDiameter',	'Solidity',			...
					'Perimeter',		'PixelIdxList',		...
					'PixelList',		'BoundingBox',		...
					'Orientation');
                
	% Compute intensities from background adjusted image
	%bounds = bwboundaries(i);
	for obj=1:size(p,1)
        p(obj).label = CO.Nuc.cellId(obj);
        [temp_x, temp_y] = ind2sub(size(CO.Nuc_label),find(CO.Nuc_label==obj));
		p(obj).bound = [temp_x(boundary(temp_x,temp_y)),temp_y(boundary(temp_x,temp_y))];
        p(obj).debris     	= CO.class.debris(obj);
        p(obj).nucleus    	= CO.class.nucleus(obj);
        p(obj).over       	= CO.class.over(obj);
        p(obj).under      	= CO.class.under(obj);
        p(obj).predivision 	= CO.class.predivision(obj);
        p(obj).postdivision	= CO.class.postdivision(obj);
        p(obj).apoptotic  	= CO.class.apoptotic(obj);
        p(obj).newborn    	= CO.class.newborn(obj);
        p(obj).edge         = CO.class.edge(obj);
    end
  
end % NaiveSegment
