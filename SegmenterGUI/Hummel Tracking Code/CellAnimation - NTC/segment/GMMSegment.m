function objSet = GMMSegment(im, OS, trainingset)

	objSet = OS;

	% determine average and standard deviations from training set
	% used in determining best outcome by max likelihood
	p = [];
	for(i=1:size(trainingset,2))
		p2 = [p; trainingset(i).props];
		clear p;
		p = p2;
		clear p2;
	end
	nuclei = p(find([p(:).nucleus]));
	
	% properties chosen based on variable importance
	% from classification

	% area
	avgArea = mean([nuclei.Area]);
	stdArea = std([nuclei.Area]);

	% eccentricity
	avgEccentricity = mean([nuclei.Eccentricity]);
	stdEccentricity = std([nuclei.Eccentricity]);
    
	% minor axis length
    avgMinAL = mean([nuclei.MinorAxisLength]);
    stdMinAL = std([nuclei.MinorAxisLength]);
    
	% solidity
    avgSolidity = mean([nuclei.Solidity]);
    stdSolidity = std([nuclei.Solidity]);

	clear nuclei
	clear p

	% begin segmentation of each object seperately
	for(n=1:size(objSet.props,1))			
	
		for(i=1:size(objSet.props(n).PixelList,1))
			objSet.labels(	objSet.props(n).PixelList(i,2), ...
							objSet.props(n).PixelList(i,1)) = 0;
		end
		
		gmmIm = zeros(size(im));
		i = im2double(im);

		% extract pixels
		pl = objSet.props(n).PixelList;
		points = [];
		for(pt = 1:size(pl,1))
			numPts = i(pl(pt,2), pl(pt,1)) * 100 * 10;
			for(j=1:numPts)
				pts2 = [points; pl(pt,2), pl(pt,1)];
				clear points;
				points = pts2;
				clear pts2;
			end
		end
		clear pl;	

		maxlklhd = -Inf;
		finalNum = 0;

		% try to segment object into numObj objects, check likelihoo
		for(numObj=1:3)

			% gaussian mixture modeling ...
			options = statset('Display', 'off', 'MaxIter', 500);
			gm = gmdistribution.fit(points, numObj,...
									'Options',options, ...
									'Start', 'randSample', ...
									'Replicates', 3);
			idx = cluster(gm, points);

			im2 = zeros(size(im));
			for(obj=1:numObj)
				for(pt=1:size(idx))
					if(idx(pt) == obj)
						im2(points(pt,1), points(pt,2)) = obj;
					end
				end
			end
			% fill holes
			im2 = imfill(im2, 'holes');

			likelihood = 0;
			% properties for likelihoods
			props = regionprops(im2, 'MinorAxisLength',...
									 'Solidity', ...
									 'Area', ...
									 'Eccentricity');
			for(obj=1:size(props,1))
				% determine likelihood
				likelihood = likelihood + ...
							log(normpdf(props(obj).MinorAxisLength,...
										avgMinAL,...
										stdMinAL)) + ...
							log(normpdf(props(obj).Solidity, ...
										avgSolidity, ...
										stdSolidity)) + ...
							log(normpdf(props(obj).Area, ...
										avgArea, ...
										stdArea)) + ...
							log(normpdf(props(obj).Eccentricity, ...
										avgEccentricity, ...
										stdEccentricity));
			end

			% likelihood correction based on number of objects
			likelihood = likelihood - (obj * log(obj));
			% compare to current maximum likelihood,
			% replace if better
			if(likelihood > maxlklhd)
				maxlklhd = likelihood;
				clear gmmIm;
				gmmIm = im2;
				finalNum = numObj;
			end
			clear im2;
		end

		%place division between newly segmented objects
		%gmmIm is image with final segmentation
		for(obj=1:finalNum)
			tempIm = gmmIm == obj;
			bounds = bwboundaries(tempIm);
			for(i=1:size(bounds{1},1))
				gmmIm(bounds{1}(i,1), bounds{1}(i,2)) = 0;
			end
			clear tempIm;
		end	

		%insert new objects into labels
		objSet.labels = objSet.labels | gmmIm;
		clear gmmIm;
		clear points;
		
	end

	%relabel and find new object properties
	objSet.labels = bwlabel(objSet.labels);
	objSet.props = regionprops(logical(objSet.labels), 	...
								'Area',					...
								'Centroid', 			...
								'MajorAxisLength', 		...
								'MinorAxisLength',		...
								'Eccentricity',			...
								'ConvexArea',			...
								'FilledArea',			...
								'EulerNumber',			...
								'EquivDiameter',		...
								'Solidity',				...
								'Perimeter',			...
								'PixelIdxList',			...
								'PixelList',			...
								'BoundingBox');
	
	%compute intensities, store labels, determine edge condition,
	%first pass classification - same as NaiveSegment.m
	bounds = bwboundaries(objSet.labels);
	i = imtophat(im2double(im), strel('disk', 50));
	
	for(obj=1:size(objSet.props, 1))
		objSet.props(obj).label = obj;
		objSet.props(obj).Intensity = ...
			sum(i(objSet.props(obj).PixelIdxList));
		objSet.props(obj).bound = bounds{obj};
		objSet.props(obj).edge = 0;
		if(find(objSet.props(obj).PixelList(:,1) == 1))
			objSet.props(obj).edge = 1;
		end
		if(find(objSet.props(obj).PixelList(:,2) == 1))
			objSet.props(obj).edge = 1;
		end
		if(find(objSet.props(obj).PixelList(:,1) == size(i,2)))
			objSet.props(obj).edge = 1;
		end
		if(find(objSet.props(obj).PixelList(:,2) == size(i,1)))
			objSet.props(obj).edge = 1;
		end
		objSet.props = ClassifyFirstPass(objSet.props);
	end
	
	clear i

end
