function output_args=getIntegratedIntensities(input_args)
%module to calculate the integrated intensity of objects in a
%label matrix.
%Input Structure Members
%LabelMatrix - Label matrix from which the object properties will be
%extracted
%Output Structure Members
%IntegratedIntensities - Matrix containing the integrated intensity values
%for each object

objects_lbl=input_args.ObjectsLabel.Value;
intensity_img=input_args.IntensityImage.Value;
objects_idx=(objects_lbl>0);

I = input_args.Image.Value;

% added on 10DEC12 IOT generate cell area
cells_props=regionprops(objects_lbl,I,'Centroid','Area','Eccentricity','MajorAxisLength','MinorAxisLength',...
    'Perimeter','Solidity','ConvexArea', 'PixelIdxList', 'PixelList','MeanIntensity','PixelValues');
shape_params=[[cells_props.Area]'];

% Output segment of module
output_args.IntegratedIntensities=accumarray(objects_lbl(objects_idx),intensity_img(objects_idx));
output_args.ShapeParameters=shape_params; 


%end getIntegratedIntensities
end