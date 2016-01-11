function output_args=generateBinImgUsingGlobInt(input_args)
% Usage
% This module is used to convert a grayscale image to binary using a global intensity threshold.
% Input Structure Members
% ClearBorder – If this value is set to true, objects that are within ClearBorderDist of the image edges will be erased.
% ClearBorderDist – Objects that are within this distance from the edges of the image will be erased if ClearBorder is set to true.
% Pixel intensities greater than the threshold intensity are converted to 1 in the binary image.
% Image – Grayscale image to be converted.
% IntensityThresholdPct – This is a percentage of the intensity range of the image. The threshold intensity value is calculated as IntensityThresholdPct*double(max_pixel-min_pixel)+min_pixel.
% 
% Output Structure Members
% Image – Resulting binary image.


max_pixel=max(input_args.Image.Value(:));
min_pixel=min(input_args.Image.Value(:));
brightnessPct=input_args.IntensityThresholdPct.Value;
threshold_intensity=brightnessPct*double(max_pixel-min_pixel)+min_pixel;
img_bw=input_args.Image.Value>threshold_intensity;
% img_bw=im2bw(img_to_proc,brightnessPct*graythresh(img_to_proc));
clear_border_dist=input_args.ClearBorderDist.Value;
if (input_args.ClearBorder.Value)
    if (clear_border_dist>1)
        img_bw(1:clear_border_dist-1,1:end)=1;
        img_bw(end-clear_border_dist+1:end,1:end)=1;
        img_bw(1:end,1:clear_border_dist-1)=1;
        img_bw(1:end,end-clear_border_dist+1:end)=1;
    end
    output_args.Image=imclearborder(img_bw);
else
    output_args.Image=img_bw;
end

%end generateBinImgUsingGlobInt
end
