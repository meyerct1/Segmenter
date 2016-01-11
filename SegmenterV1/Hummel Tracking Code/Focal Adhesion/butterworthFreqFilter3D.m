function output_args=butterworthFreqFilter3D(input_args)
% Usage
% This module is used to filter a 3D image in the frequency domain one
% z-slice at a time
% Input Structure Members
% Image – Grayscale image to be converted.
% CutOffFreq - The cut-off frequency of the butterworth filter
% FilterOrder - The order of the filter
% FilterType - Can be either 'HighPass' or 'LowPass'
% 
% Output Structure Members
% Image – Filtered 3D grayscale image.

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
nr_slices=original_img_sz(3);
img_filtered=zeros(original_img_sz);
for i=1:nr_slices
    slice_fft=fft2(double(img(:,:,i)),img_sz(1),img_sz(2));
    filtered_slice=real(ifft2(butterworth_filter.*slice_fft));
    img_filtered(:,:,i)=filtered_slice(1:original_img_sz(1),1:original_img_sz(2));
end
output_args.Image=img_filtered;

%butterworthFilter
end