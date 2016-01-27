function output_args=combineImages(input_args)
%Usage
%This module is used to combine two binary images using logical operations.
%
%Input Structure Members
%CombineOperation - String value indicating the logical operation used to combine the images.
%Currently, only AND and OR are supported.
%Image1 - First binary image.
%Image2 - Second binary image.
%
%Output Structure Members
%Image - Binary image resulting from the logical operation.

switch (input_args.CombineOperation.Value)
    case 'AND'
        output_args.Image=input_args.Image1.Value&input_args.Image2.Value;
    case 'OR'
        output_args.Image=input_args.Image1.Value|input_args.Image2.Value;
end

%end combineImages
end
