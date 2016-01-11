function Tracks = GlobalTracks(Potential_Matches, ALL_Selected, ALL_MO_Selected, StartFrame, EndFrame, FrameSkip)

[rows cols] = size(ALL_Selected);
Track_ID = zeros(rows, 1);
Information = zeros(rows, 1);

Track_Info = struct('TrackID', Track_ID,'Information',Information);
Track_Info = struct2dataset(Track_Info);
Updated_Selection = horzcat(Track_Info(:,1), ALL_Selected, Track_Info(:,2));

if isempty(ALL_MO_Selected)
    Siblings = [];
else
    MO_Track_ID = zeros(1,1);
    MO_Information = zeros(1,1);
    MO_Track_Info = struct('TrackID', MO_Track_ID,'Information',MO_Information);
    MO_Track_Info = struct2dataset(MO_Track_Info);
    Siblings = [];
    for RT = 1: length(ALL_MO_Selected)
        Frame = ALL_MO_Selected.ImageNumber(RT);
        Par_ID = ALL_MO_Selected.ParentID(RT);
        Daughter1_ID = ALL_MO_Selected.Daughter1(RT);
        Daughter2_ID = ALL_MO_Selected.Daughter2(RT);
        Daughter1_loc = find(Potential_Matches.Curr_KNN_ID == Par_ID & Potential_Matches.Next_KNN_ID == Daughter1_ID & Potential_Matches.CurrentImage == Frame);
        Daughter2_loc = find(Potential_Matches.Curr_KNN_ID == Par_ID & Potential_Matches.Next_KNN_ID == Daughter2_ID & Potential_Matches.CurrentImage == Frame);
        Daughter_1 = horzcat(MO_Track_Info(:,1),(Potential_Matches(Daughter1_loc,:)), MO_Track_Info(:,2));
        Daughter_2 = horzcat(MO_Track_Info(:,1),(Potential_Matches(Daughter2_loc,:)), MO_Track_Info(:,2));
        Daughter_1.Information = 111222;
        Daughter_2.Information = 222111;
        Daughters = vertcat(Daughter_1, Daughter_2);
        Siblings = vertcat(Siblings, Daughters);
    end
end
Updated_Selection = vertcat(Updated_Selection, Siblings);
Updated_Selection = sortrows(Updated_Selection, 2);

Frame = [];
for Frame = StartFrame:FrameSkip:EndFrame
Image_Tracks = Updated_Selection(Updated_Selection.CurrentImage == Frame,:);
    
if Frame == 1 % Set up of Initial Tracks
    StartList = length(Image_Tracks);
        for CT = 1:StartList
           Updated_Selection.TrackID(CT) = CT; 
        end
    
else % All Subset Images
    PreviousTrack = Updated_Selection(Updated_Selection.CurrentImage == Frame-FrameSkip,:);    
    X_length = length(unique(Image_Tracks.PDF_Sum));
    %  X_length = length(unique(Image_Tracks.Curr_X));    %%%%%%%
  for XT = 1:X_length 
            Curr_loc = Image_Tracks.Curr_X(XT);
            Curr_locY = Image_Tracks.Curr_Y(XT);
            CurrArea = Image_Tracks.Curr_Area(XT);
            PreviousRow = find(PreviousTrack.Next_X == Curr_loc & PreviousTrack.Next_Y == Curr_locY & PreviousTrack.Next_Area == CurrArea);
        if isempty(PreviousRow)
            Row = [];
        else
            ContinuedID = PreviousTrack.TrackID(PreviousRow);
            Row = find(Updated_Selection.CurrentImage == Frame & Updated_Selection.Curr_X == Curr_loc);
        end
       
        if isempty(Row)
        else
            Updated_Selection.TrackID(Row) = ContinuedID;
        end
  end  
 
    Tracks_NotID = find(Updated_Selection.TrackID == 0 & Updated_Selection.CurrentImage == Frame);
    Largest_TrackID = max(Updated_Selection.TrackID);
    if isempty(Tracks_NotID)
    else
        for TNI = 1:length(Tracks_NotID)
            Loc = Tracks_NotID(TNI);
            Updated_Selection.TrackID(Loc) = (TNI + Largest_TrackID);
            if Updated_Selection.Information(Loc) == 0
            Updated_Selection.Information(Loc) = 333333;
            else
            end
        end
    end
    Daughter1 = find(Updated_Selection.CurrentImage == Frame & Updated_Selection.Information == 111222);
    Daughter2 = find(Updated_Selection.CurrentImage == Frame & Updated_Selection.Information == 222111);
    for DA = 1:length(Daughter1)
       DA_row = Daughter1(DA);
       DB_row = Daughter2(DA);
       Updated_Selection.TrackID(DA_row) = (max(Updated_Selection.TrackID) + 1);
       Updated_Selection.TrackID(DB_row) = (max(Updated_Selection.TrackID) + 1);
    end
       
end
Tracks = Updated_Selection;
%%%Tracks = Updated_Selection;
end