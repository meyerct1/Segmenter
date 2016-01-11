function output_args=gaussianFilter(input_args)
% Usage
% This module is used to apply a gaussian blur to an image. See MATLAB
% documentation on fspecial for additional details.
% Input Structure Members
% KernelSize – The size of the kernel.
% StandardDev – The standard deviation of the gaussian distribution.
% Output Structure Members
% Image – The normalized image.

kernel_size=input_args.KernelSize.Value;
standard_dev=input_args.StandardDev.Value;
output_args.Image=imfilter(input_args.Image.Value, fspecial('gaussian',kernel_size,standard_dev), 'symmetric', 'conv');

%end function
end
