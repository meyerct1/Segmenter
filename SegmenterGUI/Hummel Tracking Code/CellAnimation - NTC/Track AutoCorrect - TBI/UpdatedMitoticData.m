TimeResolution = 6; % minutes betweem images
% Modified_Tracks = Modified_Tracksv2;
Set111 = find(Modified_Tracks.Information == 111222);
Set222 = find(Modified_Tracks.Information == 222111);
MitoticData_1 = [];
for RT = 1:length(Set111)
    Row111 = Set111(RT);    
    Daughter1_Start = Modified_Tracks(Row111,:);
    Parent_Loc = Daughter1_Start.Curr_X;
    Parent_row = find(Modified_Tracks.CurrentImage == (Daughter1_Start.CurrentImage-FrameSkip) & (Modified_Tracks.Next_X == Parent_Loc));
    Parent_Info = Modified_Tracks(Parent_row,:);
    Parent_ID = Parent_Info.TrackID;
    if isempty(Parent_ID)
    elseif length(Parent_ID) > 1
    else
       Parent = Modified_Tracks(Modified_Tracks.TrackID == Parent_ID,:);
       Daughter1 = Modified_Tracks(Modified_Tracks.TrackID == Daughter1_Start.TrackID,:);
       MO_Info_1 = struct('ParentID', Parent.TrackID(1), 'Start', min(Parent.CurrentImage), 'End', max(Parent.CurrentImage), ...
            'Daughter1', Daughter1.TrackID(1), 'Start1', min(Daughter1.CurrentImage), 'End1', max(Daughter1.CurrentImage),...
            'Daughter2', 0, 'Start2', 0, 'End2', 0);
    MO_Info_1 = struct2dataset(MO_Info_1);
    MitoticData_1 = vertcat(MitoticData_1, MO_Info_1);
    end
end

MitoticData_2 = [];
for RT = 1:length(Set222)
    Row222 = Set222(RT);    
    Daughter2_Start = Modified_Tracks(Row222,:);
    Parent_Loc = Daughter2_Start.Curr_X;
    Parent_row = find(Modified_Tracks.CurrentImage == (Daughter2_Start.CurrentImage-FrameSkip) & (Modified_Tracks.Next_X == Parent_Loc));
    Parent_Info = Modified_Tracks(Parent_row,:);
    Parent_ID = Parent_Info.TrackID;
    if isempty(Parent_ID)
    elseif length(Parent_ID) > 1
    else
       Parent = Modified_Tracks(Modified_Tracks.TrackID == Parent_ID,:);
       Daughter2 = Modified_Tracks(Modified_Tracks.TrackID == Daughter2_Start.TrackID,:);
       MO_Info_2 = struct('ParentID', Parent.TrackID(1), 'Start', min(Parent.CurrentImage), 'End', max(Parent.CurrentImage), ...
            'Daughter1', 0, 'Start1', 0, 'End1', 0,...
            'Daughter2', Daughter2.TrackID(1), 'Start2', min(Daughter2.CurrentImage), 'End2', max(Daughter2.CurrentImage));
    MO_Info_2 = struct2dataset(MO_Info_2);
    MitoticData_2 = vertcat(MitoticData_2, MO_Info_2);
    end
end

MitoticData = vertcat(MitoticData_1,MitoticData_2);
MitoticData = sortrows(MitoticData,1);

% Filter for LifeSpan
LifeSpan = 6; % Frames
Index_LS = (MitoticData.End(:) - MitoticData.Start(:)) > LifeSpan;
MitoticData = MitoticData(Index_LS,:);
Index_LS_2 = find(MitoticData.Start1 >= MitoticData.End | MitoticData.Start2 >= MitoticData.End);
MitoticData = MitoticData(Index_LS_2,:);

running_list = unique(MitoticData.ParentID);
countofunique = hist(MitoticData.ParentID, unique(MitoticData.ParentID));
index_1 = countofunique ==1;
index_2 = countofunique ==2;
IDs_1A = running_list(index_1);
Rows_1A = [];
for RT = 1:length(IDs_1A)
    ID = IDs_1A(RT);
    Row = find(MitoticData.ParentID == ID);
    Rows_1A = vertcat(Rows_1A, Row);
end
Mitotic_sub1 = MitoticData(Rows_1A,:);

IDs_2A = running_list(index_2);
Mitotic_sub2 = [];
for RT = 1:length(IDs_2A)
    ID = IDs_2A(RT);
    Row = find(MitoticData.ParentID == ID);
    New_Row = horzcat(MitoticData(Row(1),1:6), MitoticData(Row(2),7:9));
    Mitotic_sub2 = vertcat(Mitotic_sub2, New_Row);
end

MitoticData = vertcat(Mitotic_sub1,Mitotic_sub2);
MitoticData = sortrows(MitoticData,1);
MitoticData = double(MitoticData);

ALL_Data = [];
for RT = 1:length(MitoticData)
    Set_1 = horzcat(MitoticData(RT,1), MitoticData(RT,4), MitoticData(RT,5), MitoticData(RT,6));
    Set_2 = horzcat(MitoticData(RT,1), MitoticData(RT,7), MitoticData(RT,8), MitoticData(RT,9));
    Data = vertcat(Set_1, Set_2);
    ALL_Data = vertcat(ALL_Data,Data);
    Data = [];
end
Data = struct('ParentID', ALL_Data(:,1), 'DaughterID', ALL_Data(:,2),'BirthFrame', ALL_Data(:,3), 'EndFrame', ALL_Data(:,4));
Data = struct2dataset(Data);
Rows = find(Data.DaughterID ~= 0);
Data = Data(Rows,:);

Option_Data = zeros(length(Data),1);
EoE_Frame = max(Data.EndFrame(:));
Rows = find(Data.EndFrame == EoE_Frame);
EoE = Option_Data;
EoE(Rows) = 1;

Death = Option_Data;
Death_IDs = find(Data.EndFrame ~= EoE_Frame);
Death(Death_IDs,:) = 1;

Division_ALL = [];
for RT = 1:length(Data)
   Division = find(Data.DaughterID == Data.ParentID(RT));
   Division_ALL = vertcat(Division_ALL, Division);
end
Division_ALL = unique(Division_ALL);

Death(Division_ALL,:) = 0;

BirthTime = Data.BirthFrame * (TimeResolution / 60);
LifeSpan = (Data.EndFrame - Data.BirthFrame) * (TimeResolution / 60);

Right_Half = struct('EndofExperiment', EoE, 'Death', Death,'BirthTime',BirthTime, 'LifeSpan',LifeSpan);
Right_Half = struct2dataset(Right_Half);
FracProLife = horzcat(Data,Right_Half);

Rows = find(FracProLife.LifeSpan > 0);
FracProLife = FracProLife(Rows,:);

% Mitotic Cell Information....
mitotic_cells = find(FracProLife.EndofExperiment == 0 & FracProLife.Death == 0);
mitotic_cells = FracProLife(mitotic_cells,:);
% Censored Cell Information....
censored_cells = find(FracProLife.EndofExperiment == 1 & FracProLife.Death == 0);
censored_cells = FracProLife(censored_cells,:);

DataFileName='FracProLifev3';
Type2='.csv';
export(FracProLife, 'File', [ImageFolder DataFileName Date Type2],'Delimiter',',')

