function [KNN_Characteristics, IP_Information_TRACKS, BorderTracksALL, HighConfidenceALL, TheLeftOverTracksALL ]...
           = InitialTracks10(StartFrame, FrameSkip, EndFrame, MaxFrames, ImageFolder, Type, ImageWidth, ImageHeight, ImageBorder)

load([ImageFolder 'Characterisitcs' Type]);
KNN_Characteristics = struct('InitialObjectID',1, 'KNN_ID', 2, 'KNN_Distance',3, 'ImageNumber', 4, 'CentroidX',5,...
                         'CentroidY',6,'Area',7, 'Eccentricity',8, 'Perimeter',9,'MajorAxisLength',10,...
                         'MinorAxisLength',11, 'ConvexArea',12, 'EquivDiameter',13, 'FilledArea',14, 'Solidity',15,...
                         'Intensity',16, 'Events',17);
KNN_Characteristics_sub = struct('InitialObjectID',1, 'KNN_ID', 2, 'KNN_Distance',3, 'ImageNumber', 4, 'CentroidX',5,...
                         'CentroidY',6,'Area',7, 'Eccentricity',8, 'Perimeter',9,'MajorAxisLength',10,...
                         'MinorAxisLength',11, 'ConvexArea',12, 'EquivDiameter',13, 'FilledArea',14, 'Solidity',15,...
                         'Intensity',16, 'Events',17);
FirstImage = Characteristics(Characteristics.ImageNumber == StartFrame,:);
% LastImage = Characteristics(Characteristics.ImageNumber == EndFrame,:);

for knn = (StartFrame:FrameSkip:EndFrame)
   if knn == StartFrame
       [knn_trackID, knn_distance] = knnsearch(FirstImage(:,[1 3:4]),FirstImage(:,[1 3:4]));

       KNN_Characteristics.InitialObjectID= FirstImage.ImageObjectID;
       KNN_Characteristics.KNN_ID = knn_trackID;
       KNN_Characteristics.KNN_Distance = knn_distance;
       KNN_Characteristics.ImageNumber = repmat(knn,[size(unique(FirstImage.ImageObjectID)),1]);
       KNN_Characteristics.CentroidX= FirstImage.CentroidX;
       KNN_Characteristics.CentroidY= FirstImage.CentroidY;
       KNN_Characteristics.Area= FirstImage.Area;
       KNN_Characteristics.Eccentricity = FirstImage.Eccentricity;
       KNN_Characteristics.Perimeter = FirstImage.Perimeter;
       KNN_Characteristics.MajorAxisLength = FirstImage.MajorAxisLength;
       KNN_Characteristics.MinorAxisLength = FirstImage.MinorAxisLength;
       KNN_Characteristics.ConvexArea = FirstImage.ConvexArea;
       KNN_Characteristics.EquivDiameter = FirstImage.EquivDiameter;
       KNN_Characteristics.FilledArea = FirstImage.FilledArea;
       KNN_Characteristics.Solidity = FirstImage.Solidity;
       KNN_Characteristics.Intensity = FirstImage.Intensity;
       KNN_Characteristics.Events = FirstImage.Events;
       
       KNN_Characteristics = struct2dataset(KNN_Characteristics);
   else
       % Nearest Neighbor Search for remaining images
       NEWImage = Characteristics(Characteristics.ImageNumber == knn,:);
       PREVIOUSImage = KNN_Characteristics(KNN_Characteristics.ImageNumber == knn-FrameSkip,:);
 
       [knn_trackID_sub, knn_distance_sub] = knnsearch(PREVIOUSImage(:,5:8),NEWImage(:,3:6), 'NSMethod','exhaustive');
       new_IDs = double(PREVIOUSImage((knn_trackID_sub(1:end)),2));
       running = unique(new_IDs);
       countofunique = hist(new_IDs, unique(new_IDs));
       index = countofunique ~=1;
       repeatedvalues = running(index);
       new_ID_generator = isempty(repeatedvalues);
       
       KNN_Characteristics_sub.InitialObjectID= NEWImage.ImageObjectID;
       KNN_Characteristics_sub.KNN_ID = new_IDs;
       KNN_Characteristics_sub.KNN_Distance = knn_distance_sub;
       KNN_Characteristics_sub.ImageNumber = repmat(knn,[size(unique(NEWImage.ImageObjectID)),1]);
       KNN_Characteristics_sub.CentroidX= NEWImage.CentroidX;
       KNN_Characteristics_sub.CentroidY= NEWImage.CentroidY;
       KNN_Characteristics_sub.Area= NEWImage.Area;
       KNN_Characteristics_sub.Eccentricity = NEWImage.Eccentricity;
       KNN_Characteristics_sub.Perimeter = NEWImage.Perimeter;
       KNN_Characteristics_sub.MajorAxisLength = NEWImage.MajorAxisLength;
       KNN_Characteristics_sub.MinorAxisLength = NEWImage.MinorAxisLength;
       KNN_Characteristics_sub.ConvexArea = NEWImage.ConvexArea;
       KNN_Characteristics_sub.EquivDiameter = NEWImage.EquivDiameter;
       KNN_Characteristics_sub.FilledArea = NEWImage.FilledArea;
       KNN_Characteristics_sub.Solidity = NEWImage.Solidity;
       KNN_Characteristics_sub.Intensity = NEWImage.Intensity;
       KNN_Characteristics_sub.Events = NEWImage.Events;
       
       KNN_Characteristics_sub2 = struct2dataset(KNN_Characteristics_sub); 
       
       for new_ID_generator = 0
           [run y] = size(repeatedvalues);
           for repeat_length = 1:run   % length(repeatedvalues)
           older_ID_matrix = PREVIOUSImage(PREVIOUSImage.KNN_ID == (repeatedvalues(repeat_length)),:);
           old_ID_matrix = KNN_Characteristics_sub2(KNN_Characteristics_sub2.KNN_ID == (repeatedvalues(repeat_length)),:);
           max_distance = max(old_ID_matrix.KNN_Distance);
           old_ID_matrix = old_ID_matrix(old_ID_matrix.KNN_Distance == max_distance,:);
           [row, col] = find(KNN_Characteristics_sub2.KNN_Distance == max_distance);
           new_ID = (row * 100) * 100 + KNN_Characteristics_sub2.ImageNumber(1);
%            new_ID = (old_ID_matrix.KNN_ID * 100 + knn) * 100 + KNN_Characteristics_sub2.InitialObjectID(row);
           KNN_Characteristics_sub2.KNN_ID(row,:) = new_ID;
           end  
       end
       
%%
       NumRep_IDs = length(KNN_Characteristics_sub2) - length(unique(KNN_Characteristics_sub2.KNN_ID)); 
for rep_IDs = 1:NumRep_IDs 
    if length(KNN_Characteristics_sub2.KNN_ID) == length(unique(KNN_Characteristics_sub2.KNN_ID))
        continue
    else
        running2 = unique(KNN_Characteristics_sub2.KNN_ID);
        countofunique2 = hist(KNN_Characteristics_sub2.KNN_ID, unique(KNN_Characteristics_sub2.KNN_ID));
        index2 = countofunique2 ~=1;
        repeatedvalues2 = running2(index2);
        new_ID_check = isempty(repeatedvalues2);  
           for new_ID_check = 0
               [run y] = size(repeatedvalues2);
               for repeat_length2 = 1:run
                ID_check = KNN_Characteristics_sub2(KNN_Characteristics_sub2.KNN_ID == (repeatedvalues2(repeat_length2)),:);   
                max_distance = max(ID_check.KNN_Distance);
                furthest_away = ID_check(ID_check.KNN_Distance == max_distance,:);
                newer_ID = 10000 + furthest_away.InitialObjectID + furthest_away.KNN_ID;
                [row, col] = find(KNN_Characteristics_sub2.KNN_Distance == max_distance);
                KNN_Characteristics_sub2.KNN_ID(row,:) = newer_ID;
               end 
           end   
    end
end

  KNN_Characteristics = vertcat(KNN_Characteristics, KNN_Characteristics_sub2);
   end
end

IP_Information_TRACKS = [];
for j = 1:length(unique(KNN_Characteristics.KNN_ID))
  TotalUniqueID = unique(KNN_Characteristics.KNN_ID);
  Cell_ID = TotalUniqueID(j);
  IP_Information = KNN_Characteristics(KNN_Characteristics.KNN_ID == Cell_ID,:);
  Potential_MC = strmatch('dividing', IP_Information.Events);
  max_length = length(IP_Information);
  Start_Frame_IP = min(IP_Information.ImageNumber); % (1,:);
  End_Frame_IP = max(IP_Information.ImageNumber); %(max_length,:); % Look at dividing cells
  Start_LocationX = IP_Information.CentroidX(1,:);
  Start_LocationY = IP_Information.CentroidY(1,:);
  Start_Area = IP_Information.Area(1,:);
  Start_Eccentricity = IP_Information.Eccentricity(1,:);
  Start_Perimeter = IP_Information.Perimeter(1,:);
  Start_MajorAxis = IP_Information.MajorAxisLength(1,:);
  Start_MinorAxis = IP_Information.MinorAxisLength(1,:);
  Start_ConvexArea = IP_Information.ConvexArea(1,:);
  Start_EquivDiameter = IP_Information.EquivDiameter(1,:);
  Start_Solidity = IP_Information.Solidity(1,:);
  Start_Intensity = IP_Information.Intensity(1,:);
  Start_Event = IP_Information.Events(1,:);
  % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
  End_LocationX = IP_Information.CentroidX(max_length);
  End_LocationY = IP_Information.CentroidY(max_length);
  End_Area = IP_Information.Area(max_length);
  End_Eccentricity = IP_Information.Eccentricity(max_length);
  End_Perimeter = IP_Information.Perimeter(max_length);
  End_MajorAxis = IP_Information.MajorAxisLength(max_length);
  End_MinorAxis = IP_Information.MinorAxisLength(max_length);
  End_ConvexArea = IP_Information.ConvexArea(max_length);
  End_EquivDiameter = IP_Information.EquivDiameter(max_length);
  End_Solidity = IP_Information.Solidity(max_length);
  End_Intensity = IP_Information.Intensity(max_length);
  End_Event = IP_Information.Events(max_length);

  IP_Information_TRACKS = vertcat(IP_Information_TRACKS, IP_Information);
end

%% Clears cells near the image edge
BorderTracksALL = [];
for CT = 1:length(unique(KNN_Characteristics.KNN_ID))
   TotalUniqueID = unique(KNN_Characteristics.KNN_ID);
   Cell_ID = TotalUniqueID(CT);
   BorderTracks = IP_Information_TRACKS(IP_Information_TRACKS.KNN_ID == Cell_ID,:);
   HorizontalWidthMin = min(BorderTracks.CentroidX) >= (ImageWidth * ImageBorder); 
   HorizontalWidthMax = max(BorderTracks.CentroidX) <= (ImageWidth - (ImageWidth * ImageBorder));
   VerticalMin = min(BorderTracks.CentroidY) >= (ImageHeight * ImageBorder);
   VerticalMax = max(BorderTracks.CentroidY) <= (ImageHeight - (ImageHeight * ImageBorder));
   BorderSum = HorizontalWidthMax + HorizontalWidthMin + VerticalMax + VerticalMin;
   if BorderSum == 4
      BorderTracksALL = vertcat(BorderTracksALL, BorderTracks);
     BorderTracks = [];
       continue
   end
% % %    if BorderSum == 0
% % %       BorderTracksRunning = BorderTracks;
% % %    else
% % %        continue
% % %    end
% % %      BorderTracksALL = vertcat(BorderTracksALL, BorderTracks);
% % %      BorderTracks = [];
end
%% NEED TO ID THE CONTINUOUS TRACKS FROM THE START FRAME TO THE MAX FRAME
HighConfidenceALL = [];
HighConfidence = [];
TheLeftOverTracksALL = [];
TheLeftOverTracks =[];
SelectTracks_All = [];
for CT = (StartFrame:FrameSkip:MaxFrames)
    SelectTracks = BorderTracksALL(BorderTracksALL.ImageNumber == CT,:);
    SelectTracks_All = vertcat(SelectTracks_All, SelectTracks);
    SelectTracks = [];
end

for CT = 1: length(unique(SelectTracks_All.KNN_ID))
       TotalUniqueID = unique(SelectTracks_All.KNN_ID);
       Cell_ID = TotalUniqueID(CT);
       ConfidenceTracks = SelectTracks_All(SelectTracks_All.KNN_ID == Cell_ID,:); % IP_Information_TRACKS(IP_Information_TRACKS.KNN_ID == Cell_ID,:);
       Potential_Mitotic = strmatch('dividing', ConfidenceTracks.Events);
       Area_Limit = find(ConfidenceTracks.Area >= 5000);
       ContinuousTracks = max(ConfidenceTracks.ImageNumber) - ConfidenceTracks.ImageNumber(1);
       FrameDiff = (max(StartFrame:FrameSkip:MaxFrames))-StartFrame;
       if ContinuousTracks == FrameDiff  && isempty(Potential_Mitotic) % && isempty(Area_Limit)
   % Track begins at start frame and ends at the last frame with no mitotic event
      HighConfidence = ConfidenceTracks; 
   else
       TheLeftOverTracks = ConfidenceTracks;
   end
    HighConfidenceALL = vertcat(HighConfidenceALL, HighConfidence);
    TheLeftOverTracksALL = vertcat(TheLeftOverTracksALL, TheLeftOverTracks);
    HighConfidence =[];
    TheLeftOverTracks = [];   
end

    TheLeftOverTracksALL = BorderTracksALL;
%%
end