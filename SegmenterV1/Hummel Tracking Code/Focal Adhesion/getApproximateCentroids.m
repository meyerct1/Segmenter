function cell_centroids=getApproximateCentroids(cells_lbl)
%helper function. these centroids are exact for shapes without disconnects but only
%approximate the centroids of shapes with disconnects. it is however close
%enough for matching purposes
lbl_idx=cells_lbl>0;
[cells_1 cells_2]=find(lbl_idx);
cell_coords_1=accumarray(cells_lbl(lbl_idx),cells_1);
cell_coords_2=accumarray(cells_lbl(lbl_idx),cells_2);
cell_areas=accumarray(cells_lbl(lbl_idx),1);
cell_centroids=[cell_coords_1 cell_coords_2]./[cell_areas cell_areas];

%end getApproximateCentroids
end