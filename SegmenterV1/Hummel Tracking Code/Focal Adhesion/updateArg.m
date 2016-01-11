function []=updateArg(instance_name,update_name,var_name,var_val)
%CellAnimation core function
%update input parameters of dependent functions for the variable var_name only
global dependencies_list;
global dependencies_index;

cur_idx=dependencies_index.get(instance_name);
dependency_item=dependencies_list{cur_idx};
dependent_functions=dependency_item.DependentFunctions;
for i=1:size(dependent_functions,1)
    cur_function=dependent_functions{i};
    function_instance=cur_function.InstanceName;
    function_idx=dependencies_index.get(function_instance);
    dependent_args=cur_function.DependentArgs;
    for j=1:size(dependent_args,1)
        args_struct=dependent_args{j};
        args_fields=fieldnames(args_struct);
        switch(update_name)
            case {'input'}
                if max(strcmp(args_fields,'InputArg'))
                    this_arg_name=args_struct.InputArg;
                    update_type=2;
                else
                    continue;
                end
            case {'output'}
                if max(strcmp(args_fields,'OutputArg'))
                    this_arg_name=args_struct.OutputArg;
                    update_type=1;
                else
                    continue;
                end
        end
        if (~strcmp(var_name,this_arg_name))
            continue;
        end
        if (args_struct.Type~=update_type)
            continue;
        end
        dependent_arg_name=args_struct.ArgumentName;
        if (args_struct.DependencyType==1)
            dependencies_list{function_idx}.FunctionArgs.(dependent_arg_name).Value=var_val;
        elseif (args_struct.DependencyType==2)
            dependencies_list{function_idx}.KeepValues.(dependent_arg_name).Value=var_val;
        end
    end    
end

%end updateArgs
end