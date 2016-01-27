function output_args=isNotEmptyFunction(input_args)
%module wrapper for is not empty Matlab function
%Input Structure Members
%TestVariable - The variable to be tested.
%Output Structure Members
%Boolean - The result of the test.
output_args.Boolean=~isempty(input_args.TestVariable.Value);

%end is_empty_function
end