function [handles] = ExportSegmentation(handles)
%Function for exporting the data after segmentation.
%Cell Events.csv contains each cell's data
%Image Events is a summary of each image segmented
%Handles.mat contains handle to the segmenter and all the parameters
%Processing Parameters.csv contains all the segmentation parameters used

seg_file = dir([handles.expDir filesep 'Segmented/*.mat'])

handles.numCh

%Declare structure for holding data
Seg = struct('Nuc_IntperA',[],'NucArea',[],'NucInt',[],'numCytowoutNuc',[],...
    'cellcount',[],'RW',cell(1),'CL',cell(1),'ImNum',[],'min',cell(1),'day',...
    cell(1),'month',cell(1),'year',cell(1),'NucBackground',[],...
    'class',struct('debris',[],'nucleus',[],'over',[],'under',[],...
    'predivision',[],'postdivision',[],'apoptotic',[],'newborn',[],'edge',[]),...
    'xpos',[],'ypos',[],'RowSingle',[],'ColSingle',[],'cellId',[],...
    'yearFile',[],'monthFile',[],'dayFile',[],'minFile',[],'ImNumSingle',[])
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)]
    Seg.(chnm).IntperA = [];
    Seg.(chnm).Intensity = [];
    Seg.(chnm).Area = [];
    Seg.(chnm).Perimeter = []; 
    Seg.(chnm).AtoP = [];
    Seg.(chnm).Background = [];
end
for i = 1:size(seg_file,1)
    load([handles.expDir filesep 'Segmented/' seg_file(i).name])
    if CO.cellCount ~=0
        Seg.year = [Seg.year;repmat(CO.tim.year,CO.cellCount,1)];
        Seg.month = [Seg.month;repmat(CO.tim.month,CO.cellCount,1)];
        Seg.day = [Seg.day;repmat(CO.tim.day,CO.cellCount,1)];
        Seg.min=[Seg.min;repmat(CO.tim.min,CO.cellCount,1)];
        Seg.yearFile = [Seg.yearFile;CO.tim.year];
        Seg.dayFile = [Seg.dayFile;CO.tim.day];
        Seg.monthFile = [Seg.monthFile;CO.tim.month];
        Seg.minFile = [Seg.minFile;CO.tim.min];
        Seg.RowSingle = [Seg.RowSingle;seg_file(i).name(1:3)];
        Seg.ColSingle = [Seg.ColSingle;seg_file(i).name(5:7)];
        idx = strfind(seg_file(i).name,'_');
        Seg.ImNumSingle = [Seg.ImNumSingle;str2num(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1))];
        Seg.ImNum = [Seg.ImNum; str2num(repmat(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1),CO.cellCount,1))];
        Seg.RW = [Seg.RW;repmat(seg_file(i).name(1:3),CO.cellCount,1)];
        Seg.CL = [Seg.CL;repmat(seg_file(i).name(5:7),CO.cellCount,1)];
        Seg.NucArea = [Seg.NucArea, CO.Nuc.Area];
        Seg.NucInt = [Seg.NucInt, CO.Nuc.Intensity];
        Seg.Nuc_IntperA = [Seg.Nuc_IntperA, CO.Nuc.Intensity./CO.Nuc.Area];
        Seg.numCytowoutNuc = [Seg.numCytowoutNuc, CO.numCytowoutNuc];
        Seg.cellcount = [Seg.cellcount, CO.cellCount];
        Seg.NucBackground = [Seg.NucBackground, CO.Nuc.Background];
        Seg.class.debris = [Seg.class.debris, CO.class.debris];
        Seg.class.nucleus = [Seg.class.nucleus, CO.class.nucleus];
        Seg.class.over = [Seg.class.over, CO.class.over];
        Seg.class.under = [Seg.class.under, CO.class.under];
        Seg.class.predivision = [Seg.class.predivision, CO.class.predivision];
        Seg.class.postdivision = [Seg.class.postdivision, CO.class.postdivision];
        Seg.class.apoptotic = [Seg.class.apoptotic, CO.class.apoptotic];
        Seg.class.newborn = [Seg.class.newborn, CO.class.newborn];
        Seg.cellId = [Seg.cellId, CO.cellId];
        Seg.xpos = [Seg.xpos; CO.Centroid(:,1)];
        Seg.ypos = [Seg.ypos; CO.Centroid(:,2)];
        Seg.class.edge = [Seg.class.edge, CO.class.edge];
        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            Seg.(chnm).IntperA = [Seg.(chnm).IntperA, CO.(chnm).Intensity./CO.(chnm).Area];
            Seg.(chnm).Intensity = [Seg.(chnm).Intensity, CO.(chnm).Intensity];
            Seg.(chnm).Area = [Seg.(chnm).Area, CO.(chnm).Area];
            Seg.(chnm).Perimeter = [Seg.(chnm).Perimeter, CO.(chnm).Perimeter];
            Seg.(chnm).AtoP = [Seg.(chnm).AtoP, CO.(chnm).Area./CO.(chnm).Perimeter];
            Seg.(chnm).Background = [Seg.(chnm).Background, CO.(chnm).Background];
        end
    else
        Seg.year = [Seg.year;CO.tim.year];
        Seg.month = [Seg.month;CO.tim.month];
        Seg.day = [Seg.day;CO.tim.day];
        Seg.min=[Seg.min;CO.tim.min];
        Seg.yearFile = [Seg.yearFile;CO.tim.year];
        Seg.dayFile = [Seg.dayFile;CO.tim.day];
        Seg.monthFile = [Seg.monthFile;CO.tim.month];
        Seg.minFile = [Seg.minFile;CO.tim.min];
        Seg.RowSingle = [Seg.RowSingle;seg_file(i).name(1:3)];
        Seg.ColSingle = [Seg.ColSingle;seg_file(i).name(5:7)];
        idx = strfind(seg_file(i).name,'_');
        Seg.ImNumSingle = [Seg.ImNumSingle;str2num(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1))];
        Seg.ImNum = [Seg.ImNum; str2num(repmat(seg_file(i).name(idx(2)+1:strfind(seg_file(i).name,'.')-1),1,1))];
        Seg.RW = [Seg.RW;seg_file(i).name(1:3)];
        Seg.CL = [Seg.CL;seg_file(i).name(5:7)];
        Seg.NucArea = [Seg.NucArea,0];
        Seg.NucInt = [Seg.NucInt, 0];
        Seg.Nuc_IntperA = [Seg.Nuc_IntperA, 0];
        Seg.numCytowoutNuc = [Seg.numCytowoutNuc, 0];
        Seg.cellcount = [Seg.cellcount, CO.cellCount];
        Seg.NucBackground = [Seg.NucBackground, 0];
        Seg.class.debris = [Seg.class.debris, 0];
        Seg.class.nucleus = [Seg.class.nucleus, 0];
        Seg.class.over = [Seg.class.over,0];
        Seg.class.under = [Seg.class.under, 0];
        Seg.class.predivision = [Seg.class.predivision, 0];
        Seg.class.postdivision = [Seg.class.postdivision, 0];
        Seg.class.apoptotic = [Seg.class.apoptotic, 0];
        Seg.class.newborn = [Seg.class.newborn,0];
        Seg.cellId = [Seg.cellId, 0];
        Seg.xpos = [Seg.xpos; 0];
        Seg.ypos = [Seg.ypos; 0];
        Seg.class.edge = [Seg.class.edge, 0];
        for q = 1:handles.numCh
            chnm = ['CH_' num2str(q)];
            Seg.(chnm).IntperA = [Seg.(chnm).IntperA,0];
            Seg.(chnm).Intensity = [Seg.(chnm).Intensity, 0];
            Seg.(chnm).Area = [Seg.(chnm).Area,0];
            Seg.(chnm).Perimeter = [Seg.(chnm).Perimeter, 0];
            Seg.(chnm).AtoP = [Seg.(chnm).AtoP,0];
            Seg.(chnm).Background = [Seg.(chnm).Background, 0];
        end
    end
end
Seg.Nuc_IntperA = Seg.Nuc_IntperA';
Seg.NucArea = Seg.NucArea';
Seg.NucInt = Seg.NucInt';
Seg.numCytowoutNuc = Seg.numCytowoutNuc';
Seg.cellcount = Seg.cellcount';
Seg.NucBackground = Seg.NucBackground';
Seg.cellId = Seg.cellId';
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    Seg.(chnm).IntperA = Seg.(chnm).IntperA';
    Seg.(chnm).Intensity = Seg.(chnm).Intensity';
    Seg.(chnm).Area = Seg.(chnm).Area';
    Seg.(chnm).Perimeter = Seg.(chnm).Perimeter';
    Seg.(chnm).AtoP = Seg.(chnm).AtoP';
    Seg.(chnm).Background = Seg.(chnm).Background';
end
Seg.class.debris = Seg.class.debris';
Seg.class.nucleus = Seg.class.nucleus';
Seg.class.over = Seg.class.over';
Seg.class.under = Seg.class.under';
Seg.class.predivision = Seg.class.predivision';
Seg.class.postdivision = Seg.class.postdivision';
Seg.class.newborn = Seg.class.newborn';
Seg.class.apoptotic = Seg.class.apoptotic';
Seg.class.edge = Seg.class.edge';


save([handles.expDir filesep 'Compiled Segmentation Results.mat'],'Seg')
Condition = {'Year','Month','Day','Min','Row','Col','ImNumber','cellId','Xposition','Yposition','Nuc_IntperA','NucArea','NucInt'};
tempMat = [];
tempMat = array2table([Seg.year,Seg.month,Seg.day,Seg.min],'VariableNames',{Condition{1:4}}); 
tempMat = [tempMat, cell2table([cellstr(Seg.RW),cellstr(Seg.CL)],'VariableNames',{Condition{5:6}})];
tempMat = [tempMat, array2table([Seg.ImNum,Seg.cellId,Seg.xpos,Seg.ypos,Seg.Nuc_IntperA,Seg.NucArea,Seg.NucInt],'VariableNames',{Condition{7:13}})];
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    Condition = {Condition{:}, [chnm '_IntperA'],[chnm '_Intensity'],[chnm '_Area'],[chnm '_Perimeter'],[chnm '_AtoP']};
    tempMat = [tempMat, array2table([Seg.(chnm).IntperA,Seg.(chnm).Intensity,Seg.(chnm).Area,Seg.(chnm).Perimeter,Seg.(chnm).AtoP],'VariableNames',{Condition{(q-1)*5+14:q*5+13}})];
end
Condition = {Condition{:},'Class_Nucleus','Class_Debris','Class_Over','Class_Under','Class_Predivision','Class_Postdivision','Class_Newborn','Class_Apoptotic','Class_Edge'};
tempMat = [tempMat, array2table([Seg.class.nucleus,Seg.class.debris,Seg.class.over,Seg.class.under,Seg.class.predivision,Seg.class.postdivision,Seg.class.newborn,Seg.class.apoptotic,Seg.class.edge],'VariableNames',{Condition{(handles.numCh)*5+14:end}})];
writetable(tempMat,[handles.expDir filesep 'Cell Events.csv'])

tempMat = [];
Condition = [];
Condition = {'ImageNumber','Year','Month','Day','Min','Row','Col','CellCount','NuclearCh_Background'};
tempMat = array2table([Seg.ImNumSingle,Seg.yearFile,Seg.monthFile,Seg.dayFile,Seg.minFile],'VariableNames',{Condition{1:5}}); 
tempMat = [tempMat, cell2table([cellstr(Seg.RowSingle),cellstr(Seg.ColSingle)],'VariableNames',{Condition{6:7}})];
tempMat = [tempMat, array2table([Seg.cellcount,Seg.NucBackground],'VariableNames',{Condition{8:9}})];
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)];
    Condition = {Condition{:}, [chnm '_Background']};
    tempMat = [tempMat, array2table([Seg.(chnm).Background],'VariableNames',{Condition{end}})];
end
tempMat = [tempMat, array2table(Seg.numCytowoutNuc,'VariableNames',{'NumCytoWoutNuc'})];
writetable(tempMat,[handles.expDir filesep 'Image Events.csv']);

tempMat = [];
ImageParameter = [];
ImageParameter = {'Number_Flourescent_Channels_ex_Nuc','Nuclear_Segmentation_Level','Cytoplasm_Segmentation_Level'...
    'Split_Nuclei','Noise_Filter_Cytoplasm','Noise_Filter_Nucleus','Segmentation_Smoothing_Factor','Cidre_correct_1_is_true',...
    'Correct_by_Background_Sub','Segment_by_Nuclear_Dilation','Nuclear_Dilation_Factor','Segment_Cell_Surface',...
    'Cell_Surface_Dilation_Factor','Clear_Border_Cells','BD_pathway_exp'};
T = array2table([handles.numCh,handles.NucnumLevel,handles.CytonumLevel,handles.NucSegHeight,handles.noise_disk,handles.nuc_noise_disk,...
handles.smoothing_factor,handles.cidrecorrect,handles.background_corr,handles.nuclear_segment,...
handles.nuclear_segment_factor,handles.surface_segment,handles.surface_segment_factor,...
handles.cl_border,handles.bd_pathway],'VariableNames',ImageParameter);
if handles.cidrecorrect
    T.Cidre_Directory = handles.cidreDir;
else
    T.Cidre_Directory = 0;
end
if handles.background_corr
    T.Background_CorrIm_file = handles.CorrIm_file;
else
    T.Background_CorrIm_file = 0;
end
writetable(T,[handles.expDir filesep 'Processing Parameters.csv']);

end