

function data = LoadnResize(path,target_size,msg,data_field)

%% function to load a single field from PATH, to have a specified size TARGET_SIZE
%% works only if dimensions do not differ by more than one

  %%% --- INPUT ---
  %% PATH 		- path containing the data
  %% TARGET_SIZE 	- array, containing d entries, that specify the target data dimensionality with entries s(i), where s(i) is the size of dimension i. if s(i) = 0, size is unspecified and chosen according to loaded data
  %% MSG 		- message to be displayed in GUI when loading
  
  %%% --- OUTPUT ---
  %% DATA		- array, containing the resized data. If loading failed, because no fitting dimension was found, returns 0
  
  data = 0;
  if ~exist(path,'file')
    msgbox(sprintf('The file %s does not exist!',path))
    return
  end
  d = numel(target_size);
  
  if nargin == 4
    fields = who('-file',path);
  end
  
  if nargin < 4 || ~ismember(data_field,fields)
    mFile = matfile(path);
    details = whos(mFile);
    fields = (['']);
    field_string = (['']);
    for i=1:length(details)
      fields{i} = details(i).name;
      str_dim = '';
      for j=1:numel(details(i).size)
        if j>1
      str_dim = strcat(str_dim,'x');
        end
        str_dim = strcat(str_dim,sprintf('%d',details(i).size(j)));
      end
      field_string{i} = sprintf('%s (%s)',fields{i},str_dim);
    end
    
    data_field = '';
    if numel(fields) > 1;
      str_output = select_field(field_string,msg);
      %% what happens with cancelled selection?
      if str_output > 0		
        data_field = fields{str_output};
      else
        return
      end
    else
      data_field = fields{1};
    end
  end
  
  if ~isempty(data_field)
    data_tmp = load(path,data_field);
    data_tmp = getfield(data_tmp,data_field);
    data_size = size(data_tmp);
    %% case of same dimensions - permutations only
    if numel(data_size) == d
      if all(data_size == target_size) || all(target_size==0)	%% if everything agrees
	data = data_tmp;
%  	go on...
      else
	permute_dim = find_permutation(data_size,target_size);
	if any(permute_dim == 0)
	  return
	else
	  data = permute(data_tmp,permute_dim);
	end
      end
    elseif numel(data_size) < d	%% if number of dimensions is smaller
      %% find dimensions that match
      mask_data = true(numel(data_size),1);
      mask_target = true(numel(target_size),1);
      mask_target(target_size==0) = false;
      for i=1:numel(data_size)
	this_size = data_size(i);
	if sum(target_size(mask_target)==this_size) == 1
	  mask_target(find(target_size(mask_target)==this_size)) = false;
	  mask_data(i) = false;
	end
      end
      tmp_target = target_size(mask_target);
      tmp_dat = data_size(mask_data);
      
      for i=1:length(tmp_target)
	for j=i+1:length(tmp_target)
	  for k=1:length(tmp_dat)
	    [i,j,k]
	    if tmp_target(i)*tmp_target(j)==tmp_dat(k)
	      %% assign them
	      wildcard = data_size(~(data_size==tmp_dat(k)));
	      target_size(target_size==0) = wildcard;
	      entry = find(target_size == wildcard);
	      if entry == 1
		data = reshape(full(data_tmp),wildcard,tmp_target(i),tmp_target(j));
	      elseif entry == 2
		data = reshape(full(data_tmp),tmp_target(i),wildcard,tmp_target(j));
	      elseif entry == 3
		data = reshape(full(data_tmp),tmp_target(i),tmp_target(j),wildcard);
	      end
	      return
	    end
	  end
	end
      end
      
    elseif numel(data_size) > d	%% if number of dimensions is larger
      mask_data = true(numel(data_size),1);
      mask_target = true(numel(target_size),1);
      mask_target(target_size==0) = false;
      for i=1:numel(data_size)
	this_size = data_size(i);
	if sum(target_size(mask_target)==this_size) == 1
	  mask_target(find(target_size(mask_target)==this_size)) = false;
	  mask_data(i) = false;
	end
      end
      tmp_target = target_size(mask_target);
      tmp_dat = data_size(mask_data);
      %% find combination of data dimensions, that can produce target dimension
      for i=1:length(tmp_dat)
	for j=i+1:length(tmp_dat)
	  for k=1:length(tmp_target)
	    if tmp_dat(i)*tmp_dat(j)==tmp_target(k)
	      %% assign them
%  	      disp(sprintf('matching: %d,%d to %d',tmp_dat(i),tmp_dat(j),tmp_target(k)))
	      wildcard = data_size(~(data_size==tmp_dat(i) | data_size==tmp_dat(j)));
	      target_size(target_size==0) = wildcard;
	      entry = find(target_size == wildcard);
%  	      wildcard
	      if entry == 1
            data = reshape(full(data_tmp),wildcard,tmp_dat(i)*tmp_dat(j));
	      elseif entry == 2
            data = reshape(full(data_tmp),tmp_dat(i)*tmp_dat(j),wildcard);
	      end
	      return
	    end
	  end
	end
      end
      
%        reshape()
      %% find proper permutation of new dimensions
%        permute_dim = find_permutation()
%        data = permute
      
      
      
      
      
%        h.data.imSize(1)*h.data.imSize(2) == size(ROI_data_tmp,1)
%  	data.A = sparse(ROI_data_tmp);
%        else
%  	uiwait(msgbox(sprintf('1st dimension of ROI data (%d) and background data (%dx%d) do not agree',size(ROI_data_tmp,1),h.data.imSize(1),h.data.imSize(2))));
%        end
%        
%      else
%        if size(ROI_data_tmp,1) == h.data.imSize(1) || size(ROI_data_tmp,2) == h.data.imSize(2)
%  	data.A = sparse(h.data.imSize(1)*h.data.imSize(2),size(ROI_data_tmp,3));
%  	for n=1:size(ROI_data_tmp,3)
%  	  data.A(:,n) = sparse(reshape(ROI_data_tmp(:,:,n),h.data.imSize(1)*h.data.imSize(2),1));
%  	end
%        else
%  	uiwait(msgbox(sprintf('Dimensions of ROI data (%dx%d) and background data (%dx%d) do not agree',size(ROI_data_tmp,1),size(ROI_data_tmp,2),h.data.imSize(1),h.data.imSize(2))))
%        end
      
    end
  end
end
    
    
function permute_dim = find_permutation(data_size,target_size)
  
  d = numel(data_size);
  
  mask_target = true(d,1);
  mask_data = true(d,1);
  
  permute_dim = zeros(d,1);
  dim_chosen = false;
  
  %% match dimensions to one another
  for i=1:d
    this_size = data_size(i);
    if ~dim_chosen && sum(this_size==data_size) > 1 && ~(sum(this_size==data_size)==d)
      disp('Data contains several dimensions of the same size - please help matching')
      permute_dim = choose_dimensions(data_size);
      if permute_dim == 0
	return
      end
      dim_chosen = true;
    end
  end
  if ~dim_chosen
    for i=1:d
      this_size = data_size(i);
      if sum(target_size(mask_target)==this_size) == 1
	tmp = (target_size==this_size);
	permute_dim(i) = find(tmp(mask_target));
	mask_target(permute_dim(i)) = false;
	mask_data(i) = false;
      end
    end
    if sum(permute_dim==0) == sum(target_size==0)
      permute_dim(permute_dim==0) = find(mask_target);
    else
      msgbox('Dimensions could not be matched. Are you sure this is the right data?')
      return
    end
  end
end
  
  %% check if data sizes are ambiguous and let choose the right dimension