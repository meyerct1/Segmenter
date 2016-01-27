function varargout = SegmenterV1(varargin)
% SEGMENTERV1 MATLAB code for SegmenterV1.fig
%      SEGMENTERV1, by itself, creates a new SEGMENTERV1 or raises the existing
%      singleton*.
%
%      H = SEGMENTERV1 returns the handle to a new SEGMENTERV1 or the handle to
%      the existing singleton*.
%
%      SEGMENTERV1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SEGMENTERV1.M with the given input arguments.
%
%      SEGMENTERV1('Property','Value',...) creates a new SEGMENTERV1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SegmenterV1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SegmenterV1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SegmenterV1

% Last Modified by GUIDE v2.5 12-Jan-2016 08:57:07

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SegmenterV1_OpeningFcn, ...
                   'gui_OutputFcn',  @SegmenterV1_OutputFcn, ...
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


% --- Executes just before SegmenterV1 is made visible.
function SegmenterV1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SegmenterV1 (see VARARGIN)

% Choose default command line output for SegmenterV1
handles.axes1
handles.output = hObject;
%Initialize the default settings.  If you wish to change them you must
%change them both here and in the guide editor of the specific field you
%wish to change.
%Experimental Directory
handles.expDir  = 'Desktop';
%Image Extension
handles.imExt = '.tiff';
%Number of non nuclear fluorescent channels
handles.numCh = 1;
%Number of levels to use in Otsu's thresholding for the nuclear stain
handles.NucnumLevel = 3;
%Number of levels to use in Otsu's thresholding for the cytoplasmic stain
handles.CytonumLevel = 3;
%The Row and Column Must be three characters
handles.row = 'R02';
handles.col = 'C06';
%Size of disk applied both cytoplasmic to filter out
%noise using imtophat function
handles.noise_disk = 5;
%Size of disk applied to nuclear channel to filter out noise
handles.nuc_noise_disk = 5;
%Factor to smooth the segementation by dilating and eroding the binarized
%image
handles.smoothing_factor = 20; 
%Use cidre correction method for correcting vinetting
handles.cidrecorrect = 0;
%Clear the border cells?
handles.cl_border = 1;
%Segment the surface
handles.surface_segment = 0;
%Segment based on dilating the nucleus
handles.nuclear_segment = 0;
%Factor to dilate nuclear segmented image by
handles.nuclear_segment_factor = 5;
%Factor to dilate surface segmented image by
handles.surface_segment_factor = 5;
%Channel to show in handles.axis1
handles.ChtoSeg = 1;
%Keep track of the image number
handles.imNum = 0;
%Value to assist watershed algorithm in splitting nuclei. See lines 91-95
%in NaiveSegmentv2
handles.NucSegHeight = 3;
%Directory of the Cidre map
handles.cidreDir = '/home/xnmeyer/Documents/Lab/TNBC_Project/Experiments/Models_CIDRE_BaysSeg/20X_GREEN_2048/';
handles %Show handles in command window after starting up
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SegmenterV1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SegmenterV1_OutputFcn(hObject, eventdata, handles) 
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
%Sort out segmentation parameters using the findobj() function to find the
%current value of every field
handles.imExt = get(findobj('Tag','edit6'),'String');
handles.numCh = str2double(get(findobj('Tag','edit4'),'String'));
handles.NucnumLevel = str2double(get(findobj('Tag','edit11'),'String'));
handles.CytonumLevel = str2double(get(findobj('Tag','edit14'),'String'));
handles.col = get(findobj('Tag','edit9'),'String');
handles.row = get(findobj('Tag','edit8'),'String');
handles.ChtoSeg = str2double(get(findobj('Tag','edit12'),'String'));
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
handles.cl_border = get(findobj('Tag','checkbox4'),'Value');
handles.Parallel = get(findobj('Tag','checkbox6'),'Value');


%Set up structure with the filenames of the images to be segmented
%Nuclei Directory (N)
NUC.dir = 'Nuc';
NUC.filnms = dir([handles.expDir filesep NUC.dir filesep '*' handles.imExt]);
NUC.filnms = strcat(handles.expDir, '/', {NUC.dir}, '/', {NUC.filnms.name});
if isempty(NUC.filnms)
    msgbox('You are not in a directory with sorted images... Try again')
    return
end
%Store the number of images total
handles.numberofImages = length(NUC.filnms);
%Create a structure for each of the channels which contains all the
%filenames of each cytoplasmic channel to be segmented.  Also store the
%cidre correction map if applicable
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
[temp, idx] = sort(val);
NUC.filnms = {NUC.filnms{idx(:,1)}};
for i = 1:handles.numCh
    chnm = ['CH_' num2str(i)];
    Cyto.(chnm).filnms = {Cyto.(chnm).filnms{idx(:,i+1)}};
end

%Store the stuructures and send for segmenting
handles.NUC = NUC;
handles.Cyto = Cyto;
if handles.Parallel
   MultiChSegmenterV14GUI(handles)
else
   MultiChSegmentNoParallel(handles)
end

guidata(hObject, handles);




% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1

handles.cidrecorrect = (get(hObject,'Value'));
if handles.cidrecorrect == 1
    h = findobj('Tag','pushbutton3')
    set(h,'Visible','on')
end
guidata(hObject, handles);

% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
handles.nuc_segment = (get(hObject,'Value'));
if handles.nuc_segment == 1
    h = findobj('Tag','edit2')
    set(h,'Visible','on')
end
guidata(hObject, handles);

% --- Executes on button press in checkbox3.
function checkbox3_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox3
handles.surface_segment = (get(hObject,'Value'));
if handles.surface_segment == 1
    h = findobj('Tag','edit3')
    set(h,'Visible','on')
end
guidata(hObject, handles);


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
handles.nuclear_segment_factor = str2double(get(hObject,'String'));
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
handles.surface_segment_factor = str2double(get(hObject,'String'));
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


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.cidreDir = uigetdir()
guidata(hObject, handles);

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double
handles.imNum = 0;
handles.row = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double
handles.imNum = 0;
handles.col = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox4.
function checkbox4_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox4

handles.cl_border = get(hObject,'Value');
guidata(hObject, handles);


function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double
handles.smoothing_factor = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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


% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FileSorterGUI()
guidata(hObject, handles);



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

handles.imExt = get(hObject,'String');
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


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.expDir = uigetdir();
if ~isempty(strfind(handles.expDir,'-'))
    errordlg('Please remame the file path to contain no - signs and try again')
end
set(hObject,'String',handles.expDir)

guidata(hObject, handles);




function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double

handles.numCh = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called




function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double
handles.noise_disk = str2double(get(hObject,'String'));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
% %       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.NucnumLevel = get(hObject,'Value')
h = findobj('Tag','edit11')
set(h,'String',num2str(handles.NucnumLevel))
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double
handles.NucnumLevel = str2num(get(hObject,'String'));
h = findobj('Tag','slider1');
set(h,'Value',handles.NucnumLevel)
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imExt = get(findobj('Tag','edit6'),'String');
handles.numCh = str2double(get(findobj('Tag','edit4'),'String'));
handles.NucnumLevel = str2double(get(findobj('Tag','edit11'),'String'));
handles.CytonumLevel = str2double(get(findobj('Tag','edit14'),'String'));
handles.col = get(findobj('Tag','edit9'),'String');
handles.row = get(findobj('Tag','edit8'),'String');
handles.ChtoSeg = str2double(get(findobj('Tag','edit12'),'String'));

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
handles.cl_border = get(findobj('Tag','checkbox4'),'Value');


handles
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

handles.NUC = NUC;
handles.Cyto = Cyto;

if handles.imNum == 0
    file_list = dir([handles.expDir '/Nuc/*' handles.imExt]);
    tempR = (strfind({file_list.name},handles.row));
    tempC = (strfind({file_list.name},handles.col));
    tempR = find(cellfun(@isempty,tempR)==0);
    tempC = find(cellfun(@isempty,tempC)==0);
    %files to segment
    temp = intersect(tempR,tempC);
    handles.imNum = temp(1);
    handles.imNumArray = temp;
    set(findobj('Tag','pushbutton7'),'Visible','on')
end
segmenterTestGUI(handles)
guidata(hObject, handles);



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double
handles.ChtoSeg = str2double(get(hObject,'String'))
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in pushbutton7.
function pushbutton7_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if handles.imNum ~= handles.imNumArray(length(handles.imNumArray))
    handles.imNum = handles.imNum + 1;
else
    handles.imNum = handles.imNumArray(1);
end
handles.imNum
pushbutton6_Callback(hObject, eventdata, handles)
guidata(hObject,handles)


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%AnalysisGUI(handles.expDir)
str = sprintf('Exporting now...This box will close once finished.\n  Look in the Experiment Directory for:\nCompiled Segmentation Results.mat  Contains all data\nImage Events.csv Information about individual cells\nCell Events.csv Contains individual frame information')
h = msgbox(str)
seg_file = dir([handles.expDir filesep 'Segmented/*.mat'])

handles.numCh

%Declare structure for holding data
Seg = struct('Nuc_IntperA',[],'NucArea',[],'NucInt',[],'numCytowoutNuc',[],...
    'cellcount',[],'RW',cell(1),'CL',cell(1),'ImNum',[],'min',cell(1),'day',...
    cell(1),'month',cell(1),'year',cell(1),'NucBackground',[],...
    'class',struct('debris',[],'nucleus',[],'over',[],'under',[],...
    'predivision',[],'postdivision',[],'apoptotic',[],'newborn',[]),...
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
        Seg.ImNumSingle = [Seg.ImNumSingle;str2num(seg_file(i).name(9:strfind(seg_file(i).name,'.')-1))];
        Seg.RW = [Seg.RW;repmat(seg_file(i).name(1:3),CO.cellCount,1)];
        Seg.CL = [Seg.CL;repmat(seg_file(i).name(5:7),CO.cellCount,1)];
        Seg.ImNum = [Seg.ImNum; str2num(repmat(seg_file(i).name(9:strfind(seg_file(i).name,'.')-1),CO.cellCount,1))];
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
        Seg.ImNumSingle = [Seg.ImNumSingle;str2num(seg_file(i).name(9:strfind(seg_file(i).name,'.')-1))];
        Seg.RW = [Seg.RW;seg_file(i).name(1:3)];
        Seg.CL = [Seg.CL;seg_file(i).name(5:7)];
        Seg.ImNum = [Seg.ImNum; str2num(seg_file(i).name(9:strfind(seg_file(i).name,'.')))];
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
Condition = {Condition{:},'Class_Nucleus','Class_Debris','Class_Over','Class_Under','Class_Predivision','Class_Postdivision','Class_Newborn','Class_Apoptotic'};
tempMat = [tempMat, array2table([Seg.class.nucleus,Seg.class.debris,Seg.class.over,Seg.class.under,Seg.class.predivision,Seg.class.postdivision,Seg.class.newborn,Seg.class.apoptotic],'VariableNames',{Condition{(handles.numCh)*5+14:end}})];
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
    'Segment_by_Nuclear_Dilation','Nuclear_Dilation_Factor','Segment_Cell_Surface',...
    'Cell_Surface_Dilation_Factor','Clear_Border_Cells'};
T = array2table([handles.numCh,handles.NucnumLevel,handles.CytonumLevel,handles.NucSegHeight,handles.noise_disk,handles.nuc_noise_disk,...
handles.smoothing_factor,handles.cidrecorrect,handles.nuclear_segment,...
handles.nuclear_segment_factor,handles.surface_segment,handles.surface_segment_factor,...
handles.cl_border],'VariableNames',ImageParameter);
T.Cidre_Directory = handles.cidreDir;
writetable(T,[handles.expDir filesep 'Processing Parameters.csv']);

close(h)
guidata(hObject,handles)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.imExt = get(findobj('Tag','edit6'),'String');
%BayesClassifier(1,handles.expDir,[handles.expDir '/BayesClassifier.mat'])
guidata(hObject,handles)


% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.NucSegHeight = get(hObject,'Value');
h = findobj('Tag','edit13');
set(h,'String',num2str(handles.NucSegHeight))
guidata(hObject,handles)



% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double
handles.NucSegHeight = str2double(get(hObject,'String'));
h = findobj('Tag','slider2');
set(h,'Value',handles.NucSegHeight);
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox6.
function checkbox6_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox6
handles.Parallel = get(hObject,'Value');
guidata(hObject,handles)


% --- Executes on button press in checkbox7.
function checkbox7_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox7
if get(hObject,'Value')
    handles.ChtoSeg = 0;
end
guidata(hObject,handles)


% --- Executes on button press in pushbutton13.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
h = getframe(handles.axes1);
[x,map] = frame2im(h);
filename = [handles.expDir filesep 'Image_' num2str(handles.imNum) '.png'];
imwrite(x,filename,'png')
save([handles.expDir filesep 'Processing_parameters.mat'],'handles');
guidata(hObject,handles)


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.CytonumLevel = get(hObject,'Value')
h = findobj('Tag','edit14')
set(h,'String',num2str(handles.CytonumLevel))
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double
handles.CytonumLevel = str2num(get(hObject,'String'));
h = findobj('Tag','slider3');
set(h,'Value',handles.CytonumLevel)
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double
handles.nuc_noise_disk = str2double(get(hObject,'String'))
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
