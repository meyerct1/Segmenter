function output_args=makeOutputStruct(function_struct)
%core CellAnimation function. create a CellAnimation output structure
global dependencies_list;
global dependencies_index;
output_args=[];

function_idx=dependencies_index.get(function_struct.InstanceName);
dependency_struct=dependencies_list{function_idx};
function_field_names=fieldnames(dependency_struct);
if (max(strcmp('KeepValues',function_field_names))==0)
    %parent doesn't want to save any values    
    return;
end

field_names=fieldnames(dependency_struct.KeepValues);
for i=1:size(field_names,1)
    arg_name=field_names{i};
    keep_value_fields=fieldnames(dependency_struct.KeepValues.(arg_name));    
    if max(strcmp(keep_value_fields,'Value'))
        %a value has been filled in so pass it along
        output_args.(arg_name)=dependency_struct.KeepValues.(arg_name).Value;
    end    
end

end