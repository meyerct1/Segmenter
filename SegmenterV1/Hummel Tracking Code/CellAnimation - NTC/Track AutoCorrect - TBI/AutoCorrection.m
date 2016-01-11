% % function AutoTracksCorrected = AutoCorrection(StartFrame, EndFrame, ...
% %     FrameSkip, Tracks, ImageWidth, ImageHeight, PotentialRange)
% Temporary Code
% Used for debuging
Tracks = xlsread('/Users/sg_hummel/Dropbox/SegImages_2/Tracks_27MAR14.xlsx');
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
EndFrame = 931;
%
%

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

% Repeat of First Portion to Re-confirm List
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
        'TrackLength', tail, 'Issues', Issues);
    Tracker = struct2dataset(Tracker);
    All_Tracker = vertcat(All_Tracker, Tracker);  
end

% Autocorrection Workhorse
ModifiedTracks = Tracks;
MergeTable_ALL = [];
Merge_MitTable_ALL = [];
NonMergeTable_ALL = [];
for CM = (StartFrame:FrameSkip:EndFrame)
    if CM == 1
    else
     ExamineSet = All_Tracker(All_Tracker.StartFrame == CM,:); % finds cells that start at the selected frame
     CompareSet_1 = All_Tracker(All_Tracker.EndFrame == CM-FrameSkip,:); % finds cells that end at the previous frame 
     CompareSet_2 = All_Tracker(All_Tracker.EndFrame == CM-(2* FrameSkip),:);
     CompareSet_3 = All_Tracker(All_Tracker.EndFrame == CM-(3* FrameSkip),:);
     CompareSet_4 = All_Tracker(All_Tracker.EndFrame == CM-(4* FrameSkip),:);
     CompareSet_5 = All_Tracker(All_Tracker.EndFrame == CM-(5* FrameSkip),:);
     CompareSet_6 = All_Tracker(All_Tracker.EndFrame == CM-(6* FrameSkip),:);
     CompareSet_7 = All_Tracker(All_Tracker.EndFrame == CM-(7* FrameSkip),:);
     CompareSet_8 = All_Tracker(All_Tracker.EndFrame == CM-(8* FrameSkip),:);
     CompareSet = vertcat(CompareSet_1,CompareSet_2, CompareSet_3,CompareSet_4,...
         CompareSet_5, CompareSet_6,CompareSet_7,CompareSet_8);
     if isempty(CompareSet)
     else
     [id, range] = rangesearch(ExamineSet(:,6:7),CompareSet(:,4:5), PotentialRange); % Search Engine
     MergeTable = [];
     Merge_MitTable = [];
     NonMergeTable = [];
     for l = 1:length(id)
        idx_rows = cell2mat(id(l));
        distance = cell2mat(range(l));
        [M N] = size(idx_rows);
        if N == 0
            Table_Gone = struct('GoodID',CompareSet.TrackID(l), 'StartFrame', CompareSet.StartFrame(l),'EndFrame',CompareSet.EndFrame(l),...
                'StartX',CompareSet.StartX(l),'StartY', CompareSet.StartY(l), 'EndX',CompareSet.EndX(l), 'EndY', ...
                CompareSet.EndY(l), 'IDtoMerge', 0, 'Merge_StartFrame', 0, ...
                'Merge_EndFrame', 0, 'Merge_StartX', 0, 'Merge_StartY', ...
                0, 'Merge_EndX', 0, 'Merge_EndY', 0, 'Information',...
                187187, 'distance',0);
            Table_Gone = struct2dataset(Table_Gone);
            % % % % % % % % % % % % % % % % % %
            % % % % % % % % % % % % % % % % % %
            RemoveList = find(Table_Gone.StartFrame(:) == Table_Gone.EndFrame(:));
            RemoveList = flipud(RemoveList);
            ID_Rows = [];
            for ER = 1:length(RemoveList)
               Row = RemoveList(ER);
               ID = Table_Gone.GoodID(Row);
               ID_Row = find(ModifiedTracks.TrackID == ID);
               % ID_Rows = vertcat(ID_Rows, ID_Row);     
               ModifiedTracks(ID_Row,:) = [];
            end
            % % % % % % % % % % % % % % % % % % 
            % % % % % % % % % % % % % % % % % %
            TagList = find(Table_Gone.StartFrame(:) ~= Table_Gone.EndFrame(:));
            ER = [];
            for ER = 1:length(TagList) 
                Row = TagList(ER);
                ID = Table_Gone.GoodID(Row);
                ID_Row = max(find(ModifiedTracks.TrackID == ID));
                ModifiedTracks.Information(ID_Row) = 187187;
            end 
             % % % % % % % % % % % % % % % % % %
             % % % % % % % % % % % % % % % % % %
            NonMergeTable = vertcat(NonMergeTable, Table_Gone);
       
        elseif N == 1 % one to one
            row = idx_rows(:,N);
            Table = struct('GoodID',CompareSet.TrackID(l), 'StartFrame', CompareSet.StartFrame(l),'EndFrame',CompareSet.EndFrame(l),...
                'StartX',CompareSet.StartX(l),'StartY', CompareSet.StartY(l), 'EndX',CompareSet.EndX(l), 'EndY', ...
                CompareSet.EndY(l), 'IDtoMerge', ExamineSet.TrackID(row), 'Merge_StartFrame', ExamineSet.StartFrame(row), ...
                'Merge_EndFrame', ExamineSet.EndFrame(row), 'Merge_StartX', ExamineSet.StartX(row), 'Merge_StartY', ...
                ExamineSet.StartY(row), 'Merge_EndX', ExamineSet.EndX(row), 'Merge_EndY', ExamineSet.EndY(row), 'Information',...
                101010, 'distance',distance);
            Table = struct2dataset(Table);
             % % % % % % % % % % % % % % % % % % 
             % % % % % % % % % % % % % % % % % % 
            List = find(ModifiedTracks.Information == 333333);
            IDs = ModifiedTracks.TrackID(List);
            NewLists = [];
            for ER = 1:length(IDs)
               ID = IDs(ER);
               NewList = find(Table.IDtoMerge == ID);
               NewLists = vertcat(NewLists, NewList);
            end
            ER = [];
            for ER = 1:length(NewLists)
               Row = NewLists(ER);
               GoodID = Table.GoodID(Row);
                MergeID = Table.IDtoMerge(Row);
                ROW = find(ModifiedTracks.TrackID == MergeID);
                ModifiedTracks.TrackID(ROW) = GoodID; 
            end
             % % % % % % % % % % % % % % % % % % 
             % % % % % % % % % % % % % % % % % %  
            MergeTable = vertcat(MergeTable, Table);   
        elseif N == 2 % divergence (1 to 2)
          row_1 = idx_rows(:,1);
          row_2 = idx_rows(:,2);
          distance_1 = distance(:,1);
          distance_2 = distance(:,2);
          Table_1 = struct('GoodID',CompareSet.TrackID(l), 'StartFrame', CompareSet.StartFrame(l),'EndFrame',CompareSet.EndFrame(l),...
                'StartX',CompareSet.StartX(l),'StartY', CompareSet.StartY(l), 'EndX',CompareSet.EndX(l), 'EndY', ...
                CompareSet.EndY(l), 'IDtoMerge', ExamineSet.TrackID(row_1), 'Merge_StartFrame', ExamineSet.StartFrame(row_1), ...
                'Merge_EndFrame', ExamineSet.EndFrame(row_1), 'Merge_StartX', ExamineSet.StartX(row_1), 'Merge_StartY', ...
                ExamineSet.StartY(row_1), 'Merge_EndX', ExamineSet.EndX(row_1), 'Merge_EndY', ExamineSet.EndY(row_1), 'Information',...
                111222, 'distance', distance_1 );  
          Table_1 = struct2dataset(Table_1);
          Table_2 = struct('GoodID',CompareSet.TrackID(l), 'StartFrame', CompareSet.StartFrame(l),'EndFrame',CompareSet.EndFrame(l),...
                'StartX',CompareSet.StartX(l),'StartY', CompareSet.StartY(l), 'EndX',CompareSet.EndX(l), 'EndY', ...
                CompareSet.EndY(l), 'IDtoMerge', ExamineSet.TrackID(row_2), 'Merge_StartFrame', ExamineSet.StartFrame(row_2), ...
                'Merge_EndFrame', ExamineSet.EndFrame(row_2), 'Merge_StartX', ExamineSet.StartX(row_2), 'Merge_StartY', ...
                ExamineSet.StartY(row_2), 'Merge_EndX', ExamineSet.EndX(row_2), 'Merge_EndY', ExamineSet.EndY(row_2), 'Information',...
                222111, 'distance', distance_2);
          Table_2 = struct2dataset(Table_2);
          MitoticTable = vertcat(Table_1, Table_2);
          Merge_MitTable = vertcat(Merge_MitTable, MitoticTable);
        end
        
        MergeTable_ALL = vertcat(MergeTable_ALL, MergeTable);
        Merge_MitTable_ALL = vertcat(Merge_MitTable_ALL, Merge_MitTable);
        NonMergeTable_ALL = vertcat(NonMergeTable_ALL, NonMergeTable);
     end
     end
    end   
end
% Concatinate all lists
All_Merge_Tracks = vertcat(MergeTable_ALL, Merge_MitTable_ALL, NonMergeTable_ALL);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % RemoveList = find(NonMergeTable_ALL.StartFrame(:) == NonMergeTable_ALL.EndFrame(:));
% % RemoveList = flipud(RemoveList);
% % ModifiedTracks = Tracks;
% % ID_Rows = [];
% % for ER = 1:length(RemoveList)
% %    Row = RemoveList(ER);
% %    ID = NonMergeTable_ALL.GoodID(Row);
% %    ID_Row = find(ModifiedTracks.TrackID == ID);
% %    % ID_Rows = vertcat(ID_Rows, ID_Row);     
% %    ModifiedTracks(ID_Row,:) = [];
% % end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Tags the cells in the frame in which they die
% % TagList = find(NonMergeTable_ALL.StartFrame(:) ~= NonMergeTable_ALL.EndFrame(:));
% % ER = [];
% % for ER = 1:length(TagList) 
% %     Row = TagList(ER);
% %     ID = NonMergeTable_ALL.GoodID(Row);
% %     ID_Row = max(find(ModifiedTracks.TrackID == ID));
% %     ModifiedTracks.Information(ID_Row) = 187187;
% % end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Merge Tracks
% % List = find(ModifiedTracks.Information == 333333);
% % IDs = ModifiedTracks.TrackID(List);
% % NewLists = [];
% % for ER = 1:length(IDs)
% %    ID = IDs(ER);
% %    NewList = find(MergeTable_ALL.IDtoMerge == ID);
% %    NewLists = vertcat(NewLists, NewList);
% % end
% % ER = [];
% % for ER = 1:length(NewLists)
% %    Row = NewLists(ER);
% %    GoodID = MergeTable_ALL.GoodID(Row);
% %     MergeID = MergeTable_ALL.IDtoMerge(Row);
% %     ROW = find(ModifiedTracks.TrackID == MergeID);
% %     ModifiedTracks.TrackID(ROW) = GoodID; 
% % end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
% Remove Debris
DebrisList_ALL = [];
DebrisList = [];
ID_List = unique(ModifiedTracks.TrackID);
for ER = 1:length(ID_List)
    subset = ModifiedTracks(ModifiedTracks.TrackID == ID_List(ER),:);
    MeanArea = mean(subset.Curr_Area);
    if MeanArea <= 80
       DebrisList = subset.TrackID(1);
       DebrisID = subset.TrackID(1);
       Location = find(ModifiedTracks.TrackID == DebrisID);
       ModifiedTracks(Location,:) = [];
    else
    end
    DebrisList_ALL = vertcat(DebrisList_ALL,DebrisList);
end


ImageFolder = '/Users/sg_hummel/Dropbox/SegImages_2/';
Date = '09APR14';
DataFileName7 = 'ModifiedTracks_';
Type2 = '.csv';
export(ModifiedTracks, 'File', [ImageFolder DataFileName7 Date Type2],'Delimiter',',');







