 function Testing = MergeTracks(Tracks, StartFrame, EndFrame, FrameSkip, ImageWidth, ImageHeight, PotentialRange)
PotentialRange = PotentialRange;
EndFrame = EndFrame;
 
 
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
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% TRACK EDGE FILTER
minX = ImageWidth * 0.05;
maxX = ImageWidth - (ImageWidth * 0.05);
minY = ImageHeight * 0.05;
maxY = ImageHeight - (ImageHeight * 0.05);

EdgeIndex = find(All_Tracker.StartX >= minX & All_Tracker.StartX <= maxX & All_Tracker.StartY <= maxY & All_Tracker.StartY >= minY); 
All_Tracker = All_Tracker(EdgeIndex,:);
EdgeIndex = find(All_Tracker.EndX >= minX & All_Tracker.EndX <= maxX & All_Tracker.EndY <= maxY & All_Tracker.EndY >= minY);
All_Tracker = All_Tracker(EdgeIndex,:);
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %
All_Adjust = [];
All_Mitotic = [];
MitoticID = [];
AdjustID = [];
for RT = (StartFrame:FrameSkip:EndFrame)
   pause on
   ExamineSet = All_Tracker(All_Tracker.StartFrame == RT,:);
   if isempty(ExamineSet)
   else
       if RT == 1
       else
          CompareSet = All_Tracker(All_Tracker.EndFrame == RT-FrameSkip,:); 
          if isempty(CompareSet)
          else
              Plot = MergePlot(ExamineSet, Tracks, CompareSet, PotentialRange, EndFrame); 
              prompt = 'Are there tracks to adjust? Y/N: ';
              str = input(prompt,'s');
              if isempty(str)                  
              elseif str == 'N'
              elseif str == 'n'
              else
                  prompt = 'How many tracks to adjust? ';
                  adjust = input(prompt);
                  AdjustID = [];
                  Mitotic = [];
                  for UT = 1:adjust
                  prompt = 'Potential Mitotic Event? Y/N: ';
                  str = input(prompt,'s');
                      if str == 'Y'
                          prompt = 'Enter ParentID: ';
                          parent = input(prompt);
                          prompt = 'Enter Daughter_1 ID: ';
                          daughter1 = input(prompt);
                          prompt = 'Enter Daughter_2 ID: ';
                          daughter2 = input(prompt);
                          Mitotic = horzcat(RT, parent, daughter1, daughter2);    
                      else
                          prompt = 'Enter TrackID to continue: ';
                          oldTrackID = input(prompt);
                          prompt = 'Enter premature TrackID: ';
                          PrematureTrackID = input(prompt);
                          IDs = horzcat(RT, oldTrackID, PrematureTrackID);
                      end
                      MitoticID = vertcat(MitoticID, Mitotic);
                      AdjustID = vertcat(AdjustID, IDs);
                      IDs = [];
                      Mitotic = [];
                  end
              end
          end
       end
   end 
   clf
   All_Adjust = vertcat(All_Adjust, AdjustID);
   All_Mitotic = vertcat(All_Mitotic, MitoticID);
   AdjustID = [];
   MitoticID = [];
end



Testing = Tracks;
end