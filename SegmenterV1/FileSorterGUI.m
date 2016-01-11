function varargout = FileSorterGUI(varargin)
%Make sure to run the program by command line calling FileSorterGUI instead
%of double clicking the file!!!!!!
% FILESORTERGUI MATLAB code for FileSorterGUI.fig
%      FILESORTERGUI, by itself, creates a new FILESORTERGUI or raises the existing
%      singleton*.
%
%      H = FILESORTERGUI returns the handle to a new FILESORTERGUI or the handle to
%      the existing singleton*.
%
%      FILESORTERGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FILESORTERGUI.M with the given input arguments.
%
%      FILESORTERGUI('Property','Value',...) creates a new FILESORTERGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before FileSorterGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to FileSorterGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help FileSorterGUI

% Last Modified by GUIDE v2.5 28-Dec-2015 08:54:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @FileSorterGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @FileSorterGUI_OutputFcn, ...
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
%D = struct('numCh','2','BFchannel','0','imExt','*.tiff','NucCH','1','expDir','Desktop','mvWhole_Well','1');
% End initialization code - DO NOT EDIT

% --- Executes just before FileSorterGUI is made visible.
function FileSorterGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to FileSorterGUI (see VARARGIN)

% Choose default command line output for FileSorterGUI
handles.output = hObject;
%Set default values
%
% Update handles structure
handles.expDir = '/home/xnmeyer/Documents/Lab/TNBC_Project/Experiments/2015_Dec/12182015 hcc1143 vim dilution';
handles.numCh = 2;
handles.BFchannel = 0;
handles.imExt = '.tiff';
handles.NucCh = 1;
handles.mvWhole_Well = 0;
% handles.axes1 = findobj('Tag','axes1');

guidata(hObject, handles);

% UIWAIT makes FileSorterGUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = FileSorterGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%Get the directory
handles.expDir = uigetdir()
set(hObject,'String',handles.expDir)
% Update handles structure
guidata(hObject, handles);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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

h = msgbox('Please Be Patient, This box will close when operation is finished. See Command Window for estimate of time to completion')

% 
% numChannels = str2double(get(findobj('Tag','edit1'),'String'));
% imExt = get(findobj('Tag','edit2'),'String');
% NucCH = str2double(get(findobj('Tag','edit3'),'String'));
% BF = str2double(get(findobj('Tag','edit6'),'String'));
% mvWhole_Well = get(findobj('Tag','checkbox1'),'Value');  %Move the whole well images?  1 = yes
numChannels = handles.numCh;
imExt = handles.imExt;
NucCH = handles.NucCh;
BF = handles.BFchannel;
mvWhole_Well = handles.mvWhole_Well;
tempDir = pwd;
cd(handles.expDir)


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

cd(tempDir)
close(h)
guidata(hObject, handles)


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
handles.numCh = str2double(get(hObject,'String'));

% Update D structure
guidata(hObject, handles);



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
handles.imExt = get(hObject,'String');
% Update handles structure
guidata(hObject, handles);

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



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double
handles.NucCh = str2double(get(hObject,'String'));
% Update handles structure
guidata(hObject, handles);


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


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1
handles.mvWhole_Well = get(hObject,'Value')
guidata(hObject,handles)



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double
handles.BFchannel = str2double(get(hObject,'String'))

% Update handles structure
guidata(hObject, handles);


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


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 
% numChannels = str2double(get(findobj('Tag','edit1'),'String'));
% handles.imExt = get(findobj('Tag','edit2'),'String')
% NucCH = str2double(get(findobj('Tag','edit3'),'String'));
% BF = str2double(get(findobj('Tag','edit6'),'String'));
% mvWhole_Well = get(findobj('Tag','checkbox1'),'Value');  %Move the whole well images?  1 = yes
numChannels = handles.numCh;
imExt = handles.imExt;
NucCH = handles.NucCh;
BF = handles.BFchannel;
mvWhole_Well = handles.mvWhole_Well

NucCH
 if BF ~=0
     numCh = numChannels - 2;
 else
     numCh = numChannels - 1;
 end
 tempDir = pwd;
 cd(handles.expDir)
 
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

 
 %Store the number of experiments in this directory
 numExp = size(ExpImDir,2);
 %Declare a cell array for holding the file names and what channel it
 %corresponds to.
 file_names = cell(1,2);
 k = 1;
 
 %Create a cell list of all the files locations
 for i = 1:numExp
     temp = dir([ExpImDir{i} '/*' handles.imExt]);
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
 
 
% %Now move the files into the correct directories leaving the whole well
% %images in the experimental directory.
 temp = strfind({file_names{:,2}},'Nuc');
 idx = find(cellfun(@isempty,temp)==0);
 im = imread(file_names{idx(1),1});
 handles.axes1
 idx
 imshow(im,[],'Parent',handles.axes1);

cd(tempDir)

guidata(hObject, handles)
