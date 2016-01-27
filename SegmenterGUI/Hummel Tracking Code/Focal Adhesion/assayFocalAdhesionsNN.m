function []=assayFocalAdhesionsNN()
%assayFocalAdhesions3DNN - This module is used to track fluorescent focal adhesions in 2-D. It saves 
%            a set 
%of  images  that  display  the  outlines  of  
%the   detected   FAs   as   well  
% as the   ID of   each individual   FA 
%overlyed   over  the   original  image.   The 
% assay   also   saves  the position   and 
% integrated intensity   for   each detected   FA  
% in a   comma-delimited    file. ImageName   - 
%  String variable that   specifies    the   
%      absolute location of    the  
%  image which          contains 
%the     time-lapse     images.  An  
%  example      of  such a   
% string variable     would       
%be  'c:/sample images/adhesionturnover.tif'. StartFrame  -  Number     
% specifying       the first  image   
% in  the sequence   to  be     
% analyzed.           The minimum 
%     value  for  this  variable depends  
%     on  the     numbering  
%  of     the   image    
% sequence so       if   the  
%   first    image in     the 
%  sequence is  'image003.tif'         
%  then the   minimum    value    
% is 3.     FrameCount   - Number   
%specifying    how        many images 
% from     the image      sequence 
%    should   be processed. TimeFrame     
%  -    Number    specifying   the 
%time     between  consecutive    images in  
%       minutes.  FrameStep -    
%   Number    specifying    the step  
%size  when      reading images.    Set 
%      this variable     to  
% 1      to    read   
% every    image  in     the  
%sequence,    2  to      read every 
%    other image   and      
% so         on.   NumberFormat 
%  -   String value specifying  the     
% number      of     digits  
% in   the     image  file names  
%      in    the   sequence that will be generated. 
%  For example        if   
%the    desired output  image   file name is  
%'image020.jpg'    the    value for     
%           the   
%NumberFormat should be  '%03d', while  if  the   file name 
% wanted     is   'image000020.jpg' 
%     the   value    should  
% be '%06d'.    MaxMissingFrames -       
%  Number    specifying  for    how  
%    many frames     a    
%cell  may    be  disappear before   its  
%       track   is    
%      ended. OutputDirectory     -  
%  The  folder  where the overlayed    images  
% and track     data       
%will       be   saved. By   
%     default    this value    
% is set  to    a    folder  
%   named      'Output' within    
%   the folder     where     
%the   images    to  be analyzed   are 
%     located.    BrightnessThresholdPct     
%-       Number    specifying the percentage 
%   threshold      a  pixel  has 
%to be brighter   than  pixels   in its   
%  neighborhood   to   be assigned  as a  
% FA  pixel. MinFAArea   -       
%Number specifying   the minimum   area  for a   
%  FA. Objects  smaller  than this value     
%will      not  be considered FAs.  MaxFAArea - 
%     Number  specifying  the     
% maximum area for a   FA. Objects  greater than   
%this value   will     not    be 
% considered FAs. GlobalIntensityThresh - Percentage value   that   determines  
%    if a    pixel is assigned   
%as being  part    of  the  cytoplasm or part 
%  of  the       background. GaussStdDev - 
%   The   standard deviation of the   Gaussian kernel 
%  used    to blur  the image   for 
% processing.  The  kernel   size of the Gaussian  function 
%  used  to blur       the image. ShowIDs - boolean value indicating
%  whether the track IDs of the detected focal adhesions should be
%  displayed in the output images.

global functions_list;
functions_list=[];
%script variables
ImageName='~/Dropbox/Josh/HT1080 Time Series-2.tif';
OutputDirectory='~/Dropbox/Josh/MatLab data/Output/';
StartFrame=1;
FrameCount=26;
TimeFrame=1;
FrameStep=1;
NumberFormat='%02d';
ImageExtension='.tif';
MaxMissingFrames=3;
BrightnessThresholdPct=1.25;
GlobalIntensityThresh=0.015;
MinFAArea=25;
MaxFAArea=500;
GaussStdDev=1;
GaussKernSize=2;
ShowIDs=false;
%end script variables

AssignCellsToTrackLoopLoopFunctions=[];
ifisfirstlabelelsefunctions=[];
ifisfirstlabeliffunctions=[];
SegmentationLoopLoopFunctions=[];

loadtrackslayout.InstanceName='LoadTracksLayout';
loadtrackslayout.FunctionHandle=@loadTracksLayout;
loadtrackslayout.FunctionArgs.FileName.Value='tracks_layout_fa_3dv2.mat';
functions_list=addToFunctionChain(functions_list,loadtrackslayout);

getimageinfo.InstanceName='GetImageInfo';
getimageinfo.FunctionHandle=@getFileInfo;
getimageinfo.FunctionArgs.PathName.Value=ImageName;
functions_list=addToFunctionChain(functions_list,getimageinfo);

makeoutputfoldername.InstanceName='MakeOutputFolderName';
makeoutputfoldername.FunctionHandle=@concatenateText;
makeoutputfoldername.FunctionArgs.Text3.Value='_Output';
makeoutputfoldername.FunctionArgs.Text1.FunctionInstance='GetImageInfo';
makeoutputfoldername.FunctionArgs.Text1.OutputArg='DirName';
makeoutputfoldername.FunctionArgs.Text2.FunctionInstance='GetImageInfo';
makeoutputfoldername.FunctionArgs.Text2.OutputArg='FileName';
functions_list=addToFunctionChain(functions_list,makeoutputfoldername);

makeoutputfolder.InstanceName='MakeOutputFolder';
makeoutputfolder.FunctionHandle=@mkdir_Wrapper;
makeoutputfolder.FunctionArgs.DirectoryName.FunctionInstance='MakeOutputFolderName';
makeoutputfolder.FunctionArgs.DirectoryName.OutputArg='String';
functions_list=addToFunctionChain(functions_list,makeoutputfolder);

makeimagesrootname.InstanceName='MakeImagesRootName';
makeimagesrootname.FunctionHandle=@concatenateText;
makeimagesrootname.FunctionArgs.Text2.Value='/';
makeimagesrootname.FunctionArgs.Text1.FunctionInstance='MakeOutputFolderName';
makeimagesrootname.FunctionArgs.Text1.OutputArg='String';
makeimagesrootname.FunctionArgs.Text3.FunctionInstance='GetImageInfo';
makeimagesrootname.FunctionArgs.Text3.OutputArg='FileName';
functions_list=addToFunctionChain(functions_list,makeimagesrootname);

displaycurframe.InstanceName='DisplayCurFrame';
displaycurframe.FunctionHandle=@displayVariable;
displaycurframe.FunctionArgs.VariableName.Value='Current Tracking Frame';
displaycurframe.FunctionArgs.Variable.FunctionInstance='SegmentationLoop';
displaycurframe.FunctionArgs.Variable.OutputArg='LoopCounter';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,displaycurframe);

readimageslice.InstanceName='ReadImageSlice';
readimageslice.FunctionHandle=@readImageSlice;
readimageslice.FunctionArgs.ImageChannel.Value='r';
readimageslice.FunctionArgs.ImageName.Value=ImageName;
readimageslice.FunctionArgs.SliceIndex.FunctionInstance='SegmentationLoop';
readimageslice.FunctionArgs.SliceIndex.OutputArg='LoopCounter';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,readimageslice);

normalizeimageto16bit.InstanceName='NormalizeImageTo16Bit';
normalizeimageto16bit.FunctionHandle=@imNorm;
normalizeimageto16bit.FunctionArgs.IntegerClass.Value='uint16';
normalizeimageto16bit.FunctionArgs.RawImage.FunctionInstance='ReadImageSlice';
normalizeimageto16bit.FunctionArgs.RawImage.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,normalizeimageto16bit);

gaussianfilter.InstanceName='GaussianFilter';
gaussianfilter.FunctionHandle=@gaussianFilter;
gaussianfilter.FunctionArgs.KernelSize.Value=GaussKernSize;
gaussianfilter.FunctionArgs.StandardDev.Value=GaussStdDev;
gaussianfilter.FunctionArgs.Image.FunctionInstance='NormalizeImageTo16Bit';
gaussianfilter.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,gaussianfilter);

normalizefilteredimageto16bit.InstanceName='NormalizeFilteredImageTo16Bit';
normalizefilteredimageto16bit.FunctionHandle=@imNorm;
normalizefilteredimageto16bit.FunctionArgs.IntegerClass.Value='uint16';
normalizefilteredimageto16bit.FunctionArgs.RawImage.FunctionInstance='GaussianFilter';
normalizefilteredimageto16bit.FunctionArgs.RawImage.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,normalizefilteredimageto16bit);

localaveragefilter.InstanceName='LocalAverageFilter';
localaveragefilter.FunctionHandle=@generateBinImgUsingLocAvg;
localaveragefilter.FunctionArgs.BrightnessThresholdPct.Value=BrightnessThresholdPct;
localaveragefilter.FunctionArgs.ClearBorder.Value=true;
localaveragefilter.FunctionArgs.ClearBorderDist.Value=1;
localaveragefilter.FunctionArgs.Strel.Value='disk';
localaveragefilter.FunctionArgs.StrelSize.Value=10;
localaveragefilter.FunctionArgs.Image.FunctionInstance='NormalizeFilteredImageTo16Bit';
localaveragefilter.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,localaveragefilter);

frequencyfilter.InstanceName='FrequencyFilter';
frequencyfilter.FunctionHandle=@butterworthFreqFilter;
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
intensityfilter.FunctionHandle=@generateBinImgUsingGlobInt;
intensityfilter.FunctionArgs.ClearBorder.Value=false;
intensityfilter.FunctionArgs.ClearBorderDist.Value=1;
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

clearsmallobjects.InstanceName='ClearSmallObjects';
clearsmallobjects.FunctionHandle=@clearSmallObjects;
clearsmallobjects.FunctionArgs.MinObjectArea.Value=MinFAArea;
clearsmallobjects.FunctionArgs.Image.FunctionInstance='CombineImages';
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
getcentroids.FunctionHandle=@getCentroids;
getcentroids.FunctionArgs.LabelMatrix.FunctionInstance='AreaFilter';
getcentroids.FunctionArgs.LabelMatrix.OutputArg='LabelMatrix';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,getcentroids);

getfasintegratedintensities.InstanceName='GetFAsIntegratedIntensities';
getfasintegratedintensities.FunctionHandle=@getIntegratedIntensities;
getfasintegratedintensities.FunctionArgs.IntensityImage.FunctionInstance='FlattenBackground';
getfasintegratedintensities.FunctionArgs.IntensityImage.OutputArg='Quotient';
getfasintegratedintensities.FunctionArgs.ObjectsLabel.FunctionInstance='AreaFilter';
getfasintegratedintensities.FunctionArgs.ObjectsLabel.OutputArg='LabelMatrix';
getfasintegratedintensities.FunctionArgs.Image.FunctionInstance='ClearSmallObjects';
getfasintegratedintensities.FunctionArgs.Image.OutputArg='Image';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,getfasintegratedintensities);

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
assignfastotracks.FunctionHandle=@assignCellToTrackUsingNN;
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
ifisfirstlabelelsefunctions=addToFunctionChain(ifisfirstlabelelsefunctions,continuetracks);

displaytracks.InstanceName='DisplayTracks';
displaytracks.FunctionHandle=@displayTracksData;
displaytracks.FunctionArgs.IDList.Value=[];
displaytracks.FunctionArgs.LabelColorRGB.Value=[0 255 0];
displaytracks.FunctionArgs.NumberFormat.Value=NumberFormat;
displaytracks.FunctionArgs.ShowIDs.Value=true;
displaytracks.FunctionArgs.CurrentTracks.FunctionInstance='ContinueTracks';
displaytracks.FunctionArgs.CurrentTracks.OutputArg='NewTracks';
displaytracks.FunctionArgs.CurFrame.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
displaytracks.FunctionArgs.Image.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.Image.InputArg='NormalizeImageTo16Bit_Image';
displaytracks.FunctionArgs.TracksLayout.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
displaytracks.FunctionArgs.FileRoot.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.FileRoot.InputArg='MakeImagesRootName_String';
displaytracks.FunctionArgs.CellsLabel.FunctionInstance='IfIsFirstLabel';
displaytracks.FunctionArgs.CellsLabel.InputArg='AreaFilter_LabelMatrix';
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
ifisfirstlabeliffunctions=addToFunctionChain(ifisfirstlabeliffunctions,starttracks);

displayinitialtracks.InstanceName='DisplayInitialTracks';
displayinitialtracks.FunctionHandle=@displayTracksData;
displayinitialtracks.FunctionArgs.LabelColorRGB.Value=[0 255 0];
displayinitialtracks.FunctionArgs.NumberFormat.Value=NumberFormat;
displayinitialtracks.FunctionArgs.ShowIDs.Value=true;
displayinitialtracks.FunctionArgs.CurrentTracks.FunctionInstance='StartTracks';
displayinitialtracks.FunctionArgs.CurrentTracks.OutputArg='Tracks';
displayinitialtracks.FunctionArgs.CurFrame.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.CurFrame.InputArg='SegmentationLoop_LoopCounter';
displayinitialtracks.FunctionArgs.Image.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.Image.InputArg='NormalizeImageTo16Bit_Image';
displayinitialtracks.FunctionArgs.TracksLayout.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
displayinitialtracks.FunctionArgs.FileRoot.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.FileRoot.InputArg='MakeImagesRootName_String';
displayinitialtracks.FunctionArgs.CellsLabel.FunctionInstance='IfIsFirstLabel';
displayinitialtracks.FunctionArgs.CellsLabel.InputArg='AreaFilter_LabelMatrix';
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
ifisfirstlabel.FunctionArgs.NormalizeImageTo16Bit_Image.FunctionInstance='NormalizeImageTo16Bit';
ifisfirstlabel.FunctionArgs.NormalizeImageTo16Bit_Image.OutputArg='Image';
ifisfirstlabel.FunctionArgs.AreaFilter_LabelMatrix.FunctionInstance='AreaFilter';
ifisfirstlabel.FunctionArgs.AreaFilter_LabelMatrix.OutputArg='LabelMatrix';
ifisfirstlabel.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='SegmentationLoop';
ifisfirstlabel.FunctionArgs.LoadTracksLayout_TracksLayout.InputArg='LoadTracksLayout_TracksLayout';
ifisfirstlabel.FunctionArgs.MakeImagesRootName_String.FunctionInstance='SegmentationLoop';
ifisfirstlabel.FunctionArgs.MakeImagesRootName_String.InputArg='MakeImagesRootName_String';
ifisfirstlabel.KeepValues.ContinueTracks_Tracks.FunctionInstance='ContinueTracks';
ifisfirstlabel.KeepValues.ContinueTracks_Tracks.OutputArg='Tracks';
ifisfirstlabel.ElseFunctions=ifisfirstlabelelsefunctions;
ifisfirstlabel.IfFunctions=ifisfirstlabeliffunctions;
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,ifisfirstlabel);

savefaslabel.InstanceName='SaveFAsLabel';
savefaslabel.FunctionHandle=@saveCellsLabel;
savefaslabel.FunctionArgs.NumberFormat.Value=NumberFormat;
savefaslabel.FunctionArgs.CellsLabel.FunctionInstance='AreaFilter';
savefaslabel.FunctionArgs.CellsLabel.OutputArg='LabelMatrix';
savefaslabel.FunctionArgs.CurFrame.FunctionInstance='SegmentationLoop';
savefaslabel.FunctionArgs.CurFrame.OutputArg='LoopCounter';
savefaslabel.FunctionArgs.FileRoot.FunctionInstance='SegmentationLoop';
savefaslabel.FunctionArgs.FileRoot.InputArg='MakeImagesRootName_String';
SegmentationLoopLoopFunctions=addToFunctionChain(SegmentationLoopLoopFunctions,savefaslabel);

segmentationloop.InstanceName='SegmentationLoop';
segmentationloop.FunctionHandle=@forLoop;
segmentationloop.FunctionArgs.EndLoop.Value=(StartFrame+FrameCount-1)*FrameStep;
segmentationloop.FunctionArgs.IncrementLoop.Value=FrameStep;
segmentationloop.FunctionArgs.StartLoop.Value=StartFrame;
segmentationloop.FunctionArgs.LoadTracksLayout_TracksLayout.FunctionInstance='LoadTracksLayout';
segmentationloop.FunctionArgs.LoadTracksLayout_TracksLayout.OutputArg='TracksLayout';
segmentationloop.FunctionArgs.MakeImagesRootName_String.FunctionInstance='MakeImagesRootName';
segmentationloop.FunctionArgs.MakeImagesRootName_String.OutputArg='String';
segmentationloop.KeepValues.ContinueTracks_Tracks.FunctionInstance='IfIsFirstLabel';
segmentationloop.KeepValues.ContinueTracks_Tracks.OutputArg='ContinueTracks_Tracks';
segmentationloop.LoopFunctions=SegmentationLoopLoopFunctions;
functions_list=addToFunctionChain(functions_list,segmentationloop);

maketracksfilename.InstanceName='MakeTracksFileName';
maketracksfilename.FunctionHandle=@concatenateText;
maketracksfilename.FunctionArgs.Text2.Value='/tracks.mat';
maketracksfilename.FunctionArgs.Text1.FunctionInstance='MakeOutputFolderName';
maketracksfilename.FunctionArgs.Text1.OutputArg='String';
functions_list=addToFunctionChain(functions_list,maketracksfilename);

savetracks.InstanceName='SaveTracks';
savetracks.FunctionHandle=@saveTracks;
savetracks.FunctionArgs.TracksFileName.FunctionInstance='MakeTracksFileName';
savetracks.FunctionArgs.TracksFileName.OutputArg='String';
savetracks.FunctionArgs.Tracks.FunctionInstance='SegmentationLoop';
savetracks.FunctionArgs.Tracks.OutputArg='ContinueTracks_Tracks';
functions_list=addToFunctionChain(functions_list,savetracks);

makespreadsheetname.InstanceName='MakeSpreadsheetName';
makespreadsheetname.FunctionHandle=@concatenateText;
makespreadsheetname.FunctionArgs.Text2.Value='_FAs.csv';
makespreadsheetname.FunctionArgs.Text1.FunctionInstance='MakeImagesRootName';
makespreadsheetname.FunctionArgs.Text1.OutputArg='String';
functions_list=addToFunctionChain(functions_list,makespreadsheetname);

exportfadata.InstanceName='ExportFAData';
exportfadata.FunctionHandle=@saveMatrixToSpreadsheet;
exportfadata.FunctionArgs.ColumnNames.Value='Focal Point ID,Time,Centroid 1,Centroid 2,Intensity, Area';
exportfadata.FunctionArgs.SpreadsheetFileName.FunctionInstance='MakeSpreadsheetName';
exportfadata.FunctionArgs.SpreadsheetFileName.OutputArg='String';
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