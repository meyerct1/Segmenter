% Experiment 20150910
%%Christian Meyer pg. 85 in notebook

%CH_2 is Calcien
%CH_1 is EpCAM

numCh = 2;
%Analyse all segmented wells (excluding well r5 as it was deleted due to a
%clump of cells)
%Add all the wells together segmentation together.
Seg = struct()
seg_file = dir(['Segmented/*.mat']);
    for i = 1:size(seg_file,1)
        load(['Segmented/' seg_file(i).name])
        for q = 1:numCh
            chnm = ['CH_' num2str(q)]
        for j = 1:size(CO.(chnm).Intensity,2)
            if CO.(chnm).Intensity(j) ~= 0
                Seg.(chnm).IntperA(k) = CO.(chnm).Intensity(j)./CO.(chnm).Area(j);
                Seg.(chnm).Intensity(k) = CO.(chnm).Intensity(j);
                Seg.(chnm).Area(k) = CO.(chnm).Area(j);
                Seg.(chnm).Perimeter(k) = CO.(chnm).Perimeter(j);
                Seg.(chnm).AtoP(k) = CO.(chnm).Area(j)./CO.(chnm).Perimeter(j);
                k = k + 1;
            end
        end
        Seg.numCytowoutNuc(l) = CO.numCytowoutNuc;
        Seg.cellCount(l) = CO.cellCount;
        l = l+1;
    end
end
for i = 1:size(seg_file,1)
    load(['Segmented/' seg_file(i).name])
    Seg.Nuc.IntperA = [Seg.Nuc.IntperA, CO.Nuc.Intensity./CO.Nuc.Area];


fontsz = 16;

%look at epcam stain
q = 2;
chnm = ['CH_' num2str(q)];

figure()
[x,y] = ksdensity(Seg.(chnm).Intensity);
plot(y,x,'linewidth',4);
str = sprintf('HCC1143 Hoechst + EpCAM + calcein stain\n')
title(str,'fontsize',fontsz)
xlabel('Intensity EpCAM','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)

figure()
[x,y] = ksdensity(Seg.(chnm).IntperA);
plot(y,x,'linewidth',4);
str= sprintf('HCC1143 Hoechst + EpCAM + calcein stain\n');
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)

%look at epcam stain
q = 1;
chnm = ['CH_' num2str(q)];

figure()
[x,y] = ksdensity(Seg.(chnm).IntperA);
plot(y,x,'linewidth',4);
str= sprintf('HCC1143 Hoechst + EpCAM + calcein stain\n');
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area Calcein','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)

figure()
[x,y] = ksdensity(Seg.(chnm).IntperA);
plot(y,x,'linewidth',4);
str= sprintf('HCC1143 Hoechst + EpCAM + calcein stain\n');
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area Nuclear Channel','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)
