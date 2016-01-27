function [output_args]=if_statement(function_struct)
% Usage
% This module is used to create branching execution in an assay. Depending on the result of a test function, either the modules in the IfFunctions or the modules in the ElseFunctions structures will be executed.
% Input Structure Members
% TestVariable – The module which will be used to determine what subset of modules will be executed. This module needs to return a true/false value.
% IfFunctions – Set of modules which will be executed if the value returned by the test function is true.
% ElseFunctions – Set of modules which will be executed if the value returned by the test function is false.

updateArgs(function_struct.InstanceName,function_struct.FunctionArgs,'input');
input_args=function_struct.FunctionArgs;
if(input_args.TestVariable.Value)
    if_functions=function_struct.IfFunctions;
else
    if_functions=function_struct.ElseFunctions;
end

for i=1:size(if_functions,1)
    if_function_instance_name=if_functions{i}.InstanceName;
    callFunction(if_function_instance_name,false);
end

output_args=makeOutputStruct(function_struct);

%end if_statement
end
