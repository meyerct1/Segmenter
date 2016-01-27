function makeDependencies(parent_function_struct)
%core CellAnimation function. used to make a dependency tree from the module list.
global functions_list;
global dependencies_list;
global dependencies_index;
nr_functions=size(functions_list,1);
prev_functions_nr=size(dependencies_list,1);
dependencies_list=[dependencies_list; cell(nr_functions,1)];
for i=1:nr_functions
    function_struct=functions_list{i};
    dependency_struct=function_struct;
    dependency_struct.DependentFunctions={};
    %deal with special control functions differently
    switch(char(function_struct.FunctionHandle))
        case 'forLoop'
            temp=functions_list;
            functions_list=function_struct.LoopFunctions;
            dependency_struct=getDependencies(dependency_struct,0,parent_function_struct);
            makeDependencies(function_struct);
            functions_list=temp;
        case 'whileLoop'
            temp=functions_list;
            functions_list=function_struct.LoopFunctions;
            dependency_struct=getDependencies(dependency_struct,0,parent_function_struct);
            makeDependencies(function_struct);
            functions_list=temp;
        case 'if_statement'
            temp=functions_list;
            functions_list=[function_struct.IfFunctions; function_struct.ElseFunctions];
            dependency_struct=getDependencies(dependency_struct,0,parent_function_struct);
            makeDependencies(function_struct);
            functions_list=temp;
    end
    dependencies_list{prev_functions_nr+i}=getDependencies(dependency_struct,i,parent_function_struct);
    dependencies_index.put(dependency_struct.InstanceName,prev_functions_nr+i);
end

%end makeDependencies
end

function dependency_struct=getDependencies(dependency_struct,this_idx,parent_function_struct)
global functions_list;
instance_name=dependency_struct.InstanceName;
dependent_functions=dependency_struct.DependentFunctions;
if (~isempty(parent_function_struct))
    [b_dependent dependency_item]=makeDependencyRecord(instance_name,parent_function_struct);
    [b_dependent dependency_item]=addValuesToKeep(instance_name,parent_function_struct,dependency_item, b_dependent);
    if (b_dependent)
        dependent_functions=[dependent_functions; {dependency_item}];
    end    
end
for i=1:size(functions_list,1)
    [b_dependent dependency_item]=makeDependencyRecord(instance_name,functions_list{i});
    if (b_dependent)
        dependent_functions=[dependent_functions; {dependency_item}];
    end    
end
dependency_struct.DependentFunctions=dependent_functions;

%end getDependencies
end

function [b_dependent dependency_item]=makeDependencyRecord(instance_name,function_struct)
%if function_struct has any arguments that depend on the function for which
%we're building the dependency chain create a dependency record 

field_names=fieldnames(function_struct);
if max(strcmp(field_names,'FunctionArgs'))
    function_args=function_struct.FunctionArgs;
else
    function_args={};
end
function_instance=function_struct.InstanceName;
b_first_dep=true;
b_dependent=false;
dependency_item=[];
if isempty(function_args)
    return;
else
    field_names=fieldnames(function_args);
end
dependent_args={};
for i=1:size(field_names,1)
    arg_struct=function_args.(char(field_names{i}));
    struct_field_names=fieldnames(arg_struct);
    function_instances_idx=strncmp('FunctionInstance',struct_field_names,16);
    dependency_field_names=struct_field_names(function_instances_idx);
    arg_field_names=struct_field_names(circshift(function_instances_idx,1));
    for j=1:size(dependency_field_names,1)        
        if strcmp(instance_name,arg_struct.(char(dependency_field_names{j})))
            %this argument is a dependency - add it to the list
            if (b_first_dep)
                %create a dependency record
                dependency_item.InstanceName=function_instance;                
                b_first_dep=false;
            end
            dependent_arg.ArgumentName=field_names{i};
            if (strncmp('OutputArg',arg_field_names{j},9))
                dependent_arg.OutputArg=arg_struct.(arg_field_names{j});
                dependent_arg.Type=1; %output
            else
                dependent_arg.InputArg=arg_struct.(arg_field_names{j});
                dependent_arg.Type=2; %input
            end
            dependent_arg.DependencyType=1; %functionargs
            dependent_args=[dependent_args; {dependent_arg}];
            break;
        end        
    end
end
if (~b_first_dep)
    b_dependent=true;
    dependency_item.DependentArgs=dependent_args;    
end

end

function [b_dependent dependency_item]=addValuesToKeep(instance_name,parent_function_struct,dependency_item, b_dependent)

parent_fields=fieldnames(parent_function_struct);
if (max(strcmp('KeepValues',parent_fields))==0)
    %parent doesn't want to save any values
    return;
end
parent_instance=parent_function_struct.InstanceName;
if (b_dependent)
    b_initially_dependent=true;
    b_first_dep=false;
else
    b_initially_dependent=false;
    b_first_dep=true;
end
values_to_keep=parent_function_struct.KeepValues;
values_names=fieldnames(values_to_keep);
b_found_dependency=false;
dependent_args={};
for i=1:size(values_names,1)
    value_struct=values_to_keep.(char(values_names{i}));
    value_struct_field_names=fieldnames(value_struct);
    function_instances_idx=strncmp('FunctionInstance',value_struct_field_names,16);
    dependency_field_names=value_struct_field_names(function_instances_idx);
    arg_field_names=value_struct_field_names(circshift(function_instances_idx,1));
    for j=1:size(dependency_field_names,1)        
        if strcmp(instance_name,value_struct.(char(dependency_field_names{j})))    
            %this argument is a dependency - add it to the list
            b_found_dependency=true;
            if (b_first_dep)
                %create a dependency record
                dependency_item.InstanceName=parent_instance;
                b_first_dep=false;
            end
            dependent_arg.ArgumentName=values_names{i};
            if (strncmp('OutputArg',arg_field_names{j},9))
                dependent_arg.OutputArg=value_struct.(arg_field_names{j});
                dependent_arg.Type=1; %output                
            else
                dependent_arg.InputArg=value_struct.(arg_field_names{j});
                dependent_arg.Type=2; %input
            end
            dependent_arg.DependencyType=2; %keepvalue
            dependent_args=[dependent_args; {dependent_arg}];
            break;
        end
    end
end

if (b_found_dependency)
    if (b_initially_dependent)
        dependency_item.DependentArgs=[dependency_item.DependentArgs; dependent_args];
    else
        b_dependent=true;
        dependency_item.DependentArgs=dependent_args;
    end
end

%end addValuesToKeep
end