function [Array, L_PDF, Three, intcon, lower_bounds, upper_bounds] = MainArray_STE(Potential_Matches, Mitotic_Options, Frame)
% [Array, L_PDF, Three] = MainArray_STE(Potential_Matches, Mitotic_Options, Frame)

Image_Potential_Matches = Potential_Matches(Potential_Matches.CurrentImage == Frame,:);
Image_Mitotic_Options = Mitotic_Options(Mitotic_Options.ImageNumber == Frame,:);

if isempty(Image_Potential_Matches)
Array = [];
L_PDF = [];
Three = [];
intcon = [];
lower_bounds = [];
upper_bounds = [];
else
% % % % % FOR NON-DIVIDING CELLS % % % % % % % % % % % % % % % % % % % %
row1  = length(unique(Image_Potential_Matches.Curr_KNN_ID));
row2 = length(Image_Potential_Matches.Curr_KNN_ID);
array1 = zeros(row2, row1);

Cell_ID_List = unique(Image_Potential_Matches.Curr_KNN_ID);
standard_size = length(Cell_ID_List);
Options_ID_List = unique(Image_Potential_Matches.Next_KNN_ID);
row_depth = 0;
for Cell_KNN = 1:row1        
   Cell_ID = Cell_ID_List(Cell_KNN);
   [shift_row shift_col] = find(Cell_ID_List == Cell_ID);    
   PDF_Cell_subset = Image_Potential_Matches(Image_Potential_Matches.Curr_KNN_ID == Cell_ID,:);
   
   [dimensions_x y] = size(PDF_Cell_subset.Next_KNN_ID);    
   Cell_ID_List_2 = unique(PDF_Cell_subset.Next_KNN_ID);       
     for Cell_KNN_2 = 1:length(Cell_ID_List_2) 
       Cell_ID_2 = Cell_ID_List_2(Cell_KNN_2);
       [shift_row2 shift_col2] = find(Options_ID_List == Cell_ID_2);
       array1((Cell_KNN_2 + row_depth), Cell_KNN) = 1;   
     end
   row_depth = dimensions_x + row_depth;                        
end  

keys = Options_ID_List;
array2 = zeros(row2, (length(keys)));
for ID = 1:length(keys)
   Opt_ID = keys(ID);
   list = find(Image_Potential_Matches.Next_KNN_ID == Opt_ID);
    for enum = 1:length(list)
       row_value = list(enum);
       array2(row_value, ID) = 1;
    end
end
ArrayA = horzcat(array1, array2); 
PDF_Main = Image_Potential_Matches.PDF_Sum;
%
% % % % % FOR MITOTIC CELLS % % % % % % % % % % % % % % % % % % % % 
%

if isempty(Image_Mitotic_Options)
       Array3 = [];
       PDF_IMO = [];
       MO_row = [];
        
else
    row1  = length(unique(Image_Potential_Matches.Curr_KNN_ID));
    %     row1  = length(unique(Image_Mitotic_Options.ParentID));
    [MO_row MO_col] = size(Image_Mitotic_Options);
    array3A = zeros(MO_row, row1);
    Options_ID_List = unique(Image_Mitotic_Options.ParentID);
    row_depth = 0;
    MO_ID_List = unique(Image_Mitotic_Options.ParentID);
        for MO_num = 1:length(MO_ID_List) % MO_row
        MO_ID = MO_ID_List(MO_num,:);
        [MO_row2 MO_col2] = find(Cell_ID_List == MO_ID);
        [MO_x MO_y] = find(Image_Mitotic_Options.ParentID == MO_ID);        
            for MO_num2 = 1:length(MO_x)            
                array3A((row_depth + MO_num2),MO_row2) = 1;
                MO_num2 = MO_num2 + MO_num2;
            end
        row_depth = row_depth + length(MO_x);
        end
    keys = unique(Image_Potential_Matches.Next_KNN_ID); % unique(vertcat(Image_Mitotic_Options.Daughter1, Image_Mitotic_Options.Daughter2));  
    array3B = zeros(MO_row, length(keys));
    for ID = 1:MO_row
     key_MO1 = Image_Mitotic_Options.Daughter1;
     key_MO2 = Image_Mitotic_Options.Daughter2;
    
     Opt_ID1 = key_MO1(ID);
     Opt_ID2 = key_MO2(ID);
     
     list1 = find(keys == Opt_ID1);
     list2 = find(keys == Opt_ID2);
      for enum = 1:length(list1)
       array3B(ID, list1) = 1;
       array3B(ID, list2) = 1;
      end
    end
Array3 = horzcat(array3A, array3B);
PDF_IMO = (0.0833 * Image_Mitotic_Options.PDF_Sum); % 0.0833 * 0.125 is a weighting factor for Mitotic Cells. Cannot just add PDFs
 end

Array = vertcat(ArrayA, Array3);
L_PDF = vertcat(PDF_Main, PDF_IMO);

[row2 col2] = size(Array);
Three = ones(col2, 1);

intcon = row1 + MO_row;
lower_bounds = zeros(length(L_PDF),1);
upper_bounds = ones(length(L_PDF),1);
end
end