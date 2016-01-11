function output_args=labelObjects(input_args)
%simple wrapper module for bwlabeln function
%Input Structure Members
%Image - The image to be processed.
%Output Structure Members
%LabelMatrix - The resulting label matrix.
output_args.LabelMatrix=bwlabeln(input_args.Image.Value);

%end labelObjects
end