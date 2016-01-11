imExt = '.jpg'
cidrecorrect =1
numLevels = 20
surface_segment = 0
nuclear_segment = 0
noise_disk = 5
nuclear_segment_factor = 0
surface_segment_factor = 0
cl_border = 1
smoothing_factor = 2
numCh = 1;
NucSegHeight = 1;
handles.numCh = numCh
handles.expDir = pwd;
handles.cidreDir = uigetdir();
handles.imExt = imExt;
handles.cidrecorrect = cidrecorrect;
%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
NUC.dir = 'Nuc';
NUC.filnms = dir([handles.expDir filesep NUC.dir filesep '*' handles.imExt]);
NUC.filnms = strcat(handles.expDir, '/', {NUC.dir}, '/', {NUC.filnms.name});
if isempty(NUC.filnms)
    msgbox('You are not in a directory with sorted images... Try again')
    return
end


%Create a structure for each of the channels
for i = 1:handles.numCh
    chnm = ['CH_' num2str(i)];
    Cyto.(chnm).dir = chnm;
    Cyto.(chnm).filnms = dir([handles.expDir filesep chnm filesep '*' handles.imExt]);
    Cyto.(chnm).filnms = strcat(handles.expDir, '/',chnm, '/', {Cyto.(chnm).filnms.name});
    if (handles.cidrecorrect)
       Cyto.(chnm).CIDREmodel.v = csvread([handles.cidreDir filesep 'cidre_model_v.csv']);
       Cyto.(chnm).CIDREmodel.z = csvread([handles.cidreDir filesep 'cidre_model_z.csv']);
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
for j = 1:handles.numCh
    for i = 1:size(NUC.filnms,2)
         chnm = ['CH_' num2str(j)];
         str = (Cyto.(chnm).filnms{i}); idx = strfind(str,'-'); 
         val(i,j+1) = str2num(str(idx(1)+1:idx(2)-1));
    end
end
[temp idx] = sort(val);
NUC.filnms = {NUC.filnms{idx(:,1)}};
for i = 1:handles.numCh
    chnm = ['CH_' num2str(i)];
    Cyto.(chnm).filnms = {Cyto.(chnm).filnms{idx(:,i+1)}};
end


i = 20
NaiveSegmentV1(imExt,cidrecorrect,numLevels,surface_segment,nuclear_segment,noise_disk,...
    nuclear_segment_factor,surface_segment_factor,cl_border,smoothing_factor,NucSegHeight,numCh,NUC,Cyto,i)