function output_args=getCurrentUnassignedCell(input_args)
%module to retrieve the current unassigned cell from the list
output_args.CellID=input_args.UnassignedCells.Value(1);

%end getCurrentUnassignedCell
end