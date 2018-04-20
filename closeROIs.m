

function closeROIs(mouse,session)
  
  %% specify parameters for plotting etc...
  parameter = struct;
  
  parameter.t_max = 8989;	%% number of frames to be processed
  parameter.frq = 15;		%% framerate of data
  
  parameter.border = 25;	%% pixel-radius of area to be displayed
  parameter.ROI_thr = 0.25;	%% weight-cutoff of ROI region to be displayed
  parameter.nR_max = 5;		%% maximum number of ROIs to be analyzed
  
  parameter.tw_l = 300;		%% number of frames to be displayed in Ca-window
  parameter.tw_offset = 45;	%% number of past frames to be displayed in Ca window
  parameter.max_val_y = 2*10^5;	%% maximum value of y-axis in Ca window
  
  parameter.Ca_thr = 2;		%% number of standard deviations to detect "activity" 
  parameter.noise_skp_stp = 0;	%% frames which are skipped during noise-only activity
  
  
%    if nargin < 3 || isempty(mk_vid)
%      mk_vid = false;
%    end
%    if mk_vid
%      parameter.frq_vid = 30;	%% framerate of video
%    end
  
  
  %% set paths
  pathMouse = sprintf('/media/mizuta/Analyze_AS1/%d',mouse);
  pathSession = pathcat(pathMouse,sprintf('Session%02d',session));
  CNMFfile = pathcat(pathSession,'resultsCNMF_MF1_LK1.mat');
%    if mk_vid
%      pathVideo = pathcat(pathSession,'close_corr.avi');
%    end
  
  %% load CNMF results
  CNMFdata = load(CNMFfile);
  
  CNMF = struct;
  CNMF.pathSession = pathSession;
  
  A = CNMFdata.A2;
  CNMF.C2 = CNMFdata.C2;
  CNMF.nROI = size(A,2);
  
  CNMF.A = sparse(size(A,1),CNMF.nROI);
  CNMF.centroid = zeros(CNMF.nROI,2);
  
  for n=1:CNMF.nROI
    CNMF.A(:,n) = A(:,n)./sum(A(:,n));
    CNMF.normA(n) = norm(CNMF.A(:,n));
    CNMF.centroid(n,1) = sum((1:512)*reshape(CNMF.A(:,n),512,512));
    CNMF.centroid(n,2) = sum(reshape(CNMF.A(:,n),512,512)*(1:512)');
  end
  CNMF.dist = zeros(CNMF.nROI);
  
  
  %% calculate distance and spatial overlap
  for n=1:CNMF.nROI
    for m=n+1:CNMF.nROI
      CNMF.dist(n,m) = sqrt((CNMF.centroid(n,1)-CNMF.centroid(m,1))^2+(CNMF.centroid(n,2)-CNMF.centroid(m,2))^2);
      CNMF.dist(m,n) = CNMF.dist(n,m);
      
      if CNMF.dist(n,m) < 50
	CNMF.fp_corr(n,m) = (CNMF.A(:,n)'*CNMF.A(:,m))/(CNMF.normA(n)*CNMF.normA(m));
	CNMF.fp_corr(m,n) = CNMF.fp_corr(n,m);
      end
    end
  end
  disp(sprintf('CNMF preprocessing %d ROIs done',CNMF.nROI))
  
  
  CNMF.time = linspace(0,parameter.t_max/parameter.frq,parameter.t_max);
  
  
  %% choose ROI for center
  if nargin < 4 || isempty(n_ROI)
    %% random draw from high spatial correlated ROI
    [n_l,m_l] = find(CNMF.fp_corr > 0.2);
    n_ROI = n_l(randi(length(n_l)));
  end
  
  %% find nearby ROIs
  ROI_list = find(CNMF.dist(n_ROI,:)<parameter.border);
  ROI_list = vertcat(ROI_list,CNMF.dist(n_ROI,ROI_list))';
  CNMF.ROI_list = sortrows(ROI_list,2,'ascend');
  clear ROI_list;
  CNMF.nR = min(parameter.nR_max,size(CNMF.ROI_list,1));
  
  %% get area to display
  CNMF.window = struct;
  CNMF.window.min_x = ceil(CNMF.centroid(n_ROI,2))-parameter.border;
  CNMF.window.max_x = ceil(CNMF.centroid(n_ROI,2))+parameter.border;
  CNMF.window.min_y = ceil(CNMF.centroid(n_ROI,1))-parameter.border;
  CNMF.window.max_y = ceil(CNMF.centroid(n_ROI,1))+parameter.border;
  
  CNMF.window.offset = [CNMF.window.min_y,CNMF.window.max_y;CNMF.window.min_x,CNMF.window.max_x];
  
  
  %% read in image files
  pathH5 = dir(pathcat(pathSession,'imageStack','*_MF1_LK1.h5'));
  CNMF.pathIm = pathcat(pathSession,'imageStack',pathH5.name);
  CNMF.im = h5read(CNMF.pathIm,'/DATA');
  
  pathH5 = dir(pathcat(pathSession,'imageStack','*_MF0_LK0.h5'));
  CNMF.pathImRef = pathcat(pathSession,'imageStack',pathH5.name);
  CNMF.imRef = h5read(CNMF.pathImRef,'/DATA');
  
  %% make colors
  pltDat = struct;
  pltDat.col = {'r','g','b','m','c'};
  for i=CNMF.nR+1:size(CNMF.ROI_list,1)
    pltDat.col{i} = 'y';
  end
  
  
  closeROIs_GUI(CNMF,parameter,pltDat)
  
  
%  %    set(gcf,'doublebuffer','off')
%    
%    if mk_vid
%      %% make video
%      disp(fprintf('creating video @ %s',pathVideo))
%      vObj = VideoWriter(pathVideo);
%      vObj.FrameRate = parameter.frq_vid;
%      vObj.Quality = 90;
%      open(vObj);
%    end
%    
%    subplot(4,1,3)
%    for t=1:parameter.t_max
%      
%      %% get current times
%      t_now = t/parameter.frq;
%      start_t = max(1,t-parameter.tw_offset);
%      end_t = min(8989,start_t + parameter.tw_l-1);
%      
%      %% update background images
%      hIm.CData = CNMF.im(CNMF.window.min_y:CNMF.window.max_y,CNMF.window.min_x:CNMF.window.max_x,t);
%      hImRef.CData = CNMF.imRef(CNMF.window.min_y:CNMF.window.max_y,CNMF.window.min_x:CNMF.window.max_x,t);
%      set(htext,'String',sprintf('time: %4.2f s',t_now));
%      
%      %% update Ca-traces
%      set(p,'Vertices',[t_now 0; t_now parameter.max_val_y; t_now+1 parameter.max_val_y; t_now+1 0])
%      xlim([start_t/parameter.frq,end_t/parameter.frq])
%      
%      drawnow
%      if mk_vid
%      %% save as video
%        frame = getframe(hFig);
%        writeVideo(vObj,frame);
%      end
%    end
%    if mk_vid
%      close(vObj)
%    end
end
  
  
  
  
  function [blob] = prep_blob(A,thr,offset)
    if isempty(offset)
      A = medfilt2(A,[3,3]);
    else
      A = medfilt2(A(offset(1,1):offset(1,2),offset(2,1):offset(2,2)),[3,3]);
    end
    A(A<thr*max(A(:))) = 0;
    BW = bwareafilt(A>0,1);
    blob = bwboundaries(BW);
    if ~isempty(blob)
      for ii = 1:length(blob)
	blob{ii} = fliplr(blob{ii});
      end
    end
  end
	
  function plot_blob(blob,line,col)
    if ~isempty(blob)
      for ii = 1:length(blob)
	  mask = (blob{ii}(:,1)==1 | blob{ii}(:,1)==51 | blob{ii}(:,2)==1 | blob{ii}(:,2)==51);
	  blob{ii}(mask,1) = NaN;
	  blob{ii}(mask,2) = NaN;
	  
	  plot(blob{ii}(:,1),blob{ii}(:,2),line,'Color',col,'linewidth', 0.5);
      end
    end
  end