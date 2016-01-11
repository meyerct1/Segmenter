% Experiment 20150910
%%Christian Meyer pg. 85 in notebook

%CH_2 is Calcien
%CH_1 is EpCAM

numCh = 2;
%Analyse all segmented wells (excluding well r5 as it was deleted due to a
%clump of cells)
%Add all the wells together segmentation together.
seg_file = dir(['Segmented/*.mat']);
%Declare structure for holding data
Seg = struct('Nuc_IntperA',[],'numCytowoutNuc',[],'cellcount',[])
for q = 1:numCh
    chnm = ['CH_' num2str(q)]
    Seg.(chnm).IntperA = [];
    Seg.(chnm).Intensity = [];
    Seg.(chnm).Area = [];
    Seg.(chnm).Perimeter = []; 
    Seg.(chnm).AtoP = [];
end
for i = 1:size(seg_file,1)
    load(['Segmented/' seg_file(i).name])
    Seg.Nuc_IntperA = [Seg.Nuc_IntperA, CO.Nuc.Intensity./CO.Nuc.Area];
    Seg.numCytowoutNuc = [Seg.numCytowoutNuc, CO.numCytowoutNuc];
    Seg.cellcount = [Seg.cellcount, CO.numCytowoutNuc];
    for q = 1:numCh
        chnm = ['CH_' num2str(q)];
        Seg.(chnm).IntperA = [Seg.(chnm).IntperA, CO.(chnm).Intensity./CO.(chnm).Area];
        Seg.(chnm).Intensity = [Seg.(chnm).Intensity, CO.(chnm).Intensity];
        Seg.(chnm).Area = [Seg.(chnm).Area, CO.(chnm).Area];
        Seg.(chnm).Perimeter = [Seg.(chnm).Perimeter, CO.(chnm).Perimeter];
        Seg.(chnm).AtoP = [Seg.(chnm).AtoP, CO.(chnm).Area./CO.(chnm).Perimeter];
    end
end

fontsz = 16;

%look at epcam stain
q = 1;
chnm = ['CH_' num2str(q)];

figure()
[x,y] = ksdensity(Seg.(chnm).IntperA);
plot(y,x,'linewidth',4);
str= sprintf('HCC1143 Hoechst + EpCAM + calcein stain\n');
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)


%look at calcein stain
q = 2;
chnm = ['CH_' num2str(q)];

figure()
[x,y] = ksdensity(Seg.(chnm).IntperA);
plot(y,x,'linewidth',4);
str= sprintf('HCC1143 Hoechst + EpCAM + calcein stain\n');
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area Calcein','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)

%look at nuclear stain
figure()
[x,y] = ksdensity(Seg.Nuc_IntperA);
plot(y,x,'linewidth',4);
str= sprintf('HCC1143 Hoechst + EpCAM + calcein stain\n');
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area Nuclear Channel','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)


