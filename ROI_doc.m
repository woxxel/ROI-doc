function varargout = ROI_doc(varargin)
% ROI_DOC MATLAB code for ROI_doc.fig
%      ROI_DOC, by itself, creates a new ROI_DOC or raises the existing
%      singleton*.
%
%      H = ROI_DOC returns the handle to a new ROI_DOC or the handle to
%      the existing singleton*.
%
%      ROI_DOC('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_DOC.M with the given input arguments.
%
%      ROI_DOC('Property','Value',...) creates a new ROI_DOC or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_doc_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_doc_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_doc

% Last Modified by GUIDE v2.5 08-Mar-2018 18:56:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_doc_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_doc_OutputFcn, ...
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


% --- Executes just before ROI_doc is made visible.
function ROI_doc_OpeningFcn(hObject, eventdata, h, pathStart, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_doc (see VARARGIN)

  h.path = struct;
  
  h.data = struct;		%% keep small and simple!
  h.data.nsessions = 0;
  
  h.plots = struct('background',{},'ROIs',{},'ROI_tag',{});
  
  h.status = struct('background',{},'ROIs',{},'CaTrace',{},'ROI_select',{},'ROI_paired',{},'ROI_retain',{});
  h.status(1).background = false;
  
  h.ROI_status = struct('list_pick',[],'highlight',[],'half_pair',0,'add',false);
  
  if nargin<4 || isempty(pathStart)
    pathStart = '/media/wollex/Data/Documents/Uni/2016-XXXX_PhD/Japan/Work/Data/Session01';
%      pathStart = '';
  else
    set(h.save_path_spec,'String',pathcat(pathStart,'test_fig'))
  end
  
  set(h.session_spec,'String',pathStart)
%    set(h.spec_background_path,'String','reduced_MF1_LK1.mat')
  h.path.background_data = get(h.spec_background_path,'String');
%    set(h.spec_ROI_path,'String','resultsCNMF_MF1_LK1.mat')
  h.path.ROI_data = get(h.spec_ROI_path,'String');
%    set(h.spec_Ca_path,'String','resultsCNMF_MF1_LK1.mat')
  h.path.Ca_data = get(h.spec_Ca_path,'String');
  
  set(h.ROI_info_table,'ColumnName',{'' 'ID' 'x' 'y' 'area' 'rate'})
  set(h.ROI_info_table,'ColumnWidth',{[20],[50],[60],[60],[50],[70]})
  set(h.ROI_info_table,'Data',cell(0,6))
  
  h.parameter = {};
  h.parameter.ROI_thr = 0.01;
  h.parameter.radius = 20;
  h.parameter.diameter = 2*h.parameter.radius+1;
  h.parameter.frq = 15;
  
  
  lin_log_string = cellstr(['lin-lin';...
			    'lin-log';...
			    'log-lin';...
			    'log-log']);
  set(h.ax_stat_3_lin_log,'String',lin_log_string);
  
  
  %% set up drop down menu for mass select
  h.drop_down_mass_select_string_single = cellstr(['None                 ';...
                                                   'Spatial correlation  ';...
                                                   'Temporal correlation ';...
                                                   'Filter size          ';...	%% could remove this in pair mode
                                                   'Firing rate          ';... %% could remove this in pair mode	
                                                   'border proximity     ']);	%% could remove this in pair mode
                                                   %%% what else?
                            
  h.drop_down_mass_select_string_pair = cellstr(['None                 ';...
                                                 'Distance             ';...
                                                 'Spatial correlation  ';...
                                                 'Temporal correlation ']);
  set(h.drop_down_mass_select,'String',h.drop_down_mass_select_string_single,'Value',1);
  
  
  
  %% set up drop down menu for mass select threshold option
  h.drop_down_mass_select_thr_string = cellstr(['<';'>']);
  set(h.drop_down_mass_select_thr,'String',h.drop_down_mass_select_thr_string,'Value',2);
  
  
  h.drop_down_ROI_tag_string = cellstr(['ROI tag    ';...
					'ROI ID     ';...
					'Firing rate']); %% add in pair mode: partner ID / pair ID
  set(h.drop_down_ROI_tag,'String',h.drop_down_ROI_tag_string,'Value',1);
  
  
  
  h.drop_down_save_string = cellstr(['Choose what to save';...
                                     'Figure: Axis 1     ';...
                                     'Figure: Axis 2     ';...
                                     'Figure: Axis 3     ';...
                                     'Figure: Axis 4     ';...
                                     'Figure: whole GUI  ';...
                                     'Data: current ROIs ']);
  set(h.drop_down_save_fig_spec,'String',h.drop_down_save_string,...
			      'Value',1)
			      
  h.save_file_extensions_string_fig = cellstr(['png';'jpg';'fig';'pdf']);
  h.save_file_extensions_string_data = cellstr(['mat']);

  
  set(h.drop_down_choose_session_color,'String',cellstr(['Yellow ';...
                                                         'Green  ';...
                                                         'Blue   ';...
                                                         'White  ';...
                                                         'Orange ';...
                                                         'Pink   ';...
                                                         'Brown  ';...
                                                         'Azure  ';...
                                                         'Violet ']))
  
  
  
% Choose default command line output for ROI_doc
h.output = hObject;

% Update h structure
guidata(hObject, h);

% UIWAIT makes ROI_doc wait for user response (see UIRESUME)
% uiwait(h.ROI_doc);






% --- Outputs from this function are returned to the command line.
function varargout = ROI_doc_OutputFcn(hObject, eventdata, h) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = h.output;


% --- Executes on selection change in ax_stat_1_menu.
function ax_stat_1_menu_Callback(hObject, eventdata, h)
% hObject    handle to ax_stat_1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ax_stat_1_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ax_stat_1_menu
  
  dd_string_stats_small = get(hObject,'String');
  plotType = dd_string_stats_small{get(hObject,'Value')};
  h = update_stats_plot(h,plotType,h.ax_stat_1);
  guidata(hObject,h);

% --- Executes during object creation, after setting all properties.
function ax_stat_1_menu_CreateFcn(hObject, eventdata, h)
% hObject    handle to ax_stat_1_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ax_stat_2_menu.
function ax_stat_2_menu_Callback(hObject, eventdata, h)
% hObject    handle to ax_stat_2_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ax_stat_2_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ax_stat_2_menu
  
  dd_string_stats_small = get(hObject,'String');
  plotType = dd_string_stats_small{get(hObject,'Value')};
  h = update_stats_plot(h,plotType,h.ax_stat_2);
  guidata(hObject,h);

% --- Executes during object creation, after setting all properties.
function ax_stat_2_menu_CreateFcn(hObject, eventdata, h)
% hObject    handle to ax_stat_2_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ax_stat_3_menu.
function ax_stat_3_menu_Callback(hObject, eventdata, h)
% hObject    handle to ax_stat_3_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ax_stat_3_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ax_stat_3_menu
    
  dd_string_stats_small = get(hObject,'String');
  plotType = dd_string_stats_small{get(hObject,'Value')};
  switch plotType
    case 'Scatter'
      set(h.ax_stat_3_1st_val_spec,'Visible','on','enable','on');
      set(h.ax_stat_3_2nd_val_spec,'Visible','on','enable','on');
      set(h.ax_stat_3_helper_text,'Visible','on');
      set(h.ax_stat_3_histo_bin_spec,'enable','off')
      set(h.ax_stat_3_lin_log,'enable','on')
    case 'Histogram'
      set(h.ax_stat_3_1st_val_spec,'Visible','on','enable','on');
      set(h.ax_stat_3_2nd_val_spec,'Visible','off','enable','off');
      set(h.ax_stat_3_helper_text,'Visible','off');
      set(h.ax_stat_3_histo_bin_spec,'enable','on')
      set(h.ax_stat_3_lin_log,'enable','on')
    otherwise
      set(h.ax_stat_3_1st_val_spec,'Visible','off','enable','off');
      set(h.ax_stat_3_2nd_val_spec,'Visible','off','enable','off');
      set(h.ax_stat_3_helper_text,'Visible','off');
      set(h.ax_stat_3_histo_bin_spec,'enable','off')
      set(h.ax_stat_3,'xscale','lin')
      set(h.ax_stat_3,'yscale','lin')
      set(h.ax_stat_3_lin_log,'Value',1)
      set(h.ax_stat_3_lin_log,'enable','off')
  end
  h = update_stats_plot(h,plotType,h.ax_stat_3);
  guidata(hObject,h);
  

% --- Executes during object creation, after setting all properties.
function ax_stat_3_menu_CreateFcn(hObject, eventdata, h)
% hObject    handle to ax_stat_3_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function h = update_stats_plot(h,plotType,ax,ROI_idx)

  table_data = get(h.ROI_info_table,'Data');
  switch plotType
    case 'ROI filter'
      if size(table_data,1) > 0
        if nargin < 4 || isempty(ROI_idx)
          ROI_idx = get_n_from_table(h,1);        
        end
        update_filter(h,ax,ROI_idx);
      end
    case 'Calcium trace'
      if h.status(h.data.current_session).CaData
        if size(table_data,1) > 0
          if nargin < 4 || isempty(ROI_idx)
            ROI_idx = get_n_from_table(h,1);
          end
          update_CaTrace(h,ax,ROI_idx);
        end
      else
        uiwait(msgbox('Calcium data not yet loaded'))
      end
    case 'Spike train'
      if h.status(h.data.current_session).CaData
        if size(table_data,1) > 0
          if nargin < 4 || isempty(ROI_idx)
            ROI_idx = get_n_from_table(h,1);
          end
          plot_spikeTrain(h,ax,ROI_idx)
        end
      else
        uiwait(msgbox('Calcium data not yet loaded'))
      end
    case 'Correlation raster'
      if h.status(h.data.current_session).CaData
        h = plot_CorrRaster(h,ax);
      end
    case 'Histogram'
      if get(h.ax_stat_3_1st_val_spec,'Value') > 1
        plot_histogram(h,ax);
      end
    case 'Scatter'
      if get(h.ax_stat_3_2nd_val_spec,'Value') > 1 && get(h.ax_stat_3_1st_val_spec,'Value') > 1
        plot_scatter(h,ax);
      end
    otherwise
      cla(ax,'reset')
%        disp('nothing to be done')
  end

  
function pickROI(hObject,eventdata)
  
  h = guidata(hObject);
  sn = h.data.current_session;
  
  h.ROI_status.add = false;
  
  coords = get(hObject,'CurrentPoint');
  coords1 = [coords(1,2), coords(1,1)];
  
  ROIs = getappdata(0,'ROIs');
  
  if get(h.radio_single_mode,'Value')
    final_rect = rbbox;
    coords = get(hObject,'CurrentPoint');
    coords2 = [coords(1,2), coords(1,1)];
  end
  
  if get(h.radio_single_mode,'Value') && any(abs(coords1-coords2)>5)
    x = sort([coords1(2),coords2(2)]);
    y = sort([coords1(1),coords2(1)]);
    
    ROI_idx_list = find(ROIs(sn).centroid(:,2)>x(1) & ROIs(sn).centroid(:,2)<x(2) & ROIs(sn).centroid(:,1)>y(1) & ROIs(sn).centroid(:,1)<y(2));
    for i=1:length(ROI_idx_list)
      n = ROI_idx_list(i);
      if ~h.status(sn).ROI_select(n)
        h = update_ROI_select(h,[sn n],'r','-');
      end
    end
  else
    % identify closest ROI
    [min_val n] = min(sum((ROIs(sn).centroid(:,1)-coords1(1)).^2 + (ROIs(sn).centroid(:,2)-coords1(2)).^2,2));
    if sqrt(min_val) < 10
      if get(h.radio_single_mode,'Value')
        h = update_ROI_select(h,[sn n],'r','-');
      
      elseif get(h.radio_pairs_mode,'Value')
        
        if ~h.ROI_status.half_pair
          h.ROI_status.half_pair = n;
          set(h.plots(sn).ROIs(n),'Color','m')
        elseif n == h.ROI_status.half_pair
          if h.status(sn).ROI_select(n)
              set(h.plots(sn).ROIs(n),'Color','r')
          else
            set(h.plots(sn).ROIs(n),'Color',get_ROI_color(h,sn))
          end
          h.ROI_status.half_pair = 0;
        else
          h = update_ROI_select(h,[sn n],'r','-');
          h.ROI_status.half_pair = 0;
        end
      
      elseif get(h.radio_matching_mode,'Value')
        ROI_idx = [sn n];
        for s = 1:h.data.nsessions
          if h.status(s).ROIs && h.data.session_display(s) && ~(s==sn)
            m_list = find(sqrt(sum((ROIs(s).centroid(:,1)-ROIs(sn).centroid(n,1)).^2 + (ROIs(s).centroid(:,2)-ROIs(sn).centroid(n,2)).^2,2))<5);
            
            for i=1:length(m_list)
              ROI_idx = [ROI_idx; [s m_list(i)]];
            end
          end
        end
        h = update_ROI_select(h,ROI_idx,'r','-');
      end
      
    end
  end
  
  if h.ROI_status.add
    dd_string_stats_small = get(h.ax_stat_3_menu,'String');
    plotType = dd_string_stats_small{get(h.ax_stat_3_menu,'Value')};
    ROI_idx = get_n_from_table(h,1);
    if get(h.radio_single_mode,'Value')
      if ~strcmp(plotType,'Histogram') && ~strcmp(plotType,'Scatter') || get(h.checkbox_select_in_stats,'Value')
        h = update_stats_plot(h,plotType,h.ax_stat_3,ROI_idx);
      end
    elseif get(h.radio_pairs_mode,'Value')
      table_data = get(h.ROI_info_table,'Data');
      if ~strcmp(plotType,'Histogram') && ~strcmp(plotType,'Scatter') || get(h.checkbox_select_in_stats,'Value')
        h = update_stats_plot(h,plotType,h.ax_stat_3,ROI_idx);
      end
    elseif get(h.radio_matching_mode,'Value')
      table_data = get(h.ROI_info_table,'Data');
      if size(table_data,1) > 0
        if ~strcmp(plotType,'Histogram') && ~strcmp(plotType,'Scatter') || get(h.checkbox_select_in_stats,'Value')
          h = update_stats_plot(h,plotType,h.ax_stat_3,ROI_idx);
        end
      end
    end
  else
    ROI_idx = [];
  end
  
  h = update_plots(h,ROI_idx);
  guidata(hObject,h);

% --- Executes on button press in button_export_ROI.
function button_export_ROI_Callback(hObject, eventdata, h)
% hObject    handle to button_export_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  
  %% for exporting to other GUI, not for saving!
  
  export = true;
  
  %% get selected neurons
  ROI_idx = [];
  for s = 1:h.data.nsessions
    if h.status(s).ROIs
      for n=1:h.data.nROI(s)
        if h.status(s).ROI_select(n)
          ROI_idx = [ROI_idx; [s n]];
        end
      end
    end
    if ~isempty(ROI_idx) && ismember(s,ROI_idx(:,1)) && ~h.status(s).CaData
      uiwait(msgbox('You have not yet loaded calcium data for all selected ROIs. Please do so, before exporting!'))
      export = false;
      break
    end
  end
  
  sessions = unique(ROI_idx(:,1));
  pathRef = h.data.paths(ROI_idx(1,1)).session;
  for i = 1:length(sessions)
    s = sessions(i);
    if ~strcmp(h.data.paths(s).session,pathRef)
      uiwait(msgbox('There is data from different sessions involved. Please plot data from a single session only'))
      export = false;
      break
    end
  end
  
  if isempty(ROI_idx)
    msgbox('nothing selected to export')
  elseif export
    output = struct;
    output.ROI_idx = ROI_idx;
    output.pathSession = pathRef;
    output.parameter = h.parameter;
    setappdata(0,'handover',output)
    
    ROI_video
  end
  
  
  
  
  
  
function ChecknUpdate_button(string,suffix,button_handle)
  
  suffix_l = length(suffix);
  if ~isempty(string) && strcmp(suffix,string(end-(suffix_l-1):end))
    set(button_handle,'enable','on')
  else
    set(button_handle,'enable','off')
  end


% --- Executes on button press in background_data_button.
function background_data_button_Callback(hObject, eventdata, h)
% hObject    handle to background_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  pathSearch = pathcat(get(h.session_spec,'String'),get(h.spec_background_path,'String'));
  [fileName, pathName] = uigetfile({'*.mat'},'Choose background data file',pathSearch);
  
  if ischar(fileName)
    if ~strcmp(pathName,h.data.paths(h.data.current_session).session)
      fileName = erase(pathcat(pathName,fileName),h.data.paths(h.data.current_session).session);
      if strcmp(fileName(1),'/') || strcmp(fileName(1),'\')
        fileName = fileName(2:end);
      end
    end
    set(h.spec_background_path,'String',fileName)
    ChecknUpdate_button(fileName,'.mat',h.background_plot_button)
  end
  
  
function spec_background_path_Callback(hObject, eventdata, h)
% hObject    handle to spec_background_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_background_path as text
%        str2double(get(hObject,'String')) returns contents of spec_background_path as a double
  
  if ~h.status(h.data.current_session).background
    ChecknUpdate_button(get(h.spec_background_path,'String'),'.mat',h.background_plot_button)
  else
    set(hObject,'String',h.data.paths(h.data.current_session).background)
    msgbox('You can not change this path in this dataset anymore')
  end
  

% --- Executes during object creation, after setting all properties.
function spec_background_path_CreateFcn(hObject, eventdata, h)
% hObject    handle to spec_background_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in background_plot_button.
function background_plot_button_Callback(hObject, eventdata, h)
% hObject    handle to background_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  set(h.background_plot_button,'enable','off')
  set(h.background_data_button,'enable','off')
  set(h.spec_background_path,'enable','off')
  
  h = load_background();
  guidata(hObject,h)
  
  if h.data.current_session == 1 || ~h.status(h.data.current_session).background
    set(h.background_plot_button,'enable','on')
    set(h.background_data_button,'enable','on')
  end
  
  if h.status(h.data.current_session).background && ~h.status(h.data.current_session).ROIs
    set(h.ROI_plot_button,'enable','on')
    set(h.ROI_data_button,'enable','on')
  end
  
  set(h.spec_background_path,'enable','on')
  
  update_session_stat_display(h)
  
  
  
  

function [h] = load_background(h)

  field_name = get(h.spec_bg_field,'String');
  bg_tmp = LoadnResize(pathcat(get(h.session_spec,'String'),get(h.spec_background_path,'String')),[0,0],sprintf('Could not find the field %s. Choose the array containing background data',field_name),field_name);
  if numel(bg_tmp) > 1
    set(h.background_plot_button,'String','...')
    if h.data.current_session == 1
      h.parameter.imSize = size(bg_tmp);
      if h.status(1).background
        h.plots(1).background.CData = bg_tmp;
        set(h.ax_ROIs,'clim',[0 3*mean(bg_tmp(:))])
      else
%          h.plots(h.data.current_session).background = imshow(bg_tmp,'Parent',h.ax_ROIs);
        h.plots(h.data.current_session).background = imagesc(h.ax_ROIs,bg_tmp);
        colormap(h.ax_ROIs,'gray')
        set(h.ax_ROIs,'clim',[0 max(bg_tmp(:))])
      end
      
      h.data.shift(h.data.current_session,:) = [0,0];
      h.data.rotation(h.data.current_session) = 0;
      
      setappdata(0,'background_data',bg_tmp)
      
      set(h.plots(1).background,'Hittest','off')	%% disable, to allow clicking axes
      
    else
      %% check for same size
      if ~all(size(bg_tmp)==h.parameter.imSize)
        uiwait(msgbox('The background data you provided has different dimensions than the reference one. Please provide same-sized data'))
      end
      
      %% finding shift towards reference background (1st)
      bg_ref = getappdata(0,'background_data');
      
      rot_max = 5;
      rot = linspace(-rot_max,rot_max,20*rot_max+1);
      max_C = 0;
      rot_tmp = -rot_max;
      for r = rot
        bg_rot = imrotate(bg_tmp,r,'crop');
        C = fftshift(real(ifft2(fft2(bg_ref).*fft2(rot90(bg_rot,2)))));
        if max(C(:)) > max_C;
          max_C = max(C(:));
          rot_tmp = r;
          [ind_y,ind_x] = find(C == max_C);
        elseif max(C(:)) == max_C;
          rot_tmp = [rot_tmp r];
        end
      end
      rot_tmp = mean(rot_tmp);
      
      %% imtranslate takes [x,y,z] vector
      h.data.shift(h.data.current_session,2) = floor(h.parameter.imSize(1)/2) - ind_y;
      h.data.shift(h.data.current_session,1) = floor(h.parameter.imSize(2)/2) - ind_x;
      h.data.rotation(h.data.current_session) = rot_tmp;
    end
    h.status(h.data.current_session).background = true;
    
    h.data.paths(h.data.current_session).background = get(h.spec_background_path,'String');
    
    set(h.background_plot_button,'String','Add')
    
    set(h.drop_down_save_fig_spec,'enable','on')
    set(h.save_path_choose,'enable','on')
    set(h.save_path_spec,'enable','on')
    set(h.drop_down_choose_session_color,'enable','on')
    
  else
    set(h.background_plot_button,'enable','on')
    set(h.background_data_button,'enable','on')
  end
  

% --- Executes on button press in ROI_data_button.
function ROI_data_button_Callback(hObject, eventdata, h)
% hObject    handle to ROI_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  pathSearch = pathcat(get(h.session_spec,'String'),get(h.spec_ROI_path,'String'));
  [fileName, pathName] = uigetfile({'*.mat'},'Choose ROI data file',pathSearch);
  
  if ischar(fileName)
    if ~strcmp(pathName,h.data.paths(h.data.current_session).session)
      fileName = erase(pathcat(pathName,fileName),h.data.paths(h.data.current_session).session);
      if strcmp(fileName(1),'/') || strcmp(fileName(1),'\')
        fileName = fileName(2:end);
      end
    end
    set(h.spec_ROI_path,'String',fileName)
    ChecknUpdate_button(fileName,'.mat',h.ROI_plot_button)
  end
  
  

function spec_ROI_path_Callback(hObject, eventdata, h)
% hObject    handle to spec_ROI_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_ROI_path as text
%        str2double(get(hObject,'String')) returns contents of spec_ROI_path as a double
  
  if ~h.status(h.data.current_session).ROIs && h.status(h.data.current_session).background
    ChecknUpdate_button(get(h.spec_ROI_path,'String'),'.mat',h.ROI_plot_button)
  elseif h.status(h.data.current_session).ROIs
    set(hObject,'String',h.data.paths(h.data.current_session).ROIs)
    msgbox('You can not change this path in this dataset anymore')
  end

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

% --- Executes on button press in ROI_plot_button.
function ROI_plot_button_Callback(hObject, eventdata, h)
% hObject    handle to ROI_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  set(h.background_plot_button,'enable','off')
  set(h.ROI_plot_button,'enable','off')
  set(h.ROI_data_button,'enable','off')
  set(h.spec_ROI_path,'enable','off')
  
  set(h.drop_down_choose_session,'enable','off')
  set(h.drop_down_choose_session_color,'enable','off')
  
  h = load_ROIs(h);
  guidata(hObject,h);
  
%      set(h.ROI_tag_checkbox,'enable','on')
    
  if h.status(h.data.current_session).ROIs
    
    set(h.drop_down_mass_select,'enable','on')
    set(h.drop_down_mass_select_thr,'enable','on')
    set(h.mass_select_thr_spec,'enable','on')
    
    set(h.mass_select_checkbox,'enable','on')
    set(h.drop_down_ROI_tag,'enable','on')
    set(h.checkbox_session_display_ROIs,'enable','on')
    
    set(h.checkbox_select_in_stats,'enable','on')
    
    set(h.Ca_plot_button,'enable','on')
    set(h.Ca_data_button,'enable','on')
    set(h.spec_Ca_path,'enable','on')
    
    set(h.button_clear_selection,'enable','on')
    set(h.button_remove_ROI,'enable','on')
    
    set(h.button_remove_ROI,'enable','on')
    set(h.radio_single_mode,'enable','on')
    set(h.radio_pairs_mode,'enable','on')
    
    set(h.button_export_ROI,'enable','on')
    
    if sum(horzcat(h.status.ROIs)) > 1
      set(h.radio_matching_mode,'enable','on')
    end
    
    update_plot_menus(h)
    update_session_stat_display(h)
  
  end
  
  set(h.spec_ROI_path,'enable','on')
  
  set(h.drop_down_choose_session,'enable','on')
  set(h.drop_down_choose_session_color,'enable','on')
  
  
  
function [h] = load_ROIs(h)
  field_name = get(h.spec_ROI_field,'String');
  A = sparse(LoadnResize(pathcat(get(h.session_spec,'String'),get(h.spec_ROI_path,'String')),[h.parameter.imSize(1)*h.parameter.imSize(2),0],sprintf('Could not find the field %s. Choose the array containing ROI data',field_name),field_name));
  
  if numel(A)>1
    set(h.ROI_plot_button,'String','...')
    
    if h.data.nsessions > 1
      data = getappdata(0,'data');
      ROIs = getappdata(0,'ROIs');
    else
      data = struct;
      ROIs = struct('centroid',[],'area',[],'n_events',[],'rate',[]);
    end
    
    h.data.nROI(h.data.current_session) = size(A,2);
    hwait = waitbar(0,sprintf('Loading and processing %d ROIs...',h.data.nROI(h.data.current_session)));
    
%      field_name = 'status';
%      data(h.data.current_session).Astatus = LoadnResize(pathcat(get(h.session_spec,'String'),get(h.spec_ROI_path,'String')),[h.data.nROI(h.data.current_session),0],sprintf('Could not find the field %s. Choose the array containing ROI status data',field_name),field_name);
%      if ~nnz(data(h.data.current_session).Astatus)
%        data(h.data.current_session).Astatus = ones(h.data.nROI(h.data.current_session));
%      end
    
    %% shift the data before further processing
    A_tmp = reshape(full(A),h.parameter.imSize(1),h.parameter.imSize(2),h.data.nROI(h.data.current_session));
    A_tmp = imtranslate(A_tmp,-[h.data.shift(h.data.current_session,:),0]);
    if h.data.rotation(h.data.current_session) ~= 0
      A_tmp = imrotate(A_tmp,h.data.rotation(h.data.current_session),'crop');
    end
    
    data(h.data.current_session).A = sparse(reshape(A_tmp,h.parameter.imSize(1)*h.parameter.imSize(2),h.data.nROI(h.data.current_session)));
    
    h.status(h.data.current_session).ROI_select = sparse(h.data.nROI(h.data.current_session),1,false);
    h.status(h.data.current_session).ROI_retain = true(h.data.nROI(h.data.current_session),1);
    
    ROIs(h.data.current_session).filter(h.data.nROI(h.data.current_session)) = struct;
    ROIs(h.data.current_session).centroid = zeros(h.data.nROI(h.data.current_session),1);
    
    %% get basic data of ROIs
    data(h.data.current_session).normA = zeros(h.data.nROI(h.data.current_session),1);
    for n=1:h.data.nROI(h.data.current_session)
      waitbar(n/(2*h.data.nROI(h.data.current_session)),hwait)
      if nanmax(data(h.data.current_session).A(:,n)) == 0       %% if a neuron got shifted out by the image shift
        ROIs(h.data.current_session).centroid(n,:) = nan;
        ROIs(h.data.current_session).filter(n).shape = nan;
        ROIs(h.data.current_session).filter(n).extent = nan;
        ROIs(h.data.current_session).area(n) = nan;
        ROIs(h.data.current_session).rate(n) = nan;
        ROIs(h.data.current_session).n_events(n) = nan;
        h.status(h.data.current_session).ROI_retain(n) = false;    %% kick this one out
        disp(sprintf('Neuron #%d removed, as it has no contribution to the shifted imaging window',n))
      else
        data(h.data.current_session).normA(n) = norm(data(h.data.current_session).A(:,n));
        A_tmp_norm = sparse(A_tmp(:,:,n)/sum(data(h.data.current_session).A(:,n)));
        ROIs(h.data.current_session).centroid(n,1) = sum((1:h.parameter.imSize(1))*A_tmp_norm);
        ROIs(h.data.current_session).centroid(n,2) = sum(A_tmp_norm*(1:h.parameter.imSize(2))');
        ROIs(h.data.current_session).filter(n).shape = sparse(h.parameter.diameter,h.parameter.diameter);
        ROIs(h.data.current_session).filter(n).extent(2,1) = max(1,ceil(ROIs(h.data.current_session).centroid(n,2)-h.parameter.radius));
        ROIs(h.data.current_session).filter(n).extent(2,2) = min(h.parameter.imSize(2),ceil(ROIs(h.data.current_session).centroid(n,2)+h.parameter.radius));
        ROIs(h.data.current_session).filter(n).extent(1,1) = max(1,ceil(ROIs(h.data.current_session).centroid(n,1)-h.parameter.radius));
        ROIs(h.data.current_session).filter(n).extent(1,2) = min(h.parameter.imSize(1),ceil(ROIs(h.data.current_session).centroid(n,1)+h.parameter.radius));
        
        win_y = ceil([h.parameter.radius-(ROIs(h.data.current_session).centroid(n,1)-ROIs(h.data.current_session).filter(n).extent(1,1)), h.parameter.radius+(ROIs(h.data.current_session).filter(n).extent(1,2)-ROIs(h.data.current_session).centroid(n,1))]);
        win_x = ceil([h.parameter.radius-(ROIs(h.data.current_session).centroid(n,2)-ROIs(h.data.current_session).filter(n).extent(2,1)), h.parameter.radius+(ROIs(h.data.current_session).filter(n).extent(2,2)-ROIs(h.data.current_session).centroid(n,2))]);
        
        ROIs(h.data.current_session).filter(n).shape(win_y(1):win_y(2),win_x(1):win_x(2)) = A_tmp_norm(ROIs(h.data.current_session).filter(n).extent(1,1):ROIs(h.data.current_session).filter(n).extent(1,2),ROIs(h.data.current_session).filter(n).extent(2,1):ROIs(h.data.current_session).filter(n).extent(2,2));
        
        ROIs(h.data.current_session).area(n) = nnz(A_tmp_norm);
      end
    end
    
    data(h.data.current_session).distance = zeros(h.data.nROI(h.data.current_session));
    data(h.data.current_session).fp_corr = zeros(h.data.nROI(h.data.current_session));
    %% calculate distance and spatial overlap
    for n=1:h.data.nROI(h.data.current_session)
      waitbar((n+h.data.nROI(h.data.current_session))/(2*h.data.nROI(h.data.current_session)),hwait)
      for m=n+1:h.data.nROI(h.data.current_session)
        if any(isnan(ROIs(h.data.current_session).centroid(n,:))) || any(isnan(ROIs(h.data.current_session).centroid(m,:)))
          data(h.data.current_session).distance(n,m) = nan;
          data(h.data.current_session).fp_corr(n,m) = nan;
        else
          data(h.data.current_session).distance(n,m) = sqrt((ROIs(h.data.current_session).centroid(n,1)-ROIs(h.data.current_session).centroid(m,1))^2+(ROIs(h.data.current_session).centroid(n,2)-ROIs(h.data.current_session).centroid(m,2))^2);
          
          if data(h.data.current_session).distance(n,m) < 50
            data(h.data.current_session).fp_corr(n,m) = (data(h.data.current_session).A(:,n)'*data(h.data.current_session).A(:,m))/(data(h.data.current_session).normA(n)*data(h.data.current_session).normA(m));
          end
        end
      end
    end
    
    data(h.data.current_session).distance = triu(data(h.data.current_session).distance) + triu(data(h.data.current_session).distance,1)';
    data(h.data.current_session).fp_corr = triu(data(h.data.current_session).fp_corr) + triu(data(h.data.current_session).fp_corr,1)';
    
%      for n=1:h.data.nROI(h.data.current_session)
%        switch data(h.data.current_session).Astatus(n)
%          case 0
%            ROI_line{n} = ':';
%          case 1
%            ROI_line{n} = '-';
%          case 2
%            ROI_line{n} = '--';
%        end
%      end
    
    h.plots(h.data.current_session).ROIs = plot_blobs(h.ax_ROIs,A_tmp,[],h.parameter.ROI_thr,'-',get_ROI_color(h,h.data.current_session),hwait);
    
%      n_bad = find(data(h.data.current_session).Astatus==0);
%      for n=n_bad
%        set(h.plots(h.data.current_session).ROIs(n),'LineStyle',':');
%      end
    
%      n_fill = find(data(h.data.current_session).Astatus==2);
%      for n=n_fill
%        set(h.plots(h.data.current_session).ROIs(n),'LineStyle','--','Color','y');
%      end
    
    
    h.status(h.data.current_session).ROI_tag = h.drop_down_ROI_tag_string{get(h.drop_down_ROI_tag,'Value')};
    
    for n=1:h.data.nROI(h.data.current_session)
      if h.status(h.data.current_session).ROI_retain(n)
        switch h.status(h.data.current_session).ROI_tag
          case 'ROI ID'
            ROI_tag = sprintf('%d',n);
          otherwise
            ROI_tag = '';
        end
        h.plots(h.data.current_session).ROI_tag(n) = text(ROIs(h.data.current_session).centroid(n,2)+2,ROIs(h.data.current_session).centroid(n,1)-5,ROI_tag,'color','w','fontsize',10,'fontweight','bold','Visible','off','Hittest','off','Parent',h.ax_ROIs);
      end
    end
    
    h.plots(1).ROI_text = text('Units','normalized','Position',[0 -0.05],'String','','Color','k','Parent',h.ax_ROIs);
    
    set(h.ROI_info_table,'Data',cell(0,6));
    
    setappdata(0,'data',data);
    setappdata(0,'ROIs',ROIs);
  
    set(h.ax_ROIs,'ButtonDownFcn',@pickROI,'Hittest','on','PickableParts','All');
    set(gcf,'WindowButtonMotionFcn',@MouseOver_getAx);
    
    h.data.paths(h.data.current_session).ROIs = get(h.spec_ROI_path,'String');
    h.status(h.data.current_session).ROIs = true;
    
    set(h.ROI_plot_button,'String','Add')
    
    close(hwait)
    
  else
    set(h.ROI_plot_button,'enable','on')
    set(h.ROI_data_button,'enable','on')
  end
  
  
  
function update_plot_menus(h)
  
  %% set up drop down menu for plotting statistics
  dd_string_stats_small = cellstr(['Choose display         ';...
                                   'ROI filter             ';...
                                   'Calcium trace          ';...
                                   'Spike train            ';...
                                   'Correlation raster     ']);	%% what else?
  
  if ~h.status(h.data.current_session).CaData
    dd_string_stats_small{3} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_small{3});
    dd_string_stats_small{4} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_small{4});
    dd_string_stats_small{5} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_small{5});
  end
  
  set(h.ax_stat_1_menu,'String',dd_string_stats_small,'Value',1);
  set(h.ax_stat_2_menu,'String',dd_string_stats_small,'Value',1);
  
  
  %%% now, large statistics field
  dd_string_stats_large = cellstr(['Choose display         ';...
                                   'Calcium trace          ';...
                                   'Spike train            ';...
                                   'Correlation raster     ';...
                                   'Scatter                ';...
                                   'Histogram              ']);	%% what else?
  
  if ~h.status(h.data.current_session).CaData
    dd_string_stats_large{2} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large{2});
    dd_string_stats_large{3} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large{3});
    dd_string_stats_large{4} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large{4});
  end
  
  set(h.ax_stat_3_menu,'String',dd_string_stats_large);
  
  if get(h.radio_single_mode,'Value')==1
    dd_string_stats_large_x = cellstr(['x value         ';...
                                       'Filter size     ';...
                                       'Max overlap     ';...
                                       'Firing rate     ';...
                                       'Max correlation ';...
                                       'Mean correlation']);
    
    dd_string_stats_large_y = cellstr(['y value         ';...
                                       'Filter size     ';...
                                       'Max overlap     ';...
                                       'Firing rate     ';...
                                       'Max correlation ';...
                                       'Mean correlation']);
    
    if ~h.status(h.data.current_session).CaData
      dd_string_stats_large_x{4} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_x{4});
      dd_string_stats_large_x{5} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_x{5});
      dd_string_stats_large_x{6} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_x{6});
      dd_string_stats_large_y{4} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_y{4});
      dd_string_stats_large_y{5} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_y{5});
      dd_string_stats_large_y{6} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_y{6});
    end
  
  elseif get(h.radio_pairs_mode,'Value')==1
    dd_string_stats_large_x = cellstr(['x value             ';...
                                       'Overlap             ';
                                       'Distance            ';...
                                       'Temporal correlation']);
    
    dd_string_stats_large_y = cellstr(['y value             ';...
                                       'Overlap             ';
                                       'Distance            ';...
                                       'Temporal correlation']);
    if ~h.status(h.data.current_session).CaData
      dd_string_stats_large_x{4} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_x{4});
      dd_string_stats_large_y{4} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_y{4});
    end
  
  elseif get(h.radio_matching_mode,'Value')==1
    dd_string_stats_large_x = cellstr(['x value             ';...
                                       'Overlap             ';
                                       'Distance            ';...
                                       'Temporal correlation']);
    
    dd_string_stats_large_y = cellstr(['y value             ';...
                                       'Overlap             ';
                                       'Distance            ';...
                                       'Temporal correlation']);
    if ~h.status(h.data.current_session).CaData
      dd_string_stats_large_x{4} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_x{4});
      dd_string_stats_large_y{4} = sprintf('<html><font color="gray">%s</font></html>',dd_string_stats_large_y{4});
    end
  end
  
  set(h.ax_stat_3_1st_val_spec,'String',dd_string_stats_large_y,'Value',1)
  set(h.ax_stat_3_2nd_val_spec,'String',dd_string_stats_large_x,'Value',1)
  
  
  if h.status(h.data.current_session).ROIs
    set(h.ax_stat_1_menu,'enable','on')
    set(h.ax_stat_2_menu,'enable','on')
    set(h.ax_stat_3_menu,'enable','on')
  else
    set(h.ax_stat_1_menu,'enable','off')
    set(h.ax_stat_2_menu,'enable','off')
    set(h.ax_stat_3_menu,'enable','off')
  end
  
  
  

% --- Executes on button press in Ca_data_button.
function Ca_data_button_Callback(hObject, eventdata, h)
% hObject    handle to Ca_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  pathSearch = pathcat(get(h.session_spec,'String'),get(h.spec_Ca_path,'String'));
  [fileName, pathName] = uigetfile({'*.mat'},'Choose Calcium data file',pathSearch);
  
  if ischar(fileName)
    if ~strcmp(pathName,h.data.paths(h.data.current_session).session)
      fileName = erase(pathcat(pathName,fileName),h.data.paths(h.data.current_session).session);
      if strcmp(fileName(1),'/') || strcmp(fileName(1),'\')
        fileName = fileName(2:end);
      end
    end
    set(h.spec_Ca_path,'String',fileName)
    ChecknUpdate_button(fileName,'.mat',h.Ca_plot_button)
  end
  
  
function spec_Ca_path_Callback(hObject, eventdata, h)
% hObject    handle to spec_Ca_path (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_Ca_path as text
%        str2double(get(hObject,'String')) returns contents of spec_Ca_path as a double
  
  if ~h.status(h.data.current_session).CaData && h.status(h.data.current_session).ROIs
    ChecknUpdate_button(get(h.spec_Ca_path,'String'),'.mat',h.Ca_plot_button)
  elseif h.status(h.data.current_session).CaData
    set(hObject,'String',h.data.paths(h.data.current_session).CaData)
    msgbox('You can not change this path in this dataset anymore')
  end
  
  
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

% --- Executes on button press in Ca_plot_button.
function Ca_plot_button_Callback(hObject, eventdata, h)
% hObject    handle to Ca_plot_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  
%      set(h.background_plot_button,'enable','off')
%      set(h.ROI_plot_button,'enable','off')
  set(h.Ca_plot_button,'enable','off')
  set(h.Ca_data_button,'enable','off')
  set(h.spec_Ca_path,'enable','off')
  
  field_name = get(h.spec_Ca_field1,'String');
  Ca_data_tmp = LoadnResize(pathcat(get(h.session_spec,'String'),get(h.spec_Ca_path,'String')),[0,h.data.nROI(h.data.current_session)],sprintf('Could not find the field %s. Choose Calcium trace array',field_name),field_name);
  
%    noise_tmp = 0;
%    if numel(Ca_data_tmp) > 1
%      noise_tmp = LoadnResize(pathcat(get(h.session_spec,'String'),get(h.spec_Ca_path,'String')),[0,h.data.nROI(h.data.current_session)],'Choose Calcium noise array');
%    end
  
  S_tmp = 0;
  if numel(Ca_data_tmp) > 1
    field_name = get(h.spec_Ca_field2,'String');
    S_tmp = LoadnResize(pathcat(get(h.session_spec,'String'),get(h.spec_Ca_path,'String')),[0,h.data.nROI(h.data.current_session)],sprintf('Could not find the field %s. Choose deconvolved activity',field_name),field_name);
  end
  
  if numel(Ca_data_tmp) > 1% && numel(noise_tmp) > 1
    
    set(h.Ca_plot_button,'String','...')
    
    if h.data.nsessions > 1 && any(horzcat(h.status.CaData))
      CaData = getappdata(0,'CaData');
    end
    data = getappdata(0,'data');
    
    CaData(h.data.current_session).traces = Ca_data_tmp;
    h.parameter.t_max = size(CaData(h.data.current_session).traces,1);
    
    disp('Processing Calcium data...')
    CaData(h.data.current_session).time = linspace(1,h.parameter.t_max,h.parameter.t_max)/h.parameter.frq;
    nsd = 3;		%% threshold = nsd multiples of standard deviations above noise level
    
    if S_tmp == 0
      CY = CaData(h.data.current_session).traces;
      md = zeros(h.data.nROI(h.data.current_session),1);
      for n = 1:h.data.nROI(h.data.current_session)
        [bandwidth,density,xmesh]=kde(CY(:,n),2^floor(log2(h.parameter.t_max)-1));
        [~,id] = max(density);
        md(n) = xmesh(id);
        %bd(i) = bandwidth;
      end
      CaData(h.data.current_session).activity_thr = md + nsd*std(CY);
      CaData(h.data.current_session).activity = false(size(CaData(h.data.current_session).traces));
      nfr = 5;		%% number of frames above threshold counted as activity
      for n = 1:h.data.nROI(h.data.current_session)
        ff = CY(:,n) > CaData(h.data.current_session).activity_thr(n);
        CaData(h.data.current_session).activity(:,n) = bwareaopen(ff,nfr);
      end
    else
      CaData(h.data.current_session).activity = zeros(size(CaData(h.data.current_session).traces));
      for n = 1:h.data.nROI(h.data.current_session)
        %% store threshold and times in CaData
        CaData(h.data.current_session).activity_thr(n) = nsd*median(S_tmp(S_tmp(:,n)>0,n));  %% maybe choose differently?
        CaData(h.data.current_session).activity(:,n) = floor(S_tmp(:,n)/CaData(h.data.current_session).activity_thr(n));
      end
    end
    
    ROIs = getappdata(0,'ROIs');
    ROIs(h.data.current_session).n_events = sum(CaData(h.data.current_session).activity);
    ROIs(h.data.current_session).rate = ROIs(h.data.current_session).n_events/(h.parameter.t_max/h.parameter.frq);
    
    data(h.data.current_session).corr = get_CaCorr(CaData(h.data.current_session).traces);
    
    setappdata(0,'CaData',CaData);
    setappdata(0,'ROIs',ROIs);
    setappdata(0,'data',data);
    
    set(h.Ca_plot_button,'String','Add')
    set(h.button_export_ROI,'enable','on')
    
    h.status(h.data.current_session).CaData = true;
    h.data.paths(h.data.current_session).CaData = get(h.spec_Ca_path,'String');
    
    update_plot_menus(h)
    update_session_stat_display(h)
    guidata(hObject,h);
    disp('Succesfully loaded Calcium data!')
  else
    set(h.Ca_plot_button,'enable','on','String','Add')
    set(h.Ca_data_button,'enable','on')
  end
  
  set(h.spec_Ca_path,'enable','on')



function [corr_out] = get_CaCorr(traces)
    gcp;
    tic
    nROI = size(traces,2);
    par_traces = traces;   %% somehow parfor has problems with taking CaData itself...
    par_corr = zeros(nROI);
    parfor n = 1:nROI
      corr_tmp = zeros(nROI,1);
      for m = n+1:nROI
        cM = corrcoef(par_traces(:,n),par_traces(:,m));
        corr_tmp(m) = cM(1,2);
      end
      par_corr(n,:) = corr_tmp;
    end
    corr_out = triu(par_corr) + triu(par_corr,1)';
    toc
    
    
  
%% update functions
function [h] = update_ROI_select(h,ROI_idx,ROI_color,ROI_line)

  table_data = get(h.ROI_info_table,'Data');
  
  if get(h.radio_single_mode,'Value')   %% single mode
    
    n = ROI_idx(2);
    sn = ROI_idx(1);
    
    if ~h.status(sn).ROI_select(n)		%% update table with new ROI data
      ROIs = getappdata(0,'ROIs');
      
      h = update_highlighted(h,ROI_idx);
      
%        set(h.plots(sn).ROIs(n),'Color',ROI_color,'LineStyle',ROI_line)
      if get(h.drop_down_ROI_tag,'Value')>1
        set(h.plots(sn).ROI_tag(n),'Visible','on')
      end
      
      h.status(sn).ROI_select(n) = true;
      
      %% add ROI information to table
      if h.status(sn).CaData
        rate = ROIs(sn).rate(n);
      else
        rate = 'nA';
      end
      table_data(2:end+1,:) = table_data;
      table_data(1,:) = {true,...
                        sprintf('%4.0d',n),...
                        ROIs(sn).centroid(n,2), ROIs(sn).centroid(n,1),...
                        ROIs(sn).area(n),...
                        rate};
      h.ROI_status.add = true;
    else
      %% reset ROI appearance
      set(h.plots(sn).ROIs(n),'Color',get_ROI_color(h,sn));
      set(h.plots(sn).ROI_tag(n),'Visible','off');
      h.status(sn).ROI_select(n) = false;
      
      if ~isempty(h.ROI_status.highlight) && any(h.ROI_status.highlight(:,2)==n)
        h = update_highlighted(h,[]);
      end
      %% remove ROI data from table
      table_data(str2num(vertcat(table_data{:,2})) == n,:) = [];
      h.ROI_status.add = false;
    end
  
  elseif get(h.radio_pairs_mode,'Value')                                 %% pair mode
    
    n = ROI_idx(2);
    sn = ROI_idx(1);
    m = h.ROI_status.half_pair;
    
    if isempty(h.status(sn).ROI_paired(m).list) || ~ismember(n,h.status(sn).ROI_paired(m).list(:,2))
      
      h = update_highlighted(h,[ROI_idx;[sn m]]);
      
%        set(h.plots(sn).ROIs(n),'Color',ROI_color,'LineStyle',ROI_line)
%        set(h.plots(sn).ROIs(m),'Color',ROI_color,'LineStyle',ROI_line)
      
      if get(h.drop_down_ROI_tag,'Value')>1
        set(h.plots(sn).ROI_tag(n),'Visible','on')
        set(h.plots(sn).ROI_tag(m),'Visible','on')
      end
      h.status(sn).ROI_select(n) = true;
      h.status(sn).ROI_select(m) = true;
      
      h.status(sn).ROI_paired(n).list = [h.status(sn).ROI_paired(n).list; [sn m]];
      h.status(sn).ROI_paired(m).list = [h.status(sn).ROI_paired(m).list; [sn n]];
      
      %% update table
      data = getappdata(0,'data');
      if h.status(sn).CaData
        corr = data(sn).corr(m,n);
      else
        corr = 'nA';
      end
      if size(table_data,1) > 0
        table_data(2:end+1,:) = table_data;
      end
      table_data(1,:) = {true,...
                        sprintf('%4.0d',m),...
                        sprintf('%4.0d',n),...
                        data(sn).distance(m,n),...
                        data(sn).fp_corr(m,n),...
                        corr};
      h.ROI_status.add = true;
    else %% reset to unselected
      
      h.status(sn).ROI_paired(n).list(h.status(sn).ROI_paired(n).list(:,2)==m,:) = [];
      h.status(sn).ROI_paired(m).list(h.status(sn).ROI_paired(m).list(:,2)==n,:) = [];
      
      if isempty(h.status(sn).ROI_paired(n).list)
        set(h.plots(sn).ROIs(n),'Color',get_ROI_color(h,sn))
        set(h.plots(sn).ROI_tag(n),'Visible','off')
        h.status(sn).ROI_select(n) = false;
      end
      if isempty(h.status(sn).ROI_paired(m).list)
        set(h.plots(sn).ROIs(m),'Color',get_ROI_color(h,sn))
        set(h.plots(sn).ROI_tag(m),'Visible','off')
        h.status(sn).ROI_select(m) = false;
      else
        set(h.plots(sn).ROIs(m),'Color',ROI_color)
      end
      
      table_data(str2num(vertcat(table_data{:,2}))==n & str2num(vertcat(table_data{:,3}))==m,:) = [];
      if size(table_data,1) > 0
        table_data(str2num(vertcat(table_data{:,2}))==m & str2num(vertcat(table_data{:,3}))==n,:) = [];
      end
      
      if ismember(n,h.ROI_status.highlight) && ismember(m,h.ROI_status.highlight(:,2))
        h = update_highlighted(h,[]);
      end
      h.ROI_status.add = false;
    end
    
    
  elseif get(h.radio_matching_mode,'Value')
    
    if ~h.status(ROI_idx(1,1)).ROI_select(ROI_idx(1,2))
      
      h = update_highlighted(h,ROI_idx);
      
      for i = 1:size(ROI_idx,1)
        n = ROI_idx(i,2);
        sn = ROI_idx(i,1);
        
        %% set plot color
%          set(h.plots(sn).ROIs(n),'Color',ROI_color,'LineStyle',ROI_line)
        if get(h.drop_down_ROI_tag,'Value')>1 && sn == h.data.current_session
          set(h.plots(sn).ROI_tag(n),'Visible','on')
        end
        
        %% set selected status for both
        h.status(sn).ROI_select(n) = true;
      
        for j = i+1:size(ROI_idx,1)
          m = ROI_idx(j,2);
          sm = ROI_idx(j,1);
          
          %% set paired status for both
          h.status(sn).ROI_paired(n).list = [h.status(sn).ROI_paired(n).list; [sm m]];
          h.status(sm).ROI_paired(m).list = [h.status(sm).ROI_paired(m).list; [sn n]];
          
          %% new table entry
          data = getappdata(0,'data');
          CaData = getappdata(0,'CaData');
          ROIs = getappdata(0,'ROIs');
          if h.status(sn).CaData && h.status(sm).CaData
            corr = corrcoef(CaData(sm).traces(:,m),CaData(sn).traces(:,n));
            corr = corr(1,2);
          else
            corr = 'nA';
          end
          dist = sqrt((ROIs(sn).centroid(n,1)-ROIs(sm).centroid(m,1))^2+(ROIs(sn).centroid(n,2)-ROIs(sm).centroid(m,2))^2);
          fp_corr = (data(sn).A(:,n)'*data(sm).A(:,m))/(data(sn).normA(n)*data(sm).normA(m));
          
          table_data(2:end+1,:) = table_data(1:end,:);
          table_data(1,:) = {true,...
                            sprintf('%4.0d (%d)',n,sn),...
                            sprintf('%4.0d (%d)',m,sm),...
                            dist,...
                            fp_corr,...
                            corr};
        end
      end
      h.ROI_status.add = true;
    else
      for i = 1:size(ROI_idx,1)
        n = ROI_idx(i,2);
        sn = ROI_idx(i,1);
      
        set(h.plots(sn).ROIs(n),'Color',get_ROI_color(h,sn))
        h.status(sn).ROI_select(n) = false;
        h.status(sn).ROI_paired(n).list = [];
        set(h.plots(sn).ROI_tag(n),'Visible','off')
        for j = i+1:size(ROI_idx,1)
          m = ROI_idx(j,2);
          sm = ROI_idx(j,1); 
          
          for k=1:size(table_data,1)
            ROI_table = get_n_from_table(h,k);
            if ROI_table(1,1) == sn && ROI_table(1,2) == n && ROI_table(2,1) == sm && ROI_table(2,2) == m
              table_data(k,:) = [];
              break
            elseif ROI_table(1,1) == sm && ROI_table(1,2) == m && ROI_table(2,1) == sn && ROI_table(2,2) == n
              table_data(k,:) = [];
              break
            end
          end
        end
      end
      if ~isempty(h.ROI_status.highlight)
        h = update_highlighted(h,[]);
      end
      h.ROI_status.add = false;
    end
  end
  
  %% update all data
  set(h.ROI_info_table,'Data',table_data);
  update_selected_stats(h)


  
  
function [h] = update_highlighted(h,ROI_idx)
  
  if get(h.radio_matching_mode,'Value')==0
    
    sn = h.data.current_session;
    for n_tupel = h.ROI_status.highlight'
      n = n_tupel(2);
      
      if (get(h.radio_single_mode,'Value')==1) && ~h.status(sn).ROI_select(n)
        ROI_color = get_ROI_color(h,sn);
      elseif (get(h.radio_pairs_mode,'Value')==1) && isempty(h.status(sn).ROI_paired(n).list)
        ROI_color = get_ROI_color(h,sn);
      else
        ROI_color = 'r';
      end
      set(h.plots(sn).ROIs(n),'Color',ROI_color,'LineWidth',0.75);
    end
    h.ROI_status.highlight = [];
    if ~isempty(ROI_idx)
      for n_tupel = ROI_idx'
        n = n_tupel(2);
        set(h.plots(sn).ROIs(n),'Color','c','LineWidth',2);
        h.ROI_status.highlight = [h.ROI_status.highlight; [sn n]];
      end
    end
  
  else
    for n_tupel = h.ROI_status.highlight'
      n = n_tupel(2);
      sn = n_tupel(1);
      if (get(h.radio_single_mode,'Value')==1) && ~h.status(sn).ROI_select(n)
        ROI_color = get_ROI_color(h,sn);
      elseif (get(h.radio_pairs_mode,'Value')==1) && isempty(h.status(sn).ROI_paired(n).list)
        ROI_color = get_ROI_color(h,sn);
      else
        ROI_color = 'r';
      end
      set(h.plots(sn).ROIs(n),'Color',ROI_color,'LineWidth',0.75);
    end
    h.ROI_status.highlight = [];
    if ~isempty(ROI_idx)
      for n_tupel = ROI_idx'
        n = n_tupel(2);
        sn = n_tupel(1);
        set(h.plots(sn).ROIs(n),'Color','c','LineWidth',2);
        h.ROI_status.highlight = [h.ROI_status.highlight; [sn n]];
      end
    end
  end
  
  if ~isempty(ROI_idx)
    ROIs = getappdata(0,'ROIs');
    sn = h.ROI_status.highlight(1,1);
    n = h.ROI_status.highlight(1,2);
    set(h.text_stat_ID1,'String',sprintf('%d (%d)',n,sn))
    set(h.text_stat_area1,'String',sprintf('%g',ROIs(sn).area(n)))
    if h.status(sn).CaData
      set(h.text_stat_rate1,'String',sprintf('%g',ROIs(sn).rate(n)));
    end
    
    if size(h.ROI_status.highlight,1)>1
      sn = h.ROI_status.highlight(2,1);
      n = h.ROI_status.highlight(2,2);
      set(h.text_stat_ID2,'String',sprintf('%d (%d)',n,sn))
      set(h.text_stat_area2,'String',sprintf('%5.3g',ROIs(sn).area(n)))
      if h.status(sn).CaData
        set(h.text_stat_rate2,'String',sprintf('%5.3g',ROIs(sn).rate(n)));
      end
    end
  end
  
%% clear table 
function [h] = clear_selection(h)
  
  set(h.ROI_info_table,'Data',cell(0,6));
  h.ROI_status.half_pair = 0;
  for s = 1:h.data.nsessions
    if h.status(s).ROIs
      h.status(s).ROI_select(:) = false;
      h.ROI_status.highlight = [];
      for n=1:h.data.nROI(s)
        if h.status(s).ROI_retain(n)
          set(h.plots(s).ROIs(n),'Color',get_ROI_color(h,s),'LineWidth',0.75);
          set(h.plots(s).ROI_tag(n),'Visible','off');
%            if get(h.radio_matching_mode,'Value')
%              h.status(s).ROI_paired(n).list = zeros(0,2);
%            elseif get(h.radio_pairs_mode,'Value')
          h.status(s).ROI_paired(n).list = [];
%            end
        end
      end
    end
  end
  cla(h.ax_stat_1,'reset')
  cla(h.ax_stat_2,'reset')
  
  update_selected_stats(h)
  
% --- Executes during object creation, after setting all properties.
function mass_select_thr_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to mass_select_thr_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function update_mass_select(hObject,eventdata,h)
  
  
  %% should be handled differently for pairs: no "kicking down the table" - only append (and preinitiate with thresholding)
  if get(h.mass_select_checkbox,'Value')
    data = getappdata(0,'data');
    sn = h.data.current_session;
    
    if get(h.radio_single_mode,'Value')
      h = clear_selection(h);
      
      corr_thr = str2double(get(h.mass_select_thr_spec,'String'));
      mode = h.drop_down_mass_select_string_single{get(h.drop_down_mass_select,'Value')};
      
      %% get data and values to compare to threshold
      switch mode
        case 'None'
          
        case 'Spatial correlation'
          values = max(data(sn).fp_corr,[],2);
        case {'Filter size','Firing rate','border proximity'}
          ROIs = getappdata(0,'ROIs');
          switch mode
            case 'Filter size'
              values = ROIs(sn).area;
            case 'Firing rate'
              if h.status(sn).CaData
                values = ROIs(sn).rate;
              end
            case 'border proximity'
              x_pos = ROIs(sn).centroid(:,2)+h.data.shift(h.data.current_session,1);
              y_pos = ROIs(sn).centroid(:,1)+h.data.shift(h.data.current_session,2);
              values = min(min(y_pos-1,h.parameter.imSize(1)-y_pos),min(x_pos-1,h.parameter.imSize(2)-x_pos));
          end
        case 'Temporal correlation'
          if h.status(sn).CaData
            values = max(data(sn).corr,[],2);
          end
        otherwise
        disp('nothing to do')
      end
      
      if exist('values','var')
        switch h.drop_down_mass_select_thr_string{get(h.drop_down_mass_select_thr,'Value')}
          case '<'
            ROI_idx_list = find(values < corr_thr);
          case '>'
            ROI_idx_list = find(values > corr_thr);
        end
        
        %% fill anew
        if ~isempty(ROI_idx_list)
          for i=1:length(ROI_idx_list)
            n = ROI_idx_list(i);
            if h.status(sn).ROI_retain(n)
              h = update_ROI_select(h,[sn n],'r','-');
            end
          end
        end
      end
      
      dd_string_stats_small = get(h.ax_stat_1_menu,'String');
      plotType = dd_string_stats_small{get(h.ax_stat_1_menu,'Value')};
      if ~strcmp(plotType,'Correlation raster')
        set(h.ax_stat_1_menu,'Value',1)
      end
      
      dd_string_stats_small = get(h.ax_stat_2_menu,'String');
      plotType = dd_string_stats_small{get(h.ax_stat_2_menu,'Value')};
      if ~strcmp(plotType,'Correlation raster')
        set(h.ax_stat_2_menu,'Value',1)
      end
      
      h = update_plots(h,[]);
      
      dd_string_stats_large = get(h.ax_stat_3_menu,'String');
      plotType = dd_string_stats_large{get(h.ax_stat_3_menu,'Value')};
      if get(h.checkbox_select_in_stats,'Value') && (strcmp(plotType,'Histogram') || strcmp(plotType,'Scatter'))
        h = update_stats_plot(h,plotType,h.ax_stat_3);
      end
    
    elseif get(h.radio_pairs_mode,'Value')
      
      corr_thr = str2double(get(h.mass_select_thr_spec,'String'));
      mode = h.drop_down_mass_select_string_pair{get(h.drop_down_mass_select,'Value')};
      
      %% get data and values to compare to threshold
      switch mode
        case 'None'
          
        case 'Temporal correlation'
          values = data(sn).corr;
        case 'Spatial correlation'
          values = data(sn).fp_corr;
        case 'Distance'
          values = data(sn).distance;
      end
      
      if ~strcmp(mode,'None')
        for i=1:h.data.nROI(sn)
          values(i,i) = nan;
          if ~h.status(sn).ROI_retain(i)
            values(i,:) = nan;
            values(:,i) = nan;
          end
        end
        
        if h.ROI_status.half_pair
          mask = false(size(values));
          mask(:,h.ROI_status.half_pair) = true;
          mask(h.ROI_status.half_pair,:) = true;
        else
          mask = true(size(values));
        end
        
        h = clear_selection(h);
        
        if exist('values','var')
          switch h.drop_down_mass_select_thr_string{get(h.drop_down_mass_select_thr,'Value')}
            case '<'
              [ROI_list_n, ROI_list_m] = find(values < corr_thr & mask);
            case '>'
              [ROI_list_n, ROI_list_m] = find(values > corr_thr & mask); 
          end
          ROI_idx_unique = unique([ROI_list_n,ROI_list_m]);
          
          disp(sprintf('%d ROIs are tagged, with %5.0f pairs in total',length(ROI_idx_unique), length(ROI_list_n)/2))
          for i = 1:length(ROI_idx_unique)
            n = ROI_idx_unique(i);
            set(h.plots(sn).ROIs(n),'Color','r')              
            if get(h.drop_down_ROI_tag,'Value')>1
              set(h.plots(sn).ROI_tag(n),'Visible','on')
            end
            h.status(sn).ROI_select(n) = true;
          end
          
          table_data = cell(0,6);
          %% fill anew
          j = 0;
          if ~isempty(ROI_list_n)
            for i=1:length(ROI_list_n)
              n = ROI_list_n(i);
              m = ROI_list_m(i);
              if n>m && h.status(sn).ROI_retain(n) && h.status(sn).ROI_retain(m)
                j = j+1;
                
                h.status(sn).ROI_paired(n).list = [h.status(sn).ROI_paired(n).list; [sn m]];
                h.status(sn).ROI_paired(m).list = [h.status(sn).ROI_paired(m).list; [sn n]];
                
                if j <= 100
                  if h.status(sn).CaData
                    corr = data(sn).corr(n,m);
                  else
                    corr = 'nA';
                  end
                  table_data(j,:) = {true,...
                      sprintf('%4.0d',n),...
                      sprintf('%4.0d',m),...
                      data(sn).distance(n,m),...
                      data(sn).fp_corr(n,m),...
                      corr};
                end
              end
            end
          end
        else
          table_data = cell(0,6);
        end
        
        set(h.ROI_info_table,'Data',table_data)
        
        h = update_plots(h,[]);
        
        dd_string_stats_small = get(h.ax_stat_3_menu,'String');
        plotType = dd_string_stats_small{get(h.ax_stat_3_menu,'Value')};
        if get(h.checkbox_select_in_stats,'Value') && (strcmp(plotType,'Histogram') || strcmp(plotType,'Scatter'))
          h = update_stats_plot(h,plotType,h.ax_stat_3);
        end
      end
      
      h.ROI_status.half_pair = 0;
    end
  elseif eq(hObject,h.mass_select_checkbox)
    h = clear_selection(h);
  end
  update_selected_stats(h)
  guidata(hObject,h);
  
  


% --- Executes on selection change in drop_down_ROI_tag.
function drop_down_ROI_tag_Callback(hObject, eventdata, h)
% hObject    handle to drop_down_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns drop_down_ROI_tag contents as cell array
%        contents{get(hObject,'Value')} returns selected item from drop_down_ROI_tag
  
  set(hObject,'enable','off');
%    set(h.ROI_tag_checkbox,'enable','off');
  if strcmp(h.status(h.data.current_session).ROI_tag,h.drop_down_ROI_tag_string{get(h.drop_down_ROI_tag,'Value')});
    disp('nothing')
  else
    h.status(h.data.current_session).ROI_tag = h.drop_down_ROI_tag_string{get(h.drop_down_ROI_tag,'Value')};
    h.status(h.data.current_session).ROI_tag
    for n=1:h.data.nROI(h.data.current_session)
      switch h.status(h.data.current_session).ROI_tag;
        case 'ROI ID'
          ROI_tag = sprintf('%d',n);
          if h.status(h.data.current_session).ROI_select(n)
            set(h.plots(h.data.current_session).ROI_tag(n),'Visible','on')
          end
        case 'Firing rate'
          if h.status(h.data.current_session).CaData
            ROIs = getappdata(0,'ROIs');
            ROI_tag = sprintf('%3.1f',ROIs(h.data.current_session).rate(n));
          else
            ROI_tag ='';
          end
          if h.status(h.data.current_session).ROI_select(n)
            set(h.plots(h.data.current_session).ROI_tag(n),'Visible','on')
          end
        case 'ROI tag'
          ROI_tag ='';
          set(h.plots(h.data.current_session).ROI_tag(n),'Visible','off')
    %  	case 'Pair ID'
      end
      set(h.plots(h.data.current_session).ROI_tag(n),'String',ROI_tag)
    end
    guidata(hObject,h);
  end
  
  
  set(hObject,'enable','on');      
%    set(h.ROI_tag_checkbox,'enable','on');      
      
      

% --- Executes during object creation, after setting all properties.
function drop_down_ROI_tag_CreateFcn(hObject, eventdata, h)
% hObject    handle to drop_down_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ax_stat_3_lin_log.
function ax_stat_3_lin_log_Callback(hObject, eventdata, h)
% hObject    handle to ax_stat_3_lin_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ax_stat_3_lin_log contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ax_stat_3_lin_log
  
  lin_log_string = get(hObject,'String');
  lin_log = lin_log_string{get(hObject,'Value')};
  %% in case of histogram: replot!
  plotType_string = get(h.ax_stat_3_menu,'String');
  plotType = plotType_string{get(h.ax_stat_3_menu,'Value')};
  
  switch plotType
    case 'Scatter'
      switch lin_log
	case 'lin-log'
	  set(h.ax_stat_3,'xscale','log')
	  set(h.ax_stat_3,'yscale','lin')
	case 'lin-lin'
	  set(h.ax_stat_3,'xscale','lin')
	  set(h.ax_stat_3,'yscale','lin')
	case 'log-lin'
	  set(h.ax_stat_3,'xscale','lin')
	  set(h.ax_stat_3,'yscale','log')
	case 'log-log'
	  set(h.ax_stat_3,'xscale','log')
	  set(h.ax_stat_3,'yscale','log')
	otherwise
      end
    case 'Histogram'
      plot_histogram(h,h.ax_stat_3)
    otherwise
  end
  

% --- Executes during object creation, after setting all properties.
function ax_stat_3_lin_log_CreateFcn(hObject, eventdata, h)
% hObject    handle to ax_stat_3_lin_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ax_stat_3_histo_bin_spec_Callback(hObject, eventdata, h)
% hObject    handle to ax_stat_3_histo_bin_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ax_stat_3_histo_bin_spec as text
%        str2double(get(hObject,'String')) returns contents of ax_stat_3_histo_bin_spec as a double
  
  plot_histogram(h,h.ax_stat_3);
  

% --- Executes during object creation, after setting all properties.
function ax_stat_3_histo_bin_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to ax_stat_3_histo_bin_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on selection change in ax_stat_1_lin_log.
function ax_stat_1_lin_log_Callback(hObject, eventdata, h)
% hObject    handle to ax_stat_1_lin_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ax_stat_1_lin_log contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ax_stat_1_lin_log


% --- Executes during object creation, after setting all properties.
function ax_stat_1_lin_log_CreateFcn(hObject, eventdata, h)
% hObject    handle to ax_stat_1_lin_log (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in save_figure_button.
function save_figure_button_Callback(hObject, eventdata, h)
% hObject    handle to save_figure_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  save_mode = h.drop_down_save_string{get(h.drop_down_save_fig_spec,'Value')};
  save_path = get(h.save_path_spec,'String');
  
  switch save_mode
    case 'Figure: Axis 1'
      suffix = h.save_file_extensions_string_fig{get(h.save_file_extension_spec,'Value')};
      export_fig(h.ax_stat_1,save_path,sprintf('-%s',suffix))
      msg = sprintf('Saved axis 1 in %s-format to path "%s"!',suffix,save_path);
    case 'Figure: Axis 2'
      suffix = h.save_file_extensions_string_fig{get(h.save_file_extension_spec,'Value')};
      export_fig(h.ax_stat_2,save_path,sprintf('-%s',suffix))
      msg = sprintf('Saved axis 2 in %s-format to path "%s"!',suffix,save_path);
    case 'Figure: Axis 3'
      suffix = h.save_file_extensions_string_fig{get(h.save_file_extension_spec,'Value')};
      export_fig(h.ax_stat_3,save_path,sprintf('-%s',suffix))
      msg = sprintf('Saved axis 3 in %s-format to path "%s"!',suffix,save_path);
    case 'Figure: Axis 4'
      suffix = h.save_file_extensions_string_fig{get(h.save_file_extension_spec,'Value')};
      export_fig(h.ax_ROIs,save_path,sprintf('-%s',suffix))
      msg = sprintf('Saved axis 4 in %s-format to path "%s"!',suffix,save_path);
    case 'Figure: whole GUI'
      suffix = h.save_file_extensions_string_fig{get(h.save_file_extension_spec,'Value')};
      export_fig(save_path,sprintf('-%s',suffix))
      msg = sprintf('Saved current GUI in %s-format to path "%s"!',suffix,save_path);
    case 'Data: current ROIs'
      suffix = h.save_file_extensions_string_data{get(h.save_file_extension_spec,'Value')};
      %% gather data
      data = getappdata(0,'data');
      CaData = getappdata(0,'CaData');
      
      %% put retained ROIs into arrays
      ROI_idx_list = find(h.status(h.data.current_session).ROI_retain);
      A = data(h.data.current_session).A(:,ROI_idx_list);
      V = CaData(h.data.current_session).traces(:,ROI_idx_list);
      
      %% and save
      save(save_path,'A','V','-v7.3')
      msg = sprintf('Saved current ROI data to mat-file in path "%s"!',save_path);
    otherwise
  end
  uiwait(msgbox(msg));

function save_path_spec_Callback(hObject, eventdata, h)
% hObject    handle to save_path_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of save_path_spec as text
%        str2double(get(hObject,'String')) returns contents of save_path_spec as a double

  if ~isempty(get(hObject,'String'))
    set(h.save_figure_button,'enable','on')
  else
    set(h.save_figure_button,'enable','off')
  end

% --- Executes during object creation, after setting all properties.
function save_path_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to save_path_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in save_path_choose.
function save_path_choose_Callback(hObject, eventdata, h)
% hObject    handle to save_path_choose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  [fileName, pathName] = uiputfile({'*.png';'*.jpg';'*.fig';'*.pdf'},'Choose path to save to',get(h.save_path_spec,'String'));
  
  if ~(fileName==0)
    save_file_string = pathcat(pathName,fileName);
    set(h.save_path_spec,'String',save_file_string(1:end-4))
    
    if ~isempty(get(h.save_path_spec,'String'))
      set(h.save_figure_button,'enable','on')
    else
      set(h.save_figure_button,'enable','off')
    end
  end
  

% --- Executes on selection change in drop_down_save_fig_spec.
function drop_down_save_fig_spec_Callback(hObject, eventdata, h)
% hObject    handle to drop_down_save_fig_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns drop_down_save_fig_spec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from drop_down_save_fig_spec
  
  save_mode = h.drop_down_save_string{get(hObject,'Value')};
  if strcmp(save_mode(1:6),'Figure')
    set(h.save_file_extension_spec,'enable','on','String',h.save_file_extensions_string_fig)
    if ~isempty(get(h.save_path_spec,'String'))
      set(h.save_figure_button,'enable','on')
    else
      set(h.save_figure_button,'enable','off')
    end
  elseif strcmp(save_mode(1:4),'Data')
    set(h.save_file_extension_spec,'enable','on','String',h.save_file_extensions_string_data,'Value',1)
    if ~isempty(get(h.save_path_spec,'String')) && h.status(h.data.current_session).CaData
      set(h.save_figure_button,'enable','on')
    else
      set(h.save_figure_button,'enable','off')
    end
  else
    set(h.save_file_extension_spec,'enable','off')
  end

% --- Executes during object creation, after setting all properties.
function drop_down_save_fig_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to drop_down_save_fig_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in button_remove_ROI.
function button_remove_ROI_Callback(hObject, eventdata, h)
% hObject    handle to button_remove_ROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
  ROI_idx_list = find(h.status(h.data.current_session).ROI_select);
  nROI_remove = numel(ROI_idx_list);
  
  choice = questdlg(sprintf('You are about to remove %d ROIs from the dataset. This change will not be permanent until you export the current data to a data file.\n Do you want to proceed?',nROI_remove),'Remove ROIs','No','Yes','No');
  
  msgbox('implement check, that only ROIs from current session are selected')
  switch choice
    case 'Yes'
      for i = 1:nROI_remove
        n = ROI_idx_list(i);
        h = update_ROI_select(h,[h.data.current_session n],get_ROI_color(h,h.data.current_session),':');
        h.status(h.data.current_session).ROI_retain(n) = false;
    %      delete(h.plots(h.data.current_session).ROIs(n));
      end
      update_session_stat_display(h)
      guidata(hObject,h);
    case 'No'
    
  end
%      Think about how to remove them: directly purge them from data, or rather have a list of "ok" vs "removed" and have linestyle of removed ones set to ":", ignore them in plotting and get this list later when saving the ROIs to data?
  
    
    
    
% --- Executes on button press in merge_ROI_button.
function merge_ROI_button_Callback(hObject, eventdata, h)
% hObject    handle to merge_ROI_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in ax_stat_3_1st_val_spec.
function ax_stat_3_1st_val_spec_Callback(hObject, eventdata, h)
% hObject    handle to ax_stat_3_1st_val_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ax_stat_3_1st_val_spec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ax_stat_3_1st_val_spec

  contents = cellstr(get(h.ax_stat_3_menu,'String'));
  switch contents{get(h.ax_stat_3_menu,'Value')};
    case 'Scatter'
      if get(hObject,'Value') > 1 && get(h.ax_stat_3_2nd_val_spec,'Value') > 1
	plot_scatter(h,h.ax_stat_3);
      end
    case 'Histogram'
      if get(hObject,'Value') > 1
	plot_histogram(h,h.ax_stat_3);
      end
    otherwise
      disp('what happened?')
  end  
  
  

% --- Executes during object creation, after setting all properties.
function ax_stat_3_1st_val_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to ax_stat_3_1st_val_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ax_stat_3_2nd_val_spec.
function ax_stat_3_2nd_val_spec_Callback(hObject, eventdata, h)
% hObject    handle to ax_stat_3_2nd_val_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ax_stat_3_2nd_val_spec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ax_stat_3_2nd_val_spec
  
  if get(h.ax_stat_3_1st_val_spec,'Value') > 1 && get(hObject,'Value') > 1
    plot_scatter(h,h.ax_stat_3);
  end

% --- Executes during object creation, after setting all properties.
function ax_stat_3_2nd_val_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to ax_stat_3_2nd_val_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%% plot functions
function update_filter(h,ax,ROI_idx)
  
  set(ax,'ButtonDownFcn',[]);
  set(gcf,'WindowButtonMotionFcn',[]);
  
  sn = ROI_idx(1);
  n = ROI_idx(2);
  
  cla(ax,'reset')
  
  ROIs = getappdata(0,'ROIs');
  
%    hold(ax,'on')
  
  imagesc(ROIs(sn).filter(n).shape,'Parent',ax)%,'XData',[1,h.parameter.diameter],'YData',[1,h.parameter.diameter]);
  colormap(ax,'gray');
  if get(h.radio_matching_mode,'Value')
    text('Units','normalized','Position',[0.05 0.05],'String',sprintf('ROI #%d (%d)',n,sn),'Color','r','Parent',ax);    
  else
    text('Units','normalized','Position',[0.05 0.05],'String',sprintf('ROI #%d',n),'Color','r','Parent',ax); 
  end
%    hold(ax,'off')
  low_dec_x = floor(ROIs(sn).filter(n).extent(2,1)/10)*10;
  low_dec_y = floor(ROIs(sn).filter(n).extent(1,1)/10)*10;
  ticks = linspace(0,h.parameter.diameter-1,floor(h.parameter.diameter/10)+1);
  
  %% update axis options
  set(ax,'XTick',(low_dec_x-ROIs(sn).filter(n).extent(2,1))+ticks,...
	'XTickLabel',low_dec_x+ticks,...
    'YDir','reverse',...
	'YTick',(low_dec_y-ROIs(sn).filter(n).extent(1,1))+ticks,...
	'YTickLabel',low_dec_y+ticks,...
	'TickDir','out')
  drawnow


function update_CaTrace(h,ax,ROI_idx)
  
  set(ax,'ButtonDownFcn',[]);
  set(gcf,'WindowButtonMotionFcn',[]);
  
  sn_list = ROI_idx(:,1);
  n_list = ROI_idx(:,2);
  
  cla(ax,'reset')
  
  CaData = getappdata(0,'CaData');
  color = {'r','b'};
  hold(ax,'on')
  for i = 1:length(n_list)
    n = n_list(i);
    sn = sn_list(i);
    y_max = max(CaData(sn).traces(:,n))*1.2;
    if get(h.radio_matching_mode,'Value')
      p3(i) = plot(ax,CaData(sn).time,CaData(sn).traces(:,n)/y_max,'Color',color{i},'LineStyle','-','DisplayName',sprintf('ROI #%d  (%d)',n,sn));
    else
      p3(i) = plot(ax,CaData(sn).time,CaData(sn).traces(:,n)/y_max,'Color',color{i},'LineStyle','-','DisplayName',sprintf('ROI #%d',n));
    end
    p1(i) = scatter(ax,CaData(sn).time(CaData(sn).activity(:,n)>0),CaData(sn).traces(CaData(sn).activity(:,n)>0,n)/y_max,'k.','SizeData',50);
    set(get(get(p1(i),'Annotation'),'LegendInformation'),'IconDisplayStyle','off')
  end
  if length(n_list)==1
    p4 = plot(ax,[0 h.parameter.t_max/h.parameter.frq],[CaData(sn).activity_thr(n_list(1)) CaData(sn).activity_thr(n_list(1))]/y_max,'--k','DisplayName','noise lvl');
  end
  legend(ax,'show')
  hold(ax,'off')
  
  set(get(ax,'XLabel'),'String','time [s]');
  set(ax,'TickDir','in')
  drawnow
  
  
function plot_spikeTrain(h,ax,ROI_idx)
  
  %% should be possible without setting axes globally
  set(ax,'ButtonDownFcn',[]);
  set(gcf,'WindowButtonMotionFcn',[]);
  
  sn_list = ROI_idx(:,1);
  n_list = ROI_idx(:,2);
  
  cla(ax,'reset')
  
  CaData = getappdata(0,'CaData');
  
  color = {'r','b'};
  hold(ax,'on')
  for i = 1:length(n_list)
    n = n_list(i);
    sn = sn_list(i);
    plot(ax,CaData(sn).time,((CaData(sn).activity(:,n)>0)+(i-1))/length(n_list),'Color',color{i},'LineStyle','-','DisplayName',sprintf('ROI #%d (%d)',n,sn));
  end
  legend(ax,'show')
  hold(ax,'off')
  
  %% update axis options
  ylim(ax,[0,1])
  set(ax,'YTick',[],...
	'YTickLabel',[])
  
  set(get(ax,'XLabel'),'String','time [s]');
  set(ax,'TickDir','in')
  drawnow
  

function [h] = plot_CorrRaster(h,ax)
  
  cla(ax,'reset')
  
  data = getappdata(0,'data');
  corr_tmp = data(h.data.current_session).corr;
  val_label = 'Temporal correlation';
  
  sn = h.data.current_session;
  
  corr_plt = zeros(nnz(h.status(sn).ROI_select));
  j=0;
  for n = find(h.status(sn).ROI_select)'
      j=j+1;
      corr_slice = corr_tmp(h.status(sn).ROI_select,n);
      corr_plt(:,j) = corr_slice;
  end
  
  %% remove entries of removed neurons (later) (shouldnt be needed - can't be selected anywho!)
  
  %% sort the correlation matrix (later... how to do that efficiently? and sort by what?)
  if eq(ax,h.ax_stat_1)
    idx = 1;
  elseif eq(ax,h.ax_stat_2)
    idx = 2;
  end
  
  h.plots(1).corr(idx) = imagesc(ax,corr_plt,'Hittest','off');
  colormap(ax,'jet')
  set(ax,'clim',[-0.2 1])
  colorbar('peer',ax)
  
  
  
  h.plots(1).corrtext(idx) = text('Units','normalized','Position',[0 -0.05],'String','','Color','k','Parent',ax); 
  set(ax,'XTick',[],...
	'XTickLabel',[],...
	'YTick',[],...
	'YTickLabel',[])
  
  set(ax,'ButtonDownFcn',{@highlight_ROI_from_corr,ax},'Hittest','on','PickableParts','All');
%    set(gcf,'WindowButtonMotionFcn',{@MouseOverCorr,ax});
  

  
function MouseOver_getAx(hObject,eventdata)
  
  h = guidata(hObject);
  if h.status(h.data.current_session).ROIs
    pos = get(gcf,'CurrentPoint');
    
    dd_string_stats_small = get(h.ax_stat_1_menu,'String');
    %% if over axes_stat_1
    if pos(1,1) >= h.ax_stat_1.Position(1) && pos(1,1) <= h.ax_stat_1.Position(1)+h.ax_stat_1.Position(3) && pos(1,2) >= h.ax_stat_1.Position(2) && pos(1,2) <= h.ax_stat_1.Position(2)+h.ax_stat_1.Position(4)
      plotType = dd_string_stats_small{get(h.ax_stat_1_menu,'Value')};
      if strcmp(plotType,'Correlation raster')
        ROI_ID = get_ROI_ID_from_corrPlot(h,h.ax_stat_1);
        set(h.plots(1).corrtext(1),'String',sprintf('ROI ID: (%d,%d)',ROI_ID(1,2),ROI_ID(2,2)))
      end
    else
      try
        set(h.plots(1).corrtext(1),'String','')
      catch
      end
    end
    
    
    %% if over axes_stat_2
    if pos(1,1) >= h.ax_stat_2.Position(1) && pos(1,1) <= h.ax_stat_2.Position(1)+h.ax_stat_2.Position(3) && pos(1,2) >= h.ax_stat_2.Position(2) && pos(1,2) <= h.ax_stat_2.Position(2)+h.ax_stat_2.Position(4)
      plotType = dd_string_stats_small{get(h.ax_stat_2_menu,'Value')};
      if strcmp(plotType,'Correlation raster')
        ROI_ID = get_ROI_ID_from_corrPlot(h,h.ax_stat_2);
        set(h.plots(1).corrtext(2),'String',sprintf('ROI ID: (%d,%d)',ROI_ID(1,2),ROI_ID(2,2)))
      end
%        set(h.plots(1).ROI_text,'String','');
    else
      try
        set(h.plots(1).corrtext(2),'String','')
      catch
      end
    end
    
    %% if over axes_stat_3
    if pos(1,1) >= h.ax_stat_3.Position(1) && pos(1,1) <= h.ax_stat_3.Position(1)+h.ax_stat_3.Position(3) && pos(1,2) >= h.ax_stat_3.Position(2) && pos(1,2) <= h.ax_stat_3.Position(2)+h.ax_stat_3.Position(4)
%        disp('over ax 3!')
    end
    
    %% if over axes_ROIs
    if pos(1,1) >= h.ax_ROIs.Position(1) && pos(1,1) <= h.ax_ROIs.Position(1)+h.ax_ROIs.Position(3) && pos(1,2) >= h.ax_ROIs.Position(2) && pos(1,2) <= h.ax_ROIs.Position(2)+h.ax_ROIs.Position(4)
      
      coords = get(h.ax_ROIs,'CurrentPoint');
      
      ROIs = getappdata(0,'ROIs');
      
      sn = h.data.current_session;
      [min_val n] = min(sum((ROIs(sn).centroid(:,1)-coords(1,2)).^2 + (ROIs(sn).centroid(:,2)-coords(1,1)).^2,2));
      stringROI = sprintf('(x,y): (%3.1f,%3.1f)',coords(1,1),coords(1,2)); 
      if sqrt(min_val) < 10
        stringROI = sprintf('%s\nROI ID: %d (%d)',stringROI,n,sn);
      end
      set(h.plots(1).ROI_text,'String',stringROI); 
    
%        disp('over ax ROI!')
  %    else
  %      disp('somwehere')
    else
      set(h.plots(1).ROI_text,'String','');
    end
  end
  
  
  
function highlight_ROI_from_corr(hObject,eventdata,ax,pos)
  
  h = guidata(hObject);
  ROI_idx = get_ROI_ID_from_corrPlot(h,ax);
  h = update_highlighted(h,ROI_idx);
%    set(h.ROI_info_table,'Value')
  h = update_plots(h,ROI_idx);
  guidata(hObject,h);
  


function [ROI_ID] = get_ROI_ID_from_corrPlot(h,ax);
  
  pos = get(ax,'CurrentPoint');
  
  raster_num_x = round(pos(1,2));
  raster_num_y = round(pos(1,1));
  
  ROI_ID_list = find(h.status(h.data.current_session).ROI_select);
  ROI_ID = [[h.data.current_session ROI_ID_list(raster_num_x)];[h.data.current_session ROI_ID_list(raster_num_y)]];
  


function plot_scatter(h,ax)
  
  if get(h.checkbox_fix_xlim,'Value')
    xlimits = xlim(ax);
  end
  
  property_string = get(h.ax_stat_3_1st_val_spec,'String');
  yval_string = property_string{get(h.ax_stat_3_1st_val_spec,'Value')};
  [yval, ylabel] = get_plot_data(h,yval_string);
  
  xval_string = property_string{get(h.ax_stat_3_2nd_val_spec,'Value')};
  [xval, xlabel] = get_plot_data(h,xval_string);
  
  lin_log_string = get(h.ax_stat_3_lin_log,'String');
  lin_log = lin_log_string{get(h.ax_stat_3_lin_log,'Value')};
  if sum(xval(:)<0)>0 && (strcmp(lin_log,'lin-log') || strcmp(lin_log,'log-log'))
    set(h.ax_stat_3_lin_log,'Value',1)
  end
  
  scatter(ax,xval,yval,'b','.')
  
  %% update axis options
  set(get(ax,'XLabel'),'String',xlabel);
  set(get(ax,'YLabel'),'String',ylabel);
  set(ax,'TickDir','in')
  
  
  switch lin_log
    case 'lin-lin'
      xscale = 'lin';
      yscale = 'lin';
    case 'lin-log'
      if sum(xval(:)<0)>0
        set(h.ax_stat_3_lin_log,'Value',1)
        xscale = 'lin';
      else
        xscale = 'log';
      end
      yscale = 'lin';
    case 'log-lin'
      xscale = 'lin';
      if sum(yval(:)<0)>0
        set(h.ax_stat_3_lin_log,'Value',1)
        yscale = 'lin';
      else
        yscale = 'log';
      end
    case 'log-log'
      if sum(xval(:)<0)>0
        set(h.ax_stat_3_lin_log,'Value',1)
        xscale = 'lin';
      else
        xscale = 'log';
      end
      if sum(yval(:)<0)>0
        set(h.ax_stat_3_lin_log,'Value',1)
        yscale = 'lin';
      else
        yscale = 'log';
      end
    otherwise
  end
  set(ax,'xscale',xscale,'yscale',yscale)
  if get(h.checkbox_fix_xlim,'Value')
    xlim(ax,[xlimits(1),xlimits(2)])
  end
  drawnow
  

function plot_histogram(h,ax)
  
  
  if get(h.checkbox_fix_xlim,'Value')
    xlimits = xlim(ax);
    xlimits
  end
  
  cla(ax,'reset')
  
  property_string = get(h.ax_stat_3_1st_val_spec,'String');
  val_string = property_string{get(h.ax_stat_3_1st_val_spec,'Value')};
  [val, xlabel] = get_plot_data(h,val_string);
  bin_num = ceil(str2double(get(h.ax_stat_3_histo_bin_spec,'String')));
  
  max_val = max(val(:));
  xmax = ceil(max_val/(10^floor(log10(max_val))))*10^floor(log10(max_val));
  
  lin_log_string = get(h.ax_stat_3_lin_log,'String');
  lin_log = lin_log_string{get(h.ax_stat_3_lin_log,'Value')};
  
  if sum(val(:)<0)>0 && (strcmp(lin_log,'lin-log') || strcmp(lin_log,'log-log'))
    msgbox('Data contains negative values, axes set back to linear')
    lin_log = 'lin-lin';
    set(h.ax_stat_3_lin_log,'Value',1)
    set(h.checkbox_fix_xlim,'Value',0)
  end
%    axes(ax)
  switch lin_log
    case 'lin-lin'
      if get(h.checkbox_fix_xlim,'Value')
        bins = linspace(xlimits(1),xlimits(2),bin_num+1);
      else
        min_val = nanmin(val(:));
        if ~(min_val==0)
          xmin = floor(min_val/(10^floor(log10(abs(min_val)))))*10^floor(log10(abs(min_val)));
        else
          xmin = 0;
        end
        xmin
        bins = linspace(xmin,xmax,bin_num+1);
      end
      xscale = 'lin';
      yscale = 'lin';
    case 'lin-log'
      if get(h.checkbox_fix_xlim,'Value')
        bins = logspace(log10(xlimits(1)),log10(xlimits(2)),bin_num+1);
      else
        min_val = nanmin(val(find(val)));
%          if ~(min_val==0)
        xmin = floor(min_val/(10^floor(log10(abs(min_val)))))*10^floor(log10(abs(min_val)));
%            xmin = floor(min_val/(10^floor(log10(min_val))))*10^floor(log10(min_val));
        bins = logspace(log10(xmin),log10(xmax),bin_num+1);
      end
      xscale = 'log';
      yscale = 'lin';
    case 'log-lin'
      if get(h.checkbox_fix_xlim,'Value')
        bins = linspace(xlimits(1),xlimits(2),bin_num+1);
      else
        min_val = nanmin(val(:));
        if ~(min_val==0)
          xmin = floor(min_val/(10^floor(log10(abs(min_val)))))*10^floor(log10(abs(min_val)));
        else
          xmin = 0;
        end
        bins = linspace(xmin,xmax,bin_num+1);
      end
      xscale = 'lin';
      yscale = 'log';
    case 'log-log'
      if get(h.checkbox_fix_xlim,'Value')
        bins = logspace(log10(xlimits(1)),log10(xlimits(2)),bin_num+1);
      else
        min_val = nanmin(val(find(val)));
        xmin = floor(min_val/(10^floor(log10(abs(min_val)))))*10^floor(log10(abs(min_val)));
%          xmin = floor(min_val/(10^floor(log10(min_val))))*10^floor(log10(min_val));
        bins = logspace(log10(xmin),log10(xmax),bin_num+1);
      end
      xscale = 'log';
      yscale = 'log';
    otherwise
  end
%    xmin
%    xmax
  hold(ax,'on')
  histogram(ax,val,'BinEdges',bins,'FaceColor','b')
  set(ax,'xscale',xscale,'yscale',yscale)
  ylimits = ylim(ax);
  plot(ax,[nanmean(val),nanmean(val)],[ylimits(1),ylimits(2)],'r')
  hold(ax,'off')
  
  %% update axis options
  set(get(ax,'XLabel'),'String',xlabel);
  if get(h.checkbox_fix_xlim,'Value')
    xlim(ax,[xlimits(1),xlimits(2)])
  end
  set(ax,'TickDir','in')
  drawnow
  
  
  
function [val,val_label] = get_plot_data(h,val_string)

  switch val_string
    case 'Filter size'
      ROIs = getappdata(0,'ROIs');
      val = ROIs(h.data.current_session).area;
      val_label = 'Area [pixel]';
    case 'Max overlap'
      data = getappdata(0,'data');
      val = nanmax(data(h.data.current_session).fp_corr,[],2);
      val_label = 'footprint overlap';
    case 'Firing rate'
      ROIs = getappdata(0,'ROIs');
      val = ROIs(h.data.current_session).rate;
      val_label = 'Firing rate [Hz]';
    case 'Max correlation'
      data = getappdata(0,'data');
      val = nanmax(data(h.data.current_session).corr,[],2);
      val_label = 'Maximum temporal correlation';
    case 'Mean correlation'
      data = getappdata(0,'data');
      val = nanmean(data(h.data.current_session).corr,2);
      val_label = 'Mean temporal correlation';
    case 'Temporal correlation'
      data = getappdata(0,'data');
      val_tmp = data(h.data.current_session).corr;
      val_label = 'Temporal correlation';
    case 'Overlap'
      data = getappdata(0,'data');
      val_tmp = data(h.data.current_session).fp_corr;
      val_label = 'Overlap';
    case 'Distance'
      data = getappdata(0,'data');
      val_tmp = data(h.data.current_session).distance;
      val_label = 'Distance [pixel]';
    end
  
  if get(h.radio_single_mode,'Value')
    %% apply filters (removed ROIs and currently selected ROIs)
    if get(h.checkbox_select_in_stats,'Value')
      val = val(h.status(h.data.current_session).ROI_retain & h.status(h.data.current_session).ROI_select);
    else
      val = val(h.status(h.data.current_session).ROI_retain);
    end
  else
    if get(h.checkbox_select_in_stats,'Value')
      j = 0;
      for n=1:h.data.nROI(h.data.current_session)
        for i=1:size(h.status(h.data.current_session).ROI_paired(n).list,1)
          if h.status(h.data.current_session).ROI_paired(n).list(i,1) == h.data.current_session
            j = j+1;
            val(j) = val_tmp(n,h.status(h.data.current_session).ROI_paired(n).list(i,2));
          end
        end
      end
    else
      val = val_tmp(h.status(h.data.current_session).ROI_retain,h.status(h.data.current_session).ROI_retain);
    end
    val = val(:);
  end

% --- Executes on button press in checkbox_select_in_stats.
function checkbox_select_in_stats_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_select_in_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_select_in_stats
  
  dd_string_stats_small = get(h.ax_stat_3_menu,'String');
  plotType = dd_string_stats_small{get(h.ax_stat_3_menu,'Value')};
  h = update_stats_plot(h,plotType,h.ax_stat_3);
  guidata(hObject,h);



% --- Executes on selection change in save_file_extension_spec.
function save_file_extension_spec_Callback(hObject, eventdata, h)
% hObject    handle to save_file_extension_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns save_file_extension_spec contents as cell array
%        contents{get(hObject,'Value')} returns selected item from save_file_extension_spec


% --- Executes during object creation, after setting all properties.
function save_file_extension_spec_CreateFcn(hObject, eventdata, h)
% hObject    handle to save_file_extension_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in radio_single_mode.
function radio_single_mode_Callback(hObject, eventdata, h)
% hObject    handle to radio_single_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_single_mode
  
  h = clear_selection(h);
  set(h.ROI_info_table,'ColumnName',{'' 'ID' 'x' 'y' 'area' 'rate'})
  set(h.ROI_info_table,'ColumnWidth',{[20],[50],[80],[80],[50],[70]})
  set(h.ROI_info_table,'Data',cell(0,6))
  
  set(h.drop_down_mass_select,'String',h.drop_down_mass_select_string_single,'Value',1)
  set(h.mass_select_checkbox,'Value',0)
  set(h.checkbox_select_in_stats,'Value',0)
  
  update_plot_menus(h)
  cla(h.ax_stat_3,'reset')
  
  set(h.mass_select_checkbox,'enable','on','Value',0)
  set(h.mass_select_thr_spec,'enable','on')
  set(h.drop_down_mass_select,'enable','on')
  set(h.drop_down_mass_select_thr,'enable','on')
  
  h.ROI_status.add = false;
  
  update_selected_stats(h)
  guidata(hObject,h)
  
  
% --- Executes on button press in radio_pairs_mode.
function radio_pairs_mode_Callback(hObject, eventdata, h)
% hObject    handle to radio_pairs_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_pairs_mode
  
  h = clear_selection(h);
  set(h.ROI_info_table,'ColumnName',{'' 'ID #1' 'ID #2' 'distance' 'overlap' 'correlation'})
  set(h.ROI_info_table,'ColumnWidth',{[20],[50],[50],[80],[70],[80]})
  set(h.ROI_info_table,'Data',cell(0,6))
  
  set(h.drop_down_mass_select,'String',h.drop_down_mass_select_string_pair,'Value',1);
  
  update_plot_menus(h)
  cla(h.ax_stat_3,'reset')
  
  set(h.mass_select_checkbox,'enable','on','Value',0)
  set(h.mass_select_thr_spec,'enable','on')
  set(h.drop_down_mass_select,'enable','on')
  set(h.drop_down_mass_select_thr,'enable','on')
    
  for n=1:h.data.nROI(h.data.current_session)
    h.status(h.data.current_session).ROI_paired(n).list = [];
  end
  
  h.ROI_status.add = false;
  h.ROI_status.half_pair = 0;
  update_selected_stats(h)
  guidata(hObject,h)


% --- Executes when selected cell(s) is changed in ROI_info_table.
function ROI_info_table_CellSelectionCallback(hObject, eventdata, h)
% hObject    handle to ROI_info_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)
  
  h.ROI_status.list_pick = eventdata.Indices;
  
  if ~isempty(h.ROI_status.list_pick)
    ROI_idx = get_n_from_table(h,h.ROI_status.list_pick(1));
    
    h = update_highlighted(h,ROI_idx);
    h = update_plots(h,ROI_idx);
    guidata(hObject,h);
  end
  

  
function h = update_plots(h,ROI_idx)

  dd_string_stats_small = get(h.ax_stat_1_menu,'String');
  plotType1 = dd_string_stats_small{get(h.ax_stat_1_menu,'Value')};
  plotType2 = dd_string_stats_small{get(h.ax_stat_2_menu,'Value')};
  
  if ~isempty(ROI_idx)
    if strcmp(plotType1,plotType2)
      if get(h.radio_single_mode,'Value')
        ROI_idx = [ROI_idx;ROI_idx];
      end
      h = update_stats_plot(h,plotType1,h.ax_stat_1,ROI_idx(1,:));
      h = update_stats_plot(h,plotType2,h.ax_stat_2,ROI_idx(2,:));
    else
      if strcmp(plotType1,'Calcium trace') || strcmp(plotType1,'Spike train')
        h = update_stats_plot(h,plotType1,h.ax_stat_1,ROI_idx);
      elseif strcmp(plotType1,'ROI filter')
        h = update_stats_plot(h,plotType1,h.ax_stat_1,ROI_idx(1,:));
      end
      if strcmp(plotType2,'Calcium trace') || strcmp(plotType2,'Spike train')
        h = update_stats_plot(h,plotType2,h.ax_stat_2,ROI_idx);
      elseif strcmp(plotType2,'ROI filter')
        h = update_stats_plot(h,plotType2,h.ax_stat_2,ROI_idx(1,:));
      end
    end
  else
    cla(h.ax_stat_1,'reset')
    cla(h.ax_stat_2,'reset')
  end
  
  if strcmp(plotType1,'Correlation raster')
    h = update_stats_plot(h,plotType1,h.ax_stat_1);
  end
  if strcmp(plotType2,'Correlation raster')
    h = update_stats_plot(h,plotType2,h.ax_stat_2);
  end
  
  
% --- Executes when entered data in editable cell(s) in ROI_info_table.
function ROI_info_table_CellEditCallback(hObject, eventdata, h)
% hObject    handle to ROI_info_table (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)



% --------------------------------------------------------------------
function ROI_info_table_menu_Callback(hObject, eventdata, h)
% hObject    handle to ROI_info_table_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function unselect_menu_Callback(hObject, eventdata, h)
% hObject    handle to unselect_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
  if ~isempty(h.ROI_status.list_pick)
    table_data = get(h.ROI_info_table,'Data');
    
    if get(h.radio_single_mode,'Value')
      ROI_idx = get_n_from_table(h,h.ROI_status.list_pick(1));
      sn = ROI_idx(1);
      n = ROI_idx(2);
      set(h.plots(sn).ROIs(n),'Color',get_ROI_color(h,sn),'LineWidth',0.75)
      
      h.ROI_status.highlight = [];
      h.status(sn).ROI_select(n) = false;
      
    elseif get(h.radio_pairs_mode,'Value')
      ROI_idx = get_n_from_table(h,h.ROI_status.list_pick(1));
      
      n = ROI_idx(1,2);
      m = ROI_idx(2,2);
      sn = ROI_idx(1,1);
      
      %% unpair
      h.status(sn).ROI_paired(n).list(h.status(sn).ROI_paired(n).list(:,2) == m,:) = [];
      h.status(sn).ROI_paired(m).list(h.status(sn).ROI_paired(m).list(:,2) == n,:) = [];
      
      %% and update colors according to if they are still matched or not
      if size(h.status(sn).ROI_paired(n).list,1) > 0
        set(h.plots(sn).ROIs(n),'Color','r','LineWidth',0.75)
      else
        set(h.plots(sn).ROIs(n),'Color',get_ROI_color(h,sn),'LineWidth',0.75)
        set(h.plots(sn).ROI_tag(n),'Visible','off')
        h.status(sn).ROI_select(n) = false;
      end
      if size(h.status(sn).ROI_paired(m).list,1) > 0
        set(h.plots(sn).ROIs(m),'Color','r','LineWidth',0.75)
      else
        set(h.plots(sn).ROIs(m),'Color',get_ROI_color(h,sn),'LineWidth',0.75)
        set(h.plots(sn).ROI_tag(m),'Visible','off')
        h.status(sn).ROI_select(m) = false;
      end
      
%        if ismember(n,h.ROI_status.highlight) && ismember(m,h.ROI_status.highlight)
      h.ROI_status.highlight = [];
%        end
      
    elseif get(h.radio_matching_mode,'Value')
%        h.status(sn).ROI_paired(n).list(h.status(sn).ROI_paired(n).list(:,1) == sm & h.status(sn).ROI_paired(n).list(:,2) == m,:) = [];
%        h.status(sn).ROI_paired(m).list(h.status(sn).ROI_paired(m).list(:,1) == sn & h.status(sm).ROI_paired(m).list(:,2) == n,:) = [];
    end
    %% remove entry from table
    table_data(h.ROI_status.list_pick(1),:) = [];
    set(h.ROI_info_table,'Data',table_data)
    update_selected_stats(h)
    guidata(hObject,h);
  end
  
% --------------------------------------------------------------------
function display_menu_Callback(hObject, eventdata, h)
% hObject    handle to display_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  %%% get ROI index
  if ~isempty(h.ROI_status)
    ROI_idx = get_n_from_table(h,h.ROI_status.list_pick(1));
    
    dd_string_stats_small = get(h.ax_stat_1_menu,'String');
    if get(h.radio_single_mode,'Value')
      set(h.ax_stat_1_menu,'Value',2)
      set(h.ax_stat_2_menu,'Value',3)
    elseif get(h.radio_pairs_mode,'Value')
      set(h.ax_stat_1_menu,'Value',2)
      set(h.ax_stat_2_menu,'Value',2)
      set(h.ax_stat_3_menu,'Value',4) %% plot spike trains
      h = update_stats_plot(h,dd_string_stats_small{4},h.ax_stat_3,ROI_idx);
    elseif get(h.radio_matching_mode,'Value')
      set(h.ax_stat_1_menu,'Value',2)
      set(h.ax_stat_2_menu,'Value',2)
      set(h.ax_stat_3_menu,'Value',4) %% plot spike trains
      h = update_stats_plot(h,dd_string_stats_small{4},h.ax_stat_3,ROI_idx);
    end
    h = update_plots(h,ROI_idx);
  end
  guidata(hObject,h);



% --- Executes on selection change in drop_down_choose_session.
function drop_down_choose_session_Callback(hObject, eventdata, h)
% hObject    handle to drop_down_choose_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns drop_down_choose_session contents as cell array
%        contents{get(hObject,'Value')} returns selected item from drop_down_choose_session
  
  if ~(get(h.drop_down_choose_session,'Value') == h.data.current_session)
    h = clear_selection(h);
    set(h.mass_select_checkbox,'Value',0)
    h = update_session(h);
    guidata(hObject,h);
  end
        
        
function [h] = update_session(h)
  
  h.data.current_session = get(h.drop_down_choose_session,'Value');
  
  set(h.drop_down_choose_session_color,'Value',h.data.session_color(h.data.current_session))
  set(h.checkbox_session_display_ROIs,'Value',h.data.session_display(h.data.current_session))
  set(h.mass_select_checkbox,'Value',0)
  set(h.checkbox_select_in_stats,'Value',0)
  
  set(h.session_spec,'String',h.data.paths(h.data.current_session).session)
  set(h.spec_background_path,'String',h.data.paths(h.data.current_session).background)
  set(h.spec_ROI_path,'String',h.data.paths(h.data.current_session).ROIs)
  set(h.spec_Ca_path,'String',h.data.paths(h.data.current_session).CaData)
  
  set(h.ROI_plot_button,'enable','off')
  set(h.ROI_data_button,'enable','off')
  set(h.background_plot_button,'enable','off')
  set(h.background_data_button,'enable','off')
  set(h.Ca_plot_button,'enable','off')
  set(h.Ca_data_button,'enable','off')
  
  if ~h.status(h.data.current_session).background || h.data.current_session==1
    set(h.background_plot_button,'enable','on')
    set(h.background_data_button,'enable','on')
  end
  
  if ~h.status(h.data.current_session).ROIs && h.status(h.data.current_session).background
    set(h.spec_background_path,'String',h.data.paths(h.data.current_session).background)
    set(h.ROI_plot_button,'enable','on')
    set(h.ROI_data_button,'enable','on')
  end
  
  if ~h.status(h.data.current_session).CaData && h.status(h.data.current_session).ROIs
    set(h.spec_background_path,'String',h.data.paths(h.data.current_session).background)
    set(h.spec_ROI_path,'String',h.data.paths(h.data.current_session).ROIs)
    set(h.Ca_plot_button,'enable','on')
    set(h.Ca_data_button,'enable','on')
  end
  
  if h.status(h.data.current_session).CaData
    set(h.spec_background_path,'String',h.data.paths(h.data.current_session).background)
    set(h.spec_ROI_path,'String',h.data.paths(h.data.current_session).ROIs)
    set(h.spec_Ca_path,'String',h.data.paths(h.data.current_session).CaData)
    set(h.button_export_ROI,'enable','on')
  end
  
  if h.status(h.data.current_session).ROIs
    set(h.button_clear_selection,'enable','on')
    set(h.button_remove_ROI,'enable','on')
    
    set(h.radio_single_mode,'enable','on')
    set(h.radio_pairs_mode,'enable','on')
    
    set(h.checkbox_select_in_stats,'enable','on')
    
    set(h.mass_select_checkbox,'enable','on','Value',0)
    set(h.drop_down_mass_select,'enable','on')
    set(h.drop_down_mass_select_thr,'enable','on')
    set(h.mass_select_thr_spec,'enable','on')
    
    set(h.drop_down_ROI_tag,'enable','on')
    
    set(h.checkbox_session_display_ROIs,'enable','on')
    set(gcf,'WindowButtonMotionFcn',@MouseOver_getAx);
    
  else
    set(h.button_clear_selection,'enable','off')
    set(h.button_remove_ROI,'enable','off')
    
    set(h.radio_single_mode,'enable','off','Value',1)
    set(h.radio_pairs_mode,'enable','off')
    
    set(h.checkbox_select_in_stats,'enable','off','Value',0)
    
    set(h.mass_select_checkbox,'enable','off','Value',0)
    set(h.drop_down_mass_select,'enable','off')
    set(h.drop_down_mass_select_thr,'enable','off')
    set(h.mass_select_thr_spec,'enable','off')
    
    set(h.drop_down_ROI_tag,'enable','off')
    
    set(h.checkbox_session_display_ROIs,'enable','off','Value',1)
    set(gcf,'WindowButtonMotionFcn',[]);
  end
  
  set(h.plots(1).ROI_text,'String','');
  update_plot_menus(h)
  
  update_session_stat_display(h)
  
  dd_string_stats_small = get(h.ax_stat_3_menu,'String');
  plotType = dd_string_stats_small{get(h.ax_stat_3_menu,'Value')};
  if strcmp(plotType,'Histogram') || strcmp(plotType,'Scatter')
    h = update_stats_plot(h,plotType,h.ax_stat_3);
  end
  
% --- Executes during object creation, after setting all properties.
function drop_down_choose_session_CreateFcn(hObject, eventdata, h)
% hObject    handle to drop_down_choose_session (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in drop_down_choose_session_color.
function drop_down_choose_session_color_Callback(hObject, eventdata, h)
% hObject    handle to drop_down_choose_session_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns drop_down_choose_session_color contents as cell array
%        contents{get(hObject,'Value')} returns selected item from drop_down_choose_session_color
  
  h.data.session_color(h.data.current_session) = get(hObject,'Value');
  if h.status(h.data.current_session).ROIs
    for n=1:h.data.nROI(h.data.current_session)
      if ~h.status(h.data.current_session).ROI_select(n) && h.status(h.data.current_session).ROI_retain(n)
        set(h.plots(h.data.current_session).ROIs(n),'Color',get_ROI_color(h,h.data.current_session))
      end
    end
  end
  guidata(hObject,h);
      

% --- Executes during object creation, after setting all properties.
function drop_down_choose_session_color_CreateFcn(hObject, eventdata, h)
% hObject    handle to drop_down_choose_session_color (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function [col] = get_ROI_color(h,s)
  
  color_string = cellstr(get(h.drop_down_choose_session_color,'String'));
  color_tmp = color_string{h.data.session_color(s)};
  
%    get(h.drop_down_choose_session_color,'Value')};
  
  switch color_tmp
    case 'Yellow'
      col = 'y';
    case 'Green'
      col = 'g';
    case 'Blue'
      col = [0,0,139]/255;
    case 'White'
      col = 'w';
    case 'Orange'
      col = [255,140,0]/255;
    case 'Pink'
      col = [255,20,147]/255;
    case 'Brown'
      col = [150,75,0]/255;
    case 'Azure'
      col = [0,128,255]/255;
    case 'Violet'
      col = [148,0,211]/255;
%      case 'Magenta'
%        col = 'm';
%      case 'Orange'
%        col
  end
  %%% should try some from http://matlab.cheme.cmu.edu/2011/09/13/check-out-the-new-fall-colors/


% --- Executes on button press in add_session_button.
function add_session_button_Callback(hObject, eventdata, h)
% hObject    handle to add_session_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  input = struct;
  input.start_path = get(h.session_spec,'String');
  if h.data.nsessions == 0
    input.background = 1;
  else
    input.background = 0;
  end
  input.name = 'Session';%sprintf('Dataset %02d',(h.data.nsessions+1));
  input.nSes = h.data.nsessions + 1;
  setappdata(0,'add_session_input',input)
  add_session_GUI;
  output = getappdata(0,'add_session_output');
  
  
  if iscell(output)
    
    %% disable everything
    set(h.background_plot_button,'enable','off')
    set(h.background_data_button,'enable','off')
    set(h.spec_background_path,'enable','off')
    set(h.ROI_plot_button,'enable','off')
    set(h.ROI_data_button,'enable','off')
    set(h.spec_ROI_path,'enable','off')
    set(h.Ca_plot_button,'enable','off')
    set(h.Ca_data_button,'enable','off')
    set(h.spec_Ca_path,'enable','off')
    
    set(h.drop_down_choose_session,'enable','off')
    set(h.drop_down_choose_session_color,'enable','off')
    
    if h.data.nsessions > 0 && h.status(h.data.current_session).ROIs
      h = clear_selection(h);
    end
    
    for s = 1:length(output)
      
      h.data.nsessions = h.data.nsessions + 1;
      h.data.current_session = h.data.nsessions;    %% make the new data the current session
      
      h.status(h.data.current_session).background = false;
      h.status(h.data.current_session).ROIs = false;
      h.status(h.data.current_session).CaData = false;
      
      %% get data to load
      h.data.paths(h.data.current_session).session = output{s}.session_path;
      set(h.session_spec,'String',output{s}.session_path)
      
      set(h.spec_background_path,'String',output{s}.bg_path)
      set(h.spec_ROI_path,'String',output{s}.ROI_path)
      set(h.spec_Ca_path,'String',output{s}.Ca_path)
      
      set(h.spec_bg_field,'String',output{s}.bg_field)
      set(h.spec_ROI_field,'String',output{s}.ROI_field)
      set(h.spec_Ca_field1,'String',output{s}.Ca_field1)
      set(h.spec_Ca_field2,'String',output{s}.Ca_field2)
      
      %% set some other parameters
      h.data.session_color(h.data.current_session) = s;
      set(h.drop_down_choose_session_color,'Value',s)
      
      session_name = output{s}.session_name;
      session_name_string = cellstr(get(h.drop_down_choose_session,'String'));
      session_name_string{h.data.current_session} = session_name;
      
      set(h.drop_down_choose_session,'String',session_name_string,'Value',h.data.current_session)
      
      h.data.paths(h.data.current_session).background = get(h.spec_background_path,'String');
      h.data.paths(h.data.current_session).ROIs = get(h.spec_ROI_path,'String');
      h.data.paths(h.data.current_session).CaData = get(h.spec_Ca_path,'String');
      
%        h.data.shift(h.data.current_session,:) = [0,0];
      
      if output{s}.bg_load
        h = load_background(h);
      end
      
      if output{s}.ROI_load
        h = load_ROIs(h);
      end
      
      if output{s}.Ca_load
        
      end
      
%        here, can introduce some filtering already (e.g. all ROIs close to border: removed!)
      
      %% disable display of ROIs at end
      if s == length(output)
        h.data.session_display(h.data.current_session) = 1;
      else
        h.data.session_display(h.data.current_session) = 0;
        toggle_display(h);
      end
      set(h.checkbox_session_display_ROIs,'Value',1);
      
      guidata(hObject,h);
      
    end
    
    set(h.drop_down_choose_session,'enable','on')
    set(h.drop_down_choose_session_color,'enable','on')
    
    set(h.save_path_spec,'String',pathcat(h.data.paths(h.data.current_session).session,'sample_fig'))
    
    h = update_session(h);
    update_session_stat_display(h)
    
  end


% --- Executes on button press in checkbox_session_display_ROIs.
function checkbox_session_display_ROIs_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_session_display_ROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_session_display_ROIs
  
  h.data.session_display(h.data.current_session) = get(hObject,'Value');
  guidata(hObject,h)
  toggle_display(h)
  


function toggle_display(h)
  if h.data.session_display(h.data.current_session)
    for n=1:h.data.nROI(h.data.current_session)
      if h.status(h.data.current_session).ROI_retain(n)
        set(h.plots(h.data.current_session).ROIs(n),'Visible','on')
      end
    end
  else
    for n=1:h.data.nROI(h.data.current_session)
      if h.status(h.data.current_session).ROI_retain(n)
        set(h.plots(h.data.current_session).ROIs(n),'Visible','off')
      end
    end
  end
  


function update_session_stat_display(h)
  
  %% set background statistics
  background_status = h.status(h.data.current_session).background;
  if background_status
    set(h.session_stats_background_status,'Value',background_status,'String','Background loaded')
    if h.data.current_session == 1
      set(h.session_stats_shift,'String','Reference session')
      set(h.session_stats_rotation,'String','')
    else
      set(h.session_stats_shift,'String',sprintf('X-Y-shifted by: %d, %d pixels',h.data.shift(h.data.current_session,1),h.data.shift(h.data.current_session,2)))
      set(h.session_stats_rotation,'String',sprintf('rotated by: %3.1f°',h.data.rotation(h.data.current_session)))
    end
  else
    set(h.session_stats_background_status,'Value',background_status,'String','Background not loaded')
    set(h.session_stats_shift,'String','')
    set(h.session_stats_rotation,'String','')
  end
  
  %% set ROI statistics
  ROI_status = h.status(h.data.current_session).ROIs;
  if ROI_status
    set(h.session_stats_ROI_status,'Value',ROI_status,'String','ROI data loaded')
    data = getappdata(0,'data');
    ROIs = getappdata(0,'ROIs');
    set(h.session_stats_ROI_detected,'String',sprintf('%d ROIs detected',h.data.nROI(h.data.current_session)))
    set(h.session_stats_ROI_removed,'String',sprintf('%d ROIs removed',sum(~h.status(h.data.current_session).ROI_retain)))
    set(h.session_stats_avg_size,'String',sprintf('Avg. size: %4.2f px',nanmean(ROIs(h.data.current_session).area(h.status(h.data.current_session).ROI_retain))))
    num_ol = nnz(data(h.data.current_session).fp_corr(:)>0)/2;
    set(h.session_stats_num_overlap,'String',sprintf('%5.0f overlaps',num_ol))
  else
    set(h.session_stats_ROI_status,'Value',ROI_status,'String','ROI data not loaded')
    set(h.session_stats_ROI_detected,'String','')
    set(h.session_stats_ROI_removed,'String','')
    set(h.session_stats_avg_size,'String','')
    set(h.session_stats_num_overlap,'String','')
  end
  
  %% set Calcium statistics
  Ca_status = h.status(h.data.current_session).CaData;
  if Ca_status
    set(h.session_stats_CaData_status,'Value',Ca_status,'String','Calcium data loaded')
    set(h.session_stats_avg_rate,'String',sprintf('Avg. firing rate: %5.3f',mean(ROIs(h.data.current_session).rate(h.status(h.data.current_session).ROI_retain))))
    if isfield(data(h.data.current_session),'corr')
      set(h.session_stats_avg_corr,'String',sprintf('Avg. correlation: %5.3f',nanmean(data(h.data.current_session).corr(:))))
    else
      set(h.session_stats_avg_corr,'String','n.A.')
    end
  else
    set(h.session_stats_CaData_status,'Value',Ca_status,'String','Calcium data not loaded')
    set(h.session_stats_avg_rate,'String','')
    set(h.session_stats_avg_corr,'String','')
  end
  
  if h.data.nsessions > 1
    set(h.radio_matching_mode,'enable','on')
  end
  



function update_selected_stats(h)
  
  set(h.selected_stats_ROI_selected,'String',sprintf('%5.0f ROIs selected',nnz(h.status(h.data.current_session).ROI_select)))
  
  if get(h.radio_pairs_mode,'Value')
    npair = 0;
    sn = h.data.current_session;
    for n=1:h.data.nROI(sn)
      npair = npair + size(h.status(sn).ROI_paired(n).list,1);
    end
    npair = npair/2;
    set(h.selected_stats_pairs_selected,'String',sprintf('%5.0f pairs selected',npair));%(nnz(list_tmp(:,2))/2)))
  else
    set(h.selected_stats_pairs_selected,'String','')
  end



function session_spec_Callback(hObject, eventdata, h)
% hObject    handle to session_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of session_spec as text
%        str2double(get(hObject,'String')) returns contents of session_spec as a double
  
  set(h.session_spec,'String',h.data.paths(h.data.current_session).session)
  msgbox('You can not change the session path in this dataset anymore')
  
% --- Executes during object creation, after setting all properties.
function session_spec_CreateFcn(hObject, eventdata, handles)
% hObject    handle to session_spec (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in remove_session_button.
function remove_session_button_Callback(hObject, eventdata, h)
% hObject    handle to remove_session_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
  
  if h.data.current_session == 1
    uiwait(msgbox('You can not remove the reference session'))
  else
    choice = questdlg('Are you sure you want to remove the current dataset?','Removing dataset','No','Yes','No');
    
    switch choice
      case 'No'
        
      case 'Yes'
        disp(sprintf('removing session %d',h.data.current_session))
        
        %% remove the data from background
        try
          h.data.shift(h.data.current_session,:) = [];
        catch
          disp('could not delete background')
        end
        
        try
          h = clear_selection(h);
          %% remove the ROIs on the plot
          for n=1:h.data.nROI(h.data.current_session)
            try
              delete(h.plots(h.data.current_session).ROIs(n))
            catch
              disp('could not delete ROI #%d',n)
            end
          end
          h.plots(h.data.current_session) = [];
          h.data.session_display(h.data.current_session) = [];
          
          h.data.nROI(h.data.current_session) = [];
          
          data = getappdata(0,'data');
          data(h.data.current_session) = [];
          setappdata(0,'data',data)
          
          ROIs = getappdata(0,'ROIs');
          ROIs(h.data.current_session) = [];
          setappdata(0,'ROIs',ROIs)
        catch
          disp('could not delete data or ROIs')
        end
        
        
        try
          CaData = getappdata(0,'CaData');
          CaData(h.data.current_session) = [];
          setappdata(0,'CaData',CaData)
        catch
          disp('could not delete CaData')
        end
        
        h.data.session_color(h.data.current_session) = [];
        h.status(h.data.current_session) = [];
        
        %% remove name from drop_down_menu
        session_name_string = cellstr(get(h.drop_down_choose_session,'String'));
        session_name_string(h.data.current_session) = [];
        set(h.drop_down_choose_session,'String',session_name_string,'Value',h.data.current_session-1)
        
        h.data.current_session = max(1,h.data.current_session - 1);
        h.data.nsessions = h.data.nsessions - 1;
        set(h.drop_down_choose_session,'Value',h.data.current_session);
        h = update_session(h);
        guidata(hObject,h);
    end
  end


% --- Executes when user attempts to close ROI_doc.
function ROI_doc_CloseRequestFcn(hObject, eventdata, h)
% hObject    handle to ROI_doc (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

choice = questdlg('Do you really want to quit?','Quit the ROI doctor','No','Yes','No');

switch choice
  case 'No'
  
  case 'Yes'
    try
      rmappdata(0,'data')
      rmappdata(0,'ROIs')
      rmappdata(0,'CaData')
    catch
      
    end
    
    % Hint: delete(hObject) closes the figure
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end
end


% --- Executes on button press in checkbox_fix_xlim.
function checkbox_fix_xlim_Callback(hObject, eventdata, h)
% hObject    handle to checkbox_fix_xlim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_fix_xlim



% --- Executes on button press in button_clear_selection.
function button_clear_selection_Callback(hObject, eventdata, h)
% hObject    handle to button_clear_selection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

  h = clear_selection(h);
  set(h.mass_select_checkbox,'Value',0)
  guidata(hObject,h);


% --- Executes on button press in radio_matching_mode.
function radio_matching_mode_Callback(hObject, eventdata, h)
% hObject    handle to radio_matching_mode (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radio_matching_mode

%    for the merging mode, one should specify the radius and footprint overlap needed (1-way?), to merge two neurons
%    also, specify how many (or which?) sessions should be matched (or rather all, that are displayed?)
  
  h = clear_selection(h);
  set(h.ROI_info_table,'ColumnName',{'' 'ID #1' 'ID #2' 'distance' 'overlap' 'correlation'})
  set(h.ROI_info_table,'ColumnWidth',{[20],[65],[65],[60],[60],[80]})
  set(h.ROI_info_table,'Data',cell(0,6))
  
  set(h.drop_down_mass_select,'String',h.drop_down_mass_select_string_single,'Value',1)
  set(h.checkbox_select_in_stats,'Value',0)
  update_plot_menus(h)
  cla(h.ax_stat_3,'reset')
  
  set(h.mass_select_checkbox,'enable','off','Value',0)
  set(h.mass_select_thr_spec,'enable','off')
  set(h.drop_down_mass_select,'enable','off')
  set(h.drop_down_mass_select_thr,'enable','off')
  
  h.ROI_status.add = false;
  
  update_selected_stats(h)
  guidata(hObject,h)
  
%    msgbox('change merging towards displaying belonging pairs in table with fp, corr, etc')



function [n] = get_n_from_table(h,idx)
  
  table_data = get(h.ROI_info_table,'Data');
  
  if get(h.radio_single_mode,'Value')
    n = [h.data.current_session str2num(table_data{idx,2})];
  elseif get(h.radio_pairs_mode,'Value')
    n = [[h.data.current_session str2num(table_data{idx,2})];...
        [h.data.current_session str2num(table_data{idx,3})]];
  elseif get(h.radio_matching_mode,'Value')
    split_string1 = split(table_data{idx,2},{'(',')'});
    split_string2 = split(table_data{idx,3},{'(',')'});
    n = [[str2num(split_string1{2}) str2num(split_string1{1})];...
        [str2num(split_string2{2}) str2num(split_string2{1})]];
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



function spec_ROI_field_Callback(hObject, eventdata, h)
% hObject    handle to spec_ROI_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of spec_ROI_field as text
%        str2double(get(hObject,'String')) returns contents of spec_ROI_field as a double


% --- Executes during object creation, after setting all properties.
function spec_ROI_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to spec_ROI_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
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
