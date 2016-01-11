function histograms = PlotDistributions(DistanceList, AreaChangeList, EccentricityChangeList, MALChangeList, MILChangeList, SolidityChangeList, IntensityChangeList)
histograms = figure;
figure
nbins = 15;

subplot(2,4,1)
hist(DistanceList, nbins)
title('Distance Distribution')

subplot(2,4,2)
hist(AreaChangeList, nbins)
title('Area Distribution')

subplot(2,4,3)
hist(EccentricityChangeList, nbins)
title('Eccentricity Distribution')

subplot(2,4,4)
hist(MALChangeList, nbins)
title('Major Axis Length Dist.')

subplot(2,4,5)
hist(MILChangeList, nbins)
title('Minor Axis Length Dist.')

% % subplot(2,4,6)
% % hist(EqDChangeList, nbins)
% % title('EquivDiameter Distribution')

subplot(2,4,6)
hist(SolidityChangeList, nbins)
title('Solidity Distribution')

subplot(2,4,7)
hist(IntensityChangeList, nbins)
title('Intensity Distribution')


end
