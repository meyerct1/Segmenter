%To get the segmentation code to work without the gui
load('Handles.mat')
handles.expDir = pwd;  %Change the experiment directory to the current working directory
%Change the location of the CIDRE directory (as it is different on my computer)
handles.cidreDir = [handles.expDir filesep '20X_GREEN_2048']; 
%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
NUC.dir = 'Nuc';
NUC.filnms = dir([handles.expDir filesep NUC.dir filesep '*' handles.imExt]);
NUC.filnms = strcat(handles.expDir, '/', {NUC.dir}, '/', {NUC.filnms.name});
if isempty(NUC.filnms)
    msgbox('You are not in a directory with sorted images... Try again')
    return
end
 
%Create a structure for each of the channels
for i = 1:handles.numCh
    chnm = ['CH_' num2str(i)];
    Cyto.(chnm).dir = chnm;
    Cyto.(chnm).filnms = dir([handles.expDir filesep chnm filesep '*' handles.imExt]);
    Cyto.(chnm).filnms = strcat(handles.expDir, '/',chnm, '/', {Cyto.(chnm).filnms.name});
    if (handles.cidrecorrect)
       Cyto.(chnm).CIDREmodel.v = csvread([handles.cidreDir filesep 'cidre_model_v.csv']);
       Cyto.(chnm).CIDREmodel.z = csvread([handles.cidreDir filesep 'cidre_model_z.csv']);
    end
end
 
%Correct directory listings based on the number in the image file between the - -
%eg the 1428 in the file name 20150901141237-1428-R05-C04.jpg
%This is necessary due to matlab dir command sorting placing 1000 ahead of
%999.
for i = 1:size(NUC.filnms,2)
    str = (NUC.filnms{i});idx = strfind(str,'-');
    val(i,1) = str2num(str(idx(1)+1:idx(2)-1));
end
for j = 1:handles.numCh
    for i = 1:size(NUC.filnms,2)
         chnm = ['CH_' num2str(j)];
         str = (Cyto.(chnm).filnms{i}); idx = strfind(str,'-'); 
         val(i,j+1) = str2num(str(idx(1)+1:idx(2)-1));
    end
end
[temp idx] = sort(val);
NUC.filnms = {NUC.filnms{idx(:,1)}};
for i = 1:handles.numCh
    chnm = ['CH_' num2str(i)];
    Cyto.(chnm).filnms = {Cyto.(chnm).filnms{idx(:,i+1)}};
end
 
handles.NUC = NUC;
handles.Cyto = Cyto;

%Load the image processing parameters from the handles structure into the correct variables
imExt = handles.imExt;
%experiment Directory
expDir = handles.expDir;
%Whether to correct with cidrecorrect
cidrecorrect = handles.cidrecorrect;
%Number of levels used in otsu's method of thresholding
NucnumLevel = handles.NucnumLevel;
CytonumLevel = handles.CytonumLevel;
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
%NOise disk for nuclei
nuc_noise_disk = handles.nuc_noise_disk;
%Smoothing factor for cytoplasm segmentation.  (-) means to erode image
smoothing_factor = handles.smoothing_factor;
%Number of channels in the image
numCh = handles.numCh;
%Segmentation height for nuclei in the watershed segmentation
NucSegHeight = handles.NucSegHeight;
%Structure to hold the filenames and segmentation results
NUC = handles.NUC;
Cyto = handles.Cyto;


%Need several of the functions in the SegmenterV1 folder.  Add it to the
%functions path using addpath() function or permenantly in home->set path

%Initialize functions involved in parallel computing
%Parfor_progress allows for an estimation of the amount of time remaining
%in each segmentation
%Par() is a class variable which records information about the parallel
%processing session and allows the measurement of time to complete each
%iteration.
%Both have been adapted from online code.
% http://www.mathworks.com/matlabcentral/fileexchange/32101-progress-monitor--progress-bar--that-works-with-parfor
% http://www.mathworks.com/matlabcentral/fileexchange/27472-partictoc/content/Par.m
% Respectively
parfor_progress(size(NUC.filnms,2),[],[]);ParallelPoolInfo = Par(size(NUC.filnms,2));
%For all images
parfor i = 1:size(NUC.filnms,2)
    Par.tic;
    %Send to segmenter code
    [CO,Im_array] = NaiveSegmentV3(imExt,cidrecorrect,numLevels,surface_segment,nuclear_segment,noise_disk,...
        nuclear_segment_factor,surface_segment_factor,cl_border,smoothing_factor,NucSegHeight,numCh,NUC,Cyto,i)
    %Save segmentation in a directory called segmented
    %Call a function to be able to save result
    parforsaverGUI(CO.rw,CO.cl,CO,i,expDir)
    ParallelPoolInfo(i) = Par.toc
    %Update the status of the segmentation.
    parfor_progress([],ParallelPoolInfo(i).ItStop-ParallelPoolInfo(i).ItStart,i);
    %save(['Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
    %Delete the stored variables... Not sure if this is necessary
    CO=structfun(@(f)[] ,CO,'uni',0);
    Im_array = [];
end
stop(ParallelPoolInfo)
parfor_progress(0,[],[]);
disp('We are finishing up processing...just a little more to go...(~2min)')
%Next we want to label all the segmented cells as nucleus, new born,
%oversegmented (too many in a single cell), undersegmented (multiple cells
%called 1) ect.  To do this we do a first pass based on nuclear size.
%This annotation is filled out in the baysian segmenter portion.

%Open all the segmented images and compile the statistics on nuclear
%size
seg_file = dir([handles.expDir filesep 'Segmented/*.mat']);
Area = [];
for i = 1:size(seg_file,1)
    load([handles.expDir filesep 'Segmented/' seg_file(i).name])
    Area = [Area, CO.Nuc.Area(CO.Nuc.Area~=0 & ~CO.class.edge)];
end
%Take the log of the area to normalize the data
logDist = log(Area);
avg_dist = mean(logDist);
std_dist = std(logDist);
%Now classify based on nuclear size
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
    if CO.cellCount == 0
        CO.class.debris    	= 0;
        CO.class.nucleus   	= 0;
        CO.class.over      	= 0;
        CO.class.under     	= 0;
        CO.class.predivision	= 0;
        CO.class.postdivision	= 0;
        CO.class.apoptotic 	= 0;
        CO.class.newborn   	= 0;
    else
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
            if ~CO.class.edge(k)
                if(log(CO.Nuc.Area(k)) < avg_dist-3*std_dist)    
                  CO.class.debris(k) 	= 1;
                elseif(log(CO.Nuc.Area(k)) < avg_dist-1.5*std_dist) 
                  CO.class.newborn(k) 	= 1;
                  CO.class.nucleus(k) 	= 1;
                elseif(log(CO.Nuc.Area(k))  < avg_dist+1.8*std_dist)  
                  CO.class.nucleus(k) 	= 1;
                else
                  CO.class.under(k) 	= 1;
                end
            end
        end
    end
    save([handles.expDir filesep 'Segmented/' seg_file(i).name], 'CO')
    clear CO
end
close(h)

