function newObjSet = RemoveObjects(objSet, classification)
	
	%Removes all objects of type classification from the set

	newObjSet = objSet;
	
	while(~isempty(find([newObjSet.props(:).(classification)])))
		removeIdx = find([newObjSet.props(:).(classification)]);
		removeMask = ...
			newObjSet.labels ~= newObjSet.props(removeIdx(1)).label;
		newObjSet.labels = newObjSet.labels .* removeMask;
		newObjSet.props(removeIdx(1)) = [];
		clear removeMask;
	end

end
