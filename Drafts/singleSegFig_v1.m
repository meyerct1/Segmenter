function [] = singleSegFig(im,numCh,imExt,cidrecorrect,numLevels,surface_segment,perimeter_size_disk,...
                            nuc_segment,nuc_dil_disk,corCH,corVal,noise_disk,NUC.Cyto)
% Multi Channel Cell Segmentation with channel correction. Single figure generation 
%%Christian Meyer 10.22.15

%Preallocate for memory
tempIm = imread(char(NUC.filnms(1)));
Im_array  = zeros(size(tempIm,1),size(tempIm,2),numCh+1);
SegIm_array  = zeros(size(tempIm,1),size(tempIm,2),numCh+1);
Nuc_label = zeros(size(tempIm,1),size(tempIm,2),1);

CO = struct(); %Cellular object structure.  To be saved
nm = char(NUC.filnms(im));
foo = strfind(nm, '-');
%Store the row and column names from the filename
nm(foo(2)+1:foo(2)+3);
nm(foo(3)+1:foo(3)+3);

Label_array = zeros(size(tempIm,1),size(tempIm,2),1);

%Read in all the images into Im_array matrix and correct for illumination with CIDRE or
%tophat.  Store the nuclear image first!
tempIm = imread(char(NUC.filnms(im)));
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
tempIm = im2uint16(tempIm);
Im_array(:,:,1) = tempIm;
%read in all cytoplasmic channels
for q = 1:numCh
    chnm = ['CH_' num2str(q)];
    tempIm = imread(char(Cyto.(chnm).filnms(im)));
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
    tempIm = im2uint16(tempIm);
    %Store in the Image array
    Im_array(:,:,q+1) = tempIm;
end

num_ImCH = size(Im_array,3)
figure()
for j = 1:num_ImCH
    subplot(2,2,j)
    imshow(Im_array(:,:,j),[])
    str = sprintf('Ill. Corr. CH_%i',j);
    title(str)
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

%Here would be a good place to load a baysian correction model that has
%been predefined to fix the segmentation....

%Now segement all the channels
for q = 1:numCh
    chnm = ['CH_' num2str(q)]; %Channel
    %Run if the image has a low variance to avoid segmenting Null Channels 
    %Speeds up computation.  Need to make unsupervised later...
    if std(std(Im_array(:,:,q+1))) > 500; %Average variance observed ~ 4000
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

if nuc_segment == 1
    %Add in a dilated Nucleus
    Label_array = Label_array + im2double(imdilate(Nuc_label,strel('disk',nuc_dil_disk))); 
end

Label_array(Label_array>1) = 1;
%Label everything
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

figure()
subplot(1,2,1)
imshow(label2rgb(CytoLabel),[])
subplot(1,2,2)
imshow(label2rgb(Nuc_label),[])

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


% %To check Segmentation
% figure
% subplot(2,2,1)
% imshow(Im_array(:,:,1),[])
% subplot(2,2,2)
% imshow(Im_array(:,:,idx+1),[])
% subplot(2,2,3)
% imshow(label2rgb(Nuc_label),[])
% subplot(2,2,4)
% imshow(label2rgb(CytoLabel),[])
% 
% i = 116
% 
% 
% figure()
% imshow(label2rgb(CytoLabel),[])
% 

 