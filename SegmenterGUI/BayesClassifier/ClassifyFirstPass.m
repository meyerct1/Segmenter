function s = ClassifyFirstPass(properties)
%
%initializes classifications in the object struct, does a rough first pass
%classification based on area
%
%INPUTS
%properties			-	a list of structs of properties representing 
%						objects
%
%OUTPUTS
%s					-	the same list as the input, with boolean 
%						classifications added (e.g. nucleus, debris)
%

    s = properties;
 

    logDist = log([s(:).Area]);
    avg_dist = mean(logDist);
    std_dist = std(logDist);

    for(obj=1:size(s,1))
    %initialize fields in the struct
    s(obj).debris     	= 0;
    s(obj).nucleus    	= 0;
    s(obj).over       	= 0;
    s(obj).under      	= 0;
    s(obj).predivision 	= 0;
    s(obj).postdivision	= 0;
    s(obj).apoptotic  	= 0;
    s(obj).newborn    	= 0;

    %rough first pass classification
        if(logDist(obj) < avg_dist-3*std_dist)    
          s(obj).debris 	= 1;
        elseif(logDist(obj) < avg_dist-2*std_dist) 
          s(obj).newborn 	= 1;
          s(obj).nucleus 	= 1;
        elseif(logDist(obj) < avg_dist+1.8*std_dist)  
          s(obj).nucleus 	= 1;
        else
          s(obj).under 	= 1;
        end
    end
    
end


