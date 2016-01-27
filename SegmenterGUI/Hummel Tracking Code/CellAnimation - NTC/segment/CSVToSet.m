function objSet = CSVToSet(objSet, directory)

  names = {'debris', 		'nucleus', 		 		'under'};%, ...
%		   'predivision', 	'postdivision',  	'newborn'};

  for(nm=1:size(names,2))
    imageName = objSet.imageName(1:(find(objSet.imageName == '.')-1));
    fileID = fopen([directory filesep imageName names{1,nm} '.csv']);
    line = fgetl(fileID);
    
    img = 1;
    while(img < size(objSet,2))
      for(obj=1:size(objSet(img).props,1))
        line = fgetl(fileID);
        objSet(img).props(obj).(names{1,nm}) = str2num(line(size(line,2)-1));
		clear line;
      end
      img = img + 1;
    end   
	clear imageName;
    fclose(fileID);
  end

  clear img;
  clear names;
  clear fildID;

end
