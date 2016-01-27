function Mitotic_Options = MitoticOptionsv2(StartFrame, FrameSkip, EndFrame, Potential_Matches)

CT = [];
Mitotic_Options = [];
for add = (StartFrame:FrameSkip:EndFrame)
    Option = Potential_Matches(Potential_Matches.CurrentImage == add,:);

% Initial Portion Finds Mitotic Events
    Curr_dividing = strmatch('dividing', Option.Curr_Event);
    Next_dividing = strmatch('dividing', Option.Next_Event);
    mitotic = intersect(Curr_dividing, Next_dividing);
    
    MO_subset_ALL = [];
    if isempty(mitotic)
        continue
    else
        for CT = 1:length(mitotic)
          number = mitotic(CT);
          MO_subset = Option(number,:);
          MO_subset_ALL = vertcat(MO_subset_ALL, MO_subset);
          MO_subset = [];   
        end
         MO_IDs = unique(MO_subset_ALL.Curr_KNN_ID);
         
         for MO2 = 1: length(MO_IDs)
          Options = MO_IDs(MO2);
          mitotic = MO_subset_ALL(MO_subset_ALL.Curr_KNN_ID == Options,:);          
          mitotic_all = length(mitotic); 
          if mitotic_all == 1             
              Mitotic_Options_STE = [];
          
          elseif mitotic_all == 2       
              Option1 = mitotic(1,:);
              Option2 = mitotic(2,:);
          
              PDF_mitotic = Option1.PDF_Sum + Option2.PDF_Sum;
              Parental_mitotic = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option1.Next_KNN_ID, Option2.Next_KNN_ID, PDF_mitotic);
              Mitotic_Options_STE = Parental_mitotic;
              
          elseif mitotic_all == 3
              Option1 = mitotic(1,:);
              Option2 = mitotic(2,:);
              Option3 = mitotic(3,:);
              
              PDF_mitotic1 = Option1.PDF_Sum + Option2.PDF_Sum;
              PDF_mitotic2 = Option1.PDF_Sum + Option3.PDF_Sum;
              PDF_mitotic3 = Option2.PDF_Sum + Option3.PDF_Sum;
              Parental_mitotic1 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option1.Next_KNN_ID, Option2.Next_KNN_ID, PDF_mitotic1);
              Parental_mitotic2 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option1.Next_KNN_ID, Option3.Next_KNN_ID, PDF_mitotic2);
              Parental_mitotic3 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option2.Next_KNN_ID, Option3.Next_KNN_ID, PDF_mitotic3);              
              Mitotic_Options_STE = vertcat(Parental_mitotic1, Parental_mitotic2, Parental_mitotic3);   
          else
              Option1 = mitotic(1,:);
              Option2 = mitotic(2,:);
              Option3 = mitotic(3,:);
              Option4 = mitotic(4,:);
              
              PDF_mitotic1 = Option1.PDF_Sum + Option2.PDF_Sum;
              PDF_mitotic2 = Option1.PDF_Sum + Option3.PDF_Sum;
              PDF_mitotic3 = Option1.PDF_Sum + Option4.PDF_Sum;
              PDF_mitotic4 = Option2.PDF_Sum + Option3.PDF_Sum;
              PDF_mitotic5 = Option2.PDF_Sum + Option4.PDF_Sum;
              PDF_mitotic6 = Option3.PDF_Sum + Option4.PDF_Sum;

              Parental_mitotic1 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option1.Next_KNN_ID, Option2.Next_KNN_ID, PDF_mitotic1);
              Parental_mitotic2 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option1.Next_KNN_ID, Option3.Next_KNN_ID, PDF_mitotic2);
              Parental_mitotic3 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option1.Next_KNN_ID, Option4.Next_KNN_ID, PDF_mitotic3);
              Parental_mitotic4 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option2.Next_KNN_ID, Option3.Next_KNN_ID, PDF_mitotic4);
              Parental_mitotic5 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option2.Next_KNN_ID, Option4.Next_KNN_ID, PDF_mitotic5);
              Parental_mitotic6 = horzcat(Option1.CurrentImage, Option1.Curr_KNN_ID, Option3.Next_KNN_ID, Option4.Next_KNN_ID, PDF_mitotic6);

              Mitotic_Options_STE = vertcat(Parental_mitotic1, Parental_mitotic2, Parental_mitotic3, Parental_mitotic4, Parental_mitotic5, Parental_mitotic6);
                            
          end 
          Mitotic_Options = vertcat(Mitotic_Options, Mitotic_Options_STE);
         end
         
    end   
end
 Mitotic_Options_ALL = struct('ImageNumber', Mitotic_Options(:,1),'ParentID',Mitotic_Options(:,2), ...
              'Daughter1', Mitotic_Options(:,3), 'Daughter2', Mitotic_Options(:,4), 'PDF_Sum',Mitotic_Options(:,5));
 Mitotic_Options = struct2dataset(Mitotic_Options_ALL); 

end