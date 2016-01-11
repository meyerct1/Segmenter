function function_output=callFunction(instance_name,b_clear_args)
%CellAnimation core function used to execute the modules and sub-modules in
%an assay
global dependencies_list;
global dependencies_index;

cur_idx=dependencies_index.get(instance_name);
dependency_item=dependencies_list{cur_idx};

functionHandle=dependency_item.FunctionHandle;
switch(char(functionHandle))
    case {'forLoop','if_statement','whileLoop'}
        function_output=functionHandle(dependency_item);        
    otherwise
        field_names=fieldnames(dependency_item);
        if max(strcmp(field_names,'FunctionArgs'))
            function_output=functionHandle(dependency_item.FunctionArgs);
        else
            function_output=functionHandle();
        end
end
instance_name=dependency_item.InstanceName;
updateArgs(instance_name,function_output,'output');
if (b_clear_args)
    clearArgs(instance_name);
end

%end callFunction
end
