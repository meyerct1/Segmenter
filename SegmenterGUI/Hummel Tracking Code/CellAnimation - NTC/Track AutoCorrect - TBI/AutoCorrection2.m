% % function AutoTracksCorrected = AutoCorrection(StartFrame, EndFrame, ...
% %     FrameSkip, Tracks, ImageWidth, ImageHeight, PotentialRange)
% Temporary Code
% Used for debuging
Date = '21APR14';
ImageFolder = '/Users/sg_hummel/Dropbox/SegImages_2/21APR14/';
Tracks = xlsread('/Users/sg_hummel/Dropbox/SegImages_2/21APR14/Tracks_21APR14.xlsx');
Tracks = struct('TrackID',Tracks(:,1), 'CurrentImage',Tracks(:,2),'NextImage',Tracks(:,3),'Initial_Track_ID',Tracks(:,4),...
    'Curr_KNN_ID',Tracks(:,5),'Next_KNN_ID',Tracks(:,6),'Distance',Tracks(:,7),'Curr_X',Tracks(:,8), 'Curr_Y',Tracks(:,9),...
    'Curr_Area',Tracks(:,10),'Curr_Eccentricity',Tracks(:,11), 'Curr_MAL',Tracks(:,12),	'Curr_MIL',Tracks(:,13), ...
    'Curr_Solidity',Tracks(:,14),'Curr_Intensity',Tracks(:,15),	'Next_X',Tracks(:,16), 'Next_Y',Tracks(:,17), 'Next_Area',...
    Tracks(:,18), 'Next_Eccentricity',Tracks(:,19), 'Next_MAL',Tracks(:,20), 'Next_MIL',Tracks(:,21), 'Next_Solidity',...
    Tracks(:,22), 'Next_Intensity',Tracks(:,23),'AreaDiff',Tracks(:,24),'EccDiff',Tracks(:,25),	'MALDiff',Tracks(:,26),...
    'MILDiff',Tracks(:,27),	'SolidityDiff',Tracks(:,28), 'IntensityDiff',Tracks(:,29), 'DistanceNLL',Tracks(:,30), ...
    'AreaNLL',Tracks(:,31),	'EccNLL',Tracks(:,32),	'MALNLL',Tracks(:,33),	'MILNLL',Tracks(:,34),	'SolidityNLL',Tracks(:,35),...
    'IntensityNLL',Tracks(:,36), 'PDF_Sum',Tracks(:,37), 'Curr_Event', Tracks(:,38), 'Next_Event', Tracks(:,39), ...
    'Information',Tracks(:,40));
Tracks = struct2dataset(Tracks);
PotentialRange = 50;
FrameSkip = 1;
StartFrame = 1;
EndFrame = 930;
Original_Tracks = Tracks;
AverageDistance = 3.5774;
MeanAreaChange = 28.9134;
MeanEccentricityChange = 0.0667;
MeanMALChange = 1.0404;
MeanMILChange = 0.8188;
MeanSolidityChange = 0.0159;
MeanIntensityChange = 0.0174;
MeanArea_HCT = 617;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Remove Debris
DebrisList_ALL = [];
DebrisList = [];
ID_List = unique(Tracks.TrackID);
for ER = 1:length(ID_List)
    subset = Tracks(Tracks.TrackID == ID_List(ER),:);
    MeanArea = mean(subset.Curr_Area);
    if MeanArea <= (MeanArea_HCT * (1/8)); 
       DebrisList = subset.TrackID(1);
       DebrisID = subset.TrackID(1);
       Location = find(Tracks.TrackID == DebrisID);
       Tracks(Location,:) = [];
    else
    end
    DebrisList_ALL = vertcat(DebrisList_ALL,DebrisList);
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
%
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
TrackList = unique(Tracks.TrackID); % Identifies all of the unique tracks in the file
All_Tracker = [];
for RT = 1:length(TrackList) % Extracts data from larger Tracks dataset for ease of use
    ID = TrackList(RT);
    All_subset = Tracks(Tracks.TrackID == ID,:);
    tail = length(All_subset);
    FrameSpan = (max(All_subset.CurrentImage) -  min(All_subset.CurrentImage));
    Issues = FrameSpan - tail;
    Tracker = struct('TrackID', ID, 'StartFrame', min(All_subset.CurrentImage), ...
        'EndFrame', max(All_subset.CurrentImage), 'StartX', All_subset.Curr_X(1), ...
        'StartY', All_subset.Curr_Y(1), 'EndX', All_subset.Curr_X(tail), 'EndY', ...
        All_subset.Curr_Y(tail), 'FrameSpan', FrameSpan,...
        'TrackLength', tail, 'Issues', Issues);
    Tracker = struct2dataset(Tracker);
    All_Tracker = vertcat(All_Tracker, Tracker);  
end

IssuesList = find(All_Tracker.Issues ~= -1);

MAX_ID = max(Tracks.TrackID);

for XT = 1:length(IssuesList)
    updatedvalue = MAX_ID + XT;
    ID = All_Tracker.TrackID(IssuesList(XT));  
    Examine = Tracks(Tracks.TrackID == ID,:);
    Values = unique(Examine.CurrentImage);
    countofunique = hist(Examine.CurrentImage, Values);
    index = countofunique ~=1;
    repeatedvalues = Values(index); 
    for TT = 1:length(repeatedvalues)
        List = Examine(Examine.CurrentImage == repeatedvalues(TT),:); 
        MaxDistance =  max(List.Distance);
        Row = find(Tracks.TrackID == ID & Tracks.CurrentImage == repeatedvalues(TT) & Tracks.Distance == MaxDistance);
        Tracks.TrackID(Row) = updatedvalue;
    end   
end

% % % % % Repeat of First Portion to Re-confirm List
TrackList = unique(Tracks.TrackID);
All_Tracker = [];
for RT = 1:length(TrackList)
    ID = TrackList(RT);
    All_subset = Tracks(Tracks.TrackID == ID,:);
    tail = length(All_subset);
    FrameSpan = (max(All_subset.CurrentImage) -  min(All_subset.CurrentImage));
    Issues = FrameSpan - tail;
    Tracker = struct('TrackID', ID, 'StartFrame', min(All_subset.CurrentImage), ...
        'EndFrame', max(All_subset.CurrentImage), 'StartX', All_subset.Curr_X(1), ...
        'StartY', All_subset.Curr_Y(1), 'EndX', All_subset.Curr_X(tail), 'EndY', ...
        All_subset.Curr_Y(tail), 'FrameSpan', FrameSpan,...
        'TrackLength', tail, 'Information_Start',All_subset.Information(1),...
        'Information_End',All_subset.Information(tail),'Issues', Issues);
    Tracker = struct2dataset(Tracker);
    All_Tracker = vertcat(All_Tracker, Tracker);  
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% AUTOCORRECTION WORKHORSE
StartFrame = 1;
FrameSkip = 1;
EndFrame = 930;

Potential_Matches = [];
Potential_ALL = [];
for CM = (StartFrame:FrameSkip:EndFrame)
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% IDENTIFIES POTENTIAL MERGE TRACKS    
    if CM == 1
    else
     ExamineSet = All_Tracker(All_Tracker.StartFrame == CM,:); % finds cells that start at the selected frame
     CompareSet_1 = All_Tracker(All_Tracker.EndFrame == CM-FrameSkip,:); % finds cells that end at the previous frame 
     CompareSet_2 = All_Tracker(All_Tracker.EndFrame == CM-(2* FrameSkip),:);
     CompareSet_3 = All_Tracker(All_Tracker.EndFrame == CM-(3* FrameSkip),:);
     CompareSet_4 = All_Tracker(All_Tracker.EndFrame == CM-(4* FrameSkip),:);
     CompareSet_5 = All_Tracker(All_Tracker.EndFrame == CM-(5* FrameSkip),:);
     CompareSet_6 = All_Tracker(All_Tracker.EndFrame == CM-(6* FrameSkip),:);
     CompareSet_7 = []; % All_Tracker(All_Tracker.EndFrame == CM-(7* FrameSkip),:);
     CompareSet_8 = []; % All_Tracker(All_Tracker.EndFrame == CM-(8* FrameSkip),:);
     CompareSet = vertcat(CompareSet_1,CompareSet_2, CompareSet_3,CompareSet_4,...
         CompareSet_5, CompareSet_6,CompareSet_7,CompareSet_8);
         if isempty(CompareSet)
         else
             [id, range] = rangesearch(ExamineSet(:,6:7),CompareSet(:,4:5), PotentialRange); % Search Engine
             MergeTable_ALL = [];
             for l = 1:length(id)
                idx_rows = cell2mat(id(l));
                distance = cell2mat(range(l));
                [M N] = size(idx_rows);
                MergeTable = [];
                for CT = 1:N
                    row_1 = idx_rows(:,CT);
                    distance_1 = distance(:,CT);
                    Table_1 = struct('GoodID',CompareSet.TrackID(l), 'StartFrame', CompareSet.StartFrame(l),'EndFrame',CompareSet.EndFrame(l),...
                        'StartX',CompareSet.StartX(l),'StartY', CompareSet.StartY(l), 'EndX',CompareSet.EndX(l), 'EndY', ...
                        CompareSet.EndY(l), 'PotentialMergeID', ExamineSet.TrackID(row_1), 'Merge_StartFrame', ExamineSet.StartFrame(row_1), ...
                        'Merge_EndFrame', ExamineSet.EndFrame(row_1), 'Merge_StartX', ExamineSet.StartX(row_1), 'Merge_StartY', ...
                        ExamineSet.StartY(row_1), 'Merge_EndX', ExamineSet.EndX(row_1), 'Merge_EndY', ExamineSet.EndY(row_1), 'Information',...
                        ExamineSet.Information_Start(row_1), 'Distance', distance_1 ); 
                    Table_1 = struct2dataset(Table_1);
                    MergeTable = vertcat(MergeTable, Table_1);
                end
                MergeTable_ALL = vertcat(MergeTable_ALL, MergeTable);
             end
             Potential_ALL = [];
             for RT = 1: length(MergeTable_ALL)
                Subset = MergeTable_ALL(RT,:);
                if Subset.Information == 111222;
                elseif Subset.Information == 222111;
                else
                Subset_1 = Tracks(Tracks.TrackID == Subset.GoodID,:);
                Subset_2 = Tracks(Tracks.TrackID == Subset.PotentialMergeID,:);
                CurrentImage = Subset_1.NextImage(end);% CM;
                NextImage = CM; % Subset_1.NextImage(tail);
                Curr_Track_ID = Subset.GoodID;
                Next_Track_ID = Subset.PotentialMergeID;
                Distance = Subset.Distance;
                % Extracts the necessary information for the IP tracking of
                % the potential merges
                Curr_X = Subset_1.Next_X(end);
                Curr_Y = Subset_1.Next_Y(end);
                Curr_Area = Subset_1.Next_Area(end);
                Curr_Eccentricity = Subset_1.Next_Eccentricity(end);
                Curr_MAL = Subset_1.Next_MAL(end);
                Curr_MIL = Subset_1.Next_MIL(end);
                Curr_Solidity = Subset_1.Next_Solidity(end);
                Curr_Intensity = Subset_1.Next_Intensity(end);
                Curr_Events = Subset_1.Next_Event(end);
                Next_X = Subset_2.Curr_X(1);
                Next_Y = Subset_2.Curr_Y(1);
                Next_Area = Subset_2.Curr_Area(1);
                Next_Eccentricity = Subset_2.Curr_Eccentricity(1);
                Next_MAL = Subset_2.Curr_MAL(1);
                Next_MIL = Subset_2.Curr_MIL(1);
                Next_Solidity = Subset_2.Curr_Solidity(1);
                Next_Intensity = Subset_2.Curr_Intensity(1);
                Next_Events = Subset_2.Curr_Event(1);
                % Calculates the differences in morphological features
                AreaDiff = abs(Curr_Area - Next_Area);
                EccDiff = abs(Curr_Eccentricity - Next_Eccentricity);
                MALDiff = abs(Curr_MAL - Next_MAL);
                MILDiff = abs(Curr_MIL - Next_MIL);
                SolidityDiff = abs(Curr_Solidity - Next_Solidity);
                IntensityDiff = abs(Curr_Intensity - Next_Intensity);
                % Calculates the NLL for each morphological feature
                Distance_NLL = log((2/(AverageDistance*pi)) + Distance.^2/(AverageDistance*AverageDistance*pi));
                Area_NLL = log((2/(MeanAreaChange*pi)) + AreaDiff.^2/(MeanAreaChange*MeanAreaChange*pi));
                Eccentricity_NLL = log((2/(MeanEccentricityChange*pi)) + EccDiff.^2/(MeanEccentricityChange*MeanEccentricityChange*pi));
                MAL_NLL = log((2/(MeanMALChange*pi)) + MALDiff.^2/(MeanMALChange*MeanMALChange*pi));
                MIL_NLL = log((2/(MeanMILChange*pi)) + MILDiff.^2/(MeanMILChange*MeanMILChange*pi));
                Solidity_NLL = log((2/(MeanSolidityChange*pi)) + SolidityDiff.^2/(MeanSolidityChange*MeanSolidityChange*pi));
                Intensity_NLL = log((2/(MeanIntensityChange*pi)) + IntensityDiff.^2/(MeanIntensityChange*MeanIntensityChange*pi));
                PDF_Sum = ((15 * Distance_NLL) + (5 * Area_NLL) + (Eccentricity_NLL + MAL_NLL + MIL_NLL + Solidity_NLL + Intensity_NLL));
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                % Adjustment for image difference
                Difference = NextImage - CurrentImage;
                if Difference == 0
                PDF_Sum = 0;
                else
                PDF_Sum = (PDF_Sum * (1/Difference));
                end
                % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
                PotentialMM = struct('CurrentImage', CurrentImage, 'NextImage', NextImage, ...
                   'Initial_Track_ID', Curr_Track_ID,'Curr_KNN_ID', Curr_Track_ID,'Next_KNN_ID', Next_Track_ID, ...
                   'Distance', Distance,'Curr_X', Curr_X, 'Curr_Y',Curr_Y, 'Curr_Area', ...
                   Curr_Area, 'Curr_Eccentricity', Curr_Eccentricity, 'Curr_MAL', Curr_MAL, 'Curr_MIL',...
                   Curr_MIL, 'Curr_Solidity', Curr_Solidity, 'Curr_Intensity', Curr_Intensity, 'Next_X',...
                   Next_X, 'Next_Y',Next_Y, 'Next_Area', Next_Area, 'Next_Eccentricity',...
                   Next_Eccentricity, 'Next_MAL', Next_MAL, 'Next_MIL',Next_MIL, 'Next_Solidity',... 
                   Next_Solidity, 'Next_Intensity', Next_Intensity, 'AreaDiff', AreaDiff, 'EccDiff', EccDiff, 'MALDiff',...
                   MALDiff, 'MILDiff', MILDiff, 'SolidityDiff', SolidityDiff, 'IntensityDiff', IntensityDiff, 'DistanceNLL', ...
                   Distance_NLL, 'AreaNLL', Area_NLL, 'EccNLL', Eccentricity_NLL, 'MALNLL', MAL_NLL, 'MILNLL', MIL_NLL, ...
                   'SolidityNLL', Solidity_NLL, 'IntensityNLL', Intensity_NLL, 'PDF_Sum', PDF_Sum, 'Curr_Event', Curr_Events,...
                   'Next_Event', Next_Events);
                PotentialMM = struct2dataset(PotentialMM);
                Potential_ALL = vertcat(Potential_ALL, PotentialMM);
                PotentialMM = [];
                end
                

                
             end


         end
     
     
    end
    Potential_Matches = vertcat(Potential_Matches, Potential_ALL);
end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Sort Data
Potential_Matches = sortrows(Potential_Matches,4);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Remove Same Image Matches
Bad_Matches = find(Potential_Matches.CurrentImage == Potential_Matches.NextImage);
Potential_Matches(Bad_Matches,:) = [];
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
Running_PM = Potential_Matches;
PM_List = unique(Running_PM.Curr_KNN_ID);
A = length(unique(Running_PM.Curr_KNN_ID));
B = length(Running_PM.Curr_KNN_ID);
C = length(unique(Running_PM.Next_KNN_ID));
Left_Matrix = zeros(B,A);
Right_Matrix = zeros(B,C);
Options_ID_List = unique(Running_PM.Next_KNN_ID);
row_depth = 0;
for MM = 1:length(PM_List) 
    ID = PM_List(MM);
    ID_subset = Running_PM(Running_PM.Curr_KNN_ID == ID,:);
    [dimensions_x y] = size(ID_subset.Next_KNN_ID);
    Cell_ID_List_2 = unique(ID_subset.Next_KNN_ID);
    for Cell_KNN_2 = 1:length(Cell_ID_List_2) 
       Cell_ID_2 = Cell_ID_List_2(Cell_KNN_2);
       [shift_row2 shift_col2] = find(Options_ID_List == Cell_ID_2);
       Left_Matrix((Cell_KNN_2 + row_depth), MM) = 1;   
     end
    row_depth = dimensions_x + row_depth;
end

for ID = 1:length(Options_ID_List)
   Opt_ID = Options_ID_List(ID);
   list = find(Running_PM.Next_KNN_ID == Opt_ID);
    for enum = 1:length(list)
       row_value = list(enum);
       Right_Matrix(row_value, ID) = 1;
    end
end

Array = horzcat(Left_Matrix, Right_Matrix);
[K M] = size(Array);
Three = ones(M, 1);
L_PDF = Running_PM.PDF_Sum;
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %

options_answer = bintprog((L_PDF-1e10), transpose(Array), Three);
% % % % options_answer = intlinprog((L_PDF-1e10), transpose(Array), Three);


Selections = find(options_answer == 1);
Matches = Potential_Matches(Selections,:);
% Merging Process
Modified_Tracks = Tracks;
Modified_Matches = flipud(Matches);
for TT = 1:length(Modified_Matches)
    Rows = find(Modified_Tracks.TrackID == Modified_Matches.Next_KNN_ID(TT));
    New_ID = Modified_Matches.Curr_KNN_ID(TT);
    Modified_Tracks.TrackID(Rows) = New_ID;
    
end

DataFileName='Modified_Tracksv2';
Type2='.csv';
export(Modified_Tracks, 'File', [ImageFolder DataFileName Date Type2],'Delimiter',',')












