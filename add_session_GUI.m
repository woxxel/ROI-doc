function varargout = add_session_GUI(varargin)
% ADD_SESSION_GUI MATLAB code for add_session_GUI.fig
%      ADD_SESSION_GUI, by itself, creates a new ADD_SESSION_GUI or raises the existing
%      singleton*.
%
%      H = ADD_SESSION_GUI returns the handle to a new ADD_SESSION_GUI or the handle to
%      the existing singleton*.
%
%      ADD_SESSION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ADD_SESSION_GUI.M with the given input arguments.
%
%      ADD_SESSION_GUI('Property','Value',...) creates a new ADD_SESSION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before add_session_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to add_session_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help add_session_GUI

% Last Modified by GUIDE v2.5 08-Mar-2018 16:36:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @add_session_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @add_session_GUI_OutputFcn, ...
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


% --- Executes just before add_session_GUI is made visible.
function add_session_GUI_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to add_session_GUI (see VARARGIN)
  
  header = { 'Dataset' 'Path' };
  h.session_list = uimulticollist ('Parent',h.figure1,...
                                  'units', 'normalized',...
                                  'position', [0.035 0.55 0.85 0.275],...
                                  'string', header,...
                                  'separator', ' - ');

  input = getappdata(0,'add_session_input');
  
  set(h.spec_session_num,'String',sprintf('%d',input.nSes))

  set(h.spec_bg_path,'String','reduced_MF1_LK1.mat')
  set(h.spec_ROI_path,'String','resultsCNMF_MF1_LK1.mat')
  set(h.spec_Ca_path,'String','resultsCNMF_MF1_LK1.mat')
  
  set(h.spec_session_name,'String','Session')
  
  %% add helper info to mouse-over fields
  set(h.spec_bg_field,'String','max_im')
  set(h.spec_ROI_field,'String','A2')
  set(h.spec_Ca_field1,'String','C2')
  set(h.spec_Ca_field2,'String','S2')
  
  set(h.checkbox_bg_loadnprocess,'Value',1)
  set(h.checkbox_ROI_loadnprocess,'Value',1)
  set(h.checkbox_Ca_loadnprocess,'Value',0)
  
  
%    if ~isempty(input.start_path)
%      set(h.listbox_session,'String',input.start_path)
%      set(h.button_add,'enable','on')
%    else
%      set(h.listbox_session,'String','')
%    end
  
%    set(h.spec_session_name,'String',input.name)
  
  setappdata(0,'add_session_output',0)
  
% Choose default command line output for add_session_GUI
h.output = hObject;

% Update handles structure
guidata(hObject, h);
% UIWAIT makes add_session_GUI wait for user response (see UIRESUME)
uiwait(h.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = add_session_GUI_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = 0;

delete(hObject);

% --- Executes on button press in button_add.
function button_add_Callback(hObject, eventdata, h)
% hObject    handle to button_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  for s = 2:uimulticollist(h.session_list,'nRows')
    set(h.session_list,'Value',s)
    output{s-1} = struct;
    session_path = uimulticollist(h.session_list,'selectedString');
    output{s-1}.session_name = session_path{1};
    output{s-1}.session_path = session_path{2};
    
    output{s-1}.bg_path = get(h.spec_bg_path,'String');
    output{s-1}.ROI_path = get(h.spec_ROI_path,'String');
    output{s-1}.Ca_path = get(h.spec_Ca_path,'String');
    
    output{s-1}.bg_field = get(h.spec_bg_field,'String');
    output{s-1}.ROI_field = get(h.spec_ROI_field,'String');
    output{s-1}.Ca_field1 = get(h.spec_Ca_field1,'String');
    output{s-1}.Ca_field2 = get(h.spec_Ca_field2,'String');
    
    output{s-1}.bg_load = get(h.checkbox_bg_loadnprocess,'Value');
    output{s-1}.ROI_load = get(h.checkbox_ROI_loadnprocess,'Value');
    output{s-1}.Ca_load = get(h.checkbox_Ca_loadnprocess,'Value');
  end
  setappdata(0,'add_session_output',output)
  guidata(hObject,h);
  close()

% --- Executes on button press in button_cancel.
function button_cancel_Callback(hObject, eventdata, h)
% hObject    handle to button_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  output = 0;
  setappdata(0,'add_session_output',output)
  guidata(hObject,h);
  close()

% --- Executes on button press in button_add_session.
function button_add_session_Callback(hObject, eventdata, h)
% hObject    handle to button_add_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  pathNames = uipickfiles;
%    pathName = uigetdir('MultiSelect','on',get(h.listbox_session,'String'),'Choose the session path');
  
  sessionName = get(h.spec_session_name,'String');
  sessionNum = str2num(get(h.spec_session_num,'String'));
  for path = pathNames
    row_string = {sprintf('%s %02d',sessionName,sessionNum),path{1}};
    uimulticollist(h.session_list, 'addRow', row_string);%,{'GREY','WHITE'});
    sessionNum = sessionNum + 1;
  end
  uimulticollist(h.session_list, 'columnColour', 1, 'RED' )
    
%    set(h.listbox_session,'String',pathNames)
  if uimulticollist(h.session_list,'nRows') > 1
    set(h.button_add,'enable','on')
    set(h.button_bg_path,'enable','on')
    set(h.button_ROI_path,'enable','on')
    set(h.button_Ca_path,'enable','on')
    set(h.spec_bg_path,'enable','on')
    set(h.spec_ROI_path,'enable','on')
    set(h.spec_Ca_path,'enable','on')
    set(h.spec_bg_field,'enable','on')
    set(h.spec_ROI_field,'enable','on')
    set(h.spec_Ca_field1,'enable','on')
    set(h.spec_Ca_field2,'enable','on')
    set(h.checkbox_bg_loadnprocess,'enable','on')
    set(h.checkbox_ROI_loadnprocess,'enable','on')
    set(h.checkbox_Ca_loadnprocess,'enable','on')
  end
  
  set(h.session_list,'Value',uimulticollist(h.session_list,'nRows'))
  


function listbox_session_Callback(hObject, eventdata, h)
% hObject    handle to listbox_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of listbox_session as text
%        str2double(get(hObject,'String')) returns contents of listbox_session as a double
  
  pathName = get(h.listbox_session,'String');
  if ~isempty(pathName)
    set(h.button_add,'enable','on')
  else
    set(h.button_add,'enable','off')
  end
  

% --- Executes during object creation, after setting all properties.
function listbox_session_CreateFcn(hObject, eventdata, h)
% hObject    handle to listbox_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_provide_bg.
function checkbox_provide_bg_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_provide_bg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_provide_bg


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, h)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: delete(hObject) closes the figure
if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end



function spec_session_name_Callback(hObject, eventdata, h)
% hObject    handle to spec_session_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_session_name as text
%        str2double(get(hObject,'String')) returns contents of spec_session_name as a double

  %% here, add update
  msgbox('add callback')

% --- Executes during object creation, after setting all properties.
function spec_session_name_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_session_name (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_auto_number.
function checkbox_auto_number_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_auto_number (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_auto_number



function spec_bg_path_Callback(hObject, eventdata, h)
% hObject    handle to spec_bg_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_bg_path as text
%        str2double(get(hObject,'String')) returns contents of spec_bg_path as a double


% --- Executes during object creation, after setting all properties.
function spec_bg_path_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_bg_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_bg_path.
function button_bg_path_Callback(hObject, eventdata, h)
% hObject    handle to button_bg_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  pathSession = uimulticollist(h.session_list,'selectedString')
  pathSession = pathSession{2};
  pathSearch = pathcat(pathSession,get(h.spec_bg_path,'String'));
  [fileName, pathName] = uigetfile({'*.mat'},'Choose background data file',pathSearch);
  
  if ischar(fileName)
    if ~strcmp(pathName,pathSession)
      fileName = erase(pathcat(pathName,fileName),pathSession);
      if strcmp(fileName(1),'/') || strcmp(fileName(1),'\')
        fileName = fileName(2:end);
      end
    end
    set(h.spec_bg_path,'String',fileName)
  end


function spec_bg_field_Callback(hObject, eventdata, h)
% hObject    handle to spec_bg_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_bg_field as text
%        str2double(get(hObject,'String')) returns contents of spec_bg_field as a double


% --- Executes during object creation, after setting all properties.
function spec_bg_field_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_bg_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_bg_loadnprocess.
function checkbox_bg_loadnprocess_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_bg_loadnprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_bg_loadnprocess



function spec_ROI_path_Callback(hObject, eventdata, h)
% hObject    handle to spec_ROI_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_ROI_path as text
%        str2double(get(hObject,'String')) returns contents of spec_ROI_path as a double


% --- Executes during object creation, after setting all properties.
function spec_ROI_path_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_ROI_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_ROI_path.
function button_ROI_path_Callback(hObject, eventdata, h)
% hObject    handle to button_ROI_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  pathSession = uimulticollist(h.session_list,'selectedString')
  pathSession = pathSession{2};
  pathSession
  pathSearch = pathcat(pathSession,get(h.spec_ROI_path,'String'));
  [fileName, pathName] = uigetfile({'*.mat'},'Choose background data file',pathSearch);
  
  if ischar(fileName)
    if ~strcmp(pathName,pathSession)
      fileName = erase(pathcat(pathName,fileName),pathSession);
      if strcmp(fileName(1),'/') || strcmp(fileName(1),'\')
        fileName = fileName(2:end);
      end
    end
    set(h.spec_ROI_path,'String',fileName)
  end
  

function spec_ROI_field_Callback(hObject, eventdata, h)
% hObject    handle to spec_ROI_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_ROI_field as text
%        str2double(get(hObject,'String')) returns contents of spec_ROI_field as a double


% --- Executes during object creation, after setting all properties.
function spec_ROI_field_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_ROI_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_ROI_loadnprocess.
function checkbox_ROI_loadnprocess_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_ROI_loadnprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_ROI_loadnprocess



function spec_Ca_path_Callback(hObject, eventdata, h)
% hObject    handle to spec_Ca_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_Ca_path as text
%        str2double(get(hObject,'String')) returns contents of spec_Ca_path as a double


% --- Executes during object creation, after setting all properties.
function spec_Ca_path_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_Ca_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_Ca_path.
function button_Ca_path_Callback(hObject, eventdata, h)
% hObject    handle to button_Ca_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  pathSession = uimulticollist(h.session_list,'selectedString')
  pathSession = pathSession{2};
  pathSearch = pathcat(pathSession,get(h.spec_Ca_path,'String'));
  [fileName, pathName] = uigetfile({'*.mat'},'Choose Calcium data file',pathSearch);
  
  if ischar(fileName)
    if ~strcmp(pathName,pathSession)
      fileName = erase(pathcat(pathName,fileName),pathSession);
      if strcmp(fileName(1),'/') || strcmp(fileName(1),'\')
        fileName = fileName(2:end);
      end
    end
    set(h.spec_Ca_path,'String',fileName)
  end


function spec_Ca_field1_Callback(hObject, eventdata, h)
% hObject    handle to spec_Ca_field1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_Ca_field1 as text
%        str2double(get(hObject,'String')) returns contents of spec_Ca_field1 as a double


% --- Executes during object creation, after setting all properties.
function spec_Ca_field1_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_Ca_field1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_Ca_loadnprocess.
function checkbox_Ca_loadnprocess_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_Ca_loadnprocess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_Ca_loadnprocess



function spec_session_num_Callback(hObject, eventdata, h)
% hObject    handle to spec_session_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_session_num as text
%        str2double(get(hObject,'String')) returns contents of spec_session_num as a double

  

% --- Executes during object creation, after setting all properties.
function spec_session_num_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_session_num (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_remove_session.
function button_remove_session_Callback(hObject, eventdata, h)
% hObject    handle to button_remove_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  idx = get(h.session_list,'Value');
  if idx > 1
    uimulticollist(h.session_list,'delRow',idx);
  end
  if idx > uimulticollist(h.session_list,'nRows')
    set(h.session_list,'Value',uimulticollist(h.session_list,'nRows'))
  end
  
  if uimulticollist(h.session_list,'nRows') == 1
    set(h.button_add,'enable','off')
    set(h.button_bg_path,'enable','off')
    set(h.button_ROI_path,'enable','off')
    set(h.button_Ca_path,'enable','off')
    set(h.spec_bg_path,'enable','off')
    set(h.spec_ROI_path,'enable','off')
    set(h.spec_Ca_path,'enable','off')
    set(h.spec_bg_field,'enable','off')
    set(h.spec_ROI_field,'enable','off')
    set(h.spec_Ca_field1,'enable','off')
    set(h.spec_Ca_field2,'enable','off')
    set(h.checkbox_bg_loadnprocess,'enable','off')
    set(h.checkbox_ROI_loadnprocess,'enable','off')
    set(h.checkbox_Ca_loadnprocess,'enable','off')
  end
%    guidata(hObject,h)

% --- Executes on button press in button_clear_session.
function button_clear_session_Callback(hObject, eventdata, h)
% hObject    handle to button_clear_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  uimulticollist(h.session_list,'delRow',[2:uimulticollist(h.session_list,'nRows')]);
  set(h.session_list,'Value',1)
  
  set(h.button_add,'enable','off')
  set(h.button_bg_path,'enable','off')
  set(h.button_ROI_path,'enable','off')
  set(h.button_Ca_path,'enable','off')
  set(h.spec_bg_path,'enable','off')
  set(h.spec_ROI_path,'enable','off')
  set(h.spec_Ca_path,'enable','off')
  set(h.spec_bg_field,'enable','off')
  set(h.spec_ROI_field,'enable','off')
  set(h.spec_Ca_field1,'enable','off')
  set(h.spec_Ca_field2,'enable','off')
  set(h.checkbox_bg_loadnprocess,'enable','off')
  set(h.checkbox_ROI_loadnprocess,'enable','off')
  set(h.checkbox_Ca_loadnprocess,'enable','off')

% --- Executes on button press in button_up.
function button_up_Callback(hObject, eventdata, h)
% hObject    handle to button_up (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  idx = get(h.session_list,'Value');
  if idx > 2
    row_string = uimulticollist( h.session_list, 'selectedString' );
    uimulticollist ( h.session_list, 'delRow', idx)
    uimulticollist ( h.session_list, 'addRow', row_string, idx-1)
    set(h.session_list,'Value',idx-1)
  end
  
  
% --- Executes on button press in button_down.
function button_down_Callback(hObject, eventdata, h)
% hObject    handle to button_down (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  idx = get(h.session_list,'Value');
  if idx > 1 && idx < uimulticollist(h.session_list,'nRows')
    row_string = uimulticollist( h.session_list, 'selectedString' );
    uimulticollist ( h.session_list, 'delRow', idx)
    uimulticollist ( h.session_list, 'addRow', row_string, idx+1)
    set(h.session_list,'Value',idx+1)
  end
  



function spec_Ca_field2_Callback(hObject, eventdata, h)
% hObject    handle to spec_Ca_field2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_Ca_field2 as text
%        str2double(get(hObject,'String')) returns contents of spec_Ca_field2 as a double


% --- Executes during object creation, after setting all properties.
function spec_Ca_field2_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_Ca_field2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
