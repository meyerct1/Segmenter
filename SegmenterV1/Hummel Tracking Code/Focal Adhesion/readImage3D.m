function output_args=readImage3D(input_args)
%used to load a 3-D image in memory
%Input Structure Members
%ImageName - Path to the image to be loaded.
%ImageChannel - Which channel to load.
%Output Structure Members
%Image - The image matrix.

image_name=input_args.ImageName.Value;
img_channel=input_args.ImageChannel.Value;
img_info = imfinfo(image_name);
nr_images = numel(img_info);
img_width=img_info.Width;
img_height=img_info.Height;
img_3d=zeros(img_width,img_height,nr_images);
for i=1:nr_images
    cur_img=imread(image_name,i);
    switch img_channel        
        case 'r'
            cur_img=cur_img(:,:,1);
        case 'g'
            cur_img=cur_img(:,:,2);
        case 'b'
            cur_img=cur_img(:,:,3);
    end
    img_3d(:,:,i)=cur_img;
end
output_args.Image=img_3d;
img_size(1)=img_width;
img_size(2)=img_height;
img_size(3)=nr_images;
output_args.ImageSize=img_size;

%end readImage3D
end