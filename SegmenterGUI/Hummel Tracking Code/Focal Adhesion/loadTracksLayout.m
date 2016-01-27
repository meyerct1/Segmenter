function output_args=loadTracksLayout(input_args)
% Usage
% This module is used to load a structure containing the order of each column in the tracks matrix from a MATLAB .mat file.
% Input Structure Members
% FileName – The name of the .mat file containing the tracks layout structure.
% Output Structure Members
% TracksLayout – Structure containing the order of each column in the tracks matrix.

load(input_args.FileName.Value);
output_args.TracksLayout=tracks_layout;

end