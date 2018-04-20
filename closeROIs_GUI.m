function varargout = closeROIs_GUI(varargin)
% CLOSEROIS_GUI MATLAB code for closeROIs_GUI.fig
%      CLOSEROIS_GUI, by itself, creates a new CLOSEROIS_GUI or raises the existing
%      singleton*.
%
%      H = CLOSEROIS_GUI returns the handle to a new CLOSEROIS_GUI or the handle to
%      the existing singleton*.
%
%      CLOSEROIS_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CLOSEROIS_GUI.M with the given input arguments.
%
%      CLOSEROIS_GUI('Property','Value',...) creates a new CLOSEROIS_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before closeROIs_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to closeROIs_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help closeROIs_GUI

% Last Modified by GUIDE v2.5 27-Jan-2018 14:57:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @closeROIs_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @closeROIs_GUI_OutputFcn, ...
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


% --- Executes just before closeROIs_GUI is made visible.
function closeROIs_GUI_OpeningFcn(hObject, eventdata, h, CNMF, parameter, pltDat, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to closeROIs_GUI (see VARARGIN)
  
  
  %% set up handles
  
  %% imaging data
  data = struct;
  data.A = CNMF.A;		%% should this be reshaped to 512x512 array?
  data.centroid = CNMF.centroid;
  data.dist = CNMF.dist;
  data.fp_corr = CNMF.fp_corr;
  setappdata(0,'data',data);
  
  ImData = struct;
  ImData.im = CNMF.im;
  ImData.imRef = CNMF.imRef;
  setappdata(0,'ImData',ImData);
  
  CaData = struct;
  CaData.traces = CNMF.C2;
  
  setappdata(0,'CaData',CaData);
  
  h.path = struct;
  h.path.session = CNMF.pathSession;
  h.path.im = CNMF.pathIm;
  h.path.imRef = CNMF.pathImRef;
  
  set(h.load_im_spec,'String',h.path.im);
  set(h.load_imRef_spec,'String',h.path.imRef);
  
  h.video = struct;
  h.video.path = pathcat(h.path.session,'sample_video.avi');
  
  set(h.rec_video_path_spec,'String',h.video.path);
  
  h.data.nROI = size(CNMF.A,2);
  h.data.t_max = size(CaData.traces,2);
  h.data.time = linspace(0,h.data.t_max/15,h.data.t_max);
  
  %% plot parameter (needed? should mostly be determined by user input from GUI)
  h.parameter = parameter;
  
  set(h.t_max_spec,'String',h.data.t_max/h.parameter.frq);
  
  %% initialize status of GUI / playback
  h.status = struct;
  h.status.play = false;
  h.status.record = false;
  h.status.t = 0;
  
  %% set up data to plot here
%    pltData = struct;	%% gets values after 'Get it!' is pushed
  
  h.axes = struct;
%    h.axes.Ca_slide = {};
%    h.axes.Ca_static = {};
%    h.axes.p = {};
  
    
  % Choose default command line output for closeROIs_GUI
  h.output = hObject;

  % Update h structure
  guidata(hObject, h);

% UIWAIT makes closeROIs_GUI wait for user response (see UIRESUME)
% uiwait(h.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = closeROIs_GUI_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = h.output;





% --- Executes on button press in play_pause_button.
function play_pause_button_Callback(hObject, eventdata, h)
% hObject    handle to play_pause_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if h.status.play
  
  h = pause_it(h);
  guidata(hObject,h);
  
else
  
  %% disable all kind of stuff during playback
  if h.status.record
    set(h.play_pause_button,'String','Pause (recording)')
  else
    set(h.play_pause_button,'String','Pause')
  end
  set(h.time_spec,'enable','off')
  set(h.t_max_spec,'enable','off')
  set(h.replay_spd_spec,'enable','off')
  set(h.rec_video_check,'enable','off')
  set(h.rec_video_frq_spec,'enable','off')
  set(h.rec_video_path_spec,'enable','off');
  set(h.rec_video_path_button,'enable','off');
  
  set(h.noise_skp_spec,'enable','off')
  set(h.noise_vsc_spec,'enable','off')
  set(h.noise_nsd_spec,'enable','off')
  
  set(h.ROI_ID_spec,'enable','off')
  set(h.ROI_num_spec,'enable','off')
  set(h.ROI_radius_spec,'enable','off')
  set(h.ROI_update_button,'enable','off')
  set(h.ROI_get_ID_from_GUI_button,'enable','off')
  
  set(h.ax_Ca_static,'ButtonDownFcn',[]);
  set(h.ax_Ca_slide,'ButtonDownFcn',[]);
  
  
  %% update values before playback
  h.status.play = true;	%% update last, to switch between play/pause function
  h.parameter.replay_spd = ceil(str2double(get(h.replay_spd_spec,'String')));
  h.status.record = get(h.rec_video_check,'Value');
  
  [t, t_max] = get_time(h);
  
  if h.status.record
    %% should at suffix, containing ROI_ID, time, frequency, what else?
    disp(fprintf('creating video @ %s',h.video.path))
    disp('here, should check, whether file already exists and if so, pop up warning message and stop execution!')
    h.video.obj = VideoWriter(h.video.path);
    h.video.obj.FrameRate = str2double(get(h.rec_video_frq_spec,'String'));
    h.video.obj.Quality = 90;
    hFig = findall(0,'Name','closeROIs_GUI');
    open(h.video.obj);
  end
  guidata(hObject,h);
  
  pltData = getappdata(0,'pltData');
  
  pause_time = 0.8*1/h.parameter.frq; 	%% estimated to give ~ real time when played
  pause_time = pause_time * 1/h.parameter.replay_spd;
  %%%% need to account for speed in video as well - how about adapting recording frequency?
  
  while t <= t_max && h.status.play  
    
    %% get current times
    t_now = t/h.parameter.frq;
    set(h.time_spec,'String',sprintf('%4.2f',t_now));
    
    %% update background images and Ca traces
%      update_background(h,t);			%%%% add stuff here
    h.hImRef.CData = pltData.imRef(:,:,t);
    h.hIm.CData = pltData.im(:,:,t);
    update_Ca_slide(h,t);
    drawnow limitrate
    h = guidata(hObject);
    
    if h.status.record && h.status.play		%% save as video
      frame = getframe(hFig);
      writeVideo(h.video.obj,frame);
    else
      pause(pause_time)
    end
    
%      if pltData.time_active(t)
%        t = t+h.parameter.replay_spd;
%      else
      t = t+1+h.parameter.noise_skp;	%% here, check for noise_skp
%      end
    
  end
  
  h = pause_it(h);
  
  guidata(hObject,h);
end


function ROI_ID_spec_Callback(hObject, eventdata, h)
% hObject    handle to ROI_ID_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_ID_spec as text
%        str2double(get(hObject,'String')) returns contents of ROI_ID_spec as a double


% --- Executes during object creation, after setting all properties.
function ROI_ID_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to ROI_ID_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function time_spec_Callback(hObject, eventdata, h)
% hObject    handle to time_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of time_spec as text
%        str2double(get(hObject,'String')) returns contents of time_spec as a double
  t = get_time(h);
  update_background(h,t);
  update_Ca_slide(h,t);
  drawnow
  guidata(hObject,h);

% --- Executes during object creation, after setting all properties.
function time_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to time_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_num_spec_Callback(hObject, eventdata, h)
% hObject    handle to ROI_num_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_num_spec as text
%        str2double(get(hObject,'String')) returns contents of ROI_num_spec as a double


% --- Executes during object creation, after setting all properties.
function ROI_num_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to ROI_num_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function replay_spd_spec_Callback(hObject, eventdata, h)
% hObject    handle to replay_spd_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of replay_spd_spec as text
%        str2double(get(hObject,'String')) returns contents of replay_spd_spec as a double


% --- Executes during object creation, after setting all properties.
function replay_spd_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to replay_spd_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function noise_skp_spec_Callback(hObject, eventdata, h)
% hObject    handle to noise_skp_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_skp_spec as text
%        str2double(get(hObject,'String')) returns contents of noise_skp_spec as a double

  h = update_noise(h);
  guidata(hObject,h);
  

% --- Executes during object creation, after setting all properties.
function noise_skp_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to noise_skp_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rec_video_check.
function rec_video_check_Callback(hObject, eventdata, h)
% hObject    handle to rec_video_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rec_video_check
  
  if get(h.rec_video_check,'Value') == 1
    set(h.rec_video_frq_spec,'enable','on')
    set(h.rec_video_path_button,'enable','on')
    set(h.rec_video_path_spec,'enable','on')
  else
    set(h.rec_video_frq_spec,'enable','off')
    set(h.rec_video_path_button,'enable','off')
    set(h.rec_video_path_spec,'enable','off')
  end


function edit8_Callback(hObject, eventdata, h)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, h)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ROI_update_button.
function ROI_update_button_Callback(hObject, eventdata, h)
% hObject    handle to ROI_update_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% get input variables
ROI_ID = ceil(str2double(get(h.ROI_ID_spec,'String')));
nR = ceil(str2double(get(h.ROI_num_spec,'String')));
border = str2double(get(h.ROI_radius_spec,'String'));		%% could further be used to plot measure on side?!
h.status.ROI_input = 0;

max_nR = 5;

%% health-check on input values

%%% first, check for each input field, if proper value is provided - else error window and back to start

errorMsg = 'Please provide a numeric, positive...';

%% check ROI ID
if isnan(ROI_ID) || isempty(ROI_ID) || ROI_ID <= 0 || ROI_ID > h.data.nROI
  errorMsg = strcat(errorMsg,sprintf('\n ... ROI ID < %d',h.data.nROI));
else
  h.status.ROI_input = h.status.ROI_input + 1;
end

%% check nR / ROI_num
if isnan(nR) || isempty(nR) || nR < 1 || nR > max_nR
  errorMsg = strcat(errorMsg,sprintf('\n ... ROI number to be displayed (<%d)',max_nR));
else
  h.status.ROI_input = h.status.ROI_input + 1;
end

%% check area
if isnan(border) || isempty(border) || border < 1 || (2*border+1) > 512	%% image size shouldn't be hardcoded, rather from structure
  errorMsg = strcat(errorMsg,sprintf('\n ... diameter of the ROI radius to be displayed'));
else
  h.status.ROI_input = h.status.ROI_input + 1;
end


if h.status.ROI_input == 3
  
  set(h.ROI_update_button,'String','processing...')
  set(h.ROI_update_button,'enable','off')
  
  %% remove data from earlier iterations
  if isfield(h.axes,'Ca_slide')
    for i=1:length(h.axes.Ca_slide)
      delete(h.axes.Ca_slide{i})
    end
    h.axes.Ca_slide = {};
  end
  
  if isfield(h.axes,'Ca_static')
    for i=1:length(h.axes.Ca_static)
      delete(h.axes.Ca_static{i})
    end
    h.axes.Ca_static = {};
  end
  
  if isfield(h.axes,'p')
    delete(h.axes.p)
  end
  
  if isfield(h.axes,'noise')
    delete(h.axes.noise)
  end
  
  %%% set up imaging window data
  pltData = struct;
  %% find nearby ROIs
  data = getappdata(0,'data');
  ROI_list = find(data.dist(ROI_ID,:)<border);
  ROI_list = vertcat(ROI_list,data.dist(ROI_ID,ROI_list))';
  pltData.ROI_list = sortrows(ROI_list,2,'ascend');
  clear ROI_list;
  pltData.nR = min(nR,size(pltData.ROI_list,1));
  
  
  %% get area to display
  pltData.window = struct;
  pltData.window.min_x = max(1,ceil(data.centroid(ROI_ID,2))-border);
  pltData.window.max_x = min(512,ceil(data.centroid(ROI_ID,2))+border);
  pltData.window.min_y = max(1,ceil(data.centroid(ROI_ID,1))-border);
  pltData.window.max_y = min(512,ceil(data.centroid(ROI_ID,1))+border);
  
  pltData.window.offset = [pltData.window.min_y,pltData.window.max_y;pltData.window.min_x,pltData.window.max_x];
  
  
  %% get image parts to display
  ImData = getappdata(0,'ImData');
  pltData.imRef = ImData.imRef(pltData.window.min_y:pltData.window.max_y,pltData.window.min_x:pltData.window.max_x,:);
  pltData.im = ImData.im(pltData.window.min_y:pltData.window.max_y,pltData.window.min_x:pltData.window.max_x,:);
  
  
  %% setting up ROI data
  pltData.A = zeros(pltData.window.max_y-pltData.window.min_y+1,pltData.window.max_x-pltData.window.min_x+1,size(pltData.ROI_list,1));
  for i=1:size(pltData.ROI_list,1)
    A_tmp = reshape(data.A(:,pltData.ROI_list(i)),512,512);
    pltData.A(:,:,i) = A_tmp(pltData.window.min_y:pltData.window.max_y,pltData.window.min_x:pltData.window.max_x)/max(A_tmp(:));
  end
  
  %% setting up plotting options
  pltData.ROI_color = {'r','g','b','m','c'};	%% should be adaptable for more than 5 ROIs - which colors?
  pltData.ROI_line = {};
  [pltData.ROI_line{1:pltData.nR}] = deal('-');
  
  for i=pltData.nR+1:size(pltData.ROI_list,1)
    pltData.ROI_color{i} = 'y';
    pltData.ROI_line{i} = '--';
  end
  setappdata(0,'pltData',pltData);
  
  
  %% plot initial state
  [t, t_max] = get_time(h);
  
  %% reference and filtered image
  axes(h.ax_imRef)
  h.hImRef = imshow(pltData.imRef(:,:,t));%,'Border','tight','InitialMagnification','fit');
  hold on
  for i=1:size(pltData.ROI_list,1)
    contour(pltData.A(:,:,i),[h.parameter.ROI_thr h.parameter.ROI_thr],'LineColor',pltData.ROI_color{i},'LineStyle',pltData.ROI_line{i})
  end
  hold off
%    plot_blobs(h);
  
  axes(h.ax_im)
  h.hIm = imshow(pltData.im(:,:,t));
  hold on
  for i=1:size(pltData.ROI_list,1)
    contour(h.ax_im,pltData.A(:,:,i),[h.parameter.ROI_thr h.parameter.ROI_thr],'LineColor',pltData.ROI_color{i},'LineStyle',pltData.ROI_line{i});
  end
  hold off
%    plot_blobs(h);
  
  %% might choose, what to plot here from drop-down menu
  
  %% put those into functions as well, to allow changes in drop-down menu
  %% plot static Ca-traces
  axes(h.ax_Ca_static)
  CaData = getappdata(0,'CaData');
  hold on
  for i=1:size(pltData.ROI_list,1)
    Ca_offset = (i-1)*h.parameter.max_val_y;
    h.axes.Ca_static{i} = plot(h.data.time, Ca_offset + CaData.traces(pltData.ROI_list(i,1),1:h.data.t_max),'Color',pltData.ROI_color{i});
  end
  hold off
  xlim([0,h.data.t_max/h.parameter.frq])
  ylim([0,size(pltData.ROI_list,1)*h.parameter.max_val_y])
  yticks([])
  xlabel('time in s')
  
  
  %% creating the possibility to interact with it to specify a time
  set(h.ax_Ca_static,'ButtonDownFcn',@set_time_from_Ca,'Hittest','on','PickableParts','All');
  
  
  %% plot moving Ca-traces
  axes(h.ax_Ca_slide)
  hold on
  for i=1:pltData.nR
    h.axes.Ca_slide{i} = plot(h.data.time,CaData.traces(pltData.ROI_list(i),1:h.data.t_max),'Color',pltData.ROI_color{i},'DisplayName',sprintf('ROI # %d',pltData.ROI_list(i,1)));
  end
  
  
  h = update_noise(h);
  
  h.axes.p = patch('Faces',[1,2,3,4],'Vertices',[0 0; 0 h.parameter.max_val_y; 1 h.parameter.max_val_y; 1 0],'FaceColor','k','FaceAlpha',0.5,'EdgeColor','none');
  set(get(get(h.axes.p,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  hold off
  ylim([0,h.parameter.max_val_y*1.2])
  legend('show')
  
  update_Ca_slide(h,t)
  
  %% creating the possibility to interact with it to specify a time
  set(h.ax_Ca_slide,'ButtonDownFcn',@set_time_from_Ca,'Hittest','on','PickableParts','All');
  
  

  %% after everything is checked and done, activate play-panel
  
  guidata(hObject,h);
  
  set(h.time_spec,'enable','on')
  set(h.t_max_spec,'enable','on')
  set(h.replay_spd_spec,'enable','on')
  set(h.rec_video_check,'enable','on')
  if get(h.rec_video_check,'Value') == 1
    set(h.rec_video_frq_spec,'enable','on')
    set(h.rec_video_path_spec,'enable','on')
    set(h.rec_video_path_button,'enable','on')
  end
  
  set(h.noise_skp_spec,'enable','on')
  set(h.noise_vsc_spec,'enable','on')
  set(h.noise_nsd_spec,'enable','on')
  
  set(h.play_pause_button,'enable','on')
  set(h.play_pause_button,'String','Play')
  
  set(h.ROI_update_button,'String','Update ROIs')
  set(h.ROI_update_button,'enable','on')
else
  %% how-to: pop-up window with error message?
  uiwait(msgbox(errorMsg));	%% could add a nice picture here
end






function rec_video_frq_spec_Callback(hObject, eventdata, h)
% hObject    handle to rec_video_frq_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rec_video_frq_spec as text
%        str2double(get(hObject,'String')) returns contents of rec_video_frq_spec as a double


% --- Executes during object creation, after setting all properties.
function rec_video_frq_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to rec_video_frq_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_radius_spec_Callback(hObject, eventdata, h)
% hObject    handle to ROI_radius_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROI_radius_spec as text
%        str2double(get(hObject,'String')) returns contents of ROI_radius_spec as a double


% --- Executes during object creation, after setting all properties.
function ROI_radius_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to ROI_radius_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rec_video_path_spec_Callback(hObject, eventdata, h)
% hObject    handle to rec_video_path_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of rec_video_path_spec as text
%        str2double(get(hObject,'String')) returns contents of rec_video_path_spec as a double

  h.video.path = get(h.rec_video_path_spec,'String');
  guidata(hObject,h);

  
% --- Executes during object creation, after setting all properties.
function rec_video_path_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to rec_video_path_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rec_video_path_button.
function rec_video_path_button_Callback(hObject, eventdata, h)
% hObject    handle to rec_video_path_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  [fileName, pathName] = uiputfile({'*.avi'},'Save video as',get(h.rec_video_path_spec,'String'));
  h.video.path = pathcat(pathName,fileName);
  set(h.rec_video_path_spec,'String',h.video.path)
  guidata(hObject,h);




%%% helper functions
function [t_now, t_max] = get_time(h)
  t_now = max(1,ceil(str2double(get(h.time_spec,'String'))*h.parameter.frq));
  t_max = ceil(str2double(get(h.t_max_spec,'String'))*h.parameter.frq);
  


%%% helper functions for plotting


%% updates should be checking for change in time and change in ROIs and change accordingly
%  function update_background(h,t)
%    
%    h.hImRef.CData = h.pltData.imRef(:,:,t);
%    h.hIm.CData = h.pltData.im(:,:,t);
%    

function update_Ca_slide(h,t)
  
  t_now = t/h.parameter.frq;
  start_t = max(1,t-h.parameter.tw_offset);
  end_t = min(8989,start_t + h.parameter.tw_l-1);
    
  set(h.axes.p,'Vertices',[t_now 0; t_now h.parameter.max_val_y; t_now+1 h.parameter.max_val_y; t_now+1 0])
  xlim(h.ax_Ca_slide,[start_t/h.parameter.frq,end_t/h.parameter.frq])

  

function plot_blobs(h)
    
  data = getappdata(0,'data');
  pltData = getappdata(0,'pltData');
  
  hold on
  %% plot ROIs
  for i=1:size(pltData.ROI_list,1)
    A_tmp = full(reshape(data.A(:,pltData.ROI_list(i)),512,512));
    pltData.blob{i} = prep_blob(A_tmp,h.parameter.ROI_thr,pltData.window.offset,pltData.line{i},pltData.col{i});
%      if i<=h.pltData.nR
%        plot_blob(h.pltData.blob{i},'-',h.pltData.col{i});
%      else
%        plot_blob(h.pltData.blob{i},'--',h.pltData.col{i});
%      end
  end
  hold off
  setappdata(0,'pltData',pltData);
  

  
function [blob] = prep_blob(A,thr,offset,line,col)
  
%    offset(1,2)-offset(1,1)
  
  if isempty(offset)
    A = medfilt2(A,[3,3]);
  else
    A = medfilt2(A(offset(1,1):offset(1,2),offset(2,1):offset(2,2)),[3,3]);	%% this should be chosen 1 larger, to distinguish between border and over-the-border values
  end
  A(A<thr*max(A(:))) = 0;
  BW = bwareafilt(A>0,1);
  blob = bwboundaries(BW);
  if ~isempty(blob)
    for ii = 1:length(blob)
      blob{ii} = fliplr(blob{ii});
      plot(blob{ii}(:,1),blob{ii}(:,2),line,'Color',col,'linewidth', 0.5);
    end
  end

  
%  function plot_blob(blob,line,col)
%    if ~isempty(blob)
%      for ii = 1:length(blob)
	
%      end
%    end



function load_imRef_spec_Callback(hObject, eventdata, h)
% hObject    handle to load_imRef_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of load_imRef_spec as text
%        str2double(get(hObject,'String')) returns contents of load_imRef_spec as a double


% --- Executes during object creation, after setting all properties.
function load_imRef_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to load_imRef_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function load_im_spec_Callback(hObject, eventdata, h)
% hObject    handle to load_im_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of load_im_spec as text
%        str2double(get(hObject,'String')) returns contents of load_im_spec as a double


% --- Executes during object creation, after setting all properties.
function load_im_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to load_im_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in load_imRef_button.
function load_imRef_button_Callback(hObject, eventdata, h)
% hObject    handle to load_imRef_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in load_im_button.
function load_im_button_Callback(hObject, eventdata, h)
% hObject    handle to load_im_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function noise_nsd_spec_Callback(hObject, eventdata, h)
% hObject    handle to noise_nsd_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_nsd_spec as text
%        str2double(get(hObject,'String')) returns contents of noise_nsd_spec as a double
  
  h = update_noise(h);
  guidata(hObject,h);
  
  
  

% --- Executes during object creation, after setting all properties.
function noise_nsd_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to noise_nsd_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [h] = update_noise(h)
  
  pltData = getappdata(0,'pltData');
  CaData = getappdata(0,'CaData');
  
  %% get noise level (for noise-skipping)
  pltData.noise_level = zeros(pltData.nR,1);
  for i=1:pltData.nR
    pltData.noise_level(i) = std(CaData.traces(pltData.ROI_list(i,1),:));
  end
  
  noise_nsd = str2double(get(h.noise_nsd_spec,'String'));
  noise_vsc = str2double(get(h.noise_vsc_spec,'String'));
  h.parameter.noise_skp = str2double(get(h.noise_skp_spec,'String'));
  activity_thr = noise_nsd*mean(pltData.noise_level);
  
  pltData.time_active = zeros(size(h.data.time));
  
  if h.parameter.noise_skp > 0
    for i=1:pltData.nR
      pltData.time_active(CaData.traces(pltData.ROI_list(i),:) > activity_thr) = 1;
    end
    frames_active = 5;
    pltData.time_active = imerode(pltData.time_active,ones(1,frames_active*2+1));			%% removing times of "arbitrary activity"
    
    dilate_offset = frames_active+h.parameter.frq*noise_vsc;
    pltData.time_active = imdilate(pltData.time_active,ones(1,dilate_offset*2+1));		%% skipping if active area is more than 1 sec away
  end
  
  setappdata(0,'pltData',pltData);
  
  if isfield(h.axes,'noise')
    delete(h.axes.noise)
  end
  
  hold on
  h.axes.noise = plot([0,h.data.t_max],[activity_thr activity_thr],'--k','DisplayName',sprintf('%3.1fx noise level',noise_nsd));
  hold off
  
  
  
function set_time_from_Ca(hObject,eventdata)

  h = guidata(hObject);
  
  coords = get(hObject,'CurrentPoint');
  t_new = coords(1,1);
  
  set(h.time_spec,'String',sprintf('%4.2f',t_new))
  t_frame = ceil(t_new*h.parameter.frq);
  
  pltData = getappdata(0,'pltData');
  h.hImRef.CData = pltData.imRef(:,:,t_frame);
  h.hIm.CData = pltData.im(:,:,t_frame);
  update_Ca_slide(h,t_frame);
  drawnow

  
function [h] = pause_it(h)
  %% save video creation, if one was going on
  if h.status.record
    close(h.video.obj)
  end
  
  set(h.play_pause_button,'String','Play')
  set(h.time_spec,'enable','on')
  set(h.t_max_spec,'enable','on')
  set(h.replay_spd_spec,'enable','on')
  set(h.rec_video_check,'enable','on')
  if get(h.rec_video_check,'Value') == 1
    set(h.rec_video_frq_spec,'enable','on')
    set(h.rec_video_path_spec,'enable','on');
    set(h.rec_video_path_button,'enable','on');
  end
  set(h.noise_skp_spec,'enable','on')
  set(h.noise_vsc_spec,'enable','on')
  set(h.noise_nsd_spec,'enable','on')
  
  set(h.ROI_ID_spec,'enable','on')
  set(h.ROI_num_spec,'enable','on')
  set(h.ROI_radius_spec,'enable','on')
  set(h.ROI_update_button,'enable','on')
  set(h.ROI_get_ID_from_GUI_button,'enable','on')
  
  set(h.ax_Ca_static,'ButtonDownFcn',@set_time_from_Ca);
  set(h.ax_Ca_slide,'ButtonDownFcn',@set_time_from_Ca);
  
  h.status.play = false;
  
  

% --------------------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, h)
% hObject    handle to Untitled_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function noise_vsc_spec_Callback(hObject, eventdata, h)
% hObject    handle to noise_vsc_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_vsc_spec as text
%        str2double(get(hObject,'String')) returns contents of noise_vsc_spec as a double
  
  h = update_noise(h);
  guidata(hObject,h);
  

% --- Executes during object creation, after setting all properties.
function noise_vsc_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to noise_vsc_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function t_max_spec_Callback(hObject, eventdata, h)
% hObject    handle to t_max_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of t_max_spec as text
%        str2double(get(hObject,'String')) returns contents of t_max_spec as a double
  
  [t_now, t_max] = get_time(h);
  
  if t_max < t_now
    set(h.t_max_spec,'String',sprintf('%4.2f',(t_now+1)/h.parameter.frq))
    t_max = t_now;
  elseif t_max < 1
    set(h.t_max_spec,'String',sprintf('%4.2f',1/h.parameter.frq))
    t_max = 1;
  elseif t_max > h.data.t_max
    set(h.t_max_spec,'String',sprintf('%4.2f',h.data.t_max/h.parameter.frq))
    t_max = h.data.t_max;
  end
      
  
  
% --- Executes during object creation, after setting all properties.
function t_max_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to t_max_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ROI_get_ID_from_GUI_button.
function ROI_get_ID_from_GUI_button_Callback(hObject, eventdata, h)
% hObject    handle to ROI_get_ID_from_GUI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
