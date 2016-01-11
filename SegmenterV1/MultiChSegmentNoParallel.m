function [] = MultiChSegmentNoParallel(handles)

% Multi Channel Cell Segmentation with channel correction without parallel loop 
%%Christian Meyer 12.30.15
%Segmentation code to find the intensities per cell of the each channel for
%a series of images from the CellaVista presorted with the
%cellaVistaFileSorter.
%Option for segmenting just the surface of the cell or segmenting based on
%the nucleus by adding a dilated nuclear channel to the cytoplasmic
%segmentation.
%All functionality assumes images have been separated into separate 
%Channels useing cellaVistaFileSorter.m
%Segmentation of all channels for each image based on nuclear image.
%First nuclei are segmented.  Then each cytoplasmic channel is segmented and 
%added together to come up with a final cytoplamsic bw image
%Finally the cytoplasmic bw image is segmented using a k-nearest neighbor algorithm to
%predict each pixel's respective nuclei.
%The intensity, area, and nuclear and cytoplasmic labels are stored in a structure which is saved to
%a folder called Segemented with the row, channel, and image number in the name.


h = msgbox('Please Be Patient, This box will close when operation is finished. See Command Window for estimate of time to completion')

imExt = handles.imExt;
expDir = handles.expDir;
%Whether to correct with cidrecorrect
cidrecorrect = handles.cidrecorrect;
%Number of levels used in otsu's method of thresholding
numLevels = handles.numLevels;
%Segment the surface
surface_segment = handles.surface_segment;
%Segment by dilating the nucleus
nuclear_segment = handles.nuclear_segment;
nuclear_segment_factor = handles.nuclear_segment_factor;
surface_segment_factor = handles.surface_segment_factor;
%Clear cells touching border?
cl_border = handles.cl_border;
%Noise disk 5 for 20x 10 for 40X
noise_disk = handles.noise_disk;
%Smoothing factor for cytoplasm segmentation.  (-) means to erode image
smoothing_factor = handles.smoothing_factor;
%Number of channels in the image
numCh = handles.numCh;
%Segmentation height for nuclei in the watershed segmentation
NucSegHeight = handles.NucSegHeight;
%Structure to hold the filenames and segmentation results
NUC = handles.NUC;
Cyto = handles.Cyto;


filnames = dir([expDir '/Segmented']); temp = [];
if length(filnames)>2
    for i = 3:length(filnames)
        temp{i-2} = filnames(i).name(9:strfind(filnames(i).name,'.')-1)
    end
    x = [1:length(NUC.filnms)];
    y = sort(str2double(temp));
    unfinishedImages = x(~ismember(x,y));
else
    unfinishedImages = 1:length(NUC.filnms);
end

%For all images
for rand = 1:size(unfinishedImages,2)
    tic
    i = unfinishedImages(rand);
    [CO,Im_array] = NaiveSegmentV1(imExt,cidrecorrect,numLevels,surface_segment,nuclear_segment,noise_disk,...
        nuclear_segment_factor,surface_segment_factor,cl_border,smoothing_factor,NucSegHeight,numCh,NUC,Cyto,i)

    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    save([expDir '/Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
    t(rand) = toc;
    fprintf('%.2f%% Complete, Estimated Time: %.2f\n',rand/length(unfinishedImages)*100,mean(t)/60*(length(unfinishedImages)-rand))
end

%Now Open all the segmented images and compile the statistics on nuclear
%size

seg_file = dir([handles.expDir filesep 'Segmented/*.mat'])

Area = [];
for i = 1:size(seg_file,1)
    load([handles.expDir filesep 'Segmented/' seg_file(i).name])
    Area = [Area, CO.Nuc.Area];
end
%Take the log of the area to normalize
logDist = log(Area);
avg_dist = mean(logDist);
std_dist = std(logDist);
for i = 1:size(seg_file,1)
    load([handles.expDir filesep 'Segmented/' seg_file(i).name])
    %initialize fields in the struct
    CO.class.debris     	= [];
    CO.class.nucleus    	= [];
    CO.class.over       	= [];
    CO.class.under      	= [];
    CO.class.predivision 	= [];
    CO.class.postdivision	= [];
    CO.class.apoptotic  	= [];
    CO.class.newborn    	= [];
    %Run a first pass to classify the nuclei
    for k=1:CO.cellCount
        CO.class.debris(k)     	= 0;
        CO.class.nucleus(k)    	= 0;
        CO.class.over(k)       	= 0;
        CO.class.under(k)      	= 0;
        CO.class.predivision(k) 	= 0;
        CO.class.postdivision(k)	= 0;
        CO.class.apoptotic(k)  	= 0;
        CO.class.newborn(k)    	= 0;
    end
    for k=1:CO.cellCount
        %rough first pass classification
        if(log(CO.Nuc.Area(k)) < avg_dist-3*std_dist)    
          CO.class.debris(k) 	= 1;
        elseif(log(CO.Nuc.Area(k)) < avg_dist-2*std_dist) 
          CO.class.newborn(k) 	= 1;
          CO.class.nucleus(k) 	= 1;
        elseif(log(CO.Nuc.Area(k))  < avg_dist+1.8*std_dist)  
          CO.class.nucleus(k) 	= 1;
        else
          CO.class.under(k) 	= 1;
        end
    end
    save([handles.expDir filesep 'Segmented/' seg_file(i).name], 'CO')
    clear CO
end
close(h)




