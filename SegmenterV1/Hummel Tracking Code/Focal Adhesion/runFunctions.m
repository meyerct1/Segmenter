%core CellAnimation function used to execute modules in the list
function []=runFunctions()
global functions_list;
for i=1:size(functions_list,1)
    function_struct=functions_list{i};
    instance_name=function_struct.InstanceName;
    callFunction(instance_name,true);
end

%end runFunctions
end