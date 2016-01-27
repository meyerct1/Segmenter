function [] = MultiChSegmenterV13GUI(handles)

% Multi Channel Cell Segmentation with channel correction.  
%%Christian Meyer 12.30.15
%Segmentation code to find the intensities per cell of the each channel for
%a series of images from the CellaVista presorted with the
%cellaVistaFileSorter.
%Option for segmenting just the surface of the cell or segmenting based on
%the nucleus by adding a dilated nuclear channel to the cytoplasmic
%segmentation.
%First block of code builds the basic sturcture of to hold the 
%Nuclear and cytoplasmic files.
%Currently a rolling ball background filter is applied to correct for
%background; however, the code is set up to take a cidre correction model
%in the future.
%All functionality assumes images have been separated into separate 
%Channels useing cellaVistaFileSorter.m
%Segmentation of all channels for each image based on nuclear image.
%First nuclei are segmented.  Then each cytoplasmic channel is segmented and 
%added together to come up with a final cytoplamsic bw image
%Finally the cytoplasmic bw image is segmented and the intensity, area, and
%nuclear and cytoplasmic labels are stored in a structure which is saved to
%a folder called segemented with the row and channel name.
h = msgbox('Please Be Patient, This box will close when operation is finished. See Command Window for estimate of time to completion')

imExt = handles.imExt;
%experiment Directory
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


%Make a directory for the segemented files
mkdir([handles.expDir filesep 'Segmented'])

%Segmentation occurs in multiple steps
%First nuclei are segmented using Otsu's method to determine background in 
%the nuclear channel.  The image is quantized into three tiers with the top
%two being assigned as nucleus (nucleus in focus and nucleus out of focus)
% Use of a watershed segmentation algorithm then assigns a label to each
% cell
%Each of the fluorescent channels are then binarized, added, and segmented.
%The intensity in each channel for each cell is then subsequently measured.
%Subsequent use of a noise filter and hole filling smooths out the image and
%then use of a watershed segmentation to label all the cells.
%The label for the cell's cytoplasm is determined using a
%kmeans nearest neighbor algorithm from each nucleus
%Each segmented image is saved in a Segmentation folder.


%Initialize functions involved in parallel computing
parfor_progress(size(NUC.filnms,2),[],[]);ParallelPoolInfo = Par(size(NUC.filnms,2));
%For all images
parfor i = 1:size(NUC.filnms,2)
    Par.tic;
    i
    
    [CO,Im_array] = NaiveSegmentV1(imExt,cidrecorrect,numLevels,surface_segment,nuclear_segment,noise_disk,...
        nuclear_segment_factor,surface_segment_factor,cl_border,smoothing_factor,NucSegHeight,numCh,NUC,Cyto,i)
    
    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    parforsaverGUI(CO.rw,CO.cl,CO,i,expDir)
    ParallelPoolInfo(i) = Par.toc
    parfor_progress([],ParallelPoolInfo(i).ItStop-ParallelPoolInfo(i).ItStart,i);
    %save(['Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
    CO=structfun(@(f)[] ,CO,'uni',0);
    tempIm = [];Nuc_label = []; CytoLabel = []; Im_array = []; SegIm_array = [];
    D = []; p= []; temp = []; Label_array = [];
end
stop(ParallelPoolInfo)
parfor_progress(0,[],[]);
close(h)


