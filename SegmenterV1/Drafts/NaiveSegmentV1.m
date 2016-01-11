function [CO,Im_array] = NaiveSegmentV1(imExt,cidrecorrect,numLevels,surface_segment,nuclear_segment,noise_disk,...
    nuclear_segment_factor,surface_segment_factor,cl_border,smoothing_factor,NucSegHeight,numCh,NUC,Cyto,i)

CO = struct(); %Cellular object structure.  To be saved
tempIdx = strfind(NUC.filnms(i),'/');
nm = char(NUC.filnms{i}(tempIdx{1}(length(tempIdx{:}))+1:end));
foo = strfind(nm, '-');
%Store the row and column names from the filename
CO.rw = nm(foo(2)+1:foo(2)+3);
CO.cl = nm(foo(3)+1:foo(3)+3);
CO.filename = char(nm);
%   store the time from the file name
CO.tim.year = str2double(nm(1:4));
CO.tim.month = str2double(nm(5:6));
CO.tim.day = str2double(nm(7:8));
CO.tim.hr = str2double(nm(9:10));
CO.tim.min = str2double(nm(11:12));
%Initalize array that holds the label image for cytoplasm

%Read in all the images into Im_array matrix and correct for illumination with CIDRE or
%tophat.  Store the nuclear image first!
tempIm = imread(char(NUC.filnms(i)));

%Initialize all the arrays within the parfor loop
Im_array  = zeros(size(tempIm,1),size(tempIm,2),numCh+1);
SegIm_array  = zeros(size(tempIm,1),size(tempIm,2),numCh+1);
Nuc_label = zeros(size(tempIm,1),size(tempIm,2),1);
Label_array = zeros(size(tempIm,1),size(tempIm,2),1);

if size(tempIm,3) ~=1
    tempIm = rgb2gray(tempIm);
end

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
        tempIm = ((double(tempIm))./(Cyto.(chnm).CIDREmodel.v))*mean(Cyto.(chnm).CIDREmodel.v(:));
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
 %Store in the Image array
    Im_array(:,:,q+1) = tempIm;
end


%%Now segment the nucleus
% To Binarize Image with otsu's threshold
num = multithresh(Im_array(:,:,1),2);
SegIm_array(:,:,1)	= imquantize(Im_array(:,:,1), num);
SegIm_array(SegIm_array(:,:,1) == 1) = 0; %Background
SegIm_array(SegIm_array(:,:,1) == 2) = 1; %slightly out of focus Nuclei
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
D = -imhmax(-D,NucSegHeight);  %Suppress values below 3. To prevent oversegmentation...  Make variable in image segmentation in future?
Nuc_label = watershed(D);
Nuc_label(SegIm_array(:,:,1) == 0) = 0; %Write all the background to zero.
%imshow(label2rgb(Nuc_label),[])
if max(std(Im_array(:,:,1))) < 15 || i == 20
    Nuc_label = zeros(size(Nuc_label));
end
%Here would be a good place to load a baysian correction model that has
%been predefined to fix the segmentation....

if nuclear_segment==1 && surface_segment == 0
        Label_array = im2double(imdilate(SegIm_array(:,:,1),strel('disk',abs(nuclear_segment_factor))));
else
    %Now segement all the channels
    for q = 1:numCh
        chnm = ['CH_' num2str(q)]; %Channel
        %Walk down in the number of levels until Otsu's method
        %converges by casting the warning messages as errors and then
        %running a while loop in a cat
        s = warning('error','images:multithresh:degenerateInput');
        s = warning('error','images:multithresh:noConvergence'); cnt = 1;
        try num = multithresh(Im_array(:,:,q+1),3);
        catch exception
            while cnt<numLevels
              try 
                  num = multithresh(Im_array(:,:,q+1),numLevels-cnt);
                  break;
              end
              cnt = cnt+1;
            end
        end
        %Run Otsu's method
        %Quantize the image based on multithreshold.  Set every level above 1 to cell and 1 to background (0)
        tempIm= imquantize(Im_array(:,:,q+1), num); 
        tempIm(tempIm == 1) = 0; %Background
        % all other levels are considered significant
        tempIm(tempIm > 1) = 1;
        % Remove Noise
        noise = imtophat(tempIm, strel('disk', noise_disk));
        SegIm_array(:,:,q+1) = tempIm - noise;
    end

    %Combine all the channels for cytoplasm segmentation
    for q=1:numCh
        Label_array = Label_array + SegIm_array(:,:,q+1);
    end
    Label_array(Label_array>1) = 1;
    if smoothing_factor > 0
        Label_array = imdilate(Label_array,strel('disk',smoothing_factor));
    elseif smoothing_factor<0
        Label_array = imerode(Label_array,strel('disk',abs(smoothing_factor)));
    end
    % Fill Holes
    Label_array = imfill(Label_array, 'holes');
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

if cl_border == 1
    %Clear the border cells.
    border_cells = [CytoLabel(1,:)   CytoLabel(:,size(CytoLabel,2))'   CytoLabel(size(CytoLabel,1),:)  CytoLabel(:,1)'];
    border_cells = unique(border_cells(border_cells~=0));
    unique_cells = unique(CytoLabel(CytoLabel~=0));
end
%Now reassign all the cells such that they have the nuclear and
%cytoplasm labels match
cnt = 1;
for k = 1:max(max(CytoLabel))
    if ismember(k,border_cells)
        CytoLabel(CytoLabel==k)=0;
    elseif ismember(k,unique_cells)
        CytoLabel(CytoLabel==k) = cnt;
        cnt = cnt+1;
    end
end
tempIm = Nuc_label;
Nuc_label = zeros(size(Nuc_label));
for j = 1:max(max(CytoLabel))
    cur_cluster = (CytoLabel==j); %Find the current cell
    %get the nuclei ids present in the cluster
    nuc_ids = unique(tempIm(cur_cluster));
    nuc_ids = nuc_ids(nuc_ids~=0);
    if length(nuc_ids)==1
        Nuc_label(tempIm == nuc_ids) = j;   %Find the nucleus that corresponds to that cluster
    else
        for k = 1:length(nuc_ids)
            temp(k) = sum(sum(tempIm(cur_cluster) == nuc_ids(k)));
        end
        [temp, idx] = max(temp);
        Nuc_label(tempIm == nuc_ids(idx)) = j;
    end 
end

%if only segmenting the perimeter of each cell to look only as cell
%surface markers
temp = [];
if surface_segment == 1 && nuclear_segment == 0
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
    Cell_Surface_Mask = imdilate(temp,strel('disk',surface_segment_factor));
    CytoLabel(Cell_Surface_Mask==0)= 0;
elseif surface_segment==1 && nuclear_segment == 1
    tempIm = Nuc_label;
    tempIm(tempIm>0) = 1;
    if nuclear_segment_factor<0
        tempIm = im2double(imerode(Nuc_label,strel('disk',abs(nuclear_segment_factor))));
    else
        tempIm = im2double(imdilate(Nuc_label,strel('disk',nuclear_segment_factor)));
    end
    CytoLabel(tempIm>0) = 0;
end
%imshow(label2rgb(CytoLabel),[])
% Segmented cytoplasm properties
p	= regionprops(CytoLabel,'PixelIdxList','Perimeter','Centroid');
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
    CO.(chnm).Background = median(tempIm(CytoLabel==0));
end

%Store similar information for the Nucleus segmentation
p	= regionprops(Nuc_label,'PixelIdxList','Perimeter','MajorAxisLength',...
    'MinorAxisLength','EquivDiameter','Solidity','EulerNumber','ConvexArea','Centroid');
Int = []; Area = []; Perimeter = [];MajorAxisLength = []; 
MinorAxisLength = []; EquivDiameter = []; Solidity = []; 
EulerNumber = []; ConvexArea= [];Centroid = [];
m = 1;
tempIm = Im_array(:,:,1);
if size(p,1) ~= 0
    for k = 1:size(p,1)
        Centroid(m,:) = p(k).Centroid;
        Int(m) = sum(tempIm(p(k).PixelIdxList));
        Area(m) = length(p(k).PixelIdxList);
        Perimeter(m) = p(k).Perimeter;
        MajorAxisLength(m) = p(k).MajorAxisLength;
        MinorAxisLength(m) = p(k).MinorAxisLength;
        EquivDiameter(m) = p(k).EquivDiameter;
        Solidity(m) = p(k).Solidity;
        EulerNumber(m) = p(k).EulerNumber;
        ConvexArea(m) = p(k).ConvexArea;
        m= m+1;
    end
end
%For each channel save information into the structure
CO.Centroid = Centroid;
CO.cellId = 1:size(p,1);
CO.Nuc.Background = median(tempIm(Nuc_label==0));
CO.Nuc.Intensity = Int;
CO.Nuc.Area = Area;
CO.Nuc.Perimeter = Perimeter;
CO.Nuc.MajorAxisLength = MajorAxisLength;
CO.Nuc.MinorAxisLength = MinorAxisLength;
CO.Nuc.EquivDiameter = EquivDiameter;
CO.Nuc.Solidity = Solidity;
CO.Nuc.EulerNumber = EulerNumber;
CO.Nuc.ConvexArea = ConvexArea;
CO.Nuc.cellId = 1:size(p,1);

%initialize fields in the struct
CO.class.debris     	= [];
CO.class.nucleus    	= [];
CO.class.over       	= [];
CO.class.under      	= [];
CO.class.predivision 	= [];
CO.class.postdivision	= [];
CO.class.apoptotic  	= [];
CO.class.newborn    	= [];
    
%Run a first pass to classify the nuclei
for k=1:size(p,1)
    CO.class.debris(k)     	= 0;
    CO.class.nucleus(k)    	= 0;
    CO.class.over(k)       	= 0;
    CO.class.under(k)      	= 0;
    CO.class.predivision(k) 	= 0;
    CO.class.postdivision(k)	= 0;
    CO.class.apoptotic(k)  	= 0;
    CO.class.newborn(k)    	= 0;
end
logDist = log(CO.Nuc.Area);
avg_dist = mean(logDist);
std_dist = std(logDist);
for k=1:size(p,1)
    %rough first pass classification
    if(logDist(k) < avg_dist-3*std_dist)    
      CO.class.debris(k) 	= 1;
    elseif(logDist(k) < avg_dist-2*std_dist) 
      CO.class.newborn(k) 	= 1;
      CO.class.nucleus(k) 	= 1;
    elseif(logDist(k) < avg_dist+1.8*std_dist)  
      CO.class.nucleus(k) 	= 1;
    else
      CO.class.under(k) 	= 1;
    end
end

%Save the nucleus information
%%Count the number of cells in the image from the number of labels
CO.cellCount = max(max(Nuc_label));     
CO.Nuc_label = Nuc_label;
CO.label = CytoLabel;
CO.numCytowoutNuc = numCytowoutNuc;
CO.numCyto = length(unique(CytoLabel))-1;
