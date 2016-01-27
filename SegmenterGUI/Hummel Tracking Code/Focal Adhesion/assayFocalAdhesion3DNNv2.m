function []=assayFocalAdhesions3DNN()
%assayFocalAdhesions3DNN - This module is used to track fluorescent focal adhesions in 3-D. It saves 
%    a set of images that display the outlines of the 
%detected  FAs  as  well  as the ID of each individual 
%FA overlyed  over the  original image.  The assay  also saves 
%the position and  integrated intensity for  each detected FA  in a 
%comma-delimited  file. ImageDirectory  - String variable that  specifies the   
%  absolute location of   the directory which     
%contains the    time-lapse  images. An   example   
%of such a  string variable   would   be  'c:/sample 
%  images/high-density'. ImageRoot - String variable     specifying the root 
% image file    name. The root    image  
%file name   for   a set   of images  
%is the  image  file name      of any 
% of the    images without   the number   
%or the file extension.  For  example,  if the    
%file name      is  'Experiment-0002_Position(8)_t021.tif' the  root  
% image file name will  be 'Experiment-0002_Position(8)_t'. StartFrame - Number   specifying 
%   the first image  in the sequence  to be  
%analyzed.        The minimum  value  for 
%this variable depends   on  the   numbering   of 
%the  image    sequence so  if   the  
% first  image in  the  sequence is  'image003.tif'   
% then the   minimum  value   is 3.  FrameCount 
%- Number   specifying  how   many images  from  
% the image   sequence  should  be processed. TimeFrame   
% -  Number specifying  the time    between  consecutive 
%images in    minutes.  FrameStep -    Number  
%specifying the step size when     reading images.  Set  
%this variable    to  1   to   read 
%every  image in    the  sequence,  2 to  
%read every    other image and    so   
%  on. NumberFormat  -  String value specifying the   number 
%  of   digits   in the  image file names 
%    in  the sequence.  For example    
% if the     image file name is 'image020.jpg'  the 
%value for          the NumberFormat is 
%'%03d', while  if the  file name      is 
%'image000020.jpg'    the value  should  be '%06d'.  MaxMissingFrames - 
%    Number specifying for    how    
%many frames a  cell  may   be disappear before its  
%   track is       ended. OutputDirectory  
%- The folder  where the overlayed  images   and track data 
%   will     be saved. By    
%default  this value  is set  to   a  folder 
%named     'Output' within    the folder where  
% the  images   to be analyzed are   located.  
% BrightnessThresholdPct   -   Number   specifying the percentage  
%threshold  a pixel  has to be brighter than pixels  in its 
%neighborhood   to be assigned as a  FA pixel. MinFAArea -  
% Number specifying   the minimum area for a FA. Objects  smaller 
%than this value   will  not be considered FAs. MaxFAArea -  
% Number specifying  the  maximum area for a FA. Objects greater than 
%this value  will  not  be considered FAs. GlobalIntensityThresh - Percentage value 
%that  determines if a    pixel is assigned as being part 
%of the cytoplasm or part  of the    background. GaussStdDev - 
%The standard deviation of the Gaussian kernel  used  to blur the image 
%for processing. The kernel size of the Gaussian  function  used to blur 
%the image.

global functions_list;
functions_list=[];
%script variables
ImageDirectory='~/Dropbox/Josh/Cells to analyze/Individual timepoint stacks/Cell 01 110712 GFP-Vinc';
Output='~/Dropbox/Josh/Cells to analyze/';
ImageRoot='Cell 01_w1Live GFP_t';
StartFrame=1;
FrameCount=22;
TimeFrame=1;
FrameStep=1;
NumberFormat='%02d';
ImageExtension='.TIF';
MaxMissingFrames=3;
OutputDirectory=[Output 'OutputTest/'];
BrightnessThresholdPct=1.75;
GlobalIntensityThresh=0.4;
MinFAArea=20;
MaxFAArea=500;
GaussStdDev=0.4;
GaussKernSize=5;
ShowIDs=true;
%end script variables

AssignCellsToTrackLoopLoopFunctions=[];
ifisfirstlabelelsefunctions=[];
ifisfirstlabeliffunctions=[];
SegmentationLoopLoopFunctions=[];

loadtrackslayout.InstanceName='LoadTracksLayout';
loadtrackslayout.FunctionHandle=@loadTracksLayout;
loadtrackslayout.FunctionArgs.FileName.Value='tracks_layout_fa_3dv2.mat';
functions_list=addToFunctionChain(functions_list,loadtrackslayout);

makeoutputfolder.InstanceName='MakeOutputFolder';
makeoutputfolder.FunctionHandle=@mkdir_Wrapper;
makeoutputfolder.FunctionArgs.DirectoryName.Value=OutputDirectory;
functions_list=addToFunctionChain(functions_list,makeoutputfolder);

displaycurframe.InstanceName='DisplayCurFrame';
displaycurframe.FunctionHandle=@displayVariable;
displaycurframe.FunctionArgs.VariableName.Value='Current Tracking Frame';
displaycurframe.FunctionArgs.Variable.FunctionInstance='SegmentationLoop';
displaycurframe.FunctionArgs.Variable.OutputArg='LoopCounter';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,displaycurframe);

makeimagename.InstanceName='MakeImageName';
makeimagename.FunctionHandle=@makeImgFileName;
makeimagename.FunctionArgs.FileBase.Value=[ImageDirectory '/' ImageRoot];
makeimagename.FunctionArgs.FileExt.Value=ImageExtension;
makeimagename.FunctionArgs.NumberFmt.Value=NumberFormat;
makeimagename.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
makeimagename.FunctionArgs.CurFrame.OutputArg='LoopCounter';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,makeimagename);

read3dimage.InstanceName='Read3DImage';
read3dimage.FunctionHandle=@readImage3D;
read3dimage.FunctionArgs.ImageChannel.Value='';
read3dimage.FunctionArgs.ImageName.FunctionInstance='MakeImageName';
read3dimage.FunctionArgs.ImageName.OutputArg='FileName';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,read3dimage);

normalizeimageto16bit.InstanceName='NormalizeImageTo16Bit';
normalizeimageto16bit.FunctionHandle=@imNorm;
normalizeimageto16bit.FunctionArgs.IntegerClass.Value='uint16';
normalizeimageto16bit.FunctionArgs.RawImage.FunctionInstance='Read3DImage';
normalizeimageto16bit.FunctionArgs.RawImage.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,normalizeimageto16bit);

gaussianfilter.InstanceName='GaussianFilter';
gaussianfilter.FunctionHandle=@gaussianFilter;
gaussianfilter.FunctionArgs.KernelSize.Value=GaussKernSize;
gaussianfilter.FunctionArgs.StandardDev.Value=GaussStdDev;
gaussianfilter.FunctionArgs.Image.FunctionInstance='Read3DImage';
gaussianfilter.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,gaussianfilter);

normalizefilteredimageto16bit.InstanceName='NormalizeFilteredImageTo16Bit';
normalizefilteredimageto16bit.FunctionHandle=@imNorm;
normalizefilteredimageto16bit.FunctionArgs.IntegerClass.Value='uint16';
normalizefilteredimageto16bit.FunctionArgs.RawImage.FunctionInstance='GaussianFilter';
normalizefilteredimageto16bit.FunctionArgs.RawImage.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,normalizefilteredimageto16bit);

localaveragefilter.InstanceName='LocalAverageFilter';
localaveragefilter.FunctionHandle=@generateBinImgUsingLocAvg3D;
localaveragefilter.FunctionArgs.BrightnessThresholdPct.Value=BrightnessThresholdPct;
localaveragefilter.FunctionArgs.Strel.Value='disk';
localaveragefilter.FunctionArgs.StrelSize.Value=10;
localaveragefilter.FunctionArgs.Image.FunctionInstance='NormalizeFilteredImageTo16Bit';
localaveragefilter.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,localaveragefilter);

frequencyfilter.InstanceName='FrequencyFilter';
frequencyfilter.FunctionHandle=@butterworthFreqFilter3D;
frequencyfilter.FunctionArgs.CutOffFreq.Value=10;
frequencyfilter.FunctionArgs.FilterOrder.Value=6;
frequencyfilter.FunctionArgs.FilterType.Value='LowPass';
frequencyfilter.FunctionArgs.Image.FunctionInstance='GaussianFilter';
frequencyfilter.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,frequencyfilter);

flattenbackground.InstanceName='FlattenBackground';
flattenbackground.FunctionHandle=@divideFunction;
flattenbackground.FunctionArgs.ConvertToDouble.Value=true;
flattenbackground.FunctionArgs.Var1.FunctionInstance='GaussianFilter';
flattenbackground.FunctionArgs.Var1.OutputArg='Image';
flattenbackground.FunctionArgs.Var2.FunctionInstance='FrequencyFilter';
flattenbackground.FunctionArgs.Var2.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,flattenbackground);

intensityfilter.InstanceName='IntensityFilter';
intensityfilter.FunctionHandle=@generateBinImgUsingGlobInt3D;
intensityfilter.FunctionArgs.IntensityThresholdPct.Value=GlobalIntensityThresh;
intensityfilter.FunctionArgs.Image.FunctionInstance='NormalizeFilteredImageTo16Bit';
intensityfilter.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,intensityfilter);

clearnoncell.InstanceName='ClearNonCell';
clearnoncell.FunctionHandle=@clearSmallObjects;
clearnoncell.FunctionArgs.MinObjectArea.Value=5000;
clearnoncell.FunctionArgs.Image.FunctionInstance='IntensityFilter';
clearnoncell.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,clearnoncell);

combineimages.InstanceName='CombineImages';
combineimages.FunctionHandle=@combineImages;
combineimages.FunctionArgs.CombineOperation.Value='AND';
combineimages.FunctionArgs.Image1.FunctionInstance='LocalAverageFilter';
combineimages.FunctionArgs.Image1.OutputArg='Image';
combineimages.FunctionArgs.Image2.FunctionInstance='ClearNonCell';
combineimages.FunctionArgs.Image2.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,combineimages);

clearborder.InstanceName='ClearBorder';
clearborder.FunctionHandle=@imclearborderSlices;
clearborder.FunctionArgs.Image.FunctionInstance='CombineImages';
clearborder.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,clearborder);

clearsmallobjects.InstanceName='ClearSmallObjects';
clearsmallobjects.FunctionHandle=@clearSmallObjects;
clearsmallobjects.FunctionArgs.MinObjectArea.Value=MinFAArea;
clearsmallobjects.FunctionArgs.Image.FunctionInstance='ClearBorder';
clearsmallobjects.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,clearsmallobjects);

labelfocaladhesions.InstanceName='LabelFocalAdhesions';
labelfocaladhesions.FunctionHandle=@labelObjects;
labelfocaladhesions.FunctionArgs.Image.FunctionInstance='ClearSmallObjects';
labelfocaladhesions.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,labelfocaladhesions);

areafilter.InstanceName='AreaFilter';
areafilter.FunctionHandle=@areaFilterLabel;
areafilter.FunctionArgs.MaxArea.Value=MaxFAArea;
areafilter.FunctionArgs.ObjectsLabel.FunctionInstance='LabelFocalAdhesions';
areafilter.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,areafilter);

getcentroids.InstanceName='GetCentroids';
getcentroids.FunctionHandle=@getCentroids3D;
getcentroids.FunctionArgs.LabelMatrix.FunctionInstance='AreaFilter';
getcentroids.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,getcentroids);

getfasintegratedintensities.InstanceName='GetFAsIntegratedIntensities';
getfasintegratedintensities.FunctionHandle=@getIntegratedIntensitiesv2;
getfasintegratedintensities.FunctionArgs.IntensityImage.FunctionInstance='FlattenBackground';
getfasintegratedintensities.FunctionArgs.IntensityImage.OutputArg='Quotient';
getfasintegratedintensities.FunctionArgs.ObjectsLabel.FunctionInstance='AreaFilter';
getfasintegratedintensities.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,getfasintegratedintensities);

%
% Used to get the number of z-planes in a 3D image
getplanes.InstanceName='GetPlanes';
getplanes.FunctionHandle=@getPlaneNumber;
getplanes.FunctionArgs.Image.FunctionInstance='Read3DImage';
getplanes.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,getplanes);
%
%

isemptylabel.InstanceName='IsEmptyLabel';
isemptylabel.FunctionHandle=@isEmptyFunction;
isemptylabel.FunctionArgs.TestVariable.Value=[];
isemptylabel.FunctionArgs.TestVariable.FunctionInstance='SaveFAsLabel';
isemptylabel.FunctionArgs.TestVariable.OutputArg='CellsLabel';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,isemptylabel);

getcurrenttracks.InstanceName='GetCurrentTracks';
getcurrenttracks.FunctionHandle=@getCurrentTracks;
getcurrenttracks.FunctionArgs.FrameStep.Value=FrameStep;
getcurrenttracks.FunctionArgs.MaxMissingFrames.Value=MaxMissingFrames;
getcurrenttracks.FunctionArgs.OffsetFrame.Value=-1;
getcurrenttracks.FunctionArgs.TimeCol.Value=2;
getcurrenttracks.FunctionArgs.TimeFrame.Value=TimeFrame;
getcurrenttracks.FunctionArgs.TrackIDCol.Value=1;
getcurrenttracks.FunctionArgs.Tracks.FunctionInstance='StartTracks';
getcurrenttracks.FunctionArgs.Tracks.OutputArg='Tracks';
getcurrenttracks.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
getcurrenttracks.FunctionArgs.Tracks.OutputArg2='Tracks';
getcurrenttracks.FunctionArgs.CurFrame.FunctionInstance='IfIsFirstLabel';
getcurrenttracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,getcurrenttracks);

getprevioustracks.InstanceName='GetPreviousTracks';
getprevioustracks.FunctionHandle=@getCurrentTracks;
getprevioustracks.FunctionArgs.FrameStep.Value=FrameStep;
getprevioustracks.FunctionArgs.MaxMissingFrames.Value=MaxMissingFrames;
getprevioustracks.FunctionArgs.OffsetFrame.Value=-2;
getprevioustracks.FunctionArgs.TimeCol.Value=2;
getprevioustracks.FunctionArgs.TimeFrame.Value=TimeFrame;
getprevioustracks.FunctionArgs.TrackIDCol.Value=1;
getprevioustracks.FunctionArgs.Tracks.FunctionInstance='StartTracks';
getprevioustracks.FunctionArgs.Tracks.OutputArg='Tracks';
getprevioustracks.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
getprevioustracks.FunctionArgs.Tracks.OutputArg2='Tracks';
getprevioustracks.FunctionArgs.CurFrame.FunctionInstance='IfIsFirstLabel';
getprevioustracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,getprevioustracks);

makeunassignedcellslist.InstanceName='MakeUnassignedCellsList';
makeunassignedcellslist.FunctionHandle=@makeUnassignedCellsList;
makeunassignedcellslist.FunctionArgs.CellsCentroids.FunctionInstance='IfIsFirstLabel';
makeunassignedcellslist.FunctionArgs.CellsCentroids.InputArg='GetCentroids_Centroids';
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,makeunassignedcellslist);

makeexcludedtrackslist.InstanceName='MakeExcludedTracksList';
makeexcludedtrackslist.FunctionHandle=@makeExcludedTracksList;
makeexcludedtrackslist.FunctionArgs.UnassignedCellsIDs.FunctionInstance='MakeUnassignedCellsList';
makeexcludedtrackslist.FunctionArgs.UnassignedCellsIDs.OutputArg='UnassignedCellsIDs';
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,makeexcludedtrackslist);

getmaxtrackid.InstanceName='GetMaxTrackID';
getmaxtrackid.FunctionHandle=@getMaxTrackID;
getmaxtrackid.FunctionArgs.TrackIDCol.Value=1;
getmaxtrackid.FunctionArgs.Tracks.FunctionInstance='StartTracks';
getmaxtrackid.FunctionArgs.Tracks.OutputArg='Tracks';
getmaxtrackid.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
getmaxtrackid.FunctionArgs.Tracks.OutputArg2='Tracks';
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,getmaxtrackid);

isnotemptyunassignedlist.InstanceName='IsNotEmptyUnassignedList';
isnotemptyunassignedlist.FunctionHandle=@isNotEmptyFunction;
isnotemptyunassignedlist.FunctionArgs.TestVariable.FunctionInstance='AssignFAsToTracks';
isnotemptyunassignedlist.FunctionArgs.TestVariable.OutputArg='UnassignedIDs';
isnotemptyunassignedlist.FunctionArgs.TestVariable.FunctionInstance2='AssignCellsToTrackLoop';
isnotemptyunassignedlist.FunctionArgs.TestVariable.InputArg2='MakeUnassignedCellsList_UnassignedCellsIDs';
AssignCellsToTrackLoopLoopFunctions=addToFunctionChain(AssignCellsToTrackLoopLoopFunctions,isnotemptyunassignedlist);

getcurrentunassignedcell.InstanceName='GetCurrentUnassignedCell';
getcurrentunassignedcell.FunctionHandle=@getCurrentUnassignedCell;
getcurrentunassignedcell.FunctionArgs.UnassignedCells.FunctionInstance='AssignFAsToTracks';
getcurrentunassignedcell.FunctionArgs.UnassignedCells.OutputArg='UnassignedIDs';
getcurrentunassignedcell.FunctionArgs.UnassignedCells.FunctionInstance2='AssignCellsToTrackLoop';
getcurrentunassignedcell.FunctionArgs.UnassignedCells.InputArg2='MakeUnassignedCellsList_UnassignedCellsIDs';
AssignCellsToTrackLoopLoopFunctions=addToFunctionChain(AssignCellsToTrackLoopLoopFunctions,getcurrentunassignedcell);

assignfastotracks.InstanceName='AssignFAsToTracks';
assignfastotracks.FunctionHandle=@assignCellToTrackUsingNN_3D;
assignfastotracks.FunctionArgs.TrackAssignments.Value=[];
assignfastotracks.FunctionArgs.TrackAssignments.FunctionInstance='AssignFAsToTracks';
assignfastotracks.FunctionArgs.TrackAssignments.OutputArg='TrackAssignments';
assignfastotracks.FunctionArgs.UnassignedCells.FunctionInstance='AssignFAsToTracks';
assignfastotracks.FunctionArgs.UnassignedCells.OutputArg='UnassignedIDs';
assignfastotracks.FunctionArgs.CellsCentroids.FunctionInstance='AssignCellsToTrackLoop';
assignfastotracks.FunctionArgs.CellsCentroids.InputArg='GetCentroids_Centroids';
assignfastotracks.FunctionArgs.CurrentTracks.FunctionInstance='AssignCellsToTrackLoop';
assignfastotracks.FunctionArgs.CurrentTracks.InputArg='GetCurrentTracks_Tracks';
assignfastotracks.FunctionArgs.MaxTrackID.FunctionInstance='AssignCellsToTrackLoop';
assignfastotracks.FunctionArgs.MaxTrackID.InputArg='GetMaxTrackID_MaxTrackID';
assignfastotracks.FunctionArgs.TracksLayout.FunctionInstance='AssignCellsToTrackLoop';
assignfastotracks.FunctionArgs.TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
assignfastotracks.FunctionArgs.UnassignedCells.FunctionInstance2='AssignCellsToTrackLoop';
assignfastotracks.FunctionArgs.UnassignedCells.InputArg2='MakeUnassignedCellsList_UnassignedCellsIDs';
AssignCellsToTrackLoopLoopFunctions=addToFunctionChain(AssignCellsToTrackLoopLoopFunctions,assignfastotracks);

assigncellstotrackloop.InstanceName='AssignCellsToTrackLoop';
assigncellstotrackloop.FunctionHandle=@whileLoop;
assigncellstotrackloop.FunctionArgs.TestFunction.FunctionInstance='IsNotEmptyUnassignedList';
assigncellstotrackloop.FunctionArgs.TestFunction.OutputArg='Boolean';
assigncellstotrackloop.FunctionArgs.MakeUnassignedCellsList_UnassignedCellsIDs.FunctionInstance='MakeUnassignedCellsList';
assigncellstotrackloop.FunctionArgs.MakeUnassignedCellsList_UnassignedCellsIDs.OutputArg='UnassignedCellsIDs';
assigncellstotrackloop.FunctionArgs.GetCurrentTracks_Tracks.FunctionInstance='GetCurrentTracks';
assigncellstotrackloop.FunctionArgs.GetCurrentTracks_Tracks.OutputArg='Tracks';
assigncellstotrackloop.FunctionArgs.GetMaxTrackID_MaxTrackID.FunctionInstance='GetMaxTrackID';
assigncellstotrackloop.FunctionArgs.GetMaxTrackID_MaxTrackID.OutputArg='MaxTrackID';
assigncellstotrackloop.FunctionArgs.GetCentroids_Centroids.FunctionInstance='IfIsFirstLabel';
assigncellstotrackloop.FunctionArgs.GetCentroids_Centroids.InputArg='GetCentroids_Centroids';
assigncellstotrackloop.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='IfIsFirstLabel';
assigncellstotrackloop.FunctionArgs.LoadTracksLayout_TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
assigncellstotrackloop.KeepValues.AssignFAsToTracks_TrackAssignments.FunctionInstance='AssignFAsToTracks';
assigncellstotrackloop.KeepValues.AssignFAsToTracks_TrackAssignments.OutputArg='TrackAssignments';
assigncellstotrackloop.LoopFunctions=AssignCellsToTrackLoopLoopFunctions;
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,assigncellstotrackloop);

continuetracks.InstanceName='ContinueTracks';
continuetracks.FunctionHandle=@continueTracks;
continuetracks.FunctionArgs.TimeFrame.Value=TimeFrame;
continuetracks.FunctionArgs.Tracks.FunctionInstance='StartTracks';
continuetracks.FunctionArgs.Tracks.OutputArg='Tracks';
continuetracks.FunctionArgs.Tracks.FunctionInstance2='ContinueTracks';
continuetracks.FunctionArgs.Tracks.OutputArg2='Tracks';
continuetracks.FunctionArgs.TrackAssignments.FunctionInstance='AssignCellsToTrackLoop';
continuetracks.FunctionArgs.TrackAssignments.OutputArg='AssignFAsToTracks_TrackAssignments';
continuetracks.FunctionArgs.CellsCentroids.FunctionInstance='IfIsFirstLabel';
continuetracks.FunctionArgs.CellsCentroids.InputArg='GetCentroids_Centroids';
continuetracks.FunctionArgs.CurFrame.FunctionInstance='IfIsFirstLabel';
continuetracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
continuetracks.FunctionArgs.ShapeParameters.FunctionInstance='IfIsFirstLabel';
continuetracks.FunctionArgs.ShapeParameters.InputArg='GetFAsIntegratedIntensities_IntegratedIntensities';
%
continuetracks.FunctionArgs.ShapeParameter_Area.FunctionInstance='IfIsFirstLabel';
continuetracks.FunctionArgs.ShapeParameter_Area.InputArg='GetFAsIntegratedIntensities_Area';
% 
% continuetracks.FunctionArgs.SliceNumber.FunctionInstance='StartTracks';
% continuetracks.FunctionArgs.SliceNumber.OutputArg='SliceNumber';
% continuetracks.FunctionArgs.SliceNumber.FunctionInstance2='ContinueTracks';
% continuetracks.FunctionArgs.SliceNumber.OutputArg2='NewSliceNumber';
%
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,continuetracks);

displaytracks.InstanceName='DisplayTracks';
displaytracks.FunctionHandle=@displayTracksData3D;
displaytracks.FunctionArgs.FileRoot.Value=[OutputDirectory '/' ImageRoot];
displaytracks.FunctionArgs.NumberFormat.Value=NumberFormat;
displaytracks.FunctionArgs.TextSize.Value=0.5;
displaytracks.FunctionArgs.ShowIDs.Value=ShowIDs;
displaytracks.FunctionArgs.CurrentTracks.FunctionInstance='ContinueTracks';
displaytracks.FunctionArgs.CurrentTracks.OutputArg='NewTracks';
displaytracks.FunctionArgs.CurFrame.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
displaytracks.FunctionArgs.Image.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.Image.InputArg='NormalizeImageTo16Bit_Image';
displaytracks.FunctionArgs.ObjectsLabel.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.ObjectsLabel.InputArg='AreaFilter_LabelMatrix';
displaytracks.FunctionArgs.TracksLayout.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
displaytracks.FunctionArgs.Adhesion_ID.FunctionInstance='ContinueTracks';
displaytracks.FunctionArgs.Adhesion_ID.OutputArg='FA_IDs';
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,displaytracks);

starttracks.InstanceName='StartTracks';
starttracks.FunctionHandle=@startTracks3D;
starttracks.FunctionArgs.TimeFrame.Value=TimeFrame;
starttracks.FunctionArgs.CurFrame.FunctionInstance='IfIsFirstLabel';
starttracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
starttracks.FunctionArgs.ObjectCentroids.FunctionInstance='IfIsFirstLabel';
starttracks.FunctionArgs.ObjectCentroids.InputArg='GetCentroids_Centroids';
starttracks.FunctionArgs.ShapeParameters.FunctionInstance='IfIsFirstLabel';
starttracks.FunctionArgs.ShapeParameters.InputArg='GetFAsIntegratedIntensities_IntegratedIntensities';
%
starttracks.FunctionArgs.ShapeParameter_Area.FunctionInstance='IfIsFirstLabel';
starttracks.FunctionArgs.ShapeParameter_Area.InputArg='GetFAsIntegratedIntensities_Area';
%
starttracks.FunctionArgs.SliceNumber.FunctionInstance='IfIsFirstLabel';
starttracks.FunctionArgs.SliceNumber.InputArg='SliceNumber';
%
ifisfirstlabeliffunctions=addToFunctionChain(ifisfirstlabeliffunctions,starttracks);

displayinitialtracks.InstanceName='DisplayInitialTracks';
displayinitialtracks.FunctionHandle=@displayTracksData3D;
displayinitialtracks.FunctionArgs.FileRoot.Value=[OutputDirectory '/' ImageRoot];
displayinitialtracks.FunctionArgs.NumberFormat.Value=NumberFormat;
displayinitialtracks.FunctionArgs.TextSize.Value=0.5;
displayinitialtracks.FunctionArgs.ShowIDs.Value=ShowIDs;
displayinitialtracks.FunctionArgs.CurrentTracks.FunctionInstance='StartTracks';
displayinitialtracks.FunctionArgs.CurrentTracks.OutputArg='Tracks';
displayinitialtracks.FunctionArgs.CurFrame.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
displayinitialtracks.FunctionArgs.Image.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.Image.InputArg='NormalizeImageTo16Bit_Image';
displayinitialtracks.FunctionArgs.ObjectsLabel.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.ObjectsLabel.InputArg='AreaFilter_LabelMatrix';
displayinitialtracks.FunctionArgs.TracksLayout.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
ifisfirstlabeliffunctions=addToFunctionChain(ifisfirstlabeliffunctions,displayinitialtracks);

ifisfirstlabel.InstanceName='IfIsFirstLabel';
ifisfirstlabel.FunctionHandle=@if_statement;
ifisfirstlabel.FunctionArgs.TestVariable.FunctionInstance='IsEmptyLabel';
ifisfirstlabel.FunctionArgs.TestVariable.OutputArg='Boolean';
ifisfirstlabel.FunctionArgs.SegmentationLoop_LoopCounter.FunctionInstance='SegmentationLoop';
ifisfirstlabel.FunctionArgs.SegmentationLoop_LoopCounter.OutputArg='LoopCounter';
ifisfirstlabel.FunctionArgs.GetCentroids_Centroids.FunctionInstance='GetCentroids';
ifisfirstlabel.FunctionArgs.GetCentroids_Centroids.OutputArg='Centroids';
ifisfirstlabel.FunctionArgs.GetFAsIntegratedIntensities_IntegratedIntensities.FunctionInstance='GetFAsIntegratedIntensities';
ifisfirstlabel.FunctionArgs.GetFAsIntegratedIntensities_IntegratedIntensities.OutputArg='IntegratedIntensities';
%
ifisfirstlabel.FunctionArgs.GetFAsIntegratedIntensities_Area.FunctionInstance='GetFAsIntegratedIntensities';
ifisfirstlabel.FunctionArgs.GetFAsIntegratedIntensities_Area.OutputArg='ShapeParameters';
%
ifisfirstlabel.FunctionArgs.SliceNumber.FunctionInstance='GetPlanes';
ifisfirstlabel.FunctionArgs.SliceNumber.OutputArg='slicenumber';
%
ifisfirstlabel.FunctionArgs.NormalizeImageTo16Bit_Image.FunctionInstance='NormalizeImageTo16Bit';
ifisfirstlabel.FunctionArgs.NormalizeImageTo16Bit_Image.OutputArg='Image';
ifisfirstlabel.FunctionArgs.AreaFilter_LabelMatrix.FunctionInstance='AreaFilter';
ifisfirstlabel.FunctionArgs.AreaFilter_LabelMatrix.OutputArg='LabelMatrix';
ifisfirstlabel.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='SegmentationLoop';
ifisfirstlabel.FunctionArgs.LoadTracksLayout_TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
ifisfirstlabel.KeepValues.ContinueTracks_Tracks.FunctionInstance='ContinueTracks';
ifisfirstlabel.KeepValues.ContinueTracks_Tracks.OutputArg='Tracks';
%
ifisfirstlabel.KeepValues.SliceNumber_Total.FunctionInstance='ContinueTracks';
ifisfirstlabel.KeepValues.SliceNumber_Total.OutputArg='SliceNumber';
%
ifisfirstlabel.ElseFunctions=ifisfirstlabelelsefunctions;
ifisfirstlabel.IfFunctions=ifisfirstlabeliffunctions;
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,ifisfirstlabel);

savefaslabel.InstanceName='SaveFAsLabel';
savefaslabel.FunctionHandle=@saveCellsLabel;
savefaslabel.FunctionArgs.FileRoot.Value=[OutputDirectory '/' ImageRoot];
savefaslabel.FunctionArgs.NumberFormat.Value=NumberFormat;
savefaslabel.FunctionArgs.CellsLabel.FunctionInstance='AreaFilter';
savefaslabel.FunctionArgs.CellsLabel.OutputArg='LabelMatrix';
savefaslabel.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
savefaslabel.FunctionArgs.CurFrame.OutputArg='LoopCounter';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,savefaslabel);

segmentationloop.InstanceName='SegmentationLoop';
segmentationloop.FunctionHandle=@forLoop;
segmentationloop.FunctionArgs.EndLoop.Value=(StartFrame+FrameCount-1)*FrameStep;
segmentationloop.FunctionArgs.IncrementLoop.Value=FrameStep;
segmentationloop.FunctionArgs.StartLoop.Value=StartFrame;
segmentationloop.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='LoadTracksLayout';
segmentationloop.FunctionArgs.LoadTracksLayout_TracksLayout.OutputArg='TracksLayout';
segmentationloop.KeepValues.ContinueTracks_Tracks.FunctionInstance='IfIsFirstLabel';
segmentationloop.KeepValues.ContinueTracks_Tracks.OutputArg='ContinueTracks_Tracks';
%
segmentationloop.KeepValues.SliceNumber_Total.FunctionInstance='IfIsFirstLabel';
segmentationloop.KeepValues.SliceNumber_Total.OutputArg='SliceNumber_Total';
%
segmentationloop.LoopFunctions=SegmentationLoopLoopFunctions;
functions_list=addToFunctionChain(functions_list,segmentationloop);

savetracks.InstanceName='SaveTracks';
savetracks.FunctionHandle=@saveTracks;
savetracks.FunctionArgs.TracksFileName.Value=[OutputDirectory '/tracks.mat'];
savetracks.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
savetracks.FunctionArgs.Tracks.OutputArg='ContinueTracks_Tracks';
functions_list=addToFunctionChain(functions_list,savetracks);

exportfadata.InstanceName='ExportFAData';
exportfadata.FunctionHandle=@saveMatrixToSpreadsheet;
exportfadata.FunctionArgs.SpreadsheetFileName.Value=[OutputDirectory '/' ImageRoot '_FAs.csv'];
exportfadata.FunctionArgs.ColumnNames.Value='Cell ID,Time,Centroid 1,Centroid 2,Centroid3,IntegratedIntensity,Area';
exportfadata.FunctionArgs.Matrix.FunctionInstance='SegmentationLoop';
exportfadata.FunctionArgs.Matrix.OutputArg='ContinueTracks_Tracks';
functions_list=addToFunctionChain(functions_list,exportfadata);


global dependencies_list;
global dependencies_index;
dependencies_list={};
dependencies_index=java.util.Hashtable;
makeDependencies([]);
runFunctions();
end