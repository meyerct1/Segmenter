function clearArgs(instance_name)
%core CellAnimation function. clear argument values to free up memory

global dependencies_list;
global dependencies_index;

cur_idx=dependencies_index.get(instance_name);
dependency_item=dependencies_list{cur_idx};
function_args=dependency_item.FunctionArgs;
field_names=fieldnames(function_args);
for i=1:size(field_names,1)
    arg_struct=function_args.(field_names{i});
    arg_field_names=fieldnames(arg_struct);
    %if the field contains a value field that is set by a function clear it
    if ((size(arg_field_names,1)>1)&&(max(strcmp('Value',arg_field_names))==1))    
        dependencies_list{cur_idx}.FunctionArgs.(field_names{i}).Value=[];
    end
end

%end clearArgs
end