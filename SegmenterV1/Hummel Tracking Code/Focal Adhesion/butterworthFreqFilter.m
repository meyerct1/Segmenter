function output_args=butterworthFreqFilter(input_args)
% Usage
% This module is used to filter a 2D image in the frequency domain
% Input Structure Members
% Image – Grayscale image to be filtered.
% CutOffFreq - The cut-off frequency of the Butterworth filter
% FilterOrder - The order of the filter
% FilterType - Can be either 'HighPass' or 'LowPass'
% 
% Output Structure Members
% Image – Filtered 2D grayscale image.
img=input_args.Image.Value;
original_img_sz=size(img);
img_sz(1)=2^nextpow2(2*original_img_sz(1)-1);
img_sz(2)=2^nextpow2(2*original_img_sz(2)-1);
%calculate the square distance matrix from the center point
dist_matrix=false(img_sz(1:2));
dist_matrix(floor(img_sz(1)/2)+1,floor(img_sz(2)/2)+1)=true;
dist_matrix=bwdist(dist_matrix).^2;
%arrange it so it's in the proper form for fft2
dist_matrix=ifftshift(rot90(dist_matrix,2));
%setup the filter
cutoff_freq=input_args.CutOffFreq.Value;
filter_order=input_args.FilterOrder.Value;
filter_type=input_args.FilterType.Value;
switch(filter_type)
    case 'LowPass'
        butterworth_filter=1./(1+ (dist_matrix./cutoff_freq).^(2*filter_order));
    case 'HighPass'
        butterworth_filter=1-1./(1+ (dist_matrix./cutoff_freq).^(2*filter_order));
end
%filter the image in the frequency domain

img_fft=fft2(double(img),img_sz(1),img_sz(2));
img_filtered=real(ifft2(butterworth_filter.*img_fft));
    
output_args.Image=img_filtered(1:original_img_sz(1),1:original_img_sz(2));

%butterworthFilter
end