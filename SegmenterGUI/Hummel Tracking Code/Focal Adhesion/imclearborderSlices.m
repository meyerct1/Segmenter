function output_args=imclearborderSlices(input_args)
%used to clear the border in a z-stack image. imclearborder can handle 3-D
%images but it clears the top and bottom slices completely.
%Input Structure Members
%Image - The binary image to be processed.
%Output Structure Members
%Image - The resulting binary image.
img=input_args.Image.Value;
img_sz=size(img);
img_output=zeros(img_sz);

for i=1:img_sz(3)
    img_output(:,:,i)=imclearborder(img(:,:,i));    
end

output_args.Image=img_output;
end