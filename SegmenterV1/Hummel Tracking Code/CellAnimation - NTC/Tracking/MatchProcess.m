function [ALL_Selected, ALL_MO_Selected] = MatchProcess(StartFrame,EndFrame, FrameSkip, ALL_Selections, Mitotic_Options, Potential_Matches)

ALL_Selected = [];
ALL_MO_Selected = [];
MO_Selected = [];

for Frame = StartFrame:FrameSkip:EndFrame

Image_Potential_Matches = Potential_Matches(Potential_Matches.CurrentImage == Frame,:);
Image_Mitotic_Options = Mitotic_Options(Mitotic_Options.ImageNumber == Frame,:);
Image_Selections = ALL_Selections(ALL_Selections.ImageNumber == Frame,:);

if isempty(Image_Mitotic_Options)
     Non_Mitotic_Selections = find(Image_Selections.Selection == 1);
    All_Selected = Image_Potential_Matches(Non_Mitotic_Selections,:);
% % % %     List = find(Image_Selections.Selection == 1);
% % % %     All_Selected = [];
% % % %     for CT = 1:length(List)
% % % %        Row = List(CT);
% % % %        Selected = Image_Potential_Matches(Row,:);
% % % %        All_Selected = vertcat(All_Selected, Selected);
% % % %     end   
else
    MO_length = length(Image_Mitotic_Options.ParentID);
    IS_length = length(Image_Selections);
    Start_MO = IS_length-MO_length;
    
    Non_Mitotic_Selections = find(Image_Selections.Selection(1:Start_MO) == 1);
    All_Selected = Image_Potential_Matches(Non_Mitotic_Selections,:);
    
    MO_Selection = Image_Selections(Start_MO+1:end,:);
    MO_List = find(MO_Selection.Selection == 1);
    MO_Selected = Image_Mitotic_Options(MO_List,:);
    
% %     for CT = 1:length(MO_List)
% %        Row = MO_List(CT);
% %        Selected = Image_Mitotic_Options(Row,:);
% %        MO_Selected = vertcat(MO_Selected, Selected);
% %     end
% %     
% %     Modified_Selections = Image_Selections(1:(end-MO_length),:);
% %     List = find(Modified_Selections.Selection == 1);
% %     All_Selected = [];
% %     for CT = 1:length(List)
% %        Row = List(CT);
% %        Selected = Image_Potential_Matches(Row,:);
% %        All_Selected = vertcat(All_Selected, Selected);
% %     end
end
ALL_Selected = vertcat(ALL_Selected, All_Selected);
ALL_MO_Selected = vertcat(ALL_MO_Selected, MO_Selected);
MO_Selected = [];
All_Selected = [];

end

end