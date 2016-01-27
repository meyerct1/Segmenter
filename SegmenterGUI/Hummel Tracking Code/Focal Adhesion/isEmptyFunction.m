function output_args=isEmptyFunction(input_args)
%wrapper module for Matlab isempty function
%Input Structure Members
%TestVariable - The variable to be tested.
%Output Structure Members
%Boolean - The result of the test.
output_args.Boolean=isempty(input_args.TestVariable.Value);

%end is_empty_function
end