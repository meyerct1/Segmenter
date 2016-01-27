function output_args=mkdir_Wrapper(input_args)
%simple wrapper for the MATLAB mkdir function
%Input Structure Members
%DirectoryName - The path where the directory will be created.
%Output Structure Members
%None

mkdir(input_args.DirectoryName.Value);
output_args=[];

end