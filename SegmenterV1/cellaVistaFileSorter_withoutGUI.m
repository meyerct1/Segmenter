function [] = cellaVistaFileSorter()
%This function moves the file images from cellavista experiment folder into separate
%image channels for all timepoints in the experiment to run CIDRE on before
%segmentation.  It makes new directories for each channel and then finds
%the all the timepoints folders.  It is assumed that whole well images have
%the string 'CH' in them.  First the function compiles an cell array of all
%the file names for each images in each experiment and assigns them a
%channel or nucleus designation.  It then passes to a for loop that moves
%all the files into the correct directory.
%numChannels includes the nucleus channel!
%imExt (image extension includes the period. ie '.jpg' or '.tiff'
%%NOTE: Function must be run in the directory where all the experimental
%%folders are and cannot be run more than once as it will overwrite
%%files!!!
%Christian Meyer 7/12/15 christian.t.meyer@vanderbilt.edu

clear

numChannels = 2;
imExt = '.tiff';
NucCH = 2;
BF = 0;  %Channel for Brightfield.  If Zero no Brightfield channel assumed
mvWhole_Well = 0;  %Move the whole well images?  1 = yes


%Find the experiment names of all the folders in the current directory.
%Usually '1' '2' '3' ect.  Only add directories
temp = dir();
k = 1;
%From 3: to ignore the . and .. directories
for i = 3:size(temp,1)
    if isdir(temp(i).name)
        ExpImDir{k} = temp(i).name;
        k = k +1;
    end
end

%Make directories for each channel and the nuclear channel to move the
%files into
mkdir('Nuc')
if BF ~=0
    mkdir('BF')
    numCh = numChannels - 2;
else
    numCh = numChannels - 1;
end

for i = 1:numCh
    mkdir(['CH_' num2str(i)]);
end
        
%Store the number of experiments in this directory
numExp = size(ExpImDir,2);
%Declare a cell array for holding the file names and what channel it
%corresponds to.
file_names = cell(1,2);
k = 1;
%Create a cell list of all the files locations
for i = 1:numExp
    temp = dir([ExpImDir{i} '/*' imExt]);
    %Find the images of the whole well
    whole_well = strfind({temp(:).name},'CH');
    whole_well = cellfun(@isempty,whole_well);
    idx1 = find(whole_well == 1);  %Find the index of non-whole well images
    idx2 = find(whole_well == 0);  %Find the index of the whole well images
    
    for j = 1:size(idx1,2)/numChannels
        init = (j-1)*numChannels; %Starting point in the idx1 array in each loop
        m = 1;
        %For each channel store the filename and give it a designation
        %which matches the directories created
        for q = 1:numChannels
            file_names{k,1} = [ExpImDir{i} filesep temp(idx1(init+q)).name];    
            if q == NucCH
                file_names{k,2} = 'Nuc';
            elseif q == BF
                file_names{k,2} = 'BF';
            else
                file_names{k,2} = ['CH_' num2str(m)];
                m = m+1;
            end
            k = k+1;
        end
    end
    %Assign desination of whole well to all the whole well images.
    %Whole well images are left in each experiment folder.
    for j = 1:size(idx2,2)
        file_names{k,1} =  [ExpImDir{i} filesep temp(idx2(j)).name];
        file_names{k,2} = 'Whole Well';
        k = k+1;
    end
end


%Optionally  move all the 'Whole Well' Images first to allow for Cidre
%correction model to be built
if mvWhole_Well == 1
    mkdir('Whole Well')
    temp = strfind({file_names{:,2}},'Whole Well');
    idx = find(cellfun(@isempty,temp)==0);
    for j = 1:size(idx,2)
        movefile([file_names{idx(j),1}],'Whole Well')
    end
end
%Now move the files into the correct directories leaving the whole well
%images in the experimental directory.
temp = strfind({file_names{:,2}},'Nuc');
idx = find(cellfun(@isempty,temp)==0);
for j = 1:size(idx,2)
    movefile([file_names{idx(j),1}],'Nuc')
end

if BF ~=0
    temp = strfind({file_names{:,2}},'BF');
    idx = find(cellfun(@isempty,temp)==0);
    for j = 1:size(idx,2)
        movefile([file_names{idx(j),1}],'BF')
    end
end

for j = 1:numCh
    temp = strfind({file_names{:,2}},['CH_' num2str(j)]);
    idx = find(cellfun(@isempty,temp)==0);
    for q = 1:size(idx,2)
        movefile([file_names{idx(q),1}],['CH_' num2str(j)]);
    end
end



