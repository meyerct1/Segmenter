function [handles] = InitializeHandles(handles)
handles.imExt = get(findobj('Tag','edit6'),'String');
handles.numCh = str2double(get(findobj('Tag','edit4'),'String'));
handles.NucnumLevel = str2double(get(findobj('Tag','edit11'),'String'));
handles.CytonumLevel = str2double(get(findobj('Tag','edit14'),'String'));
handles.col = get(findobj('Tag','edit9'),'String');
handles.row = get(findobj('Tag','edit8'),'String');
handles.ChtoSeg = str2double(get(findobj('Tag','edit12'),'String'));
handles.Parallel = get(findobj('Tag','checkbox6'),'Value');

if get(findobj('Tag','checkbox7'),'Value')
    handles.ChtoSeg = 0;
end

handles.nuclear_segment = get(findobj('Tag','checkbox2'),'Value');
handles.surface_segment =get(findobj('Tag','checkbox3'),'Value');
handles.nuclear_segement_factor = str2double(get(findobj('Tag','edit2'),'String'));
handles.surface_segment_factor = str2double(get(findobj('Tag','edit3'),'String'));
handles.smoothing_factor = str2double(get(findobj('Tag','edit10'),'String'));
handles.nuc_noise_disk = str2double(get(findobj('Tag','edit15'),'String'));
handles.noise_disk = str2double(get(findobj('Tag','edit7'),'String'));
handles.cidrecorrect = (get(findobj('Tag','checkbox1'),'Value'));
if isempty(handles.CorrIm_file)
    msgbox('Error: No Control Image Selected')
    return
end
handles.bd_pathway = get(findobj('Tag','checkbox8'),'Value');
handles.background_corr = get(findobj('Tag','checkbox9'),'Value');


handles
%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
%A lot of messy code to set up the file structure depending on whether it
%is the bd pathway or cellavista instrument.
if handles.bd_pathway
    %Set up structure with the filenames of the images to be segmented
    %Nuclei Directory (N)
    filenms = dir(handles.expDir);NUC = struct('filnms',cell(1));
    for i = 3:length(filenms)
        idx = strfind(filenms(i).name, 'Well ');
        if ~isempty(idx)
            [temp] = dir([filenms(i).name '/*' handles.imExt]);
            if isempty(NUC.filnms)
                NUC.filnms = strcat(handles.expDir, '/', filenms(i).name, '/', {temp.name});
            else
                NUC.filnms = {NUC.filnms strcat(handles.expDir, '/', filenms(i).name, '/', {temp.name})};
            end
        end
    end

    if isempty(NUC.filnms)
        msgbox('You are not in a directory with images in file structure "Well ###"... Try again')
        return
    end

    handles.NUC = NUC;

    for i = 1:handles.numCh
        chnm = ['CH_' num2str(i)];
        Cyto.(chnm).dir = chnm;
        Cyto.(chnm).filnms = dir([handles.expDir filesep chnm filesep '*' handles.imExt]);
        Cyto.(chnm).filnms = strcat(handles.expDir, '/',chnm, '/', {Cyto.(chnm).filnms.name});
        if (handles.cidrecorrect)
           Cyto.(chnm).CIDREmodel.v = csvread([handles.cidreDir filesep 'cidre_model_v.csv']);
           Cyto.(chnm).CIDREmodel.z = csvread([handles.cidreDir filesep 'cidre_model_z.csv']);
        end
        handles.Cyto = Cyto;
    end
    if handles.numCh==0
        handles.Cyto = struct();
    end
else
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

    handles.NUC = NUC;
    handles.Cyto = Cyto;
end



