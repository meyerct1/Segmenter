function Focal_Adhesion_Tracks = FinalFATracking(OutputDirectory, DataFileName, Type3)

% % % OutputDirectory='~/Documents/';
% % % Type3 = '.xlsx';
% % % DataFileName = 'FocalAdhesionDataTESTB_Box';

% Data Import
FA_Data = xlsread([OutputDirectory DataFileName Type3]);
FA_Data = struct('Counts', FA_Data(:,1), 'ImageNumber', FA_Data(:,2), 'Slice', FA_Data(:,3), ...
    'CentroidX', FA_Data(:,4), 'CentroidY', FA_Data(:,5), 'Area', FA_Data(:,6), 'Intensity', FA_Data(:,7), ...
    'IndexID', FA_Data(:,8), 'Distance', FA_Data(:,9), 'Original_Idx', FA_Data(:,10));
FA_Data = struct2dataset(FA_Data);
Images = unique(FA_Data.ImageNumber);
ALL_FAs = [];

% The Focal Adhesions in an Image are averaged in terms of their location
% across the slices so that there is One X- and One Y- location per focal
% adhesion for the image.
for image_n = 1:length(Images)
    number = Images(image_n);
    ExamineImage = FA_Data(FA_Data.ImageNumber == number,:);
   for RT = 1:length(unique(ExamineImage.IndexID))
       List = unique(ExamineImage.IndexID);
       IDs = List(RT);
       FAs = ExamineImage(ExamineImage.IndexID == IDs,:);
       Mean_CentroidX = mean(FAs.CentroidX);
       Mean_CentroidY = mean(FAs.CentroidY);
       Mean_Area = mean(FAs.Area);
       Mean_Intensity = mean(FAs.Intensity);
       Reference_ID = FAs.Counts(1);
       Focals = struct('InitialID', FAs.IndexID(1,:), 'ImageNumber', FAs.ImageNumber(1,:), ...
                'Slice', FAs.Slice(1,:), 'Mean_CentroidX', Mean_CentroidX, 'Mean_CentroidY', ...
                Mean_CentroidY, 'Mean_Area', Mean_Area, 'Mean_Intensity', Mean_Intensity, 'Reference', Reference_ID);
       Focals = struct2dataset(Focals);
       ALL_FAs = vertcat(ALL_FAs, Focals);    
   end    
end

% Tracking using a KNN Nearest Neighbor Algorithm (MATLABs internal)
Images = unique(ALL_FAs.ImageNumber);
for TT = 1:length(Images) 
    if TT == 1
        CurrentImage = ALL_FAs(ALL_FAs.ImageNumber == Images(TT),:);
        [FA_IDs, FA_distance] = knnsearch(CurrentImage(:,4:5), CurrentImage(:,4:5));
        Indexed = struct('Focal_IDs', FA_IDs, 'Focal_Distance', FA_distance);
        Indexed = struct2dataset(Indexed);
        Initial_Tracks = horzcat(CurrentImage, Indexed);
        
    else
        CurrentImage = ALL_FAs(ALL_FAs.ImageNumber == Images(TT),:);
        PreviousImage = ALL_FAs(ALL_FAs.ImageNumber == Images(TT-1),:);
        [FA_IDs, FA_distance] = knnsearch(PreviousImage(:,4:5), CurrentImage(:,4:5),'NSMethod','exhaustive');
        ALL_Index = [];
        
        for YT = 1:length(FA_IDs)
        row = FA_IDs(YT);
        distance = FA_distance(YT);
        FA_sub = Initial_Tracks(Initial_Tracks.ImageNumber == Images(TT-1),:);
        Previous_ID = FA_sub.Focal_IDs(row);
        Indexed = struct('Focal_IDs', Previous_ID, 'Focal_Distance', distance);
        Indexed = struct2dataset(Indexed);
        ALL_Index = vertcat(ALL_Index, Indexed);
        
        end
        Current = horzcat(CurrentImage, ALL_Index);
        
        NumRep_IDs = length(Current.Focal_IDs) - length(unique(Current.Focal_IDs));
        for Rep_IDs = 1:NumRep_IDs
        if length(Current.Focal_IDs) == length(unique(Current.Focal_IDs))
        else
        Values = unique(Current.Focal_IDs);
        countofunique = hist(Current.Focal_IDs, Values);
        index = countofunique ~=1;
        repeatedvalues = Values(index);
        new_ID_check = isempty(repeatedvalues);
        for new_ID_check = 0
               [run y] = size(repeatedvalues);
               for repeat_length = 1:run
                ID_check = Current(Current.Focal_IDs == (repeatedvalues(repeat_length)),:);   
                max_distance = max(ID_check.Focal_Distance);
                furthest_away = ID_check(ID_check.Focal_Distance == max_distance,:);
                new_ID = (max(Initial_Tracks.Focal_IDs) + repeat_length + Rep_IDs);
                [row, col] = find(Current.Focal_Distance == max_distance);
                Current.Focal_IDs(row) = new_ID;
                Current.Focal_Distance(row,:) = 0;
               end 
           end  
        end
        end
        
        Initial_Tracks = vertcat(Initial_Tracks, Current);
    end
     
 end
Focal_Adhesion_Tracks = struct('ImageNumber', Initial_Tracks.ImageNumber,'Slice',Initial_Tracks.Slice,...
    'Focal_IDs', Initial_Tracks.Focal_IDs,'Focal_Distance',Initial_Tracks.Focal_Distance, ...
    'Mean_CentroidX', Initial_Tracks.Mean_CentroidX, 'Mean_CentroidY', Initial_Tracks.Mean_CentroidY, ...
    'Mean_Area', Initial_Tracks.Mean_Area, 'Mean_Intensity', Initial_Tracks.Mean_Intensity, 'Reference', Initial_Tracks.Reference);
Focal_Adhesion_Tracks = struct2dataset(Focal_Adhesion_Tracks);

end





