% CELLULAR TRACKING PROGRAM 
% USES NAIVE BAYES CLASSIFIER TO PREDICT MITOTIC EVENT
% USES GENERIC NEAREST NEIGHBOR TO GENERATE HIGH CONFIDENCE TRACK
% USES RANGE SEARCH TO DETERMINE POSSIBLE MATCHES
% GENERATES PROBABILITY DISTRIBUTION FUNCTIONS FOR EACH POTENTIAL MATCH
% USES BINARY INTEGER PROGRAMING TO PROCESS THE PDFs AND DETERMINE BEST
% POSSIBLE TRACK WITH ABILITY TO SELECT MITOTIC EVENTS
% INDEXES ALL OF THE IMAGE OUTPUTS TO GENERATE GLOBAL TRACKS
%% USER INPUTS FOR THE TRACKING
disp('Running New Method Tracking For PC9 Cells');
Date = '21APR14';
StartFrame = 1;
EndFrame = 930; % 10;
MaxFrames = round(15/1); % round(655/20);
FrameSkip = 1;
ImageFolder = '/Users/sg_hummel/Dropbox/SegImages_2/'; % Documents/Segmentation_PC9/';
SegmentOutName = 'DsRed - Confocal - n';
Known_Classifier = 'PC9_Classifier_B'; 
Type = '.mat';
Type2 = '.xlsx';
NumberFormat = '%06d';

TimeResolution = 6;
MinimumFrameThreshold = 6;
ImageWidth = 2016; % 336
ImageHeight = 1536; % 536
ImageBorder = 0; % This is the trheshold around the border by percent of the image dimension
AreaThreshold = 0.0; % Percent average high confidence track area that the average area of other confidence must be greater than to not be considered debris
RangeMultiple = 10; % Factor to for the average distance a cell moves in the high confidence tracks.

%% GENERATE CELL / OBJECT CHARACTERISTICS
CharacteristicsTotal = [];
ImageObjectIDTotal_2 = [];
ImageNumber_2 = [];
CharactersTotal_2 = [];
Characteristics = struct('ImageObjectID',1, 'ImageNumber', 2, 'CentroidX',3, 'CentroidY',4,'Area',5, 'Eccentricity',6,...
                         'Perimeter',7,'MajorAxisLength',8,'MinorAxisLength',9, 'ConvexArea',10, 'EquivDiameter',11,...
                         'FilledArea',12, 'Solidity',13, 'Intensity',14, 'Events',15);
% THIS SECTION LOADS THE .MAT FILES AND SORTS THE OBJECT CHARACTERISTICS
% FOR USE. OBJECTS ARE SORTED BY IMAGE NUMBER WITH CORRESPONDING PROPERTIES
% TO THE IDS FOR THAT IMAGE. TRACKS ARE NOT ASSIGNED YET!
for a = (StartFrame:FrameSkip:EndFrame)
   Image = [ImageFolder SegmentOutName num2str(a, NumberFormat) Type]; 
   Image = load(Image);
   
   ImageObjectIDTotal = unique(Image.objSet.labels);
   ImageObjectIDTotal(ImageObjectIDTotal==0) = [];
   CharactersTotal = [];
   for ObjIdx = 1: size(ImageObjectIDTotal)
      CentroidX= Image.objSet.props(ObjIdx).Centroid(1); 
      CentroidY= Image.objSet.props(ObjIdx).Centroid(2); 
      Area = Image.objSet.props(ObjIdx).Area;
      Eccentricity = Image.objSet.props(ObjIdx).Eccentricity;
      Perimeter = Image.objSet.props(ObjIdx).Perimeter;
      MAL = Image.objSet.props(ObjIdx).MajorAxisLength;
      MIL = Image.objSet.props(ObjIdx).MinorAxisLength;
      ConvexArea = Image.objSet.props(ObjIdx).ConvexArea;
      EquivDiameter = Image.objSet.props(ObjIdx).EquivDiameter;
      FilledArea = Image.objSet.props(ObjIdx).FilledArea;
      Solidity = Image.objSet.props(ObjIdx).Solidity;
      Intensity = Image.objSet.props(ObjIdx).Intensity;
      Characters = [CentroidX, CentroidY, Area, Eccentricity, Perimeter, MAL, MIL, ConvexArea, EquivDiameter, FilledArea,...
                   Solidity, Intensity];
      CharactersTotal = vertcat(CharactersTotal, Characters);
   end
   CharactersTotal_2 = vertcat(CharactersTotal_2, CharactersTotal); 
   ImageObjectIDTotal_2= vertcat(ImageObjectIDTotal_2, ImageObjectIDTotal);
   ImageNumber = repmat(a,[size(unique(ImageObjectIDTotal)),1]);
   ImageNumber_2 = vertcat(ImageNumber_2, ImageNumber);
   
end
   Characteristics.ImageObjectID= ImageObjectIDTotal_2;
   Characteristics.ImageNumber = ImageNumber_2;
   Characteristics.CentroidX= CharactersTotal_2(:,1);
   Characteristics.CentroidY= CharactersTotal_2(:,2);
   Characteristics.Area= CharactersTotal_2(:,3);
   Characteristics.Eccentricity= CharactersTotal_2(:,4);
   Characteristics.Perimeter= CharactersTotal_2(:,5);
   Characteristics.MajorAxisLength= CharactersTotal_2(:,6);
   Characteristics.MinorAxisLength= CharactersTotal_2(:,7);
   Characteristics.ConvexArea= CharactersTotal_2(:,8);
   Characteristics.EquivDiameter= CharactersTotal_2(:,9);
   Characteristics.FilledArea= CharactersTotal_2(:,10);
   Characteristics.Solidity= CharactersTotal_2(:,11);
   Characteristics.Intensity= CharactersTotal_2(:,12);
   
%% NAIVE BAYES CLASSIFIER TO DETERMINE POTENTIAL MITOTIC CELLS
% USES A BASIC MACHINE LEARNING ALGORITHM TO DETERMINE IF THE OBJECTS /
% CELLS ARE MITOTIC EITHER PRE- OR POST-MITOSIS. FURTHER DELINEATION IS
% DONE USING THE INTEGRER PROGRAMMING. 
% Calls in the known characterized cells from the segmentation program
% Identifies the critical data columns (Area, MajorAxisLength,
% MinorAxisLength, and Eccentricity)
known_data = xlsread([ImageFolder Known_Classifier Type2]);
% known_data = known_data(:,[6 7 8 9 11 14]);
known_data = known_data(:,[6 7 8 9 12 15]);

% Imports the classification column. It is separate due to the change in
% data structure for it to be read properly
known_responses = dataset('xlsfile', [ImageFolder Known_Classifier Type2]);
% known_response = dataset2cell(known_responses(:,16)); 
known_response = dataset2cell(known_responses(:,16)); 

% Creates the fit data of known responses through a multi-variate,
% multi-nomial distribution
nb = NaiveBayes.fit(known_data,known_response,'dist','kernel');

% Sorts the data to be predicted
ToBeTested = [Characteristics.Area Characteristics.MajorAxisLength Characteristics.MinorAxisLength...
        Characteristics.Eccentricity Characteristics.EquivDiameter Characteristics.Intensity];
predicted_responses = nb.predict(ToBeTested);

Characteristics.Events = predicted_responses;

Characteristics = struct2dataset(Characteristics);

Area_Limit_Index = find(Characteristics.Area <= 1000);
Characteristics = Characteristics(Area_Limit_Index,:);
Min_Area_Limit = find(Characteristics.Area >= 51);
Characteristics = Characteristics(Min_Area_Limit,:);

save([ImageFolder 'Characterisitcs' Type]);
%% HIGH CONFIDENCE PASS USING THE K-NEAREST NEIGHBOR
% Create initial list of tracks; basically the location of the cells in the
% first image and those that are not dividing

[KNN_Characteristics, IP_Information_TRACKS, BorderTracksALL, HighConfidenceALL, TheLeftOverTracksALL ]...
           = InitialTracks10(StartFrame, FrameSkip, EndFrame, MaxFrames, ImageFolder, Type, ImageWidth,...
           ImageHeight, ImageBorder);

%% MEAN DISTANCE AND CELL PARAMETERS OF A CELL AS IT MOVES BETWEEN FRAMES (HIGH CONFIDENCE)
[AverageDistance, PotentialRange, MeanList, histograms, HTC_Data] = HighConfidDataB10(HighConfidenceALL, MaxFrames,...
    StartFrame, FrameSkip, EndFrame, RangeMultiple);

MeanAreaChange = MeanList(:,2);
MeanEccentricityChange = MeanList(:,3);
MeanMALChange = MeanList(:,4);
MeanMILChange = MeanList(:,5);
MeanSolidityChange = MeanList(:,6);
MeanIntensityChange = MeanList(:,7);

MeanArea_HCT = mean(HighConfidenceALL.Area);
Calc_List = struct('AverageDistance', MeanList(:,1), 'MeanAreaChange', MeanList(:,2),...
    'MeanEccentricityChange', MeanList(:,3), 'MeanMALChange', MeanList(:,4), 'MeanMILChange',...
    MeanList(:,5), 'MeanSolidityChange', MeanList(:,6), 'MeanIntensityChange', MeanList(:,7), 'MeanArea_HTC',MeanArea_HCT);
Calc_List = struct2dataset(Calc_List);

DataFileName='MeanList_';
Type2='.csv';
export(Calc_List, 'File', [ImageFolder DataFileName Date Type2],'Delimiter',',')

DataFileName='HighConfidenceChanges_';
Type2='.csv';
export(HTC_Data, 'File', [ImageFolder DataFileName Date Type2],'Delimiter',',')

%% Area Filter
% Removes any cellular debris by examining the area of the debris over the
% knn track prediction. The filter uses the mean of all of the areas in the
% high confidence tracks and compares it with the other confidence tracks.
% The cut off for the area uses the AreaThreshold parameter which is user
% driven.
RefinedTracksALL = [];
for CT = 1:length(unique(TheLeftOverTracksALL.KNN_ID)) 
   TotalUniqueID = unique(TheLeftOverTracksALL.KNN_ID); 
   Cell_ID = TotalUniqueID(CT);
   ConfidenceTracks = TheLeftOverTracksALL(TheLeftOverTracksALL.KNN_ID == Cell_ID,:);
   HighConfidenceArea = mean(HighConfidenceALL.Area);
   if mean(ConfidenceTracks.Area) >= (AreaThreshold * HighConfidenceArea)
     RefinedTracks = ConfidenceTracks;
   else
       continue
   end
    RefinedTracksALL = vertcat(RefinedTracksALL, RefinedTracks);
    RefinedTracks = [];
end

%% COMBINATION OF THE HIGH CONFIDENCE TRACKS AND THE LOW CONFIDENCE TRACKS FOR PROPER SEARCH
ALL_Tracks = IP_Information_TRACKS;

%% Conducts Range Search to Match All Potential IDs from Image to Image.
Potential_Matches = Potential(MeanList, AverageDistance, StartFrame, FrameSkip, EndFrame, ALL_Tracks, PotentialRange);
% Exports the potential matches for reference
FormatSpreadsheet1 = Potential_Matches;
DataFileName1 = 'PotentialMatches_';
Type2 = '.csv';
export(FormatSpreadsheet1, 'File', [ImageFolder DataFileName1 Date Type2],'Delimiter',',');

%% Scans All Images for the Potential Daughter Pairs and Corresponding Parent Cells
Mitotic_Options = MitoticOptionsv2(StartFrame, FrameSkip, EndFrame, Potential_Matches);
FormatSpreadsheet2 = Mitotic_Options;
DataFileName2 = 'Mitotic_Options_';
Type2 = '.csv';
export(FormatSpreadsheet2, 'File', [ImageFolder DataFileName2 Date Type2],'Delimiter',',');

%% Binary Integer Programming Answers 
% Section is a work horse that extracts the potential match data and
% reformats the data into interger programming language. It was originally
% designed to function with matlab's bintprog but the 2014 version
% indicates the bintprog is going away. So it now uses a mixed integer
% programming. 
% Main array has code to adjust the weight of the mitotic events!!!!
% Reweighting the mitotic event PDF will either select more or less events
% depending on the desired effect
ALL_options_answers = [];
for Frame = (StartFrame:FrameSkip:EndFrame)
[Array, L_PDF, Three, intcon, lower_bounds, upper_bounds] = MainArray_STE(Potential_Matches, Mitotic_Options, Frame);
if isempty(Array)   
else
options_answer = intlinprog((L_PDF-1e10), intcon, transpose(Array), Three, [], [], transpose(lower_bounds), transpose(upper_bounds));
% options_answer = bintprog((L_PDF-1e10), transpose(Array), Three);
Frames = repmat(Frame,[size(options_answer),1]);
ALL_options_answer = horzcat(Frames, options_answer); 
ALL_options_answers = vertcat(ALL_options_answers, ALL_options_answer);
end
end
ALL_Selections = struct('ImageNumber', ALL_options_answers(:,1), 'Selection', ALL_options_answers(:,2));
ALL_Selections = struct2dataset(ALL_Selections);
FormatSpreadsheet3 = ALL_Selections;
DataFileName3 = 'ALL_Selections_';
Type2 = '.csv';
export(FormatSpreadsheet3, 'File', [ImageFolder DataFileName3 Date Type2],'Delimiter',',');

%% Track formation based on Integer Programming Selection
% The Match Process indexes the Potential Matches and the All Selections
% data to pick the best options. 
[ALL_Selected, ALL_MO_Selected] = MatchProcess(StartFrame,EndFrame, FrameSkip, ALL_Selections, Mitotic_Options, Potential_Matches);
if isempty(ALL_MO_Selected)
else
FormatSpreadsheet4 = ALL_MO_Selected;
DataFileName4 = 'ALL_MO_Selected_';
Type2 = '.csv';
export(FormatSpreadsheet4, 'File', [ImageFolder DataFileName4 Date Type2],'Delimiter',',');
end
%% Global Track Indentification Process
Tracks = GlobalTracks(Potential_Matches, ALL_Selected, ALL_MO_Selected, StartFrame, EndFrame, FrameSkip);
FormatSpreadsheet5 = Tracks;
DataFileName5 = 'Tracks_';
Type2 = '.csv';
export(FormatSpreadsheet5, 'File', [ImageFolder DataFileName5 Date Type2],'Delimiter',',');

%%
% MitoticData = ExtractMitoticData(Tracks,ALL_MO_Selected, FrameSkip);
[MitoticData, Combined_MO_cells,Possible_Missed, FracProLife]  = ExtractMitoticData(TimeResolution, Tracks,ALL_MO_Selected, FrameSkip, PotentialRange, ImageWidth, ImageHeight);
FormatSpreadsheet6 = MitoticData;
DataFileName6 = 'MitoticData_';
Type2 = '.csv';
export(FormatSpreadsheet6, 'File', [ImageFolder DataFileName6 Date Type2],'Delimiter',',');
FormatSpreadsheet7 = FracProLife;
DataFileName7 = 'FracProLife_';
Type2 = '.csv';
export(FormatSpreadsheet7, 'File', [ImageFolder DataFileName7 Date Type2],'Delimiter',',');
%%
% clear all


