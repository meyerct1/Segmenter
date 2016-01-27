function output_args=generateBinImgUsingLocAvg3D(input_args)
%module to convert z-stack grayscale image to a binary image using the local
%average values by slices
avg_filter=fspecial(input_args.Strel.Value,input_args.StrelSize.Value);
img=input_args.Image.Value;
img_sz=size(img);
img_bw=zeros(img_sz);
brightness_pct=input_args.BrightnessThresholdPct.Value;
for i=1:img_sz(3)
    slice=img(:,:,i);
    slice_avg=imfilter(slice,avg_filter,'replicate');
    img_bw(:,:,i)=slice>(brightness_pct*slice_avg);
end

output_args.Image=img_bw;

%end generateBinImgUsingLocAvg
end