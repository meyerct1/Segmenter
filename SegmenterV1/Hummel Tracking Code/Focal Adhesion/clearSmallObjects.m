function output_args=clearSmallObjects(input_args)
% Simple wrapper module for bwareaopen MATLAB function
% Input Structure Members
% Image – Binary image from which objects will be removed.
% MinObjectArea – Objects with an area smaller than this value will be removed.
% Output Structure Members
% Image – Filtered binary image.

output_args.Image=bwareaopen(input_args.Image.Value,input_args.MinObjectArea.Value);

%end clearSmallObjects
end
