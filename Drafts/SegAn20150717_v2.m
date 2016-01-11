% Experiment 20150710 
%%Christian Meyer 06/26/15
%Segmentation code to find the intensities per cell of the scrambled vs 18S
%First builds CIDRE model for each image stack separately. Assumes images
%have been separated into separate Channels.  Done useing
%cellaVistaFileSorter.m
%Segmentation of all channels for each image based on nuclear image
%is found from the Nuclei and the intensity is measured from the SMARTflare
%channel.  The output is into a table which has the row and column number
%for each image as well as a cell count and a total intensity.
%NOTE: that the segmentation parameters for the nuclei and image intensity
%are different!  This is due to the "speckled" nature of the RNA images
%necessitating a low background threshold and a high noise disk filter.

%CH1 is the SF
%CH2 is the CD44
%CH3 is the EpCAM


numChannels = 5;
imExt = '.jpg';
NucCH = 1;
BF = 3;  %What channel the BF is on.  If none put 0
%Are the images already corrected using CIDRE? 1=yes 0 is no.  
cidrecorrected = 1;

%Count number of cytoplasmic channels
if BF ~=0
    numCh = numChannels - 2;
else
    numCh = numChannels - 1;
end

%Nuclei Directory (N)
NUC.dir = 'Nuc';
NUC.filnms = dir([NUC.dir filesep '*' imExt]);
%Build CIDREmodel for the nuclei images
%If the image is in RGB load in all the images and then build a cidre model
%after converting to grayscale.  Load in no more than 1200 images for
%memory considerations.
if ~(cidrecorrected)
    im = imread([NUC.dir filesep NUC.filnms(1).name]);
    if ndims(im) ~= 2
        tempim = zeros(size(im,1),size(im,2),size(NUC.filnms,1));
        for i = 1:size(NUC.filnms,1)
            if i > 1200
                continue
            end
            temp = imread([NUC.dir filesep NUC.filnms(i).name]);
            tempim(:,:,i) = rgb2gray(temp);
        end
        NUC.CIDREmodel = cidre(tempim)
    else
        NUC.CIDREmodel = cidre([NUC.dir filesep '*' imExt])
    end
end

%Create a structure for each of the channels
for i = 1:numCh
    str = ['CH_' num2str(i)];
    Cyto.(str).dir = str;
    Cyto.(str).filnms = dir([str filesep '*' imExt]);
    
    if ~cidrecorrected
        Cyto.(str).CIDREmodel = cidre([str filesep '*' imExt])
    end
    if ~(cidrecorrected)
        im = imread([Cyto.(str).dir filesep Cyto.(str).filnms(1).name]);
        if ndims(im) ~= 2
            tempim = zeros(size(im,1),size(im,2),size(Cyto.(str).filnms,1));
            for j = 1:size(Cyto.(str).filnms,1)
                if j > 1200
                    continue
                end
                temp = imread([Cyto.(str).dir Cyto.(str).filnms(j).name]);
                tempim(:,:,j) = rgb2gray(temp);
            end
             Cyto.(str).CIDREmodel = cidre(tempim)
        else
            Cyto.(str).CIDREmodel = cidre([Cyto.(str).dir filesep '*' imExt])
        end
    end
end

%Make a directory for the segemented files
mkdir('Segmented')
%Save in a file to be able to load later on
%save('Preliminary.mat');



%load('Preliminary.mat')

%Segmentation carried out using Otsu's method to determine background in the nuclear channel.  
%Subsequent use of a noise filter and hole filling smooths out the image and
%then use of a watershed segmentation to label all the cells.
%The label for the cells is then used to segment each channels cytoplasm
%Based on a kmeans nearest neighbor algorithm.
%Each segmented image is saved in a Segmentation folder with the time for
%each image derived from the file name.

%The noise filter used is 10.
noise_disk = 5;

if cidrecorrected
    tophat_rad = 0;  %Background correction
else
    tophat_rad = 50;
end
%Are the images monochromatic
mc = 0;


h = waitbar(0.000001,'Time to complete:');
%For all nuclear images
for i = 1:size(NUC.filnms,1)
    tic
    %Pre allocate to save space
    CO = struct(); %Cellular object structure
    foo = strfind(NUC.filnms(i).name, '-');
    %Store the row and column names from the filename
    rw = char(NUC.filnms(i).name(foo(2)+1:foo(2)+3));
    cl = char(NUC.filnms(i).name(foo(3)+1:foo(3)+3));
    
%     %store the time from the file name
%     tim.day = str2double(NUC.filnms(i).name(7:8));
%     tim.hr = str2double(NUC.filnms(i).name(9:10));
%     tim.min = str2double(NUC.filnms(i).name(11:12));
    
    %First segment the nucleus 
    NUCim = imread([NUC.dir filesep NUC.filnms(i).name]);
    if ~mc
        NUCim = rgb2gray(NUCim);  %Use if images are in jpg
    end
    
    %Correct with CIDRE model
    if ~cidrecorrected
        NUCim = (double(NUCim)-NUC.CIDREmodel.z)./(NUC.CIDREmodel.v);
        NUCim = uint16(NUCim);
    elseif tophat_rad ~=0
        NUCim = imtophat(im2double(NUCim), strel('disk', tophat_rad));
        NUCim = uint16(NUCim);
    end
    %Make sure image is uint16.
    % maps the intensity values such that 1% of data is saturated 
    % at low and high intensities 
    NUCim	= imadjust(NUCim);
    %Run otsu's method to determine background
    num = multithresh(NUCim,2);
    % To Binary Image with otsu's threshold
    NUCim	= imquantize(NUCim, num);

    NUCim(NUCim == 1) = 0;
    NUCim(NUCim == 2) = 1;
    NUCim(NUCim == 3) = 1;
    % Remove Noise
    noise = imtophat(NUCim, strel('disk', noise_disk));
    NUCim = NUCim - noise;

    % Fill Holes
    NUCim = imfill(NUCim, 'holes');
    %Compute the distance of the binary transformed image using the bright
    %areas of the image as the basins by negating the distance measure
    D = -bwdist(~NUCim);
    
    D = -imhmax(-D,10);  %To prevent oversegmentation...  Make variable in image segmentation in future?
    NUC_label = watershed(D);
    NUC_label(NUCim == 0) = 0; %Write all the background to zero.
    %NUC_label	= bwlabel(NUCim);
    %imshow(label2rgb(NUC_label),[])

    
    
    %Here would be a good place to load a baysian correction model that has
    %been predefined to fix the segmentation....
    
    
    %Now segement the channel chosen by the user based on the nuclear location
    %And use that information for subsequent analysis
    Cyto_channel = 1;
    chnm = ['CH_' num2str(Cyto_channel)];

    numCytowoutNuc = 0; % Number of cyptoplasms found without nuclei

    CYPim = imread([Cyto.(chnm).dir filesep Cyto.(chnm).filnms(i).name]);
    
    if ~mc
        CYPim = rgb2gray(CYPim);  %Use if images are in jpg
    end
    %Correct with CIDRE model
    if ~cidrecorrected
        CYPim = (double(CYPim)-Cyto.(chnm).CIDREmodel.z)./(Cyto.(chnm).CIDREmodel.v);
        CYPim = uint16(CYPim);
    elseif tophat_rad ~=0
        CYPim = imtophat(im2double(CYPim), strel('disk', tophat_rad));
        CYPim = uint16(CYPim);
    end

    tempIm = CYPim; %Store the image to sum the intensity of the pixels later in the code

    % maps the intensity values such that 1% of data is saturated 
    % at low and high intensities 
    %CYPim	= imadjust(CYPim);
    %Run otsu's method to determine background
%         num = multithresh(CYPim,2);
%         % To Binary Image with otsu's threshold
%         CYPim	= imquantize(CYPim, num);
% 
%         %Binarize image as the quantize function puts out a 1 and 2 image
%         %set.
%         CYPim(CYPim == 1) = 0;
%         CYPim(CYPim == 2) = 1;
%         CYPim(CYPim ==3) = 1;


    CYPim = imadjust(CYPim);
    CYPim = im2bw(CYPim, .1);  %Under estimate background due to uneven staining.

    % Remove Noise
    noise = imtophat(CYPim, strel('disk', noise_disk));
    CYPim = CYPim - noise;

    % Fill Holes
    CYPim = imfill(CYPim, 'holes');
    CYP_label	= bwlabel(CYPim);

    tempCytoLabel = zeros(size(CYP_label));
    nucl_ids_left = 1:max(max(NUC_label)); %Keep track of what nuclei have been assigne

    for j = 1:max(max(CYP_label))
        cur_cluster = (CYP_label==j);
        %get the nuclei ids present in the cluster
        nucl_ids=NUC_label(cur_cluster);   
        nucl_ids=unique(nucl_ids);
        %remove the background id
        nucl_ids(nucl_ids==0)=[];

        if isempty(nucl_ids)
            %don't add objects without nuclei
            numCytowoutNuc = numCytowoutNuc + 1;
            continue;
        elseif (length(nucl_ids)==1)
            %only one nucleus - assign the entire cluster to that id
            %Only add if the cytoplasm is larger than the nucleus
            if (sum(sum(cur_cluster))) > sum(sum(ismember(NUC_label,nucl_ids)))
                tempCytoLabel(cur_cluster)=nucl_ids;
                %delete the nucleus that have already been processed
                nucl_ids_left(nucl_ids_left==nucl_ids)=[];
            end
        else        
            %get an index to only the nuclei
            nucl_idx=ismember(NUC_label,nucl_ids);
            %get the x-y coordinates
            %Down sample to reduce computational time
            [nucl_x nucl_y]=find(nucl_idx); %Location of all the nuclear pixels
            [cluster_x cluster_y]=find(cur_cluster);  %Location of all cytoplasm pixels
            group_data=NUC_label(nucl_idx); %Classification of all nuclear labels


            %classify each pixel in the cluster
            %Dont need every pixel in the nucleus to find nearest neighbor.
            %Cuts down on model building timenumCytowoutNuc = 0; % Number of cyptoplasms found without nuclei

            %Build a model based on spatial information of what each group
            %each x y coordinate is assigned to then use to predict what each
            %cytoplasmic element belongs to...
            knnModel = fitcknn([nucl_x(1:10:end) nucl_y(1:10:end)],group_data(1:10:end));
            tempCytoLabel(cur_cluster) = predict(knnModel,[cluster_x cluster_y]);

            %delete the nucleus that have already been processed
            for elm = nucl_ids'   % why is there an ' ?
                nucl_ids_left(nucl_ids_left==elm)=[];
            end
        end
    end

    CYP_label = tempCytoLabel;
    
    % Segment properties (with holes filled)
     p	= regionprops(CYP_label,'PixelIdxList');
     
    %Now for each channel find the intensity and area 
    for q = 1:numCh
        chnm = ['CH_' num2str(Cyto_channel)];
        Int = [];
        Area = [];
        m = 1;
        for k = 1:size(p,1)
           if length(p(k).PixelIdxList~=0)
                Int(m) = sum(tempIm(p(k).PixelIdxList));
                Area(m) = length(p(k).PixelIdxList);
                m= m+1;
            end
        end
        %For each channel save information into the structure
        CO.(chnm).Intensity = Int;
        CO.(chnm).Area = Area;

    end
    %Save the nucleus information
    %%Count the number of cells in the image from the number of labels
    CO.cellCount = max(max(NUC_label));     
    CO.Nuc_label = NUC_label;
    CO.label = CYP_label;
    CO.numCytowoutNuc = numCytowoutNuc;
    CO.numCyto = length(unique(CYP_label))-1;

    %Save segmentation in a directory called segmented
    save(['Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
    i
    t(i) = toc;
    num = i./size(NUC.filnms,1);
    str = sprintf('Time to complete: %2.2f min', ((size(NUC.filnms,1)-i)*mean(t))./60);
    waitbar(num,h,str);
end


%Analyze Vim+CD44+EpCAM well
Seg = struct()
seg_file = dir(['Segmented/R06_C11*.mat']);
for q = 1:numCh
    k = 1;
    chnm = ['CH_' num2str(q)];
    l = 1;
    for i = 1:size(seg_file,1)
        load(['Segmented/' seg_file(i).name])
        for j = 1:size(CO.(chnm).Intensity,2)
            if CO.(chnm).Intensity(j) ~= 0
                Seg.(chnm).IntperA(k) = CO.(chnm).Intensity(j)./CO.(chnm).Area(j);
                k = k + 1;
            end
        end
        Seg.(chnm).numCwN(l) = CO.(chnm).numCytowoutNuc;
        Seg.(chnm).numCyto(l) = CO.(chnm).numCyto;
        l = l+1;
    end
end


%Plot in 3D
for q = 1:numCh
    chnm = ['CH_' num2str(q)]
    data = Seg(