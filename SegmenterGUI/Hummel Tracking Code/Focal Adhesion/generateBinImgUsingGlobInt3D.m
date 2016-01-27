function output_args=generateBinImgUsingGlobInt3D(input_args)
% Usage
% This module is used to convert a 3-D grayscale image to binary using a global intensity threshold by slices.
% Input Structure Members
% Pixel intensities greater than the threshold intensity are converted to 1 in the binary image.
% Image – Grayscale image to be converted.
% IntensityThresholdPct – This is a percentage of the intensity range of the image. The threshold intensity value is calculated as IntensityThresholdPct*double(max_pixel-min_pixel)+min_pixel.
% 
% Output Structure Members
% Image – Resulting binary image.


img=input_args.Image.Value;
img_sz=size(img);
img_bw=zeros(img_sz);
brightnessPct=input_args.IntensityThresholdPct.Value;
for i=1:img_sz(3)
    slice=img(:,:,i);
    max_pixel=max(slice(:));
    min_pixel=min(slice(:));
    threshold_intensity=brightnessPct*double(max_pixel-min_pixel)+min_pixel;
    img_bw(:,:,i)=slice>threshold_intensity;
end

output_args.Image=img_bw;

%end generateBinImgUsingGlobInt
end
