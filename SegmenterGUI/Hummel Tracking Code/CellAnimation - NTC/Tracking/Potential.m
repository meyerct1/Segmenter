 function Potential_Matches = Potential(MeanList, AverageDistance, StartFrame, FrameSkip, EndFrame, ALL_Tracks, PotentialRange)
Potential_Matches_B = [];
for add = (StartFrame:FrameSkip:EndFrame) 
   % Range Search for all possible matches in the next image 
   CURRENTImage = ALL_Tracks(ALL_Tracks.ImageNumber == add,:);
   NEXTImage = ALL_Tracks(ALL_Tracks.ImageNumber == add+FrameSkip,:);
   [ExamineIndex, ExamineDistance] = rangesearch(NEXTImage(:,5:6),CURRENTImage(:,5:6), PotentialRange);
   
   Current_Data2 = [];
   Next_Data2 = [];
   Possibles_ID_ALL = []; 
   Possibles_Distance_ALL = [];
   for CT = 1:length(ExamineIndex)  % Extracts data from the range search
    Index_NON = cell2mat(ExamineIndex(CT));
    Distance_NON = cell2mat(ExamineDistance(CT));
    dimension = size(cell2mat(ExamineIndex(CT)));  
      for NON_size = 1:dimension(1,2)
          Possibles_ID = Index_NON(:,NON_size);
          Possibles_Distance = Distance_NON(:,NON_size);
          Possibles_ID = NEXTImage.KNN_ID(Possibles_ID);
          Possibles_ID_ALL = vertcat(Possibles_ID_ALL, Possibles_ID);
          Possibles_Distance_ALL = vertcat(Possibles_Distance_ALL, Possibles_Distance);
          Next_Data = NEXTImage(NEXTImage.KNN_ID == Possibles_ID,:);
          Next_Data.KNN_Distance = Possibles_Distance;
          Next_Data2 = vertcat(Next_Data2, Next_Data);
          Next_Data = [];
          Possibles_ID = [];
          Current_Data = CURRENTImage(CT,:);
          Current_Data2 = vertcat(Current_Data2, Current_Data); 
          Current_Data = [];
      end 
   end
   
CT = [];
% Mean information from the high confidence tracks. Used to determine the
% NLL and Propability Distributions for the Integer Programming
MeanAreaChange = MeanList(:,2);
MeanEccentricityChange = MeanList(:,3);
MeanMALChange = MeanList(:,4);
MeanMILChange = MeanList(:,5);
MeanSolidityChange = MeanList(:,6);
MeanIntensityChange = MeanList(:,7);
   
Potential_Matches_A = [];   
   for CT = 1: length(Current_Data2)
   Current = Current_Data2(CT,:);
   Next = Next_Data2(CT,:);

% Differences in the morphological parameters   
AreaDiff = abs(Current.Area - Next.Area);
EccDiff = abs(Current.Eccentricity - Next.Eccentricity);
MALDiff = abs(Current.MajorAxisLength - Next.MajorAxisLength);
MILDiff = abs(Current.MinorAxisLength - Next.MinorAxisLength);
SolidityDiff = abs(Current.Solidity - Next.Solidity);
IntensityDiff = abs(Current.Intensity - Next.Intensity);
Distance = Next.KNN_Distance;

% Negative Log Liklihood Calculations % Removed the negative to test on
% 20FEB14
Distance_NLL = log((2/(AverageDistance*pi)) + Distance.^2/(AverageDistance*AverageDistance*pi));
Area_NLL = log((2/(MeanAreaChange*pi)) + AreaDiff.^2/(MeanAreaChange*MeanAreaChange*pi));
Eccentricity_NLL = log((2/(MeanEccentricityChange*pi)) + EccDiff.^2/(MeanEccentricityChange*MeanEccentricityChange*pi));
MAL_NLL = log((2/(MeanMALChange*pi)) + MALDiff.^2/(MeanMALChange*MeanMALChange*pi));
MIL_NLL = log((2/(MeanMILChange*pi)) + MILDiff.^2/(MeanMILChange*MeanMILChange*pi));
Solidity_NLL = log((2/(MeanSolidityChange*pi)) + SolidityDiff.^2/(MeanSolidityChange*MeanSolidityChange*pi));
Intensity_NLL = log((2/(MeanIntensityChange*pi)) + IntensityDiff.^2/(MeanIntensityChange*MeanIntensityChange*pi));
PDF_Sum = ((15 * Distance_NLL) + (5 * Area_NLL) + (Eccentricity_NLL + MAL_NLL + MIL_NLL + Solidity_NLL + Intensity_NLL)); % 1.5 and 0.5
% % % % % % % % % % %   
% Structure of the output
Potential_Match = struct('CurrentImage', Current.ImageNumber, 'NextImage', Next.ImageNumber, ...
       'Initial_Track_ID', Current.InitialObjectID,'Curr_KNN_ID', Current.KNN_ID,'Next_KNN_ID', Next.KNN_ID, ...
       'Distance', Next.KNN_Distance,'Curr_X', Current.CentroidX, 'Curr_Y',Current.CentroidY, 'Curr_Area', ...
       Current.Area, 'Curr_Eccentricity', Current.Eccentricity, 'Curr_MAL', Current.MajorAxisLength, 'Curr_MIL',...
       Current.MinorAxisLength, 'Curr_Solidity', Current.Solidity, 'Curr_Intensity', Current.Intensity, 'Next_X',...
       Next.CentroidX, 'Next_Y',Next.CentroidY, 'Next_Area', Next.Area, 'Next_Eccentricity',...
       Next.Eccentricity, 'Next_MAL', Next.MajorAxisLength, 'Next_MIL',Next.MinorAxisLength, 'Next_Solidity',... 
       Next.Solidity, 'Next_Intensity', Next.Intensity, 'AreaDiff', AreaDiff, 'EccDiff', EccDiff, 'MALDiff',...
       MALDiff, 'MILDiff', MILDiff, 'SolidityDiff', SolidityDiff, 'IntensityDiff', IntensityDiff, 'DistanceNLL', ...
       Distance_NLL, 'AreaNLL', Area_NLL, 'EccNLL', Eccentricity_NLL, 'MALNLL', MAL_NLL, 'MILNLL', MIL_NLL, ...
       'SolidityNLL', Solidity_NLL, 'IntensityNLL', Intensity_NLL, 'PDF_Sum', PDF_Sum, 'Curr_Event', Current.Events,...
       'Next_Event', Next.Events);
Potential_Matches_A = vertcat(Potential_Matches_A, Potential_Match);      
         
   end
   
Potential_Matches_B = vertcat(Potential_Matches_B, Potential_Matches_A);
        
end

Potential_Matches = struct2dataset(Potential_Matches_B);

 end