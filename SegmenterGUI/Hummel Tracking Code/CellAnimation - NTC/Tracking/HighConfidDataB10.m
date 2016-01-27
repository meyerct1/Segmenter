function [AverageDistance, PotentialRange, MeanList, histograms, HTC_Data] = HighConfidDataB10(HighConfidenceALL, MaxFrames,StartFrame, FrameSkip, EndFrame, RangeMultiple)
%% DISTANCE A CELL MOVES BETWEEN FRAMES (HIGH CONFIDENCE)
%
%
DistanceList = [];
Distance2 = [];
for CT = 1:length(unique(HighConfidenceALL.KNN_ID)) 
   TotalUniqueID = unique(HighConfidenceALL.KNN_ID); 
   Cell_ID = TotalUniqueID(CT);
   DistanceSearcher = HighConfidenceALL(HighConfidenceALL.KNN_ID == Cell_ID,:);
%    for CT = StartFrame:EndFrame-1
   for CT = (StartFrame:FrameSkip:MaxFrames-1)
      CurrentLocation = DistanceSearcher(DistanceSearcher.ImageNumber == (CT),:); 
      NextLocation = DistanceSearcher(DistanceSearcher.ImageNumber == (CT+FrameSkip),:);
      Distance = sqrt((NextLocation.CentroidX - CurrentLocation.CentroidX).^2 + (NextLocation.CentroidY - CurrentLocation.CentroidY).^2);
      Distance2 = vertcat(Distance2, Distance);
      Distance = [];
   end
      DistanceList = vertcat(DistanceList, Distance2);
      Distance2 = [];
end
AverageDistance = mean(DistanceList(:));
PotentialRange = RangeMultiple * AverageDistance;

%% CHANGE IN CELL PARAMETERS OVERTIME (HIGH CONFIDENCE DATASET)

AreaChangeList = [];
AreaChange2 = [];
EccentricityChangeList = [];
EccentricityChange2 = [];
PerimeterChange2 = [];
MALChange2 = [];
MILChange2 = [];
CAChange2 = [];
EqDChange2 = [];
SolidityChange2 = [];
IntensityChange2 = [];
PerimeterChangeList = [];
MALChangeList = [];
MILChangeList = [];
CAChangeList = [];
EqDChangeList = [];
SolidityChangeList = [];
IntensityChangeList = [];
for CT = 1:length(unique(HighConfidenceALL.KNN_ID)) 
   TotalUniqueID = unique(HighConfidenceALL.KNN_ID); 
   Cell_ID = TotalUniqueID(CT); 
   KNN_ID_subset = HighConfidenceALL(HighConfidenceALL.KNN_ID == Cell_ID,:);
for CT = (StartFrame:FrameSkip:MaxFrames) 
   %    for CT = StartFrame:EndFrame-1 
      Current_subset = KNN_ID_subset(KNN_ID_subset.ImageNumber == (CT),:); 
      Next_subset = KNN_ID_subset(KNN_ID_subset.ImageNumber == (CT+FrameSkip),:);
      % FOR AREA
      AreaChange = abs(Current_subset.Area - Next_subset.Area);
      AreaChange2 = vertcat(AreaChange2, AreaChange);
      AreaChange = [];     
      % FOR ECCENTRICITY
      EccentricityChange = abs(Current_subset.Eccentricity - Next_subset.Eccentricity);
      EccentricityChange2 = vertcat(EccentricityChange2, EccentricityChange);
      EccentricityChange = [];      
      % FOR PERIMETER
      PerimeterChange = abs(Current_subset.Perimeter - Next_subset.Perimeter);
      PerimeterChange2 = vertcat(PerimeterChange2, PerimeterChange);
      PerimeterChange = [];      
      % FOR MAJOR AXIS LENGTH
      MALChange = abs(Current_subset.MajorAxisLength - Next_subset.MajorAxisLength);
      MALChange2 = vertcat(MALChange2, MALChange);
      MALChange = [];     
      % FOR MINOR AXIS LENGTH
      MILChange = abs(Current_subset.MinorAxisLength - Next_subset.MinorAxisLength);
      MILChange2 = vertcat(MILChange2, MILChange);
      MILChange = [];      
      % FOR CONVEX AREA
      CAChange = abs(Current_subset.ConvexArea - Next_subset.ConvexArea);
      CAChange2 = vertcat(CAChange2, CAChange);
      CAChange = [];     
      % FOR EQUIVALENT DIAMETER
      EqDChange = abs(Current_subset.EquivDiameter - Next_subset.EquivDiameter);
      EqDChange2 = vertcat(EqDChange2, EqDChange);
      EqDChange = [];     
      % FOR SOLIDITY
      SolidityChange = abs(Current_subset.Solidity - Next_subset.Solidity);
      SolidityChange2 = vertcat(SolidityChange2, SolidityChange);
      SolidityChange = [];     
      % FOR INTENSITY
      IntensityChange = abs(Current_subset.Intensity - Next_subset.Intensity);
      IntensityChange2 = vertcat(IntensityChange2, IntensityChange);
      IntensityChange = [];      
   end
      AreaChangeList = vertcat(AreaChangeList, AreaChange2);
      EccentricityChangeList = vertcat(EccentricityChangeList, EccentricityChange2);
      PerimeterChangeList = vertcat(PerimeterChangeList, PerimeterChange2);
      MALChangeList = vertcat(MALChangeList, MALChange2);
      MILChangeList = vertcat(MILChangeList, MILChange2);
      CAChangeList = vertcat(CAChangeList, CAChange2);
      EqDChangeList = vertcat(EqDChangeList, EqDChange2);
      SolidityChangeList = vertcat(SolidityChangeList, SolidityChange2);
      IntensityChangeList = vertcat(IntensityChangeList, IntensityChange2);
      AreaChange2 = [];
      EccentricityChange2 = [];
      PerimeterChange2 = [];
      MALChange2 = [];
      MILChange2 = [];
      CAChange2 = [];
      EqDChange2 = [];
      SolidityChange2 = [];
      IntensityChange2 = [];
end
MeanAreaChange = mean(AreaChangeList(:));
MeanEccentricityChange = mean(EccentricityChangeList(:));
% MeanPerimeterChange = mean(PerimeterChangeList(:));
MeanMALChange = mean(MALChangeList(:));
MeanMILChange = mean(MILChangeList(:));
% MeanConvexAreaChange = mean(CAChangeList(:));
% MeanEquivDiameterChange = mean(EqDChangeList(:));
MeanSolidityChange = mean(SolidityChangeList(:));
MeanIntensityChange = mean(IntensityChangeList(:));

% % MeanList = horzcat(AverageDistance, MeanAreaChange, MeanEccentricityChange, MeanPerimeterChange, MeanMALChange, ...
% %     MeanMILChange, MeanConvexAreaChange, MeanSolidityChange, MeanIntensityChange);
MeanList = horzcat(AverageDistance, MeanAreaChange, MeanEccentricityChange, MeanMALChange, ...
    MeanMILChange, MeanSolidityChange, MeanIntensityChange);

histograms = PlotDistributions(DistanceList, AreaChangeList, EccentricityChangeList, MALChangeList, MILChangeList, SolidityChangeList, IntensityChangeList);

HTC_Data = struct('Distance',DistanceList, 'Area', AreaChangeList, 'Eccentricity',EccentricityChangeList, 'MajorAxis',MALChangeList, ...
    'MinorAxis',MILChangeList, 'Solidity',SolidityChangeList, 'Intensity',IntensityChangeList);

HTC_Data = struct2dataset(HTC_Data);

end