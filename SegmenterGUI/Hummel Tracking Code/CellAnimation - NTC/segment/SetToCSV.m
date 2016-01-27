function SetToCSV(objSet, filename)

	fileID = fopen(filename, 'w');

	attribs =  {'Area', 			'MajorAxisLength', 	...
				'MinorAxisLength',	'Eccentricity',		...
				'ConvexArea', 		'FilledArea', 	  	...
			  	'EulerNumber', 		'EquivDiameter', 	...
				'Solidity', 	  	'Perimeter', 		...
				'Intensity'};

  	classifs = {'edge', 			'debris', 			...
				'nucleus', 			'over', 			...
				'under', 			'predivision', 		...
			  	'postdivision', 	'apoptotic', 		...
				'newborn'};

	fprintf(fileID, '%s, %s, %s, %s', 'Well', 'Image', 'X', 'Y');
	for(nameIdx = 1:size(attribs,2))
		fprintf(fileID, ', %s', attribs{1, nameIdx});
	end
	for(nameIdx = 1:size(classifs,2))
		fprintf(fileID, ', %s', classifs{1, nameIdx});
	end

	fprintf(fileID, '\n');

	for(imIdx = 1:size(objSet,2))
		for(objIdx = 1:size(objSet(imIdx).props, 1))
			%if(size(objSet(imIdx).props,2) == 0)
			%	continue;
			fprintf(fileID, '%s, %s, %d, %d',					... 
					objSet(imIdx).wellName, 					...
					objSet(imIdx).imageName, 					...
					objSet(imIdx).props(objIdx).Centroid(1), 	...
					objSet(imIdx).props(objIdx).Centroid(2));
			for(propIdx = 1:size(attribs,2))
				fprintf(fileID, ', %d', ...
				objSet(imIdx).props(objIdx).(attribs{1,propIdx}));
			end
			for(propIdx = 1:size(classifs,2))
				fprintf(fileID,', %d', ...
				objSet(imIdx).props(objIdx).(classifs{1,propIdx}));
			end
			fprintf(fileID, '\n');
		end
	end

	fclose(fileID);

end
