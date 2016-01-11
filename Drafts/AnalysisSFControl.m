%%SmartFlare Control Experiment 201506019 
%%Christian Meyer 06/26/15
%Segmentation code to find the intensities per cell of the scrambled vs 18S
%SMART flare markers
%First builds CIDRE model for each image stack separately
%Segmentation of both channels for each image where the cell count per well
%is found from the Nuclei and the intensity is measured from the SMARTflare
%channel.  The output is into a table which has the row and column number
%for each image as well as a cell count and a total intensity.
%NOTE: that the segmentation parameters for the nuclei and image intensity
%are different!  This is due to the "speckled" nature of the RNA images
%necessitating a low background threshold and a high noise disk filter.

%CH1 is the nuclei
%CH2 is the Bright Field
%CH3 is the Smart Flare Channel

%Nuclei Directory (N)
NUC.dir = '/home/xnmeyer/Documents/Lab/Experiments/201506019 SmartFlare Control/CH_1/';
NUC.filnms = dir([NUC.dir '*.tiff']);
%Build CIDREmodel for the nuclei images
CIDREmodelNUC = cidre([NUC.dir '*.tiff'])

%SF channel Directory
SF.dir = '/home/xnmeyer/Documents/Lab/Experiments/201506019 SmartFlare Control/CH_3/';
SF.filnms = dir([SF.dir '*.tiff']);
%Build CIDREmodel
CIDREmodelSF = cidre([SF.dir '*.tiff'])

%Parameters for SF Segmentation
%%BT = Background threshold percent above norm considered significant
%%NT = Noise Threshold (Size of disk that is rolled over binary image
%%FH is the logical to fill holes
SF.P = struct( 'BT',0.1,...
            'NT',10,...
            'FH','true');

%Parameters for Nuclei Segmentation
NUC.P = struct( 'BT',0.2,...
              'NT',3,...
              'FH','true');
          
%Pre allocate to save space
row = cell(size(NUC.filnms,1),1);
col = cell(size(NUC.filnms,1),1);
cellCount = nan(size(NUC.filnms,1),1);
SFintensity = nan(size(NUC.filnms,1),1);
result = nan(size(NUC.filnms,1),1);

tic          
for i = 1:size(NUC.filnms,1)
    foo = strfind(NUC.filnms(i).name, '-');
    %Store the row and column names
    rw = char(NUC.filnms(i).name(foo(2)+1:foo(2)+3));
    cl = char(NUC.filnms(i).name(foo(3)+1:foo(3)+3));
    
    %First take the SF image and segment 
    [SFim, objSet.wellName, objSet.imageName] = ...
            LoadImage([SF.dir SF.filnms(i).name]);
    %Correct with CIDRE model
    SFim = (double(SFim)-CIDREmodelSF.z)./(CIDREmodelSF.v);
    %Reconvert the image to uint16 if corrected.
    SFim = uint16(SFim);
    j = SFim; %Store the image to sum the intensity of the pixels later in the code

    % maps the intensity values such that 1% of data is saturated 
    % at low and high intensities 
    SFim	= imadjust(SFim);

    % To Binary Image 
    SFim	= im2bw(SFim, SF.P.BT);

    % Remove Noise
    if (SF.P.NT) > 0.0
        noise = imtophat(SFim, strel('disk', (SF.P.NT)));
        SFim = SFim - noise;
    end

    % Fill Holes
    if SF.P.NT
        SFim = imfill(SFim, 'holes');
    end

    l	= bwlabel(SFim);
    % Segment properties (with holes filled)
     p	= regionprops(l,...
                     'Area',				'Centroid',			...
                     'MajorAxisLength',	'MinorAxisLength',	...
                     'Eccentricity', 	'ConvexArea',		...
                     'FilledArea',		'EulerNumber',  	...
                     'EquivDiameter',	'Solidity',			...
                     'Perimeter',		'PixelIdxList',		...
                     'PixelList',		'BoundingBox',		...
                     'Orientation');

    % Compute intensities from background adjusted image
    
    %Don't need boundaries
    %[bounds,L,N] = bwboundaries(SFim);
    intensity = 0;
    for obj=1:size(p,1)
        %Find the intensity total for each image
        intensity =  intensity + sum(j(p(obj).PixelIdxList));
    end
    
    
    %%
    %%Now look at segmenting the nuclei from all the images
    [NUCim, objSet.wellName, objSet.imageName] = ...
            LoadImage([NUC.dir NUC.filnms(i).name]);
        
    %Correct with CIDRE model
    NUCim = (double(NUCim)-CIDREmodelNUC.z)./(CIDREmodelNUC.v);
    %Reconvert the image to uint16 if corrected.
    NUCim = uint16(NUCim);

    % maps the intensity values such that 1% of data is saturated 
    % at low and high intensities 
    NUCim	= imadjust(NUCim);

    % To Binary Image 
    NUCim	= im2bw(NUCim, NUC.P.BT);

    % Remove Noise
    if (NUC.P.NT) > 0.0
        noise = imtophat(NUCim, strel('disk', (NUC.P.NT)));
        NUCim = NUCim - noise;
    end

    % Fill Holes
    if NUC.P.NT
        NUCim = imfill(NUCim, 'holes');
    end

    l	= bwlabel(NUCim);
    %%Count the number of cells in the image from the number of labels
    cellCount(i) = max(max(l));            
    %Get the overall well intensity
    SFintensity(i) = intensity;
    %Divide to two to get average smartflare signal per cell
    result(i) = SFintensity(i)./cellCount(i);
    %Store the row and colum info
    row{i} = rw;
    col{i} = cl;
    i
end
toc          


%%Plot the results...
%Find the SmartFlare images for HCC1143 for the different concentrations
HCCidxSF.two = find(ismember(col(:),'C04') & (ismember(row(:),'R02') | ismember(row(:),'R03')));
HCCidxSF.one = find(ismember(col(:),'C04') & (ismember(row(:),'R04') | ismember(row(:),'R05')));
HCCidxSF.half = find(ismember(col(:),'C04') & (ismember(row(:),'R06') | ismember(row(:),'R07')));

%Find the SC images for HCC1143 for the different concentrations
HCCidxSC.two = find(ismember(col(:),'C05') & (ismember(row(:),'R02') | ismember(row(:),'R03')));
HCCidxSC.one = find(ismember(col(:),'C05') & (ismember(row(:),'R04') | ismember(row(:),'R05')));
HCCidxSC.half = find(ismember(col(:),'C05') & (ismember(row(:),'R06') | ismember(row(:),'R07')));

%Find the Uptake Control images for HCC1143 for the different concentrations
HCCidxUC.two = find(ismember(col(:),'C03') & (ismember(row(:),'R02') | ismember(row(:),'R03')));
HCCidxUC.one = find(ismember(col(:),'C03') & (ismember(row(:),'R04') | ismember(row(:),'R05')));
HCCidxUC.half = find(ismember(col(:),'C03') & (ismember(row(:),'R06') | ismember(row(:),'R07')));


%Find the SmartFlare images for SUM149 for the different concentrations
SUMidxSF.two = find(ismember(col(:),'C09') & (ismember(row(:),'R02') | ismember(row(:),'R03')));
SUMidxSF.one = find(ismember(col(:),'C09') & (ismember(row(:),'R04') | ismember(row(:),'R05')));
SUMidxSF.half = find(ismember(col(:),'C09') & (ismember(row(:),'R06') | ismember(row(:),'R07')));

%Find the SC images for SUM149 for the different concentrations
SUMidxSC.two = find(ismember(col(:),'C10') & (ismember(row(:),'R02') | ismember(row(:),'R03')));
SUMidxSC.one = find(ismember(col(:),'C10') & (ismember(row(:),'R04') | ismember(row(:),'R05')));
SUMidxSC.half = find(ismember(col(:),'C10') & (ismember(row(:),'R06') | ismember(row(:),'R07')));

%Find the UPTAKE control images for SUM149 for the different concentrations
SUMidxUC.two = find(ismember(col(:),'C10') & (ismember(row(:),'R02') | ismember(row(:),'R03')));
SUMidxUC.one = find(ismember(col(:),'C10') & (ismember(row(:),'R04') | ismember(row(:),'R05')));
SUMidxUC.half = find(ismember(col(:),'C10') & (ismember(row(:),'R06') | ismember(row(:),'R07')));



%Create a grouped bar plot which holds the Signal (SF intensity) over the
%noise (Scramble control)

%Plot the figure of the varying cellular intensities for the different
%conditions
%Set fontsize
fntsz = 16;
fntsz_sub = 12;
figure(1)
clf;
hold on
[y1, x1] = ksdensity(result(HCCidxSF.two));
[y2, x2] = ksdensity(result(HCCidxSC.two));
[y3, x3] = ksdensity(result(HCCidxSF.one));
[y4, x4] = ksdensity(result(HCCidxSC.one));
[y5, x5] = ksdensity(result(HCCidxSF.half));
[y6, x6] = ksdensity(result(HCCidxSC.half));
subplot(2,2,1)
hold on
title('2uL','fontsize',fntsz)
plot(x1,y1,'red','linewidth',4)
plot(x2,y2,'linewidth',4)
xlabel('Average Intensity per cell','fontsize',fntsz)
ylabel('Frequency','fontsize',fntsz)

subplot(2,2,2)
hold on
title('1uL','fontsize',fntsz)
plot(x3,y3,'red','linewidth',4)
plot(x4,y4,'linewidth',4)
xlabel('Average Intensity per cell','fontsize',fntsz)
ylabel('Frequency','fontsize',fntsz)

subplot(2,2,3)
hold on
title('.5uL','fontsize',fntsz)
plot(x5,y5,'red','linewidth',4)
plot(x6,y6,'linewidth',4)
xlabel('Average Intensity per cell','fontsize',fntsz)
ylabel('Frequency','fontsize',fntsz)

subplot(2,2,4)
toplot = [mean(result(HCCidxSF.two)./result(HCCidxSC.two)) mean(result(HCCidxSF.one)./result(HCCidxSC.one)) mean(result(HCCidxSF.half)./result(HCCidxSC.half))];
hold on
bar(1,toplot(1),'red')
bar(2,toplot(2),'blue')
bar(3,toplot(3),'magenta')
set(gca,'xticklabel',{'2uL','1uL','.5uL'})
set(gca,'fontsize',fntsz_sub)
set(gca,'XTick',[1 2 3])
ylabel('Signal to Noise Ratio','fontsize',fntsz)
title('Signal to noise','fontsize',fntsz)
%Add Errorbars...
toplot_std = [std(result(HCCidxSF.two)./result(HCCidxSC.two)) std(result(HCCidxSF.one)./result(HCCidxSC.one)) std(result(HCCidxSF.half)./result(HCCidxSC.half))];
errorbar(1:3,toplot,toplot_std,'.','linewidth',3,'color','black')

%Plot the figure of the varying cellular intensities for the different
%conditions
figure(2)
clf;
hold on
[y1, x1] = ksdensity(result(SUMidxSF.two));
[y2, x2] = ksdensity(result(SUMidxSC.two));
[y3, x3] = ksdensity(result(SUMidxSF.one));
[y4, x4] = ksdensity(result(SUMidxSC.one));
[y5, x5] = ksdensity(result(SUMidxSF.half));
[y6, x6] = ksdensity(result(SUMidxSC.half));
subplot(2,2,1)
hold on
title('2uL','fontsize',fntsz)
plot(x1,y1,'red','linewidth',4)
plot(x2,y2,'linewidth',4)
xlabel('Average Intensity per cell','fontsize',fntsz)
ylabel('Frequency','fontsize',fntsz)

subplot(2,2,2)
hold on
title('1uL','fontsize',fntsz)
plot(x3,y3,'red','linewidth',4)
plot(x4,y4,'linewidth',4)
xlabel('Average Intensity per cell','fontsize',fntsz)
ylabel('Frequency','fontsize',fntsz)

subplot(2,2,3)
hold on
title('.5uL','fontsize',fntsz)
plot(x5,y5,'red','linewidth',4)
plot(x6,y6,'linewidth',4)
xlabel('Average Intensity per cell','fontsize',fntsz)
ylabel('Frequency','fontsize',fntsz)

subplot(2,2,4)
toplot = [mean(result(SUMidxSF.two)./result(SUMidxSC.two)) mean(result(SUMidxSF.one)./result(SUMidxSC.one)) mean(result(SUMidxSF.half)./result(SUMidxSC.half))];
hold on
bar(1,toplot(1),'red')
bar(2,toplot(2),'blue')
bar(3,toplot(3),'magenta')
set(gca,'xticklabel',{'2uL','1uL','.5uL'})
set(gca,'fontsize',fntsz_sub)
set(gca,'XTick',[1 2 3])
ylabel('Signal to Noise Ratio','fontsize',fntsz)
title('Signal to noise','fontsize',fntsz)
%Add Errorbars...
toplot_std = [std(result(SUMidxSF.two)./result(SUMidxSC.two)) std(result(SUMidxSF.one)./result(SUMidxSC.one)) std(result(SUMidxSF.half)./result(SUMidxSC.half))];
errorbar(1:3,toplot,toplot_std,'.','linewidth',3,'color','black')