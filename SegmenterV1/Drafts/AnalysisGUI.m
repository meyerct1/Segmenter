function varargout = AnalysisGUI(varargin)
% ANALYSISGUI MATLAB code for AnalysisGUI.fig
%      ANALYSISGUI, by itself, creates a new ANALYSISGUI or raises the existing
%      singleton*.
%
%      H = ANALYSISGUI returns the handle to a new ANALYSISGUI or the handle to
%      the existing singleton*.
%
%      ANALYSISGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ANALYSISGUI.M with the given input arguments.
%
%      ANALYSISGUI('Property','Value',...) creates a new ANALYSISGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before AnalysisGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to AnalysisGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help AnalysisGUI

% Last Modified by GUIDE v2.5 16-Dec-2015 17:03:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @AnalysisGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @AnalysisGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before AnalysisGUI is made visible.
function AnalysisGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to AnalysisGUI (see VARARGIN)

% Choose default command line output for AnalysisGUI
handles.output = hObject;
%Analyse all segmented wells (excluding well r5 as it was deleted due to a
%clump of cells)
%Add all the wells together segmentation together.

if (nargin>3)
    handles.numCh = varargin(1);
    if length(varargin)>1
        handles.expDir = varargin(2);
    else
        handles.expDir = pwd;
    end
else
    msgbox('Please restart AnalysisGUI specifying the number of non-nuclear fluorescent channels')
    return
end

seg_file = dir([handles.expDir filesep 'Segmented/*.mat'])
%Declare structure for holding data
Seg = struct('Nuc_IntperA',[],'NucArea',[],'NucInt',[],'numCytowoutNuc',[],'cellcount',[],'RW',cell(1),'CL',cell(1),'ImNum',[],'min',cell(1),'day',cell(1),'month',cell(1),'year',cell(1))
for q = 1:handles.numCh
    chnm = ['CH_' num2str(q)]
    Seg.(chnm).IntperA = [];
    Seg.(chnm).Intensity = [];
    Seg.(chnm).Area = [];
    Seg.(chnm).Perimeter = []; 
    Seg.(chnm).AtoP = [];
end
for i = 1:size(seg_file,1)
    load([handles.expDir filesep 'Segmented/' seg_file(i).name])
    Seg.year = [Seg.year;repmat(CO.year,CO.cellCount,1)];
    Seg.month = [Seg.month;repmat(CO.month,CO.cellCount,1)];
    Seg.day = [Seg.day;repmat(CO.day,CO.cellCount,1)];
    Seg.min=[Seg.min;repmat(CO.min,CO.cellCount,1)];
    Seg.RW = [Seg.RW;repmat(seg_file(i).name(1:3),CO.cellCount,1)];
    Seg.CL = [Seg.CL;repmat(seg_file(i).name(5:7),CO.cellCount,1)];
    Seg.ImNum = [Seg.ImNum; str2num(repmat(seg_file(i).name(9:strfind(seg_file(i).name,'.')-1),CO.cellCount,1))];
    Seg.NucArea = [Seg.NucArea, CO.Nuc.Area];
    Seg.NucInt = [Seg.NucInt, CO.Nuc.Intensity];
    Seg.Nuc_IntperA = [Seg.Nuc_IntperA, CO.Nuc.Intensity./CO.Nuc.Area];
    Seg.numCytowoutNuc = [Seg.numCytowoutNuc, CO.numCytowoutNuc];
    Seg.cellcount = [Seg.cellcount, CO.numCytowoutNuc];
    for q = 1:handles.numCh
        chnm = ['CH_' num2str(q)];
        Seg.(chnm).IntperA = [Seg.(chnm).IntperA, CO.(chnm).Intensity./CO.(chnm).Area];
        Seg.(chnm).Intensity = [Seg.(chnm).Intensity, CO.(chnm).Intensity];
        Seg.(chnm).Area = [Seg.(chnm).Area, CO.(chnm).Area];
        Seg.(chnm).Perimeter = [Seg.(chnm).Perimeter, CO.(chnm).Perimeter];
        Seg.(chnm).AtoP = [Seg.(chnm).AtoP, CO.(chnm).Area./CO.(chnm).Perimeter];
    end
end

handles.Seg = Seg;
handles.axes1;
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes AnalysisGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = AnalysisGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
handles.graph_options = cellstr(get(hObject,'String'))
handles.graph_selected = get(hObject,'Value')
guidata(hObject,handles)


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

numCh = handles.numCh;
handles.graph_selection
switch handles.graph_selection
    case 'Density Plot'
        switch handles.single
            case
    case 'Scatter Plot'
    case 'Time Course'
    case 'Multi Column'
    case 'Multi Row'
end

handles.xaxis
handles.yaxis
handles.singleTime
handles.singleTimePt
handles.Row
handles.col



if handles.
Seg = handles.Seg


for j = 1:7
    col = sprintf('C0%i',j+2)
    fontsz = 16;
    idx = [];temp = [];
    row = 'R02';%col = 'C04';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03

    str = sprintf('%s-%s',row,col);
    %look at epcam stain
    q = 1;
    chnm = ['CH_' num2str(q)];

    %subplot(2,2,1)
    hold on
    [x,y] = ksdensity(Seg.(chnm).IntperA(idx));
    plot(y,x,'linewidth',4);
    title(str,'fontsize',fontsz)
    xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
    ylabel('Frequency','fontsize',fontsz)
end

legend('Control','1:50','1:100','1:200','1:400','1:800','old Ab 1:100')
figure()
fontsz = 16;
idx = [];temp = [];
row = 'R02';col = 'C03';
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
str = sprintf('%s-%s',row,col);
%look at epcam stain
q = 1;
chnm = ['CH_' num2str(q)];
subplot(2,2,1)
hold on
[x,y] = ksdensity(Seg.(chnm).IntperA(idx));
plot(y,x,'linewidth',4);
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)

subplot(2,2,2)
hold on
[x,y] = ksdensity(Seg.(chnm).Intensity(idx));
plot(y,x,'linewidth',4);fontsz = 20;
%Look at all conditions together
figure(1)
for j = 1:7
    col = sprintf('C0%i',j+2)
    idx = [];temp = [];
    row = 'R02';%col = 'C04';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03

    str = sprintf('%s-%s',row,col);
    %look at epcam stain
    q = 1;
    chnm = ['CH_' num2str(q)];

    %subplot(2,2,1)
    hold on
    [x,y] = ksdensity(Seg.(chnm).IntperA(idx));
    plot(y,x,'linewidth',4);
    title(str,'fontsize',fontsz)
    xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
    ylabel('Frequency','fontsize',fontsz)
end
conditions = {'Control','1:50','1:100','1:200','1:400','1:800','old Ab 1:100'}
legend({conditions})
set(gca,'fontsize',fontsz)

%Look at any one condition specifically with control
figure()
idx = [];temp = [];
row = 'R02';col = 'C06';
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
str = sprintf('%s-%s',row,col);
%look at epcam stain
q = 1;
chnm = ['CH_' num2str(q)];
hold on
[x,y] = ksdensity(Seg.(chnm).IntperA(idx));
plot(y,x,'linewidth',4);
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)

row = 'R02';col = 'C03';
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
[x,y] = ksdensity(Seg.(chnm).IntperA(idx));
plot(y,x,'linewidth',4);
legend(conditions(col(3)-1),'Control')
set(gca,'fontsize',fontsz)


%Look at the scatter plot
figure()
row = 'R02';col = 'C03';
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
str = sprintf('%s-%s',row,col);
hold on
plot(Seg.NucArea(idx),Seg.(chnm).Intensity(idx),'.')
title(str,'fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)
ylabel('Cytoplasm Intensity','fontsize',fontsz)

figure()
hold on
plot(Seg.NucArea(idx),Seg.(chnm).IntperA(idx),'.')
title(str,'fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)
ylabel('Cytoplasm Intensity per Unit Area','fontsize',fontsz)


%Build a mixed gaussian model for each condition
fontsz = 12;
conditions = {'1:50','1:100','1:200','1:400','1:800','old Ab 1:100'}
filnm = 'C':'H'
for k = 1:length(filnm)
    tempdata = []; idx = []
    hold on
    col = sprintf('C0%d',k+3)
    row = 'R02';%col = 'C03';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images in specified row and col
    tempdata(1,:) = Seg.(chnm).IntperA(idx)';
    tempdata(2,:) = Seg.NucArea(idx);
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    tempdata = tempdata(:,~to_remove);
    GMmodel = fitgmdist(tempdata(1,:)',2); %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    
    figure('Units','normalized','Position',[.1 .6 .35 .5])
    hold on
    plot(tempdata(2,cluster_idx == 1),tempdata(1,cluster_idx==1),'.','linewidth',5)
    plot(tempdata(2,cluster_idx == 2),tempdata(1,cluster_idx==2),'.','linewidth',5)
    str = sprintf('\\begin{tabular}{c|c|c} & Group 1 & Group 2\\\\ percent & %.2f & %.2f \\\\ $\\mu$ & %.2f & %.2f \\\\ $\\sigma$ & %.1f & %.1f \\end{tabular}',...
                  GMmodel.ComponentProportion(1)*100,GMmodel.ComponentProportion(2)*100,GMmodel.mu(1),GMmodel.mu(2), std(tempdata(1,cluster_idx==1)), std(tempdata(1,cluster_idx==2)))
    ylim=get(gca,'ylim');xlim=get(gca,'xlim');
    h = annotation('textbox','Interpreter','LaTex')
    set(h,'String',str,'fontsize',fontsz)
    set(h,'Position',[.6-h.Position(3),.9-h.Position(4),h.Position(3),h.Position(4)])
    str = sprintf('20X Imaging,%s-%s,%s',row,col,conditions{k});
    title(str);xlabel('Nuclear Area'); ylabel('EpCAM intensity/area');
    set(gca,'fontsize',fontsz)
    
    figure('Units','normalized','Position',[.1 .1 .7 .5])
    subplot(1,2,1)
    hold on
    [x,y] = ksdensity(Seg.(chnm).IntperA(idx));
    plot(y,x,'linewidth',4);
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    plot(x_ran,pdf(GMmodel,x_ran),'linewidth',4)
    str = sprintf('20X Imaging,%s-%s,%s',row,col,conditions{k});
    title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
    legend('Orig Data','GM model')
    set(gca,'fontsize',fontsz)
    subplot(1,2,2)
    hold on
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    OVL = trapz(x_ran, min([dist1,dist2],[],2));
    %CohenD = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
    plot(x_ran,dist1,'linewidth',4)
    plot(x_ran,dist2,'linewidth',4)
    str = sprintf('Percent Overlap: %.2f%%',OVL*100);
    title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
    legend('Pop 1','Pop 2')
    set(gca,'fontsize',fontsz)
    
    
    figure('Units','normalized','Position',[.1 .6 .35 .5])
    hold on
    tempdata = [];
    FD.(filnm(k)) = readtable(strcat(filnm(k),'.csv'))
    tempdata(1,:) = FD.(filnm(k)).AlexaFluor488_A';
    tempdata(2,:) = FD.(filnm(k)).FSC_H';
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    tempdata = tempdata(:,~to_remove);
    GMmodel = fitgmdist(tempdata(1,:)',2) %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    plot(tempdata(2,cluster_idx == 1),tempdata(1,cluster_idx==1),'.','linewidth',5)
    plot(tempdata(2,cluster_idx == 2),tempdata(1,cluster_idx==2),'.','linewidth',5)
    str = sprintf('\\begin{tabular}{c|c|c} & Group 1 & Group 2\\\\ percent & %.2f & %.2f \\\\ $\\mu$ & %.2f & %.2f \\\\ $\\sigma$ & %.1f & %.1f \\end{tabular}',...
                  GMmodel.ComponentProportion(1)*100,GMmodel.ComponentProportion(2)*100,GMmodel.mu(1),GMmodel.mu(2),std(tempdata(1,cluster_idx==1)), std(tempdata(1,cluster_idx==2)))
    ylim=get(gca,'ylim');xlim=get(gca,'xlim');
    h = annotation('textbox','Interpreter','LaTex')
    set(h,'String',str,'fontsize',fontsz)
    set(h,'Position',[.6-h.Position(3),.9-h.Position(4),h.Position(3),h.Position(4)])
    str = sprintf('FlowCytometry,%s',conditions{k});
    title(str);xlabel('FSC_H'); ylabel('AlexaFluor488_A');
    set(gca,'fontsize',fontsz)
    
    figure('Units','normalized','Position',[.1 .1 .7 .5])
    subplot(1,2,1)
    hold on
    [x,y] = ksdensity(tempdata(1,:));
    plot(y,x,'linewidth',4);
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    plot(x_ran,pdf(GMmodel,x_ran),'linewidth',4)
    str = sprintf('FlowCytometry,%s',conditions{k});
    title(str);ylabel('Frequency'); xlabel('AlexaFluor488_A');
    legend('Orig Data','GM model','Pop 1','Pop 2')
    set(gca,'fontsize',fontsz)
    
    subplot(1,2,2)
    hold on
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    OVL = trapz(x_ran, min([dist1,dist2],[],2));
    %CohenD = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
    plot(x_ran,dist1,'linewidth',4)
    plot(x_ran,dist2,'linewidth',4)
    str = sprintf('Percent Overlap: %.2f%%',OVL*100);
    title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
    legend('Pop 1','Pop 2')
    set(gca,'fontsize',fontsz)
    
end
    


%Build a mixed gaussian model for each condition
fontsz = 12;
conditions = {'1:50','1:100','1:200','1:400','1:800','old Ab 1:100'}
filnm = 'C':'H'
for k = 1:length(filnm)
    tempdata = []; idx = []
    hold on
    col = sprintf('C0%d',k+3)
    row = 'R02';%col = 'C03';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images in specified row and col
    tempdata(1,:) = Seg.(chnm).IntperA(idx)';
    tempdata(2,:) = Seg.NucArea(idx);
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    tempdata = tempdata(:,~to_remove);
    GMmodel = fitgmdist(tempdata(1,:)',2); %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    [Im.Mean1(k), id(1)] = max(GMmodel.mu);
    [Im.Mean2(k), id(2)] = min(GMmodel.mu);
    Im.std1(k) = std(tempdata(1,cluster_idx==id(1)));
    Im.std2(k) = std(tempdata(1,cluster_idx==id(2)));
    Im.Pop1(k) = GMmodel.ComponentProportion(1);
    Im.Pop2(k) = GMmodel.ComponentProportion(2);
    Im.OVL(k) = trapz(x_ran,min([dist1,dist2],[],2));
    Im.CohenD(k) = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
    
    tempdata = [];
    %FD.(filnm(k)) = readtable(strcat(filnm(k),'.csv'))
    tempdata(1,:) = FD.(filnm(k)).AlexaFluor488_A';
    tempdata(2,:) = FD.(filnm(k)).FSC_H';
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    tempdata = tempdata(:,~to_remove);
    GMmodel = fitgmdist(tempdata(1,:)',2) %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    [Fc.Mean1(k), id(1)] = max(GMmodel.mu);
    [Fc.Mean2(k), id(2)] = min(GMmodel.mu);
    Fc.std1(k) = std(tempdata(1,cluster_idx==id(1)));
    Fc.std2(k) = std(tempdata(1,cluster_idx==id(2)));
   	Fc.Pop1(k) = GMmodel.ComponentProportion(1);
    Fc.Pop2(k) = GMmodel.ComponentProportion(2);
    Fc.OVL(k) = trapz(x_ran, min([dist1,dist2],[],2));
    Fc.CohenD(k) = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));

end



conditions = {'1:50','1:100','1:200','1:400','1:800','old Ab 1:100'}

figure()
hold on
subplot(1,2,1)
bar(1:length(conditions),[Fc.Pop1.*100;Fc.Pop2.*100]',.45,'stacked')
axis([0,length(conditions)+1,0,120]);
legend('Flow, EpCAM low','Flow, EpCAM hi')
ylabel('Percent'); title('Flow Population Distribution')
set(gca,'XTickLabel',conditions,'fontsize',fontsz)
subplot(1,2,2)
bar(1:length(conditions),[Im.Pop1.*100;Im.Pop2.*100]',.45,'stacked')
axis([0,length(conditions)+1,0,120]);
legend('Imaging, EpCAM low','Imaging, EpCAM hi')
ylabel('Percent'); title('Imaging Population Distribution')
set(gca,'XTickLabel',conditions,'fontsize',fontsz)

figure()
hold on
plot(1:length(conditions),Fc.OVL*100,'linewidth',4)
plot(1:length(conditions),Im.OVL*100,'linewidth',4)
legend('Flow','Imaging')
ylabel('Percent Overlapping')
title('Percentage Overlap by Ab conc.')
set(gca,'XTickLabel',conditions,'fontsize',fontsz)


figure()
subplot(1,2,1)
hold on
errorbar(1:length(conditions),Im.Mean1,Im.std1,'linewidth',4)
errorbar(1:length(conditions),Im.Mean2,Im.std2,'linewidth',4)
legend('EpCAM hi','EpCAM lo')
ylabel('Mean group')
title('Mean intensity by Ab conc. Imaging')
set(gca,'XTick', [1:length(conditions)], 'XTickLabel',conditions,'fontsize',fontsz)
subplot(1,2,2)
hold on
errorbar(1:length(conditions),Fc.Mean1,Fc.std1,'linewidth',4)
errorbar(1:length(conditions),Fc.Mean2,Fc.std2,'linewidth',4)
legend('EpCAM hi','EpCAM lo')
ylabel('Mean group')
title('Mean intensity by Ab conc. Flow')
set(gca,'XTick', [1:length(conditions)], 'XTickLabel',conditions,'fontsize',fontsz)













title(str,'fontsize',fontsz)
xlabel('Intensity EpCAM','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)

subplot(2,2,3)
hold on
plot(Seg.NucArea(idx),Seg.(chnm).Intensity(idx),'.')
title(str,'fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)
ylabel('Cytoplasm Intensity','fontsize',fontsz)

subplot(2,2,4)
hold on
plot(Seg.NucArea(idx),Seg.NucInt(idx),'.')
title(str,'fontsize',fontsz)
ylabel('Nuclear Intensity','fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)

figure()
hold on
plot(Seg.NucArea(idx),Seg.(chnm).IntperA(idx),'.')
title(str,'fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)
ylabel('Cytoplasm Intensity per Unit Area','fontsize',fontsz)
hold on


figure()
plot(Seg.(chnm).Intensity(idx),Seg.(chnm).Area(idx),'.')
str= sprintf('HCC1143 Hoechst + EpCAM old Ab\n');
title(str,'fontsize',fontsz)
xlabel('Area','fontsize',fontsz)
ylabel('Intensity','fontsize',fontsz)

figure()
plot(Seg.(chnm).Perimeter(idx),Seg.(chnm).Area(idx),'.')
str= sprintf('HCC1143 Hoechst + EpCAM old Ab\n');
title(str,'fontsize',fontsz)
xlabel('Area','fontsize',fontsz)
ylabel('Perimeter','fontsize',fontsz)

fontsz = 20;
%Look at all conditions together
figure(1)
for j = 1:7
    col = sprintf('C0%i',j+2)
    idx = [];temp = [];
    row = 'R02';%col = 'C04';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03

    str = sprintf('%s-%s',row,col);
    %look at epcam stain
    q = 1;
    chnm = ['CH_' num2str(q)];

    %subplot(2,2,1)
    hold on
    [x,y] = ksdensity(Seg.(chnm).IntperA(idx));
    plot(y,x,'linewidth',4);
    title(str,'fontsize',fontsz)
    xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
    ylabel('Frequency','fontsize',fontsz)
end
conditions = {'Control','1:50','1:100','1:200','1:400','1:800','old Ab 1:100'}
legend({conditions})
set(gca,'fontsize',fontsz)

%Look at any one condition specifically with control
figure()
idx = [];temp = [];
row = 'R02';col = 'C06';
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
str = sprintf('%s-%s',row,col);
%look at epcam stain
q = 1;
chnm = ['CH_' num2str(q)];
hold on
[x,y] = ksdensity(Seg.(chnm).IntperA(idx));
plot(y,x,'linewidth',4);
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)

row = 'R02';col = 'C03';
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
[x,y] = ksdensity(Seg.(chnm).IntperA(idx));
plot(y,x,'linewidth',4);
legend(conditions(col(3)-1),'Control')
set(gca,'fontsize',fontsz)


%Look at the scatter plot
figure()
row = 'R02';col = 'C03';
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
str = sprintf('%s-%s',row,col);
hold on
plot(Seg.NucArea(idx),Seg.(chnm).Intensity(idx),'.')
title(str,'fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)
ylabel('Cytoplasm Intensity','fontsize',fontsz)

figure()
hold on
plot(Seg.NucArea(idx),Seg.(chnm).IntperA(idx),'.')
title(str,'fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)
ylabel('Cytoplasm Intensity per Unit Area','fontsize',fontsz)


%Build a mixed gaussian model for each condition
fontsz = 12;
conditions = {'1:50','1:100','1:200','1:400','1:800','old Ab 1:100'}
filnm = 'C':'H'
for k = 1:length(filnm)
    tempdata = []; idx = []
    hold on
    col = sprintf('C0%d',k+3)
    row = 'R02';%col = 'C03';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images in specified row and col
    tempdata(1,:) = Seg.(chnm).IntperA(idx)';
    tempdata(2,:) = Seg.NucArea(idx);
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    tempdata = tempdata(:,~to_remove);
    GMmodel = fitgmdist(tempdata(1,:)',2); %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    
    figure('Units','normalized','Position',[.1 .6 .35 .5])
    hold on
    plot(tempdata(2,cluster_idx == 1),tempdata(1,cluster_idx==1),'.','linewidth',5)
    plot(tempdata(2,cluster_idx == 2),tempdata(1,cluster_idx==2),'.','linewidth',5)
    str = sprintf('\\begin{tabular}{c|c|c} & Group 1 & Group 2\\\\ percent & %.2f & %.2f \\\\ $\\mu$ & %.2f & %.2f \\\\ $\\sigma$ & %.1f & %.1f \\end{tabular}',...
                  GMmodel.ComponentProportion(1)*100,GMmodel.ComponentProportion(2)*100,GMmodel.mu(1),GMmodel.mu(2), std(tempdata(1,cluster_idx==1)), std(tempdata(1,cluster_idx==2)))
    ylim=get(gca,'ylim');xlim=get(gca,'xlim');
    h = annotation('textbox','Interpreter','LaTex')
    set(h,'String',str,'fontsize',fontsz)
    set(h,'Position',[.6-h.Position(3),.9-h.Position(4),h.Position(3),h.Position(4)])
    str = sprintf('20X Imaging,%s-%s,%s',row,col,conditions{k});
    title(str);xlabel('Nuclear Area'); ylabel('EpCAM intensity/area');
    set(gca,'fontsize',fontsz)
    
    figure('Units','normalized','Position',[.1 .1 .7 .5])
    subplot(1,2,1)
    hold on
    [x,y] = ksdensity(Seg.(chnm).IntperA(idx));
    plot(y,x,'linewidth',4);
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    plot(x_ran,pdf(GMmodel,x_ran),'linewidth',4)
    str = sprintf('20X Imaging,%s-%s,%s',row,col,conditions{k});
    title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
    legend('Orig Data','GM model')
    set(gca,'fontsize',fontsz)
    subplot(1,2,2)
    hold on
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    OVL = trapz(x_ran, min([dist1,dist2],[],2));
    %CohenD = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
    plot(x_ran,dist1,'linewidth',4)
    plot(x_ran,dist2,'linewidth',4)
    str = sprintf('Percent Overlap: %.2f%%',OVL*100);
    title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
    legend('Pop 1','Pop 2')
    set(gca,'fontsize',fontsz)
    
    
    figure('Units','normalized','Position',[.1 .6 .35 .5])
    hold on
    tempdata = [];
    FD.(filnm(k)) = readtable(strcat(filnm(k),'.csv'))
    tempdata(1,:) = FD.(filnm(k)).AlexaFluor488_A';
    tempdata(2,:) = FD.(filnm(k)).FSC_H';
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    tempdata = tempdata(:,~to_remove);
    GMmodel = fitgmdist(tempdata(1,:)',2) %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    plot(tempdata(2,cluster_idx == 1),tempdata(1,cluster_idx==1),'.','linewidth',5)
    plot(tempdata(2,cluster_idx == 2),tempdata(1,cluster_idx==2),'.','linewidth',5)
    str = sprintf('\\begin{tabular}{c|c|c} & Group 1 & Group 2\\\\ percent & %.2f & %.2f \\\\ $\\mu$ & %.2f & %.2f \\\\ $\\sigma$ & %.1f & %.1f \\end{tabular}',...
                  GMmodel.ComponentProportion(1)*100,GMmodel.ComponentProportion(2)*100,GMmodel.mu(1),GMmodel.mu(2),std(tempdata(1,cluster_idx==1)), std(tempdata(1,cluster_idx==2)))
    ylim=get(gca,'ylim');xlim=get(gca,'xlim');
    h = annotation('textbox','Interpreter','LaTex')
    set(h,'String',str,'fontsize',fontsz)
    set(h,'Position',[.6-h.Position(3),.9-h.Position(4),h.Position(3),h.Position(4)])
    str = sprintf('FlowCytometry,%s',conditions{k});
    title(str);xlabel('FSC_H'); ylabel('AlexaFluor488_A');
    set(gca,'fontsize',fontsz)
    
    figure('Units','normalized','Position',[.1 .1 .7 .5])
    subplot(1,2,1)
    hold on
    [x,y] = ksdensity(tempdata(1,:));
    plot(y,x,'linewidth',4);
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    plot(x_ran,pdf(GMmodel,x_ran),'linewidth',4)
    str = sprintf('FlowCytometry,%s',conditions{k});
    title(str);ylabel('Frequency'); xlabel('AlexaFluor488_A');
    legend('Orig Data','GM model','Pop 1','Pop 2')
    set(gca,'fontsize',fontsz)
    
    subplot(1,2,2)
    hold on
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    OVL = trapz(x_ran, min([dist1,dist2],[],2));
    %CohenD = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
    plot(x_ran,dist1,'linewidth',4)
    plot(x_ran,dist2,'linewidth',4)
    str = sprintf('Percent Overlap: %.2f%%',OVL*100);
    title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
    legend('Pop 1','Pop 2')
    set(gca,'fontsize',fontsz)
    
end
    


%Build a mixed gaussian model for each condition
fontsz = 12;
conditions = {'1:50','1:100','1:200','1:400','1:800','old Ab 1:100'}
filnm = 'C':'H'
for k = 1:length(filnm)
    tempdata = []; idx = []
    hold on
    col = sprintf('C0%d',k+3)
    row = 'R02';%col = 'C03';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images in specified row and col
    tempdata(1,:) = Seg.(chnm).IntperA(idx)';
    tempdata(2,:) = Seg.NucArea(idx);
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    tempdata = tempdata(:,~to_remove);
    GMmodel = fitgmdist(tempdata(1,:)',2); %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    [Im.Mean1(k), id(1)] = max(GMmodel.mu);
    [Im.Mean2(k), id(2)] = min(GMmodel.mu);
    Im.std1(k) = std(tempdata(1,cluster_idx==id(1)));
    Im.std2(k) = std(tempdata(1,cluster_idx==id(2)));
    Im.Pop1(k) = GMmodel.ComponentProportion(1);
    Im.Pop2(k) = GMmodel.ComponentProportion(2);
    Im.OVL(k) = trapz(x_ran,min([dist1,dist2],[],2));
    Im.CohenD(k) = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
    
    tempdata = [];
    %FD.(filnm(k)) = readtable(strcat(filnm(k),'.csv'))
    tempdata(1,:) = FD.(filnm(k)).AlexaFluor488_A';
    tempdata(2,:) = FD.(filnm(k)).FSC_H';
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    tempdata = tempdata(:,~to_remove);
    GMmodel = fitgmdist(tempdata(1,:)',2) %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    [Fc.Mean1(k), id(1)] = max(GMmodel.mu);
    [Fc.Mean2(k), id(2)] = min(GMmodel.mu);
    Fc.std1(k) = std(tempdata(1,cluster_idx==id(1)));
    Fc.std2(k) = std(tempdata(1,cluster_idx==id(2)));
   	Fc.Pop1(k) = GMmodel.ComponentProportion(1);
    Fc.Pop2(k) = GMmodel.ComponentProportion(2);
    Fc.OVL(k) = trapz(x_ran, min([dist1,dist2],[],2));
    Fc.CohenD(k) = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));

end



conditions = {'1:50','1:100','1:200','1:400','1:800','old Ab 1:100'}

figure()
hold on
subplot(1,2,1)
bar(1:length(conditions),[Fc.Pop1.*100;Fc.Pop2.*100]',.45,'stacked')
axis([0,length(conditions)+1,0,120]);
legend('Flow, EpCAM low','Flow, EpCAM hi')
ylabel('Percent'); title('Flow Population Distribution')
set(gca,'XTickLabel',conditions,'fontsize',fontsz)
subplot(1,2,2)
bar(1:length(conditions),[Im.Pop1.*100;Im.Pop2.*100]',.45,'stacked')
axis([0,length(conditions)+1,0,120]);
legend('Imaging, EpCAM low','Imaging, EpCAM hi')
ylabel('Percent'); title('Imaging Population Distribution')
set(gca,'XTickLabel',conditions,'fontsize',fontsz)

figure()
hold on
plot(1:length(conditions),Fc.OVL*100,'linewidth',4)
plot(1:length(conditions),Im.OVL*100,'linewidth',4)
legend('Flow','Imaging')
ylabel('Percent Overlapping')
title('Percentage Overlap by Ab conc.')
set(gca,'XTickLabel',conditions,'fontsize',fontsz)


figure()
subplot(1,2,1)
hold on
errorbar(1:length(conditions),Im.Mean1,Im.std1,'linewidth',4)
errorbar(1:length(conditions),Im.Mean2,Im.std2,'linewidth',4)
legend('EpCAM hi','EpCAM lo')
ylabel('Mean group')
title('Mean intensity by Ab conc. Imaging')
set(gca,'XTick', [1:length(conditions)], 'XTickLabel',conditions,'fontsize',fontsz)
subplot(1,2,2)
hold on
errorbar(1:length(conditions),Fc.Mean1,Fc.std1,'linewidth',4)
errorbar(1:length(conditions),Fc.Mean2,Fc.std2,'linewidth',4)
legend('EpCAM hi','EpCAM lo')
ylabel('Mean group')
title('Mean intensity by Ab conc. Flow')
set(gca,'XTick', [1:length(conditions)], 'XTickLabel',conditions,'fontsize',fontsz)



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2


% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu4.
function popupmenu4_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4


% --- Executes during object creation, after setting all properties.
function popupmenu4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4
