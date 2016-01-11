% Multi Channel Cell Segmentation
%%Christian Meyer 07/14/15
%Segmentation code to find the intensities per cell of the each channel for
%a series of images from the CellaVista presorted with the
%cellaVistaFileSorter
%First block of code builds the basic sturcture of to hold the 
%Nuclear and cytoplasmic files.
%A CIDRE model can be run however if the images are sparse cidre does not work well.
%In such case a rolling ball background filter is applied.
%All functionality assumes images have been separated into separate 
%Channels useing cellaVistaFileSorter.m
%Segmentation of all channels for each image based on nuclear image.
%First nuclei are segmented.  Then the code determines the cytoplasmic
%channel with the largest amount of staining to define the cytoplasm for
%each cell.  Finally each channel is segmented and the intensity, area, and
%nuclear and cytoplasmic labels are stored in a structure which is saved to
%a folder called segemented with the row and channel name.

clear
%Number of channels in the image
numChannels = 4;
imExt = '.jpg';
NucCH = 1;  %What Channel the nuclear label is on
BF = 0;
%Should the images be corrected using CIDRE? 1=yes 0 is no.  Sparse images
%cause poor correction and a tophat background filter is better.
cidrecorrect = 1;

%The noise filter used is 5.
noise_disk = 5;
%Use a background correction if cidre was used
if cidrecorrect
    tophat_rad = 0;  %Background correction
else
    tophat_rad = 50;
end

%Count number of cytoplasmic channels
if BF ~=0
    numCh = numChannels - 2;
else
    numCh = numChannels - 1;
end

%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
NUC.dir = 'Nuc';
NUC.filnms = dir([NUC.dir filesep '*' imExt]);
%Build CIDREmodel for the nuclei images
%If the image is in RGB load in all the images and then build a cidre model
%after converting to grayscale.  Load in no more than 200 images for
%memory considerations.
if ~(cidrecorrect)
    im = imread([NUC.dir filesep NUC.filnms(1).name]);
    if ndims(im) ~= 2
        tempim = zeros(size(im,1),size(im,2),size(NUC.filnms,1));
        for i = 1:size(NUC.filnms,1)
            if i > 200
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
    if ~(cidrecorrect)
        im = imread([Cyto.(str).dir filesep Cyto.(str).filnms(1).name]);
        if ndims(im) ~= 2
            tempim = zeros(size(im,1),size(im,2),size(Cyto.(str).filnms,1));
            for j = 1:size(Cyto.(str).filnms,1)
                if j > 200
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
%Save in a file to be able to load later on especially if cidre has been
%run
save('Preliminary.mat');



load('Preliminary.mat')

%Segmentation occurs in multiple steps
%First nuclei are segmented using Otsu's method to determine background in 
%the nuclear channel.  The image is quantized into three tiers with the top
%two being assigned as nucleus (nucleus in focus and nucleus out of focus)
% Use of a watershed segmentation algorithm then assigns a label to each
% cell
%Each of the fluorescent channels are then binarized/segmented and the channel with
%the most amount of cell area is picked as defining the cytoplasm.
%The intensity in each channel for each cell is then subsequently measured.
%Subsequent use of a noise filter and hole filling smooths out the image and
%then use of a watershed segmentation to label all the cells.
%The label for the cell's cytoplasm is determined using a
%kmeans nearest neighbor algorithm from each nucleus
%Each segmented image is saved in a Segmentation folder.

h = waitbar(0.000001,'Time to complete:');
%For all nuclear images
for i = 1:size(NUC.filnms,1)
    tic
    CO = struct(); %Cellular object structure.  To be saved
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
    %If the image is not monochromatic
    if size(NUCim,3) ~=1;
        NUCim = rgb2gray(NUCim);  %Use if images are in jpg
    end
    %Correct with CIDRE model or background correction
    if ~cidrecorrect
        NUCim = (double(NUCim)-NUC.CIDREmodel.z)./(NUC.CIDREmodel.v);
        NUCim = uint16(NUCim);
    elseif tophat_rad ~=0
        NUCim = imtophat(im2double(NUCim), strel('disk', tophat_rad));
        NUCim = uint16(NUCim);
    end
    %Make sure image is uint16.
    %Run otsu's method to determine background breaking the image into
    %three thresholds
    num = multithresh(NUCim,2);
    
    % To Binary Image with otsu's threshold
    NUCim	= imquantize(NUCim, num);
    NUCim(NUCim == 1) = 0; %Background
    NUCim(NUCim == 2) = 1; %Out of focus/less bright nuclei
    NUCim(NUCim == 3) = 1; %Bright nuclei
    
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
    %imshow(label2rgb(NUC_label),[])
    
    %Here would be a good place to load a baysian correction model that has
    %been predefined to fix the segmentation....
        
    %Now segement all the channels and chose the one with the largest
    %amount of cell staining as defining the cytoplasmic boundary
    %And use that information for subsequent analysis
    for q = 1:numCh
        chnm = ['CH_' num2str(q)];
        CYPim = imread([Cyto.(chnm).dir filesep Cyto.(chnm).filnms(i).name]);
        if size(CYPim,3) ~=1;
            CYPim = rgb2gray(CYPim);  %Use if images are in jpg
        end
        %Run if the image has a minimum value of 50 to avoid segmenting Null Channels 
        %Speeds up computation.  Need to make unsupervised later...
        if max(max(CYPim)) > 50;
            %Correct with CIDRE model
            if ~cidrecorrect
                CYPim = (double(CYPim)-Cyto.(chnm).CIDREmodel.z)./(Cyto.(chnm).CIDREmodel.v);
                CYPim = uint16(CYPim);
            elseif tophat_rad ~=0
                CYPim = imtophat(im2double(CYPim), strel('disk', tophat_rad));
                CYPim = uint16(CYPim);
            end
            tempIm = CYPim; %Store the image to sum the intensity of the pixels later in the code
            CYPim = im2bw(CYPim, .1);  %Under estimate background due to uneven staining.
            % Remove Noise
            noise = imtophat(CYPim, strel('disk', 3));
            CYPim = CYPim - noise;
            % Fill Holes
            CYPim = imfill(CYPim, 'holes');
            CYP_label	= bwlabel(CYPim);
        else
            %Make all the image black so that the summation of all the
            %labels will be zero
            CYPim(:,:) = 0;
            CYP_label = bwlabel(CYPim);
        end
            %Find the number of cytoplasm and the largest amount of area
            %covered by the cytoplasm
            CO.(chnm).numCyto = max(max(CYP_label));
            largestCyto(q) = sum(sum(CYPim));     
    end
    
    %Find the largest cytoplasms to use for segmentation all channels
    [val, idx] = max(largestCyto);        
    chnm = ['CH_' num2str(idx)];
    %Store which Channel was used
    CO.channel = chnm;
    numCytowoutNuc = 0; % Number of cyptoplasms found without nuclei
    %Segment the cells using the determined channel
    CYPim = imread([Cyto.(chnm).dir filesep Cyto.(chnm).filnms(i).name]);
    if size(CYPim,3) ~=1
        CYPim = rgb2gray(CYPim);  %Use if images are in jpg
    end
    %Correct with CIDRE model
    if ~cidrecorrect
        CYPim = (double(CYPim)-Cyto.(chnm).CIDREmodel.z)./(Cyto.(chnm).CIDREmodel.v);
        CYPim = uint16(CYPim);
    elseif tophat_rad ~=0
        CYPim = imtophat(im2double(CYPim), strel('disk', tophat_rad));
        CYPim = uint16(CYPim);
    end
    tempIm = CYPim; %Store the image to sum the intensity of the pixels later in the code
    CYPim = im2bw(CYPim, .1);  %Under estimate background due to uneven staining.
    % Remove Noise
    noise = imtophat(CYPim, strel('disk', noise_disk));
    CYPim = CYPim - noise;
    % Fill Holes
    CYPim = imfill(CYPim, 'holes');
    CYP_label	= bwlabel(CYPim);
    
    %Now for each channel find the properties of the cytoplasm for each
    %nuclei.  Do not use cytplasms with no nuclei
    tempCytoLabel = zeros(size(CYP_label));
    nucl_ids_left = 1:max(max(NUC_label)); %Keep track of what nuclei have been assigned
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

    % Segment properties
    p	= regionprops(CYP_label,'PixelIdxList');
    %For each channel read in the image and store the cytoplasmic
    %information
    for q = 1:numCh
        chnm = ['CH_' num2str(q)];
        numCytowoutNuc = 0; % Number of cyptoplasms found without nuclei
        CYPim = imread([Cyto.(chnm).dir filesep Cyto.(chnm).filnms(i).name]);
        if size(CYPim,3) ~=1;
            CYPim = rgb2gray(CYPim);  %Use if images are in jpg
        end
        %Correct with CIDRE model
        if ~cidrecorrect
            CYPim = (double(CYPim)-Cyto.(chnm).CIDREmodel.z)./(Cyto.(chnm).CIDREmodel.v);
            CYPim = uint16(CYPim);
        elseif tophat_rad ~=0
            CYPim = imtophat(im2double(CYPim), strel('disk', tophat_rad));
            CYPim = uint16(CYPim);
        end
        %Now for each channel find the intensity and area 
        Int = [];
        Area = [];
        m = 1;
        for k = 1:size(p,1)
           if length(p(k).PixelIdxList~=0)
                Int(m) = sum(CYPim(p(k).PixelIdxList));
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
    i %to see a read out as the program runs
    t(i) = toc;
    num = i./size(NUC.filnms,1); 
    %Calculate the time remaining as a rolling average
    str = sprintf('Time to complete: %2.2f min', ((size(NUC.filnms,1)-i)*mean(t))./60);
    %Update waitbar
    waitbar(num,h,str);
end







