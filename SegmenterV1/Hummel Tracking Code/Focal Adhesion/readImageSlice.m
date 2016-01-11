function output_args=readImageSlice(input_args)
%read a 2-D image slice from a 3-D image
%Input Structure Members
%ImageName - Path to the image to be loaded.
%ImageChannel - Which channel to load.
%SliceIndex - The index of the image slice to be loaded
%Output Structure Members
%Image - The 2-D image matrix for the current index.
image_name=input_args.ImageName.Value;
img_channel=input_args.ImageChannel.Value;
idx=input_args.SliceIndex.Value;
img_to_proc=imread(image_name,idx);
switch img_channel
    case 'r'
        img_to_proc=img_to_proc(:,:,1);
    case 'g'
        img_to_proc=img_to_proc(:,:,2);
    case 'b'
        img_to_proc=img_to_proc(:,:,3);
end
output_args.Image=img_to_proc;

%end readImage
end