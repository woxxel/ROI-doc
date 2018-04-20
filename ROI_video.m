function varargout = ROI_video(varargin)
% ROI_VIDEO MATLAB code for ROI_video.fig
%      ROI_VIDEO, by itself, creates a new ROI_VIDEO or raises the existing
%      singleton*.
%
%      H = ROI_VIDEO returns the handle to a new ROI_VIDEO or the handle to
%      the existing singleton*.
%
%      ROI_VIDEO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_VIDEO.M with the given input arguments.
%
%      ROI_VIDEO('Property','Value',...) creates a new ROI_VIDEO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_video_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_video_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_video

% Last Modified by GUIDE v2.5 10-Feb-2018 23:34:24

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_video_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_video_OutputFcn, ...
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


% --- Executes just before ROI_video is made visible.
function ROI_video_OpeningFcn(hObject, eventdata, h, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_video (see VARARGIN)
  
  
  %% getting ROI data to plot
  input = getappdata(0,'handover');
  rmappdata(0,'handover')
  
  disp('Im in! lets do some movies!')
  
  set(h.spec_path_imRef,'String',input.pathSession)
  set(h.spec_path_im,'String',input.pathSession)
  
%    set(h.spec_path_imRef,'String','/media/wollex/Data/Documents/Uni/2016-XXXX_PhD/Japan/Work/Data/Session01/imageStack/ImagingData_MF1_LK1.h5')
%    set(h.spec_path_im,'String','/media/wollex/Data/Documents/Uni/2016-XXXX_PhD/Japan/Work/Data/Session01/imageStack/ImagingData_MF1_LK1.h5')
  
  %% initialize video struct
  h.video = struct('path',[]);
  h.video.path = pathcat(input.pathSession,'sample_video.avi');
  
  set(h.rec_video_path_spec,'String',h.video.path);
  
  
  %% initialize status of GUI / playback
  h.status = struct;
  h.status.play = false;
  h.status.record = false;
  h.status.dual = false;
  h.status.t = 0;
  
  h.parameter = input.parameter;
  
  h.parameter.nR_max = 5;		  %% maximum number of ROIs to be analyzed
  
  h.parameter.tw_l = 20*h.parameter.frq;		%% number of frames to be displayed in Ca-window
  h.parameter.tw_offset = 3*h.parameter.frq;	%% number of past frames to be displayed in Ca window
  h.parameter.max_val_y = 2*10^5;	            %% maximum value of y-axis in Ca window
  
  h.parameter.Ca_thr = 2;		     %% number of standard deviations to detect "activity" 
  h.parameter.noise_skp_stp = 0;	 %% frames which are skipped during noise-only activity
  
  %% set up data to plot here
  pltData = struct;	%% gets values after 'Get it!' is pushed
  pltData.ROI_idx = input.ROI_idx;
  pltData.time = linspace(0,h.parameter.t_max/h.parameter.frq,h.parameter.t_max);
  setappdata(0,'pltData',pltData)
  
  set(h.t_max_spec,'String',h.parameter.t_max/h.parameter.frq);
  set(h.rec_video_check,'enable','on')
  
  h.plots = struct;
  
%    h = update_plt_window(h);
    
  % Choose default command line output for ROI_video
  h.output = hObject;

  % Update h structure
  guidata(hObject, h);

% UIWAIT makes ROI_video wait for user response (see UIRESUME)
% uiwait(h.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_video_OutputFcn(hObject, eventdata, h) 
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
  set(h.spec_window_size,'enable','off')
  set(h.button_ROI_update,'enable','off')
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
    hFig = findall(0,'Tag','ROIVideoMaker');
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
    for w=1:2
      h.plots.window(w).bg.CData = pltData.window(w).im(:,:,t);
    end
    update_Ca_slide(h,t);
%      drawnow limitrate
    drawnow
    h = guidata(hObject);
    
    if h.status.record && h.status.play		%% save as video
      frame = getframe(hFig);
      writeVideo(h.video.obj,frame);
    else
%        pause(pause_time)
    end
    
    if pltData.time_active(t)
%        disp('')
      t = t+1;%h.parameter.replay_spd;
    else
      t = t+1+h.parameter.noise_skp;	%% here, check for noise_skp
    end
    
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
  t
  pltData = getappdata(0,'pltData');
  for w=1:2
    h.plots.window(w).bg.CData = pltData.window(w).im(:,:,t);
  end
  
%    h.plots.window(1).bg = imshow(pltData.window(1).im(:,:,t)
%    h.plots.hImRef.CData = pltData.imRef(:,:,t);
%    h.hIm.CData = pltData.im(:,:,t);

%    update_background(h,t);
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

  h = update_noise(h,h.ax_Ca_slide);
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


% --- Executes on button press in button_ROI_update.
function button_ROI_update_Callback(hObject, eventdata, h)
% hObject    handle to button_ROI_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


  h = update_plt_window(h);
  guidata(hObject,h);



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



function spec_window_size_Callback(hObject, eventdata, h)
% hObject    handle to spec_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_window_size as text
%        str2double(get(hObject,'String')) returns contents of spec_window_size as a double


% --- Executes during object creation, after setting all properties.
function spec_window_size_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_window_size (see GCBO)
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
%    h.hImRef.CData = pltData.imRef(:,:,t);
%    h.hIm.CData = pltData.im(:,:,t);
%    

function update_Ca_slide(h,t)
  
  t_now = t/h.parameter.frq;
  start_t = max(1,t-h.parameter.tw_offset);
  end_t = min(8989,start_t + h.parameter.tw_l-1);
  
  set(h.plots.p_static,'Vertices',[t_now 0; t_now h.parameter.max_val_y; t_now+1 h.parameter.max_val_y; t_now+1 0])
  
  set(h.plots.p_slide,'Vertices',[t_now 0; t_now h.parameter.max_val_y; t_now+1 h.parameter.max_val_y; t_now+1 0])
  xlim(h.ax_Ca_slide,[start_t/h.parameter.frq,end_t/h.parameter.frq])

  

%  function plot_blobs(h,A,offset)
%      
%    data = getappdata(0,'data');
%    pltData = getappdata(0,'pltData');
%    
%    hold on
%    %% plot ROIs
%    for i=1:size(pltData.ROI_list,1)
%      A_tmp = full(reshape(data.A(:,pltData.ROI_list(i)),512,512));
%      pltData.blob{i} = prep_blob(A_tmp,h.parameter.ROI_thr,pltData.window.offset,pltData.line{i},pltData.col{i});
%  %      if i<=h.pltData.nR
%  %        plot_blob(h.pltData.blob{i},'-',h.pltData.col{i});
%  %      else
%  %        plot_blob(h.pltData.blob{i},'--',h.pltData.col{i});
%  %      end
%    end
%    hold off
%    setappdata(0,'pltData',pltData);
%  %    
%  %  
%    
%  function [blob] = prep_blob(A,thr,offset,line,col)
%    
%  %    offset(1,2)-offset(1,1)
%    
%    if isempty(offset)
%      A = medfilt2(A,[3,3]);
%    else
%      A = medfilt2(A(offset(1,1):offset(1,2),offset(2,1):offset(2,2)),[3,3]);	%% this should be chosen 1 larger, to distinguish between border and over-the-border values
%    end
%    A(A<thr*max(A(:))) = 0;
%    BW = bwareafilt(A>0,1);
%    blob = bwboundaries(BW);
%    if ~isempty(blob)
%      for ii = 1:length(blob)
%        blob{ii} = fliplr(blob{ii});
%        plot(blob{ii}(:,1),blob{ii}(:,2),line,'Color',col,'linewidth', 0.5);
%      end
%    end




function spec_path_imRef_Callback(hObject, eventdata, h)
% hObject    handle to spec_path_imRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_path_imRef as text
%        str2double(get(hObject,'String')) returns contents of spec_path_imRef as a double


  set(h.spec_path_im,'String',pathcat(pathName,fileName))
  
  
% --- Executes during object creation, after setting all properties.
function spec_path_imRef_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_path_imRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function spec_path_im_Callback(hObject, eventdata, h)
% hObject    handle to spec_path_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_path_im as text
%        str2double(get(hObject,'String')) returns contents of spec_path_im as a double
  
  
  
% --- Executes during object creation, after setting all properties.
function spec_path_im_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_path_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_path_imRef.
function button_path_imRef_Callback(hObject, eventdata, h)
% hObject    handle to button_path_imRef (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  [fileName, pathName] = uigetfile({'*.h5';'*.mat'},'Choose background data for video',get(h.spec_path_imRef,'String'));
  
  if ischar(fileName)
    set(h.spec_path_imRef,'String',pathcat(pathName,fileName))
    set(h.spec_path_im,'String',pathcat(pathName,fileName))
  end
  

% --- Executes on button press in button_path_im.
function button_path_im_Callback(hObject, eventdata, h)
% hObject    handle to button_path_im (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  [fileName, pathName] = uigetfile({'*.h5';'*.mat'},'Choose background data for video',get(h.spec_path_im,'String'));
  
  if ischar(fileName)
    set(h.spec_path_im,'String',pathcat(pathName,fileName))
  end

function noise_nsd_spec_Callback(hObject, eventdata, h)
% hObject    handle to noise_nsd_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of noise_nsd_spec as text
%        str2double(get(hObject,'String')) returns contents of noise_nsd_spec as a double
  
  h = update_noise(h,h.ax_Ca_slide);
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



function [h] = update_noise(h,ax)
  
  pltData = getappdata(0,'pltData');
  
  noise_nsd = str2double(get(h.noise_nsd_spec,'String'));
  
  
  %% get noise level (for noise-skipping)
  for w=1:2
    pltData.window(w).noise_level = 0;
    j = 0;
    for i=1:pltData.window(w).nR
      
      if pltData.window(w).ROIs(i,3)
        j=j+1;
        sn = pltData.window(w).ROIs(i,1);
        n = pltData.window(w).ROIs(i,2);
        
        pltData.window(w).noise_level = max(pltData.window(w).noise_level,std(pltData.window(w).CaTrace(:,i)));
      end
    end
%      pltData.window(w).noise_level = pltData.window(w).noise_level/pltData.window(w).nR;
    activity_thr(w) = noise_nsd * pltData.window(w).noise_level;
  end
  pltData.window(w).noise_level
  
  noise_vsc = str2double(get(h.noise_vsc_spec,'String'));
  h.parameter.noise_skp = str2double(get(h.noise_skp_spec,'String'));
  
  
  pltData.time_active = zeros(size(pltData.time));
  
  if h.parameter.noise_skp > 0
    for w=1:2
      for i=1:pltData.window(w).nR
        if pltData.window(w).ROIs(i,3)
          pltData.time_active(pltData.window(w).CaTrace(:,i) > activity_thr(w)) = 1;
        end
      end
    end
    sum(pltData.time_active)
    frames_active = 5;
    bwareaopen(pltData.time_active,frames_active);
    
    dilate_offset = h.parameter.frq*noise_vsc;
    pltData.time_active = imdilate(pltData.time_active,ones(1,dilate_offset*2+1));		%% skipping if active area is more than noise_vsc sec away
  end
  
  setappdata(0,'pltData',pltData);
  
  for w=1:2
    if isfield(h.plots.window(w),'noise')
      delete(h.plots.window(w).noise)
    end
    
    hold(ax,'on')
    h.plots.window(w).noise = plot(ax,[0,h.parameter.t_max],[activity_thr(w) activity_thr(w)],'--k','DisplayName',sprintf('%3.1fx noise level',noise_nsd),'Hittest','off');
    hold(ax,'off')
  end
  
  
  
function set_time_from_Ca(hObject,eventdata)

  h = guidata(hObject);
  
  coords = get(hObject,'CurrentPoint');
  t_new = coords(1,1);
  
  set(h.time_spec,'String',sprintf('%4.2f',t_new))
  t_frame = ceil(t_new*h.parameter.frq);
  
  pltData = getappdata(0,'pltData');
  for w=1:2
    h.plots.window(w).CData = pltData.window(w).im(:,:,t_frame);
  end
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
  set(h.spec_window_size,'enable','on')
  set(h.button_ROI_update,'enable','on')
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
  
  h = update_noise(h,h.ax_Ca_slide);
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
  elseif t_max > h.parameter.t_max
    set(h.t_max_spec,'String',sprintf('%4.2f',h.parameter.t_max/h.parameter.frq))
    t_max = h.parameter.t_max;
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




function [h] = update_plt_window(h)
  
  
  %% get input variables
  h.status.ROI_input = 0;

  %%% first, check for each input field, if proper value is provided - else error window and back to start
  errorMsg = 'Please provide a numeric, positive...';

  %% check ROI ID
%    if isnan(ROI_ID) || isempty(ROI_ID) || ROI_ID <= 0 || ROI_ID > h.data.nROI
%      errorMsg = strcat(errorMsg,sprintf('\n ... ROI ID < %d',h.data.nROI));
%    else
%      h.status.ROI_input = h.status.ROI_input + 1;
%    end

  %% check nR / ROI_num
%    if isnan(nR) || isempty(nR) || nR < 1 || nR > max_nR
%      errorMsg = strcat(errorMsg,sprintf('\n ... ROI number to be displayed (<%d)',max_nR));
%    else
%      h.status.ROI_input = h.status.ROI_input + 1;
%    end
  
  %% check area
  window_size = str2double(get(h.spec_window_size,'String'));
  if isnan(window_size) || isempty(window_size) || window_size < 1 || (2*window_size+1) > h.parameter.imSize(1) || (2*window_size+1) > h.parameter.imSize(2)	%% image size shouldn't be hardcoded, rather from structure
    errorMsg = strcat(errorMsg,sprintf('\n ... diameter of the ROI radius to be displayed'));
  else
    h.status.ROI_input = h.status.ROI_input + 1;
  end


  if h.status.ROI_input == 1

    set(h.button_ROI_update,'String','...')
    set(h.button_ROI_update,'enable','off')

    ROIs = getappdata(0,'ROIs');
    pltData = getappdata(0,'pltData');
    data = getappdata(0,'data');
    
    pltData.window = struct('ROIs',[],'ROI_centroid',[]);
    pltData.window(2) = struct('ROIs',[],'ROI_centroid',[]);
    
    
    sm = pltData.ROI_idx(1,1);
    m = pltData.ROI_idx(1,2);
    
    sessions = unique(pltData.ROI_idx(:,1),'stable');
    
    colors = {'r','g','b','m','c',[255,140,0]/255,[255,20,147]/255};
    
    %% ROIs: storing [session ROI_ID marked_status]
    pltData.window(1).ROIs = [sm m 1];
    pltData.window(1).ROI_centroid = ROIs(sm).centroid(m,:);
    pltData.window(1).ROI_A = zeros(h.parameter.imSize(1),h.parameter.imSize(2),1);
    pltData.window(1).ROI_A(:,:,1) = reshape(full(data(sm).A(:,m)),h.parameter.imSize(1),h.parameter.imSize(2));
    pltData.window(1).ROI_color{1} = colors{1};
    pltData.window(1).ROI_lines{1} = '-';
    
    pltData.window(2).ROIs = [];
    pltData.window(2).ROI_A = zeros(h.parameter.imSize(1),h.parameter.imSize(2),1);
    pltData.window(2).ROI_color{1} = [];
    pltData.window(2).ROI_lines{1} = [];
    

    if size(pltData.ROI_idx,1) > 1
      for i = 2:size(pltData.ROI_idx,1)
        sn = pltData.ROI_idx(i,1);
        n = pltData.ROI_idx(i,2);
        dist = sqrt((ROIs(sn).centroid(n,1)-ROIs(sm).centroid(m,1)).^2 + (ROIs(sn).centroid(n,2)-ROIs(sm).centroid(m,2)).^2);
        if dist < window_size
          pltData.window(1).ROIs = [pltData.window(1).ROIs; [sn n 1]];
          pltData.window(1).ROI_centroid = [pltData.window(1).ROI_centroid; ROIs(sn).centroid(n,:)];
          idx = size(pltData.window(1).ROIs,1);
          pltData.window(1).ROI_A(:,:,idx) = reshape(full(data(sn).A(:,n)),h.parameter.imSize(1),h.parameter.imSize(2));
          pltData.window(1).ROI_color{idx} = colors{size(pltData.window(1).ROIs,1)};
          pltData.window(1).ROI_lines{idx} = '-';
        else
          if isempty(pltData.window(2).ROIs)
            pltData.window(2).ROIs = [pltData.window(2).ROIs; [sn n 1]];
            pltData.window(2).ROI_centroid = [pltData.window(2).ROI_centroid; ROIs(sn).centroid(n,:)];
            idx = size(pltData.window(2).ROIs,1);
            pltData.window(2).ROI_A(:,:,idx) = reshape(full(data(sn).A(:,n)),h.parameter.imSize(1),h.parameter.imSize(2));
            pltData.window(2).ROI_color{idx} = colors{size(pltData.window(2).ROIs,1)};
            pltData.window(2).ROI_lines{idx} = '-';
          else
            sk = pltData.window(2).ROIs(1,1);
            k = pltData.window(2).ROIs(1,2);
            dist = sqrt((ROIs(sn).centroid(n,1)-ROIs(sk).centroid(k,1)).^2 + (ROIs(sn).centroid(n,2)-ROIs(sk).centroid(k,2)).^2);
            if dist < window_size
              pltData.window(2).ROIs = [pltData.window(2).ROIs; [sn n 1]];
              pltData.window(2).ROI_centroid = [pltData.window(2).ROI_centroid; ROIs(sn).centroid(n,:)];
              idx = size(pltData.window(2).ROIs,1);
              pltData.window(2).ROI_A(:,:,idx) = reshape(full(data(sn).A(:,n)),h.parameter.imSize(1),h.parameter.imSize(2));
              pltData.window(2).ROI_color{idx} = colors{size(pltData.window(2).ROIs,1)};
              pltData.window(2).ROI_lines{idx} = '-';
            else
              msgbox(sprintf('The ROIs you provided form at least 3 clusters, not capturable in two windows. \n Consider using a larger imaging window or providing a different set of ROIs'))
              return
            end
          end
        end
      end
    end
    
    if isempty(pltData.window(2).ROIs)
      pltData.window(2) = pltData.window(1);
      h.status.dual = true;
    end
    
    pltData.window(1).path = get(h.spec_path_imRef,'String');
    pltData.window(2).path = get(h.spec_path_im,'String');
    
    for w = 1:2
      pltData.window(w).nR = size(pltData.window(w).ROIs,1);
      pltData.window(w).center = mean(pltData.window(w).ROI_centroid,1);
      for s=1:length(sessions)
        sn = sessions(s);
        ROI_idx_list = find(sqrt(sum((ROIs(sn).centroid(:,1)-pltData.window(w).center(1)).^2 + (ROIs(sn).centroid(:,2)-pltData.window(w).center(2)).^2,2))<window_size);
        for i=1:length(ROI_idx_list)
          n = ROI_idx_list(i);
          if ~ismember([sn n 1],pltData.window(w).ROIs,'rows')
            pltData.window(w).ROIs = [pltData.window(w).ROIs; [sn n 0]];
            pltData.window(w).nR = pltData.window(w).nR + 1;
            idx = size(pltData.window(w).ROIs,1);
            pltData.window(w).ROI_A(:,:,idx) = reshape(full(data(sn).A(:,n)),h.parameter.imSize(1),h.parameter.imSize(2));
            pltData.window(w).ROI_color{idx} = 'y';
            pltData.window(w).ROI_lines{idx} = '--';
          end
        end
      end
      
      %% get imaging window (from ROI centroids and "area"-parameter)
      %%% remove harcoding of image size and time (handover?)
      pltData.window(w).min_x = max(1,round(pltData.window(w).center(2)-window_size));
      pltData.window(w).max_x = min(h.parameter.imSize(2),round(pltData.window(w).center(2)+window_size));
      pltData.window(w).min_y = max(1,round(pltData.window(w).center(1)-window_size));
      pltData.window(w).max_y = min(h.parameter.imSize(1),round(pltData.window(w).center(1)+window_size));
      
      h5inf = h5info(pltData.window(w).path);
      T = h5inf.Datasets.Dataspace.Size(3);
      pltData.window(w).offset = [pltData.window(w).min_y, pltData.window(w).min_x, 1];
      pltData.window(w).extent = [pltData.window(w).max_x-pltData.window(w).min_x+1, pltData.window(w).max_y-pltData.window(w).min_y+1, T];
      
      pltData.window(w).im = h5read(pltData.window(w).path,'/DATA',pltData.window(w).offset,pltData.window(w).extent);
    end
    
    
    %% rescale CaTraces
    CaData = getappdata(0,'CaData');
    j=0;
    for w = 1:2
      pltData.window(w).CaTrace = zeros(h.parameter.t_max,pltData.window(w).nR);
      for i=1:pltData.window(w).nR
        j=j+1;
        
        sn = pltData.window(w).ROIs(i,1);
        n = pltData.window(w).ROIs(i,2);
        
        noise_lvl = std(CaData(sn).traces(1:h.parameter.t_max,n));
        pltData.window(w).CaTrace(:,i) = CaData(sn).traces(1:h.parameter.t_max,n)/(10*noise_lvl);
      end
    end
    
    setappdata(0,'pltData',pltData);
    
    %% plot the first timepoint of the image
    [t, t_max] = get_time(h);
    h.plots.window(1).bg = imshow(pltData.window(1).im(:,:,t),'Parent',h.ax_imRef);
    h.plots.window(2).bg = imshow(pltData.window(2).im(:,:,t),'Parent',h.ax_im);
    
    %% now, plot the ROIs on top
    h.plots.window(1).ROIs = plot_blobs(h.ax_imRef,pltData.window(1).ROI_A,pltData.window(1).offset(1:2)-1,h.parameter.ROI_thr,pltData.window(1).ROI_lines,pltData.window(1).ROI_color);
    h.plots.window(2).ROIs = plot_blobs(h.ax_im,pltData.window(2).ROI_A,pltData.window(2).offset(1:2)-1,h.parameter.ROI_thr,pltData.window(2).ROI_lines,pltData.window(2).ROI_color);
    
    for w = 1:2
      for i=1:pltData.window(w).nR
        if pltData.window(w).ROIs(i,3)
          sn = pltData.window(w).ROIs(i,1);
          n = pltData.window(w).ROIs(i,2);
          pos = ROIs(sn).centroid(n,:) - pltData.window(w).offset(1:2);
          if w==1
            ax = h.ax_imRef;
          else
            ax = h.ax_im;
          end
          h.plots.window(w).ROI_tag(i) = text(pos(2)+2,pos(1)-2,sprintf('%d',n),'color','w','fontsize',10,'fontweight','bold','Visible','on','Hittest','off','Parent',ax);
        end
      end
    end

    
    %% might choose, what to plot here from drop-down menu
    
    %% now, plot CaTraces
    h = plot_CaStatic(h,h.ax_Ca_static);
    h = plot_CaSlide(h,h.ax_Ca_slide,t);
    
    %% after everything is checked and done, activate play-panel
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
    
    set(h.play_pause_button,'enable','on','String','Play')
    
    set(h.button_ROI_update,'enable','on','String','Update')
  
  else
    %% how-to: pop-up window with error message?
    uiwait(msgbox(errorMsg));	%% could add a nice picture here
  end




function [h] = plot_CaStatic(h,ax)
  
  %% remove data from earlier iterations
  if isfield(h.plots,'Ca_static')
    for i=1:length(h.plots.Ca_static)
      delete(h.plots.Ca_static{i})
    end
  end
  h.plots.Ca_static = {};
  
  if isfield(h.plots,'p_static')
    delete(h.plots.p_static)
  end
  
  %% plot static Ca-traces
  pltData = getappdata(0,'pltData');
%    CaData = getappdata(0,'CaData');
  
  if h.status.dual
    w_max = 1;
  else
    w_max = 2;
  end
    
  hold(ax,'on')
  j = 0;
  for w = 1:w_max
    for i=1:pltData.window(w).nR
      j=j+1;
      
      sn = pltData.window(w).ROIs(i,1);
      n = pltData.window(w).ROIs(i,2);
      Ca_offset = (j-1);  %% rather make scaling according to noise-level of each neurons CaTrace (10*noise level or so)
%        max_y = max(CaData(sn).traces(1:h.parameter.t_max,n));
      h.plots.Ca_static{j} = plot(ax,pltData.time, Ca_offset + pltData.window(w).CaTrace(:,i),'Color',pltData.window(w).ROI_color{i},'Hittest','off');
    end
  end
  h.plots.p_static = patch(ax,'Faces',[1,2,3,4],'Vertices',[0 0; 0 h.parameter.max_val_y; 1 h.parameter.max_val_y; 1 0],'FaceColor','k','FaceAlpha',0.5,'EdgeColor','none','Hittest','off');   %% shouldn't this already be dependent on the timepoint?
  hold(ax,'off')
  
  xlim(ax,[0,h.parameter.t_max/h.parameter.frq])
  ylim(ax,[0,j])
  set(ax,'YTick',[],...
         'YTickLabel',[])
  set(get(ax,'XLabel'),'String','time [s]');
  %% creating the possibility to interact with it to specify a time
  set(ax,'ButtonDownFcn',@set_time_from_Ca,'Hittest','on','PickableParts','All');
  
  

function [h] = plot_CaSlide(h,ax,t)
  
  %% remove data from earlier iterations
  if isfield(h.plots,'Ca_slide')
    for i=1:length(h.plots.Ca_slide)
      delete(h.plots.Ca_slide{i})
    end
  end
  h.plots.Ca_slide = {};
  
  if isfield(h.plots,'p_slide')
    delete(h.plots.p_slide)
  end
  
  if isfield(h.plots,'noise')
    delete(h.plots.noise)
  end
  
  %% plot moving Ca-traces
  pltData = getappdata(0,'pltData');
%    CaData = getappdata(0,'CaData');
  
  if h.status.dual
    w_max = 1;
  else
    w_max = 2;
  end
  
  hold(ax,'on')
  j = 0;
  for w = 1:w_max
    for i=1:pltData.window(w).nR
      if pltData.window(w).ROIs(i,3)
        j=j+1;
        sn = pltData.window(w).ROIs(i,1);
        n = pltData.window(w).ROIs(i,2);
%          [sn n]
%          max_y = max(max_y,max(CaData(sn).traces(1:h.parameter.t_max,n)));
        h.plots.Ca_slide{j} = plot(ax,pltData.time,pltData.window(w).CaTrace(:,i),'Color',pltData.window(w).ROI_color{i},'DisplayName',sprintf('ROI # %d (%d)',n,sn),'Hittest','off');
      end
    end
  end
  
  h = update_noise(h,h.ax_Ca_slide);
  
  h.plots.p_slide = patch(ax,'Faces',[1,2,3,4],'Vertices',[0 0; 0 h.parameter.max_val_y; 1 h.parameter.max_val_y; 1 0],'FaceColor','k','FaceAlpha',0.5,'EdgeColor','none','Hittest','off');   %% shouldn't this already be dependent on the timepoint?
  set(get(get(h.plots.p_slide,'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  hold(ax,'off')
  ylim(ax,[0,1.1])
  legend(ax,'show')
  
  update_Ca_slide(h,t)
  
  %% creating the possibility to interact with it to specify a time
  set(ax,'ButtonDownFcn',@set_time_from_Ca,'Hittest','on','PickableParts','All');
  
  




function ChecknUpdate_button(string,suffix,button_handle)
  length(suffix)
  for i=1:length(suffix)
    suffix(i)
    suffix_l = length(suffix{i})
    if ~isempty(string) && strcmp(suffix(i),string(end-(suffix_l-1):end))
      set(button_handle,'enable','on')
      break
    else
      set(button_handle,'enable','off')
    end
  end

  

function ROI_doc_CloseRequestFcn(hObject, eventdata, h)
% hObject    handle to ROI_doc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  choice = questdlg('Do you really want to quit?','Quit the ROI doctor','No','Yes','No');

  switch choice
    case 'No'
    
    case 'Yes'
      
      rmappdata(0,'pltData')
      
      % Hint: delete(hObject) closes the figure
      if isequal(get(hObject, 'waitstatus'), 'waiting')
          % The GUI is still in UIWAIT, us UIRESUME
          uiresume(hObject);
      else
          % The GUI is no longer waiting, just close it
          delete(hObject);
      end
  end
