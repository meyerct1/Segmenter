function varargout = SegmentReview(varargin)
% SEGMENTREVIEW M-file for SegmentReview.fig
%      	SEGMENTREVIEW, by itself, creates a new SEGMENTREVIEW or raises the 
%		existing singleton*.
%
%      	H = SEGMENTREVIEW returns the handle to a new SEGMENTREVIEW or the 
%		handle to the existing singleton*.
%
%      	SEGMENTREVIEW('CALLBACK',hObject,eventData,handles,...) calls the 
%		local function named CALLBACK in SEGMENTREVIEW.M with the given 
%		input arguments.
%
%      	SEGMENTREVIEW('Property','Value',...) creates a new SEGMENTREVIEW or 
%		raises the existing singleton*.  Starting from the left, property 
%		value pairs are applied to the GUI before SegmentReview_OpeningFcn 
%		gets called.  An unrecognized property name or invalid value makes 
%		property application 
%		stop.  All inputs are passed to SegmentReview_OpeningFcn via 
%		varargin.
%
%   	*See GUI Options on GUIDEs Tools menu.  Choose "GUI allows only one 
%		instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SegmentReview

% Last Modified by GUIDE v2.5 02-Jan-2016 18:19:21

	% Begin initialization code - DO NOT EDIT
	gui_Singleton = 1;
	gui_State = struct(	'gui_Name',       mfilename, ...
						'gui_Singleton',  gui_Singleton, ...
						'gui_OpeningFcn', @SegmentReview_OpeningFcn, ...
						'gui_OutputFcn',  @SegmentReview_OutputFcn, ...
						'gui_LayoutFcn',  [] , ...
						'gui_Callback',   []);
                   
	if nargin && ischar(varargin{1})
		gui_State.gui_Callback = str2func(varargin{1});
	end %if nargin...

	if nargout
		[varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
	else 
		gui_mainfcn(gui_State, varargin{:});
	end %if nargout
	% End initialization code - DO NOT EDIT
 % SegmentReview
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Output

% --- Outputs from this function are returned to the command line.
function varargout = SegmentReview_OutputFcn(hObject, eventdata, handles) 
 
	varargout{1} = handles.output;

 % SegmentReview_OutputFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Initialization

% --- Executes just before SegmentReview is made visible.
function SegmentReview_OpeningFcn(hObject, eventdata, handles, varargin)
  
	% Choose default command line output for SegmentReview
	handles.output = hObject;

	% Update handles structure
	guidata(hObject, handles);

	if size(varargin,2) < 3
    	errordlg([	'Must Specify Number followed by working directory, ' ...
			  		'followed by output file on Command Line'], ...
					'No Filename');
		close(handles);
	elseif size(varargin,2) > 4
		errordlg('Too many input arguments', 'Too many arguments');
	elseif InitDisplay(handles, varargin{2}, varargin{3}) == 1
		errordlg('Unable to locate directory', 'Invalid Directory');
		close(handles);
	end %if size...
 % SegmentReview_OpeningFcn

function error=InitDisplay(handles, directory, outputfile) 

	try
		handles.directory = directory;
		addpath(directory);%check to see if directory is real
	catch
		error = 1;
		return;
	end %try
  
	handles.outputfile 				= outputfile;%.mat file
	handles.outlines 				= struct();%outlines handles
	handles.highlights 				= struct();%highlights handles
	handles.rectangle				= handle(rectangle);%rectangle handle
	delete(handles.rectangle);
	handles.selected = 1; 
    handles.noise_disk = 10;
    handles.NucSegHeight = 1;
	guidata(handles.output, handles);

	try %load objSet object, if it exists
		load(outputfile, 'objSet');
		handles.objSet				= objSet;
		InitFirstSet(handles);
  	catch %initialize a new set if necessary
		handles.objSet = [];
		InitNewImage(handles);
	end %try ...
    
	error=0;

 % InitDisplay

% --- asks for and displays a fresh segmentation
function InitNewImage(handles)
  
	[imagefile, ...
	path]						= uigetfile('*.*', ...
											'Select an image: ', ...
											handles.directory);
	handles.imagefile			= [path imagefile];
	[handles.image,     ...
	handles.wellName,  ...
	handles.imageName] 			= LoadImage(handles.imagefile);

    temp_id = strfind(handles.imagefile,'.');
    handles.imExt = char(handles.imagefile(temp_id:end));
    handles.imExt
    handles.imageName
	h = msgbox('Segmenting image');
	[handles.props, ...
	handles.labels] 			= NaiveSegment_firstpass(handles.imageName,handles.imExt,handles.directory);
	close(h);

	set(handles.CurImage, 'String', handles.imageName);
	
	set(handles.SaveImgToSet,   'Enable', 'on');
	set(handles.deleteObj, 	  'Enable', 'off');  
	set(handles.SaveObjToSet,   'Enable', 'on');
	handles = PopulateObjSetPopUp(handles);
	guidata(handles.output, handles);

	set(handles.ImageDisplay, 'NextPlot', 'replacechildren');
	DrawDisplay(handles);

 %InitNewImage

% --- Displays the images and objects from the first image in the set
function InitFirstSet(handles)

	if(isempty(handles.objSet))
		InitNewImage(handles);
	else
		handles.imagefile 		= [	handles.directory filesep ...
									handles.objSet(1).wellName filesep ...
									handles.objSet(1).imageName];
		handles.image 			= imread(handles.imagefile);
		handles.imageName 		= handles.objSet(1).imageName;
		handles.wellName 		= handles.objSet(1).wellName;
		handles.props 			= handles.objSet(1).props;
		handles.labels			= handles.objSet(1).labels;

		set(handles.CurImage, 'String', handles.imageName);

		set(handles.SaveImgToSet,   'Enable', 'off');
		set(handles.deleteObj,      'Enable', 'on');  
		set(handles.SaveObjToSet,   'Enable', 'off');

		set(handles.ObjSetPopUp, 'Value', 1);
		handles = PopulateObjSetPopUp(handles);
    
		guidata(handles.output, handles);

		set(handles.ImageDisplay, 'NextPlot', 'replacechildren');
		DrawDisplay(handles);
	end

%InitFirstSet
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the main display

% --- Draws the image
function DrawDisplay(handles)
 
	handles = DeleteRectangle(handles);
	handles = DeleteHighlights(handles);
	handles = DeleteOutlines(handles);
	guidata(handles.output, handles);
 
	%initialize figure
	newplot;
	imagesc(handles.image);
	axis image
	colormap gray; 
	set(handles.ImageDisplay, 'NextPlot', 'replacechildren');
	hold on;

	%assign segment popup values
	set(handles.SegmentPopup, 'Value', 1);  
	handles = PopulateSegmentPopup(handles);

	handles.selected 	= 1;	
	handles = UpdateClassificationDisplay(handles);  

	handles = DrawRectangle(handles);
	if(get(handles.OutlineButton, 'Value'))
		handles = DrawOutlines(handles);
	end
	handles = DrawHighlights(handles);

	set(get(handles.ImageDisplay, 'Children'), 'HitTest', 'off');

	guidata(handles.output, handles);
   
 %DrawDisplay

% --- Executes on mouse press over axes background.
function ImageDisplay_ButtonDownFcn(hObject, eventdata, handles)
 
	labels		= [handles.props(:).label];
	pos 		= get(hObject, 'Currentpoint');
	x   		= int64(pos(1,1));
	y   		= int64(pos(1,2));
	s   		= size(handles.labels);

	if x > 0 && x <= s(2) && y > 0 && y <= s(1)
		if handles.labels(y,x) > 0
			l = handles.labels(y,x);
			s = find(labels == l);
			if(~isempty(s))
				handles.selected = s;
				get(handles.SegmentPopup, 'String');
				set(handles.SegmentPopup, 'Value', handles.selected);
			end %if(isempty...
		end %if handles...
  	end %if x...

	handles 	= DeleteRectangle(handles);
	handles 	= DrawRectangle(handles);
	handles	= UpdateClassificationDisplay(handles);
	guidata(handles.output, handles);
  
%ImageDisplay_ButtonDownFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the rectangle around the selected object

% --- Draws a rectangle around the selected object
function newHandles = DrawRectangle(handles)

	newHandles = handles;

	newHandles.rectangle = ... 
		rectangle(	'Position', ...
					newHandles.props(newHandles.selected).BoundingBox, ...
					'EdgeColor', 'r', ...
					'LineWidth', 2);
	set(newHandles.rectangle, 'HitTest', 'off');

%DrawRectangle

% --- Removes the rectangle
function newHandles = DeleteRectangle(handles)

	newHandles = handles;

	if(ishandle(newHandles.rectangle))
		delete(newHandles.rectangle);
	end %if(ishandle...

%DeleteRectangle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles outlines around objects

% --- Executes on button press in OutlineButton.
function OutlineButton_Callback(hObject, eventdata, handles)
 
	handles = DeleteOutlines(handles);

	if(get(hObject, 'Value'))
		handles = DrawOutlines(handles); 
	end %if(get...

	guidata(handles.output, handles);
  
% OutlineButton_Callback

% --- Draws outlines around objects
function newHandles = DrawOutlines(handles)

	newHandles = handles;

	% http://www.mathworks.com/matlabcentral/fileexchange/28982
	colors=pmkmp(20, 'IsoL');

	for obj=1:size(newHandles.props,1)
		newHandles.outlines.(['o' int2str(obj)]) = ...
		plot(	newHandles.props(obj).bound(:,2),...
				newHandles.props(obj).bound(:,1),...,
				'Color', colors(mod(obj, size(colors,1))+1, :), ...,
				'LineWidth',1.25);
		set(newHandles.outlines.(['o' int2str(obj)]), 'HitTest', 'off') ;
	end %for obj...

%DrawOutlines

% --- removes the outlines, if present
function newHandles = DeleteOutlines(handles)

	newHandles = handles;

	outlines = fieldnames(newHandles.outlines);
	for(i=1:size(outlines,1))
		if(newHandles.outlines.(outlines{i}) ~= 0)
			delete(newHandles.outlines.(outlines{i}));
		end %if(newHandles...
	end %for(i=1...

	clear newHandles.outlines;
	newHandles.outlines = struct();

 %DeleteOutlines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles popup menu which allows direct acces to objects 
%in the frame

% --- Executes on selection change in SegmentPopup.
function SegmentPopup_Callback(hObject, eventdata, handles)
 
	if(isempty(handles.props))
		msgbox('There are no objects');
	else
		handles.selected 	= get(handles.SegmentPopup, 'Value');
		handles 			= DeleteRectangle(handles);
		handles 			= DrawRectangle(handles);
		handles				= UpdateClassificationDisplay(handles);

		guidata(handles.output, handles);
	end

%SegmentPopup_Callback

% --- Executes during object creation, after setting all properties.
function SegmentPopup_CreateFcn(hObject, eventdata, handles)
 
	if ispc && isequal(	get(hObject,'BackgroundColor'), ...
						get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end %if ispc ...
  %SegmentPopup_CreateFcn

% --- Sets the string values in the pop up menu
function newHandles = PopulateSegmentPopup(handles)
  
	newHandles = handles;

	if(isempty(newHandles.props))
		set(newHandles.SegmentPopup, 'String', 'No objects');
	else
		set(newHandles.SegmentPopup, 'String', 1:size(newHandles.props)); 
	end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the segment new image button

% --- Executes on button press in SegmentNewImg.
function SegmentNewImg_Callback(hObject, eventdata, handles)
 
	InitNewImage(handles);

%SegmentNewImg_Callback

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the select object set box

% --- Executes on selection change in ObjSetPopUp.
function ObjSetPopUp_Callback(hObject, eventdata, handles)
 
	if(isempty(handles.objSet))
		msgbox('There are no sets yet.');
	else
		idx				 			= get(handles.ObjSetPopUp, 'Value');
		handles.imagefile 			= [	handles.directory filesep handles.objSet(idx).imageName];
										%handles.objSet(idx).wellName ...
										%filesep ...

		handles.image 				= imread(handles.imagefile);
		handles.imageName 			= handles.objSet(idx).imageName;
		handles.wellName 			= handles.objSet(idx).wellName;
		handles.props 				= handles.objSet(idx).props;
		handles.labels				= handles.objSet(idx).labels;
		handles.selected			= 1;

		set(handles.SaveImgToSet, 	'Enable', 'off');
		set(handles.deleteObj,    	'Enable', 'on');  
		set(handles.SaveObjToSet, 	'Enable', 'off');
		guidata(handles.output, handles);
		DrawDisplay(handles);
	end

%ObjSetPopUp_Callback

% --- Executes during object creation, after setting all properties.
function ObjSetPopUp_CreateFcn(hObject, eventdata, handles)

	if ispc && isequal(	get(hObject,'BackgroundColor'), ...
						get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end %if ispc ...

%ObjSetPopUp_CreateFcn

% --- Sets the string values in the pop up menu
function newHandles = PopulateObjSetPopUp(handles)
  
	newHandles = handles;
    newHandles.objSet
    size(newHandles.objSet,2)
	if(isempty(newHandles.objSet))
		set(newHandles.ObjSetPopUp, 'String', 'No sets');
	else
		objSetStrs = [];
		for(i=1:size(newHandles.objSet,2))
			objSetStrs = [	objSetStrs; ...
	  						newHandles.objSet(i).wellName filesep ...
							newHandles.objSet(i).imageName];
		end %for(i=1...
		set(newHandles.ObjSetPopUp, 'String', objSetStrs); 
	end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the area text box

% --- Executes of click in area text box
function AreaText_Callback(hObject, eventdata, handles)
	%nothing to do
 %AreaText_Callback

% --- Executes during object creation, after setting all properties.
function AreaText_CreateFcn(hObject, eventdata, handles)

	if ispc && isequal(	get(hObject,'BackgroundColor'), ... 
						get(0,'defaultUicontrolBackgroundColor'))
		set(hObject,'BackgroundColor','white');
	end %if ispc ...

%AreaText_CreateFcn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the classification check boxes

% --- Display selected object's classification
function newHandles = UpdateClassificationDisplay(handles)

	newHandles = handles;

	 set(newHandles.AreaText,     	  'String',...
		newHandles.props(newHandles.selected).Area);
	set(newHandles.DebrisCheck,     'Value', ...
		newHandles.props(newHandles.selected).debris);
	set(newHandles.NucleusCheck,    'Value', ...
		newHandles.props(newHandles.selected).nucleus);
	set(newHandles.OverCheck,       'Value', ...
		newHandles.props(newHandles.selected).over);
	set(newHandles.UnderCheck,      'Value', ...
		newHandles.props(newHandles.selected).under);
	set(newHandles.PostdivisionCheck,'Value', ...
		newHandles.props(newHandles.selected).postdivision);
	set(newHandles.PredivisionCheck, 'Value', ...
		newHandles.props(newHandles.selected).predivision);
	set(newHandles.ApoptoticCheck,  'Value', ...
		newHandles.props(newHandles.selected).apoptotic);
	set(newHandles.EdgeCheck,       'Value', ...
		newHandles.props(newHandles.selected).edge);



% --- Executes on button press in DebrisCheck.
function DebrisCheck_Callback(hObject, eventdata, handles)
  
	handles.props(get(handles.SegmentPopup, 'Value')).debris = ...
        get(hObject,'Value');
	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);

%DebrisCheck_Callback

% --- Executes on button press in NucleusCheck.
function NucleusCheck_Callback(hObject, eventdata, handles)

	handles.props(get(handles.SegmentPopup, 'Value')).nucleus = ...
		get(hObject,'Value');
	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);

 %NucleusCheck_Callback

% --- Executes on button press in OverCheck.
function OverCheck_Callback(hObject, eventdata, handles)

	handles.props(get(handles.SegmentPopup, 'Value')).over = ...
		get(hObject,'Value');
	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);

 %OverCheck_Callback

% --- Executes on button press in UnderCheck.
function UnderCheck_Callback(hObject, eventdata, handles)

	handles.props(get(handles.SegmentPopup, 'Value')).under = ...
		get(hObject,'Value');
	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);
 
%UnderCheck_Callback

% --- Executes on button press in postdivisioncheck.
function PostdivisionCheck_Callback(hObject, eventdata, handles)
	
	handles.props(get(handles.SegmentPopup, 'Value')).postdivision = ...
	get(hObject,'Value');
	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);
 
 %PostdivisionCheck_Callback

% --- Executes on button press in PredivisionCheck.
function PredivisionCheck_Callback(hObject, eventdata, handles)

	handles.props(get(handles.SegmentPopup, 'Value')).predivision = ...
		get(hObject,'Value');
	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);
  
%PredivisionCheck_Callback

% --- Executes on button press in ApoptoticCheck.
function ApoptoticCheck_Callback(hObject, eventdata, handles)

	handles.props(get(handles.SegmentPopup, 'Value')).apoptotic = ...
		get(hObject,'Value');
	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);
  
%ApoptoticCheck_Callback

% --- Executes on button press in EdgeCheck.
function EdgeCheck_Callback(hObject, eventdata, handles)
	%nothing to do
%EdgeCheck_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Allows objects to be outlined based on classification

% --- Executes on button press in SelectDebris.
function SelectDebris_Callback(hObject, eventdata, handles)

	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);  
	guidata(handles.output, handles);

%SelectDebris_Callback

% --- Executes on button press in SelectNuclei.
function SelectNuclei_Callback(hObject, eventdata, handles)

	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);

%SelectNuclei_Callback

% --- Executes on button press in SelectOver.
function SelectOver_Callback(hObject, eventdata, handles)

	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);
  
%SelectOver_Callback

% --- Executes on button press in SelectUnder.
function SelectUnder_Callback(hObject, eventdata, handles)

	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);

%SelectUnder_Callback

% --- Executes on button press in SelectPostdivision.
function SelectPostdivision_Callback(hObject, eventdata, handles)

	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);

%SelectPostdivision_Callback

% --- Executes on button press in SelectPredivision.
function SelectPredivision_Callback(hObject, eventdata, handles)

	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);

%SelectPredivision_Callback

% --- Executes on button press in SelectApoptotic.
function SelectApoptotic_Callback(hObject, eventdata, handles)

	handles = DeleteHighlights(handles);
	handles = DrawHighlights(handles);
	guidata(handles.output, handles);

%SelectApoptotic_Callback

% --- Draws outlines around objects which match the 
%	  selected classification
function newHandles = DrawHighlights(handles)

	newHandles = handles;

	%available options to outline
	selectButtons 	= {	'SelectDebris', 		...
				  		'SelectNuclei', 		...
						'SelectOver',   		...
						'SelectUnder',  		...
						'SelectPostdivision', 	...
						'SelectPredivision',	...
						'SelectApoptotic' };
  
	%corresponding classifications
	classifications 	= {	'debris', 				...
							'nucleus',				...
							'over',					...
							'under',				...
							'postdivision',			...
							'predivision',			...
							'apoptotic' };

	for(i = 1:size(selectButtons,2))
		if(get(newHandles.(selectButtons{1,i}), 'Value') == 1)
			hold on;
			% http://www.mathworks.com/matlabcentral/fileexchange/28982
			colors = pmkmp(20, 'IsoL'); 
			%outline all objects classified this way
			for(obj = 1:size(newHandles.props))
				if(newHandles.props(obj).(classifications{1,i}) == 1)
					newHandles.highlights.([classifications{1,i} ...
											int2str(obj)])=...
						plot(	newHandles.props(obj).bound(:,2), ...
								newHandles.props(obj).bound(:,1), ...
								'Color', colors(mod(obj, ...
												size(colors,1))+1,:), ...
								'LineWidth',1.25);
					set(newHandles.highlights.([classifications{1,i} ...
												int2str(obj)]),...
						'HitTest', 'off') ;
				end %if(newHandles...
			end %for(obj = 1:...
		end %if(get(newH...
	end %for(1 = ...

%DrawHighlights

% --- Deletes outlines if they are present
function newHandles = DeleteHighlights(handles)

  newHandles = handles;

  highlights = fieldnames(newHandles.highlights);
  for(i=1:size(highlights,1))
    if(newHandles.highlights.(highlights{i}) ~= 0)
      delete(newHandles.highlights.(highlights{i}));
    end %if(newHandles...
  end %for(i=1...

  clear newHandles.highlights;
  newHandles.highlights = struct();

%DeleteHighlights
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the delete object button

% --- Executes on button press in deleteObj.
function deleteObj_Callback(hObject, eventdata, handles)
  
	%delete the object 
	handles.props(handles.selected) = [];

	%clear display in preparation for resetting it
	handles = DeleteRectangle(handles);
	handles = DeleteOutlines(handles);
	handles = DeleteHighlights(handles);

	if(isempty(handles.props))
		%handle deletion of last object in set
		handles.objSet(get(handles.ObjSetPopUp, 'Value')) = [];
		guidata(handles.output, handles);
		InitFirstSet(handles);
	else
		%regular case
		%update set object
		handles.objSet(get(handles.ObjSetPopUp, 'Value')).props = ...
			handles.props;

		%update display to account for the removed objecti
		handles.selected = 1;
		handles = PopulateSegmentPopup(handles);
		handles = DrawRectangle(handles);
		handles = DrawHighlights(handles);
		handles = DrawOutlines(handles);
		guidata(handles.output, handles);
	end %if(size... 

%deleteObj_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles the save button

% --- Executes on button press in SaveButton.
function SaveButton_Callback(hObject, eventdata, handles)
 
	objSet = handles.objSet;
    save('Handles','handles')
    save(handles.outputfile, 'objSet');
    

%SaveButton_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Handles adding to the set

% --- Executes on button press in SaveToTrainingSet.
function SaveObjToSet_Callback(hObject, eventdata, handles)
%handles.props represents a fresh segmentation here, not any part of the
%stored set. handles.objSet is the stored set

	%find this image in the set
	idx = 1;
	while(idx <= size(handles.objSet,2))
		if(	strcmp(handles.objSet(idx).wellName,  handles.wellName) && ...
			strcmp(handles.objSet(idx).imageName, handles.imageName))	
			break;
		end %if(strcmp...
		idx = idx + 1;
	end %while(idx ...
 
	%append the object to the appropriate image set (create a new one
	%if this image is not yet in the set)
	if(idx > size(handles.objSet,2))
		handles.objSet(idx).wellName 	= handles.wellName;
		handles.objSet(idx).imageName 	= handles.imageName;
        handles.objSet(idx).props 		= handles.props(handles.selected);
		handles.objSet(idx).labels 		= handles.labels;
		handles 						= PopulateObjSetPopUp(handles);	

	else
		handles.objSet(idx).props 		= [	handles.objSet(idx).props; ...
											handles.props(handles.selected)];
	end %if(idx ...

	%disable add all, still working with fresh segmentation, not editing set
	set(handles.SaveImgToSet, 'Enable', 'off');
  
	guidata(handles.output, handles);
  
%SaveObjToSet_Callback

% --- Executes on button press in SaveImgToSet.
function SaveImgToSet_Callback(hObject, eventdata, handles)
%handles.props represents a fresh segmentation here, not any part of the
%stored set. handles.objSet is the stored set
 
	%append image to set
	idx 							= size(handles.objSet,2) + 1;
	handles.objSet(idx).wellName 	= handles.wellName;
	handles.objSet(idx).imageName 	= handles.imageName;
    handles.objSet(idx).props 		= handles.props;
    handles.objSet(idx).labels 		= handles.labels;

	handles = PopulateObjSetPopUp(handles); 
 
	%change state to editing set instead of fresh segmentation
	set(handles.SaveImgToSet, 'Enable', 'off');
	set(handles.deleteObj, 	'Enable', 'on');
	set(handles.SaveObjToSet, 'Enable', 'off');

	guidata(handles.output, handles);

 %SaveImgToSet_Callback
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
handles.NucSegHeight = get(hObject,'Value');
set(findobj('edit2','slider1'),'String',num2str(handles.NucSegHeight))
guidata(handles.output, handles)

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(findobj('Tag','slider1'),'Value',str2num(get(hObject,'string')));
handles.NucSegHeight = str2num(get(hObject,'string'));
guidata(handles.output,handles)


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
