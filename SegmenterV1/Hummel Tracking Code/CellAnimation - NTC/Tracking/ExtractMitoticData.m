function [MitoticData, Combined_MO_cells,Possible_Missed, FracProLife]  = ExtractMitoticData(TimeResolution, Tracks,ALL_MO_Selected, FrameSkip, PotentialRange, ImageWidth, ImageHeight)
% Extract Mitotic Event Data

MitoticData = [];
Images = unique(ALL_MO_Selected.ImageNumber);
Set111 = find(Tracks.Information == 111222);
Set222 = find(Tracks.Information == 222111);
for RT = 1:length(Set111)
    Row111 = Set111(RT);
    Row222 = Set222(RT);
    Daughter1_Start = Tracks(Row111,:);
    Daughter2_Start = Tracks(Row222,:);
% %     Parent_Loc = uint64(Daughter1_Start.Curr_X);
% %     Parent_row = find(Tracks.CurrentImage == (Daughter1_Start.CurrentImage-FrameSkip) & (uint64(Tracks.Next_X) == Parent_Loc));
    Parent_Loc = Daughter1_Start.Curr_X;
    Parent_row = find(Tracks.CurrentImage == (Daughter1_Start.CurrentImage-FrameSkip) & (Tracks.Next_X == Parent_Loc));    
    Parent_Info = Tracks(Parent_row,:);
    Parent_ID = Parent_Info.TrackID;
    if isempty(Parent_ID)
    elseif length(Parent_ID) > 1
    else
    Parent = Tracks(Tracks.TrackID == Parent_ID,:);
    Daughter1 = Tracks(Tracks.TrackID == Daughter1_Start.TrackID,:);
    Daughter2 = Tracks(Tracks.TrackID == Daughter2_Start.TrackID,:);
    MO_Info = struct('ParentID', Parent.TrackID(1), 'Start', min(Parent.CurrentImage), 'End', max(Parent.CurrentImage), ...
            'Daughter1', Daughter1.TrackID(1), 'Start1', min(Daughter1.CurrentImage), 'End1', max(Daughter1.CurrentImage),...
            'Daughter2', Daughter2.TrackID(1), 'Start2', min(Daughter2.CurrentImage), 'End2', max(Daughter2.CurrentImage));
    MO_Info = struct2dataset(MO_Info);
    MitoticData = vertcat(MitoticData, MO_Info);
    end
end

%%%%%%%%%%%%%
Factor = 20;
Possible_Missed = [];
Other_Options = Tracks(Tracks.Information == 333333,:);
Other_Options = Other_Options(Other_Options.Curr_X >= (PotentialRange * Factor),:);
Other_Options = Other_Options(Other_Options.Curr_X <= (ImageWidth - (PotentialRange * Factor)),:);
Other_Options = Other_Options(Other_Options.Curr_Y >= (PotentialRange * Factor),:);
Other_Options = Other_Options(Other_Options.Curr_Y <= (ImageHeight - (PotentialRange * Factor)),:);
Possibles = length(Other_Options);
    for ER = 1:Possibles
        Examine = Other_Options(ER,:);
        Test1 = find(MitoticData.Daughter1 == Examine.TrackID | MitoticData.Daughter2 == Examine.TrackID);
        if isempty(Test1)
            Examine_Track = Tracks(Tracks.TrackID == Examine.TrackID,:);
            Possible_Info = struct('ParentID', 0, 'Start', 0, 'End', 0, ...
            'Daughter1', 0, 'Start1',0, 'End1', 0,...
            'Daughter2', Examine_Track.TrackID(1), 'Start2', min(Examine_Track.CurrentImage), 'End2', max(Examine_Track.CurrentImage));
            Possible_Info = struct2dataset(Possible_Info);
            Possible_Missed = vertcat(Possible_Missed, Possible_Info);
        else
        end          
    end

Combined_MO_cells = vertcat(MitoticData, Possible_Missed);
ALL_BF = [];
ALL_EF = [];
ALL_DaughIDs = [];
ALL_ParIDs = [];

for TT = 1:length(Combined_MO_cells)
   Data = Combined_MO_cells(TT,:);
   Data = dataset2cell(Data);
   ParentIDs = vertcat(Data(2,1), Data(2,1));
   DaughterIDs = vertcat(Data(2,4), Data(2,7));
   BirthFrames = vertcat(Data(2,5), Data(2,8));
   EndFrames = vertcat(Data(2,6), Data(2,9));
   ALL_ParIDs = vertcat(ALL_ParIDs, ParentIDs);
   ALL_DaughIDs = vertcat(ALL_DaughIDs, DaughterIDs);
   ALL_BF = vertcat(ALL_BF, BirthFrames);
   ALL_EF = vertcat(ALL_EF, EndFrames);
   FracData = struct('ParentID', ALL_ParIDs, 'DaughterID', ALL_DaughIDs,'BirthFrame', ALL_BF, 'EndFrame', ALL_EF);
   FracData = struct2dataset(FracData);    
end
Remove = find(FracData.EndFrame ~= 0);
NewFrac = FracData(Remove,:);
FracData = NewFrac;
BirthTime = FracData.BirthFrame * (TimeResolution / 60);
LifeSpan = (FracData.EndFrame - FracData.BirthFrame) * (TimeResolution / 60);
MaxFrame = max(FracData.EndFrame);
Index = true(1, length(FracData.EndFrame));
Index = rot90(Index);
% Index = Index & FracData.EndFrame == MaxFrame;
EndofExperiment = Index & FracData.EndFrame == MaxFrame; % find(FracData.EndFrame == MaxFrame);

RTRT = [];
    for EW = 1:length(FracData)
       ID = FracData.DaughterID(EW);
       Test = find(FracData.ParentID == ID);
       Mit_IDs = FracData.ParentID(Test);
       RTRT = vertcat(RTRT, Mit_IDs);
       Daughter_Mit = unique(RTRT);  
    end

Index = true(1, length(FracData.EndFrame));
Index = rot90(Index);
Death = Index & FracData.EndFrame ~= MaxFrame; 
for QQ = 1:length(Daughter_Mit)
Death = Death & FracData.DaughterID ~= Daughter_Mit(QQ);
end
% % Death = Death & (FracData.DaughterID ~= FracData.ParentID);
NewFrac = struct('EndofExperiment', EndofExperiment, 'Death', Death,'BirthTime',BirthTime, 'LifeSpan',LifeSpan);
NewFrac = struct2dataset(NewFrac);
FracProLife = horzcat(FracData, NewFrac);


end
