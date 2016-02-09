function [] =  segmenterTestGUI(handles)
% Multi Channel Cell Segmentation with channel correction. Single figure generation 
%%Christian Meyer 10.22.15.  This is to test the segmentation parameters
h = msgbox('Please Be Patient, This box will close when operation is finished')
im = handles.imNum;
imExt = handles.imExt;
cidrecorrect = handles.cidrecorrect;
NucnumLevel = handles.NucnumLevel;
CytonumLevel = handles.CytonumLevel;
surface_segment = handles.surface_segment;
nuclear_segment = handles.nuclear_segment;
nuclear_segment_factor = handles.nuclear_segment_factor;
surface_segment_factor = handles.surface_segment_factor;
cl_border = handles.cl_border;
noise_disk = handles.noise_disk;
nuc_noise_disk = handles.nuc_noise_disk;
smoothing_factor = handles.smoothing_factor;
numCh = handles.numCh;
NUC = handles.NUC;
Cyto = handles.Cyto;
%Segmentation height for nuclei in the watershed segmentation
NucSegHeight = handles.NucSegHeight;
%Background correction as oppose to CIDRE?
background_corr = handles.background_corr;
%File for background correction
CorrIm_file = handles.CorrIm_file;
%Is this a pathway experiment
bd_pathway = handles.bd_pathway;

    [CO,Im_array] = NaiveSegmentV4(imExt,cidrecorrect,NucnumLevel,CytonumLevel,surface_segment,nuclear_segment,noise_disk,nuc_noise_disk,...
    nuclear_segment_factor,surface_segment_factor,cl_border,smoothing_factor,NucSegHeight,numCh,NUC,Cyto,im,background_corr,CorrIm_file,bd_pathway);
 
%Plot the result
if ~handles.viewNuc
    p = regionprops(CO.label,'PixelIdxList');
    sz = size(CO.label);
    tempIm = zeros(sz(1),sz(2),3);
    cnt = 1;
    col = jet(length(p));
    randIdx = randperm(length(p));
    for i = 1:length(p)
        if ~CO.class.edge(i)
            [x,y] = ind2sub(size(CO.label),p(i).PixelIdxList);
            for j = 1:length(x)
                tempIm(x(j),y(j),:) = col(randIdx(i),:);
            end
            cnt = cnt+1;
        end
    end
    tempIm = imdilate(tempIm,strel('disk',5));
    axes(handles.axes1)
    imshowpair(Im_array(:,:,handles.ChtoSeg+1),tempIm,'blend','Scaling','independent')
    % hold on
    % if handles.ChtoSeg > 0
    % chnm = ['CH_' num2str(handles.ChtoSeg)];
    %     for i = 1:CO.cellCount
    %       str = sprintf('%.0f',CO.(chnm).Intensity(i)/CO.(chnm).Area(i));
    %       text(CO.Centroid(i,1),CO.Centroid(i,2),str,'color', [1,1,1])
    %     end
    % end
    % figure()
    % hist(CO.(chnm).Intensity./CO.(chnm).Area)
else
    p = regionprops(CO.Nuc_label,'PixelIdxList');
    sz = size(CO.Nuc_label);
    tempIm = zeros(sz(1),sz(2),3);
    cnt = 1;
    col = jet(length(p));
    randIdx = randperm(length(p));
    for i = 1:length(p)
        if ~CO.class.edge(i)
            [x,y] = ind2sub(size(CO.Nuc_label),p(i).PixelIdxList);
            for j = 1:length(x)
                tempIm(x(j),y(j),:) = col(randIdx(i),:);
            end
            cnt = cnt+1;
        end
    end
    tempIm = imdilate(tempIm,strel('disk',5));
    axes(handles.axes1)
    imshowpair(Im_array(:,:,handles.ChtoSeg+1),tempIm,'blend','Scaling','independent')
    % hold on
    % if handles.ChtoSeg > 0
    % chnm = ['CH_' num2str(handles.ChtoSeg)];
    %     for i = 1:CO.cellCount
    %       str = sprintf('%.0f',CO.(chnm).Intensity(i)/CO.(chnm).Area(i));
    %       text(CO.Centroid(i,1),CO.Centroid(i,2),str,'color', [1,1,1])
    %     end
    % end
    % figure()
    % hist(CO.(chnm).Intensity./CO.(chnm).Area)
end
close(h)




%Other figures that have been generated....
%{


figure('Color','k')
imshow(label2rgb(Nuc_label),[])
title('Nuclear Segmentation','color',[0,0,0])
hold on
p = regionprops(Nuc_label,'Centroid')
for i = 1:length(p)
  str = sprintf('%.0f',CO.Nuc.Intensity(i)/CO.Nuc.Area(i));
  text(p(i).Centroid(1),p(i).Centroid(2),str)
end
title('Intensity per area Nucleus')




figure('Color','k')
imshow(label2rgb(CytoLabel),[])
title('Cytoplasm Segmentation','color',[0,0,0])
hold on

p = regionprops(CytoLabel,'Centroid','PixelIdxList')
for i = 1:length(p)
  str = sprintf('%.0f',CO.CH_1.Intensity(i)./CO.CH_1.Area(i));
  text(p(i).Centroid(1),p(i).Centroid(2),str)
end
title('Intensity Cytoplasm')


%}    
%{

figure()
for j = 1:numCh+1
    if numCh+1 <=4
        if j == 1
            if isempty(CO.Nuc.Intensity)
                subplot(2,2,1)
                title('No cells')
            else
                [y,x] = ksdensity(CO.Nuc.Intensity./CO.Nuc.Area);
                subplot(2,2,1)
                plot(x,y,'linewidth',4)
                str = sprintf('Nuc Intensity per Area');
                title(str)
            end
        else
            if isempty(CO.(chnm).Intensity)
                subplot(2,2,j)
                str = sprintf('No cells found in CH%i',j-1);
                title(str)
            else
                chnm = ['CH_' num2str(j-1)];                   
                [y,x] = ksdensity(CO.(chnm).Intensity./CO.(chnm).Area);
                subplot(2,2,j)
                plot(x,y,'linewidth',4)
                str = sprintf('CH%i Intensity Per Area',j-1);
                title(str)
            end
        end
    else
        if j == 1
            if isempty(CO.Nuc.Intensity)
                subplot(3,3,1)
                title('No cells')
            else
                [y,x] = ksdensity(CO.Nuc.Intensity./CO.Nuc.Area);
                subplot(3,3,1)
                plot(x,y,'linewidth',4)
                str = sprintf('Nuc Intensity per Area');
                title(str)
            end
        else
            if isempty(CO.(chnm).Intensity)
                subplot(3,3,j)
                str = sprintf('No cells found in CH%i',j-1);
                title(str)
            else
                chnm = ['CH_' num2str(j-1)];                   
                [y,x] = ksdensity(CO.(chnm).Intensity./CO.(chnm).Area);
                subplot(3,3,j)
                plot(x,y,'linewidth',4)
                str = sprintf('CH%i Intensity Per Area',j-1);
                title(str)
            end
        end
    end
end


figure()
p = regionprops(CytoLabel,'Centroid')
imshow(label2rgb(CytoLabel),[])
hold on
for i = 1:length(p)
  str = sprintf('%.0f',CO.CH_1.Intensity(i)/CO.CH_1.Area(i));
  text(p(i).Centroid(1),p(i).Centroid(2),str)
end
title('Intensity per Area Cytoplasm')

figure()
p = regionprops(CytoLabel,'Centroid')
imshow(label2rgb(CytoLabel),[])
hold on
for i = 1:length(p)
  str = sprintf('%.0f',CO.CH_1.Intensity(i));
  text(p(i).Centroid(1),p(i).Centroid(2),str)
end
title('Intensity Cytoplasm')

figure()
p = regionprops(Nuc_label,'Centroid')
imshow(label2rgb(Nuc_label),[])
hold on
for i = 1:length(p)
  str = sprintf('%.0f',CO.Nuc.Intensity(i)/CO.Nuc.Area(i));
  text(p(i).Centroid(1),p(i).Centroid(2),str)
end
title('Intensity per area Nucleus')



figure()
for j = 1:numCh+1
    if numCh+1 <=4
        if j == 1
            if isempty(CO.Nuc.Intensity)
                subplot(2,2,1)
                title('No cells')
            else
                [y,x] = ksdensity(CO.Nuc.Intensity);
                subplot(2,2,1)
                plot(x,y,'linewidth',4)
                str = sprintf('Nuc Intensity');
                title(str)
            end
        else
            if isempty(CO.(chnm).Intensity)
                subplot(2,2,j)
                str = sprintf('No cells found in CH%i',j-1);
                title(str)
            else
                chnm = ['CH_' num2str(j-1)];                   
                [y,x] = ksdensity(CO.(chnm).Intensity);
                subplot(2,2,j)
                plot(x,y,'linewidth',4)
                str = sprintf('CH%i Intensity',j-1);
                title(str)
            end
        end
    else
        if j == 1
            if isempty(CO.Nuc.Intensity)
                subplot(3,3,1)
                title('No cells')
            else
                [y,x] = ksdensity(CO.Nuc.Intensity);
                subplot(3,3,1)
                plot(x,y,'linewidth',4)
                str = sprintf('Nuc Intensity');
                title(str)
            end
        else
            if isempty(CO.(chnm).Intensity)
                subplot(3,3,j)
                str = sprintf('No cells found in CH%i',j-1);
                title(str)
            else
                chnm = ['CH_' num2str(j-1)];                   
                [y,x] = ksdensity(CO.(chnm).Intensity);
                subplot(3,3,j)
                plot(x,y,'linewidth',4)
                str = sprintf('CH%i Intensity',j-1);
                title(str)
            end
        end
    end
end
%}

%{
  figure()
  [y,x] = ksdensity(CO.Nuc.Area)
  plot(x,y,'linewidth',4)
  title('Nuclear Area')
  
  figure()
  p = regionprops(Nuc_label,'Centroid')
  imshow(label2rgb(Nuc_label),[])
  hold on
  for i = 1:length(p)
      str = sprintf('%i',CO.Nuc.Area(i));
      text(p(i).Centroid(1),p(i).Centroid(2),str)
  end

  figure()
  p = regionprops(CytoLabel,'Centroid')
  imshow(label2rgb(CytoLabel),[])
  hold on
  for i = 1:length(p)
      str = sprintf('%i',CO.CH_1.Area(i));
      text(p(i).Centroid(1),p(i).Centroid(2),str)
  end

   figure()
subplot(2,2,1)
imshow(ind2sub(size(CytoLabel),CytoLabel(CytoLabel == 1)),[])
subplot(2,2,2)
imshow(ind2sub(size(CytoLabel),CytoLabel(CytoLabel == 2)),[])
subplot(2,2,3)
imshow(ind2sub(size(CytoLabel),CytoLabel(CytoLabel == 3)),[])
subplot(2,2,4)
imshow(ind2sub(size(CytoLabel),CytoLabel(CytoLabel == 4)),[])



figure()
for j = 1:numCh+1
    if numCh+1 <=4
        if j == 1
            subplot(2,2,1)
            imshow(Im_array(:,:,1),[])
            str = sprintf('Illumination Corr. Nuc');
        else
            subplot(2,2,j)
            imshow(Im_array(:,:,j),[])
            str = sprintf('Illumination Corr. CH%i',j-1);
        end
        title(str)
    else
        if j == 1
            subplot(3,3,1)
            imshow(Im_array(:,:,1),[])
            str = sprintf('Illumination Corr. Nuc');
        else
            subplot(3,3,j)
            imshow(Im_array(:,:,j),[])
            str = sprintf('Illumination Corr. CH%i',j-1);
        end
        title(str)
    end
end


 %}