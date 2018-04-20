function varargout = choose_dimensions(varargin)
% CHOOSE_DIMENSIONS MATLAB code for choose_dimensions.fig
%      CHOOSE_DIMENSIONS, by itself, creates a new CHOOSE_DIMENSIONS or raises the existing
%      singleton*.
%
%      H = CHOOSE_DIMENSIONS returns the handle to a new CHOOSE_DIMENSIONS or the handle to
%      the existing singleton*.
%
%      CHOOSE_DIMENSIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CHOOSE_DIMENSIONS.M with the given input arguments.
%
%      CHOOSE_DIMENSIONS('Property','Value',...) creates a new CHOOSE_DIMENSIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before choose_dimensions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to choose_dimensions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help choose_dimensions

% Last Modified by GUIDE v2.5 30-Jan-2018 18:00:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @choose_dimensions_OpeningFcn, ...
                   'gui_OutputFcn',  @choose_dimensions_OutputFcn, ...
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


% --- Executes just before choose_dimensions is made visible.
function choose_dimensions_OpeningFcn(hObject, eventdata, h, data_size, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to choose_dimensions (see VARARGIN)

  %% transform data_size into strings
  h.d = numel(data_size);
  h.drop_down_string = cellstr(['']);
  
  %% reassign handles
  h.dim_spec(1) = h.dim_1_spec;
  h.dim_spec(2) = h.dim_2_spec;
  h.dim_spec(3) = h.dim_3_spec;
  
  for i=1:h.d
    h.drop_down_string{i} = sprintf('%d (%d)',data_size(i),i);
  end
  
%    h.drop_down_string = cellstr(h.drop_down_string);
  set(h.dim_spec(1),'String',h.drop_down_string,'Value',1)
  set(h.dim_spec(2),'String',h.drop_down_string,'Value',2)
  
  if h.d<3
    set(h.dim_3_spec,'visible','off')
    set(h.dim_3_text,'visible','off')
  else
    set(h.dim_spec(3),'String',h.drop_down_string,'Value',3)
  end


% Choose default command line output for choose_dimensions
h.output = 1:h.d;

% Update handles structure
guidata(hObject, h);

% UIWAIT makes choose_dimensions wait for user response (see UIRESUME)
uiwait(h.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = choose_dimensions_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = h.output;

delete(hObject);


% --- Executes on selection change in dim_1_spec.
function dim_1_spec_Callback(hObject, eventdata, h)
% hObject    handle to dim_1_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dim_1_spec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dim_1_spec
        

% --- Executes during object creation, after setting all properties.
function dim_1_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to dim_1_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dim_2_spec.
function dim_2_spec_Callback(hObject, eventdata, h)
% hObject    handle to dim_2_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dim_2_spec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dim_2_spec


% --- Executes during object creation, after setting all properties.
function dim_2_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to dim_2_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dim_3_spec.
function dim_3_spec_Callback(hObject, eventdata, h)
% hObject    handle to dim_3_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dim_3_spec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dim_3_spec


% --- Executes during object creation, after setting all properties.
function dim_3_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to dim_3_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, h)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in OK_button.
function OK_button_Callback(hObject, eventdata, h)
% hObject    handle to OK_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  for i=1:h.d
    dim(i) = get(h.dim_spec(i),'Value');
  end
  
  if length(unique(dim)) == h.d
    h.output = dim;
    guidata(hObject,h);
    close()
  else
    msgbox('Not all dimensions were assigned')
  end


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


% --- Executes on button press in cancel_button.
function cancel_button_Callback(hObject, eventdata, handles)
% hObject    handle to cancel_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  h.output = 0;
  close()