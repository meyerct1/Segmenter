function output_args=whileLoop(function_struct)
% Usage
% This module is used to loop through a series of modules. The modules that will be looped through are listed in the LoopFunctions input structure member.
% Input Structure Members
% TestFunction – The module which will be used to determine how many times the loop will iterate over the modules in LoopFunctions. This module needs to return a true/false value and be part of the whileLoop’s module loop functions. 


global dependencies_list;
global dependencies_index;

instance_name=function_struct.InstanceName;
cur_idx=dependencies_index.get(instance_name);

%propagate any input args needed by the loop functions from outside
updateArgs(instance_name,function_struct.FunctionArgs,'input');
input_args=function_struct.FunctionArgs;
loop_functions=function_struct.LoopFunctions;

test_function=input_args.TestFunction;
test_names=fieldnames(test_function);
%propagate any updated input args to the loop functions
dependency_item=dependencies_list{cur_idx};
updateArgs(instance_name,dependency_item.FunctionArgs,'input');

if (max(strcmp('FunctionInstance',test_names))==1)
    test_function_instance=input_args.TestFunction.FunctionInstance;
    test_function_dependecy_idx=dependencies_index.get(test_function_instance);
    test_function_dependency_item=dependencies_list{test_function_dependecy_idx};
    test_function_handle=test_function_dependency_item.FunctionHandle;
    test_output_name=input_args.TestFunction.OutputArg;
    test_output=test_function_handle(test_function_dependency_item.FunctionArgs);
    while(test_output.(test_output_name))
        for j=1:size(loop_functions,1)
            loop_function_instance_name=loop_functions{j}.InstanceName;
            callFunction(loop_function_instance_name,false);
        end       
        output_args=makeOutputStruct(function_struct);
        updateArgs(instance_name,output_args,'output');
        test_function_dependency_item=dependencies_list{test_function_dependecy_idx};
        test_output=test_function_handle(test_function_dependency_item.FunctionArgs);
    end
else
    %really this only makes sense for debugging purposes
    while(input_args.TestFunction.Value)
        for j=1:size(loop_functions,1)
            loop_function_instance_name=loop_functions{j}.InstanceName;
            callFunction(loop_function_instance_name,false);
        end
        output_args=makeOutputStruct(function_struct);
        updateArgs(instance_name,output_args,'output');        
    end
end


for i=1:size(loop_functions,1)
    loop_function_instance_name=loop_functions{i}.InstanceName;
    clearArgs(loop_function_instance_name);
end


%end while
end
