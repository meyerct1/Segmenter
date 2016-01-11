function output_args=imNorm(input_args)
% Usage
% This module is used to normalize an image so that the lowest pixel value is zero and the highest pixel value is the maximum allowed value for the specified integer class.
% Input Structure Members
% IntegerClass – The integer class of the image.  Has to be an integer class supported by MATLAB such as 'int8' or 'uint8'.
% RawImage – The image to be processed.
% Output Structure Members
% Image – The normalized image.

int_class=input_args.IntegerClass.Value;
max_val=double(intmax(int_class));
img_raw=input_args.RawImage.Value;
img_dbl=floor(double((img_raw-min(img_raw(:))))*max_val./double(max(img_raw(:))-min(img_raw(:))));
switch(int_class)
    case 'uint8'
       output_args.Image=uint8(img_dbl);
    case 'uint16'
       output_args.Image=uint16(img_dbl);
    otherwise
        output_args.Image=[];
end

%end function
end
