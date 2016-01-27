function output_args=saveMatrixToSpreadsheet(input_args)
% Usage
% This module is used to export the matrix to a csv file.
% Input Structure Members
% ColumnNames - The names of the column headers in the csv file.
% Matrix – The matrix containing the values to be saved.
% SpreadsheetFileName – The desired file name for the saved file.
% Output Structure Members
% None.

region_props=input_args.Matrix.Value;
%sort tracks_with_stats by cell id
column_names=input_args.ColumnNames.Value;
disp('Saving matrix to spreadsheet...');
spreadsheet_file=input_args.SpreadsheetFileName.Value;
delete(spreadsheet_file);
dlmwrite(spreadsheet_file,column_names,'');
dlmwrite(spreadsheet_file,region_props,'-append');
output_args=[];

%end saveRegionPropsSpreadsheets
end