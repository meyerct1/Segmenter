function output_args=getplanes(input_args)
%module to calculate number of z-planes in a 3D image

img=input_args.Image.Value;
img_sz=size(img);
nr_slices=img_sz(3);

% Output segment of module
output_args.slicenumber = nr_slices;


%end getplane number
end