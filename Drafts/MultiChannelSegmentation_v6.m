% Multi Channel Cell Segmentation with channel correction.  
%%Christian Meyer 10.22.15
%Segmentation code to find the intensities per cell of the each channel for
%a series of images from the CellaVista presorted with the
%cellaVistaFileSorter
%Option for segmenting just the surface of the cell or segmenting based on
%the nucleus by adding a dilated nuclear channel to the cytoplasmic
%segmentation.
%First block of code builds the basic sturcture of to hold the 
%Nuclear and cytoplasmic files.
%Currently a rolling ball background filter is applied to correct for
%background; however, the code is set up to take a cidre correction model
%in the future.
%All functionality assumes images have been separated into separate 
%Channels useing cellaVistaFileSorter.m
%Segmentation of all channels for each image based on nuclear image.
%First nuclei are segmented.  Then each cytoplasmic channel is segmented and 
%added together to come up with a final cytoplamsic bw image
%Finally the cytoplasmic bw image is segmented and the intensity, area, and
%nuclear and cytoplasmic labels are stored in a structure which is saved to
%a folder called segemented with the row and channel name.

clear

%Number of channels in the image
numCh = 2; %Excluding nuclei and BF channels
imExt = '.jpg'; %image extention
%Use CIDRE correction model? 1=yes
cidrecorrect = 0;
numLevels = 2;  %Number of levels for cytoplasmic segmentation using otsu's method

%If surface_segment == 1, segment only the perimeter of each cell to look at cell surface
%markers
surface_segment = 0;
perimeter_size_disk = 7;

%If nuc_segment == 1, segment only based on the nucleus by dilating the 
%nucleus by the disk nuc_dil_disk.  Cannot have surface_segment and
%nuc_segment == 1 at the same time.
nuc_segment = 0;
nuc_dil_disk = 10;

%Channel bleed over correction. corCH{1} is the channel to correct,
%corCH{2} is the channel to correct based on.  corVal is the percent value
%to correct per cell.  Determined from the null condition before hand for
%given exposures.
corCH{1} = 'CH_3'; corCH{2} = 'Nuc';
corVal = 29;

%The noise filter disk used is 5.
noise_disk = 5;
%Use a background correction if cidre was used
if cidrecorrect
    tophat_rad = 0;  %Background correction
else
    tophat_rad = 50;  %To correct for uneven illumination
end

%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
NUC.dir = 'Nuc';
NUC.filnms = dir([NUC.dir filesep '*' imExt]);
NUC.filnms = strcat({NUC.dir}, '/', {NUC.filnms.name});
if isempty(NUC.filnms)
    error('You are not in a directory with sorted images... Try again')
end
if cidrecorrect
    NUC.CIDREmodel.v = csvread('CIDRE model');
end

%Create a structure for each of the channels
for i = 1:numCh
    chnm = ['CH_' num2str(i)];
    Cyto.(chnm).dir = chnm;
    Cyto.(chnm).filnms = dir([chnm filesep '*' imExt]);
    Cyto.(chnm).filnms = strcat(chnm, '/', {Cyto.(chnm).filnms.name});
    if (cidrecorrect)
       Cyto.(chnm).CIDREmodel.v = csvread('CIDRE Model');
    end
end

%Correct directory listings based on the number in the image file between the - -
%eg the 1428 in the file name 20150901141237-1428-R05-C04.jpg
%This is necessary due to matlab dir command sorting placing 1000 ahead of
%999.
for i = 1:size(NUC.filnms,2)
    str = (NUC.filnms{i});idx = strfind(str,'-');
    val(i,1) = str2num(str(idx(1)+1:idx(2)-1));
end
for j = 1:numCh
    for i = 1:size(NUC.filnms,2)
         chnm = ['CH_' num2str(j)];
         str = (Cyto.(chnm).filnms{i}); idx = strfind(str,'-'); 
         val(i,j+1) = str2num(str(idx(1)+1:idx(2)-1));
    end
end
[temp idx] = sort(val);
NUC.filnms = {NUC.filnms{idx(:,1)}};
for i = 1:numCh
    chnm = ['CH_' num2str(i)];
    Cyto.(chnm).filnms = {Cyto.(chnm).filnms{idx(:,i+1)}};
end

%Make a directory for the segemented files
mkdir('Segmented')

%Check to make sure surface_segment and nuc_segment dont both ==1
if nuc_segment == 1 && surface_segment == 1
    error('Eror: nuc_segment=surface_segment=1')
end

%Segmentation occurs in multiple steps
%First nuclei are segmented using Otsu's method to determine background in 
%the nuclear channel.  The image is quantized into three tiers with the top
%two being assigned as nucleus (nucleus in focus and nucleus out of focus)
% Use of a watershed segmentation algorithm then assigns a label to each
% cell
%Each of the fluorescent channels are then binarized, added, and segmented.
%The intensity in each channel for each cell is then subsequently measured.
%Subsequent use of a noise filter and hole filling smooths out the image and
%then use of a watershed segmentation to label all the cells.
%The label for the cell's cytoplasm is determined using a
%kmeans nearest neighbor algorithm from each nucleus
%Each segmented image is saved in a Segmentation folder.


% %If you would like to look at the segmentation for a given image
% uncomment code below and change im_name to match the name of the nuclear image in Nuc folder.
%{
    im_name = ['20150910160148-5959-R02-C05' imExt];
    temp = strfind({NUC.filnms{:}},im_name);
    temp = cellfun(@isempty,temp);
    im = find(temp == 0);
    if isempty(im)
        error('No image file in the Nuc folder with that name...try again')     
    end
    singleSegFig(im,numCh,imExt,cidrecorrect,numLevels,surface_segment,perimeter_size_disk,tophat_rad,...
              nuc_segment,nuc_dil_disk,corCH,corVal,noise_disk,NUC,Cyto)
%}  

%Preallocate image arrays for memory
tempIm = imread(char(NUC.filnms(1)));
Im_array  = zeros(size(tempIm,1),size(tempIm,2),numCh+1);
SegIm_array  = zeros(size(tempIm,1),size(tempIm,2),numCh+1);
Nuc_label = zeros(size(tempIm,1),size(tempIm,2),1);

h = waitbar(0.000001,'Time to complete:');
%For all images
for i = 1:size(NUC.filnms,2)
    tic
    CO = struct(); %Cellular object structure.  To be saved
    nm = char(NUC.filnms(i));
    foo = strfind(nm, '-');
    %Store the row and column names from the filename
    rw = nm(foo(2)+1:foo(2)+3);
    cl = nm(foo(3)+1:foo(3)+3);
    
%   store the time from the file name
%   tim.day = str2double(nm(7:8));
%   tim.hr = str2double(nm(9:10));
%   tim.min = str2double(nm(11:12));
    %Initalize array that holds the label image for cytoplasm
    Label_array = zeros(size(tempIm,1),size(tempIm,2),1);

    %Read in all the images into Im_array matrix and correct for illumination with CIDRE or
    %tophat.  Store the nuclear image first!
    tempIm = imread(char(NUC.filnms(i)));
    if size(tempIm,3) ~=1
        tempIm = rgb2gray(tempIm);
    end
    %Correct with CIDRE model or background correction
    if cidrecorrect
        tempIm = (double(tempIm)-NUC.CIDREmodel.z)./(NUC.CIDREmodel.v);
    elseif tophat_rad ~=0
        tempIm = imtophat(im2double(tempIm), strel('disk', tophat_rad));
    end
    %Convert to 16bit image
    tempIm = im2uint8(tempIm);
    Im_array(:,:,1) = tempIm;
    %read in all cytoplasmic channels
    for q = 1:numCh
        chnm = ['CH_' num2str(q)];
        tempIm = imread(char(Cyto.(chnm).filnms(i)));
        if size(tempIm,3) ~=1
            tempIm = rgb2gray(tempIm);
        end
        %Correct with CIDRE model or background correction
        if cidrecorrect
            tempIm = (double(tempIm)-Cyto.(chnm).CIDREmodel.z)./(Cyto.(chnm).CIDREmodel.v);
        elseif tophat_rad ~=0
            tempIm = imtophat(im2double(tempIm), strel('disk', tophat_rad));
        end
        %For Channel correction
%         if strcmp(chnm,corCH{1}) %If this is a channel to correct
%               if strcmp(corCH{2}, 'Nuc') %If the channel to correct from is the nucleus
%                     temp_chnm = ['CH_' num2str(m)];
%                     tempIm = im2double(tempIm) - corVal/100*im2double(Im_array(:,:,1));
%                     tempIm = corVal/100*im2double(Im_array(:,:,1));
%               else %Loop through to find the channel to correct from
%                     for m = 1:numCh
%                         if strcmp(temp_chnm,corCH{1}]
%                            tempIm = im2double(tempIm) - corVal/100*im2double(Im_array(:,:,m+1));
%                            tempIm = corVal/100*im2double(Im_array(:,:,1));
%                         end
%                     end
%               end
%         end
        %Convert to 16bit image
        tempIm = im2uint8(tempIm);
        %Store in the Image array
        Im_array(:,:,q+1) = tempIm;
    end
    
    %%Now segment the nucleus
    % To Binarize Image with otsu's threshold
    num = multithresh(Im_array(:,:,1),2);
    SegIm_array(:,:,1)	= imquantize(Im_array(:,:,1), num);
    SegIm_array(SegIm_array(:,:,1) == 1) = 0; %Background
    SegIm_array(SegIm_array(:,:,1) == 2) = 1; %Out of focus/less bright nuclei
    SegIm_array(SegIm_array(:,:,1) == 3) = 1; %Bright nuclei
    
    % Remove Noise using the noise_disk
    noise = imtophat(SegIm_array(:,:,1), strel('disk', noise_disk));
    SegIm_array(:,:,1) = SegIm_array(:,:,1) - noise;
    
    % Fill Holes
    SegIm_array(:,:,1) = imfill(SegIm_array(:,:,1), 'holes');
    
    %To separate touching nuclei, compute the distance of the binary 
    %transformed image using the bright areas of the image as the basins 
    %by inverse of the distance measure
    D = -bwdist(~SegIm_array(:,:,1));
    D = -imhmax(-D,3);  %Suppress values below 3. To prevent oversegmentation...  Make variable in image segmentation in future?
    Nuc_label = watershed(D);
    Nuc_label(SegIm_array(:,:,1) == 0) = 0; %Write all the background to zero.
    %imshow(label2rgb(Nuc_label),[])
    
    %Here would be a good place to load a baysian correction model that has
    %been predefined to fix the segmentation....
    
    if nuc_segment==1
            Label_array = im2double(imdilate(SegIm_array(:,:,1),strel('disk',nuc_dil_disk)));
    else
        %Now segement all the channels
        for q = 1:numCh
            chnm = ['CH_' num2str(q)]; %Channel
            %Run if the image has a low variance to avoid segmenting Null Channels 
            %Speeds up computation.  Need to make unsupervised later...
            if std(std(Im_array(:,:,q+1))) > 2; %Average variance observed ~ 10
                 num = multithresh(Im_array(:,:,q+1),numLevels); %Run Otsu's method
                  %Quantize the image based on multithreshold.  Set every level above 1 to cell and 1 to background (0)
                  tempIm= imquantize(Im_array(:,:,q+1), num); 
                  tempIm(tempIm == 1) = 0; %Background
                  %everyother level is a cell
                  for j = (numLevels+1):(-1):2
                      tempIm(tempIm == j) = 1;
                  end
                % Remove Noise
                noise = imtophat(tempIm, strel('disk', noise_disk));
                SegIm_array(:,:,q+1) = tempIm - noise;
                % Fill Holes
                SegIm_array(:,:,q+1) = imfill(SegIm_array(:,:,q+1), 'holes');
            else
                %Make all the image black so that the summation of all the
                %labels will be zero
                SegIm_array(:,:,q+1) = 0;
            end
        end

        %Combine all the channels for cytoplasm segmentation
        for q=1:numCh
            Label_array = Label_array + SegIm_array(:,:,q+1);
        end
        Label_array(Label_array>1) = 1;
    end
    %Label cytoplasm cell staining
    Label_array = bwlabel(Label_array);
    numCytowoutNuc = 0; % Number of cyptoplasms found without nuclei
    
    %Now use a knn identifier to assign each cytoplasm to a nucleus
    %Now for each channel find the properties of the cytoplasm for each
    %nuclei.  Do not use cytplasms with no nuclei
    CytoLabel = zeros(size(Nuc_label));
    nucl_ids_left = 1:max(max(Nuc_label)); %To keep track of what nuclei have been assigned
    for j = 1:max(max(Label_array))
        cur_cluster = (Label_array==j); %Find the current cluster of cytoplasmic labels
        %get the nuclei ids present in the cluster
        nucl_ids=Nuc_label(cur_cluster);   
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
            if (sum(sum(cur_cluster))) > sum(sum(ismember(Nuc_label,nucl_ids)))
                CytoLabel(cur_cluster)=nucl_ids;
                %delete the nucleus that have already been processed
                nucl_ids_left(nucl_ids_left==nucl_ids)=[];
            end
        else
            %Use of knn classifier
            %get an index to only the nuclei
            nucl_idx=ismember(Nuc_label,nucl_ids);
            %get the x-y coordinates
            [nucl_x nucl_y]=find(nucl_idx); %Location of all the nuclear pixels
            [cluster_x cluster_y]=find(cur_cluster);  %Location of all cytoplasm pixels
            group_data= Nuc_label(nucl_idx); %Classification of all nuclear labels

            %classify each pixel in the cluster
            %Dont need every pixel in the nucleus to find nearest neighbor.
            %Cuts down on model building time
            %Build a model based on spatial information of what each group
            %each x y coordinate is assigned to then use to predict what each
            %cytoplasmic element belongs to...
            knnModel = fitcknn([nucl_x(1:10:end) nucl_y(1:10:end)],group_data(1:10:end));
            CytoLabel(cur_cluster) = predict(knnModel,[cluster_x cluster_y]);

            %delete the nucleus that have already been processed
            for elm = nucl_ids'   
                nucl_ids_left(nucl_ids_left==elm)=[];
            end
        end
    end
    %if only segmenting the perimeter of each cell to look only as cell
    %surface markers
    if surface_segment == 1 
        %Now for each cytoplasm find the perimeter
        PerimId = cell(max(max(CytoLabel)),1);
        for j = 1:max(max(CytoLabel))
            cur_cluster = (CytoLabel == j);
            PerimId{j} = find(bwperim(cur_cluster)==1);
        end
        %Now compile all the perimeters
        temp = zeros(size(Nuc_label));
        for j = 1:max(max(CytoLabel))
            temp(PerimId{j}) = 1;
        end
        %Dialate the perimeters
        Cell_Surface_Mask = imdilate(temp,strel('disk',perimeter_size_disk));
        CytoLabel(find(Cell_Surface_Mask==0))= 0;
    end
    %imshow(label2rgb(CytoLabel),[])
    %Clear the border cells.
    CytoLabel = imclearborder(CytoLabel);

    % Segmented cytoplasm properties
    p	= regionprops(CytoLabel,'PixelIdxList','Perimeter');
    %For each channel read in the image and store the cytoplasmic
    %information
    for q = 1:numCh
        chnm = ['CH_' num2str(q)];                   
        %Now for each channel find the intensity and area 
        Int = [];
        Area = [];
        Perimeter = [];
        m = 1;
        tempIm = Im_array(:,:,q+1);
        if size(p,1) ~= 0
            for k = 1:size(p,1)
                Int(m) = sum(tempIm(p(k).PixelIdxList));
                Area(m) = length(p(k).PixelIdxList);
                Perimeter(m) = p(k).Perimeter;
                m= m+1;
            end
        end
        %For each channel save information into the structure
        CO.(chnm).Intensity = Int;
        CO.(chnm).Area = Area;
        CO.(chnm).Perimeter = Perimeter;
    end
    %Store similar information for the Nucleus segmentation
    p	= regionprops(Nuc_label,'PixelIdxList','Perimeter');
    Int = []; Area = []; Perimeter = [];
    m = 1;
    tempIm = Im_array(:,:,1);
    if size(p,1) ~= 0
        for k = 1:size(p,1)
            Int(m) = sum(tempIm(p(k).PixelIdxList));
            Area(m) = length(p(k).PixelIdxList);
            Perimeter(m) = p(k).Perimeter;
            m= m+1;
        end
    end
    %For each channel save information into the structure
    CO.Nuc.Intensity = Int;
    CO.Nuc.Area = Area;
    CO.Nuc.Perimeter = Perimeter;
    
    %Save the nucleus information
    %%Count the number of cells in the image from the number of labels
    CO.cellCount = max(max(Nuc_label));     
    CO.Nuc_label = Nuc_label;
    CO.label = CytoLabel;
    CO.numCytowoutNuc = numCytowoutNuc;
    CO.numCyto = length(unique(CytoLabel))-1;

    %Save segmentation in a directory called segmented
    save(['Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
    i %to see a read out as the program runs
    t(i) = toc;
    num = i./size(NUC.filnms,2); 
    %Calculate the time remaining as a rolling average
    chnm = sprintf('Time to complete: %2.2f min', ((size(NUC.filnms,2)-i)*mean(t))./60);
    %Update waitbar
    waitbar(num,h,chnm);
end
close(h)
