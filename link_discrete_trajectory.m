%clc;
%clear all
%close all
path = '.\result\';
file_names = dir([path, '*.xml']);
number_batch = 200;number_overlap = 20; %overlap
track_set = cell(length(file_names),1);
if ~exist([path,'total.mat'],'file')  
for ii = 1:length(file_names)
    track_set{ii} = importTrackMateTracks([path,file_names(ii).name],true);
    fprintf('the process of load file %d / %d \n',ii,length(file_names))
end
save([path,'total.mat'],'track_set');
else
data = load([path,'total.mat'],'track_set');
track_set = data.track_set;
end

%tracks1 = importTrackMateTracks([path,file_names(1).name],true);
%tracks2 = importTrackMateTracks([path,file_names(2).name],true);% read one 
%choose the window_data
%interp to 10 frame
%cal the similarity
id_set = cell(numel(track_set),1);
%id_set = cell(1,1);
for m = 1:numel(track_set)-1
    if m ==1
    else
    end
    id_set{m} = link_frame(m,track_set{m},track_set{m+1},number_batch,number_overlap);
end
%id_link = link_frame(track_set{1},track_set{2},number_batch,number_overlap);
id_set{m+1} = zeros(size(track_set{m+1})); %
list_all_trajectory(track_set,id_set,number_batch,number_overlap,x000000)
%draw_trajectory(track_set{1},id_set)


function [window_overlap,id] = choose_id(tracks,head,tail) %[...)
n_tracks = numel(tracks);
cols = size(tracks{1},2);
number_overlap = tail-head;
window_overlap = zeros(number_overlap,cols,n_tracks);
id = zeros(1,n_tracks);

for ii = 1:n_tracks
    tj = tracks{ii};
    t_index = (tj(:,1) < tail & ...
        tj(:,1) >= head);
   new_tj =  tj(t_index,:);
  
    if ~isempty(new_tj) && size(new_tj,1)>(tail-head)/2
      id(ii) = 1;
      %interp:
      if size(new_tj,1) < number_overlap
       window_overlap(:,:,ii) = overlap_padding(new_tj,tail-head,...
            head);       
      else
       window_overlap(:,:,ii) = new_tj;
      end%the table contain the data;
    end
end


end

function new_A = overlap_padding(A,padding, s) %t,x,y,...
n = size(A,2);
t = A(:,1);
xq = s:s+padding-1;
new_A = zeros(padding,n);
new_A(:,1) = xq;
for ii = 2:n
    v = A(:,ii);
    vq = interp1(t,v,xq,'linear','extrap');
    new_A(:,ii) = vq;
end
end

function id_link = link_frame(list_number,tracks1,tracks2,number_batch,number_overlap)%return the id link
%number_batch = 200/220;number_overlap = 20;
% 1 pre 2 after
if list_number > 1 
    number_batch = number_batch+number_overlap; 
end
[window1,id1] = choose_id(tracks1,...
    number_batch-number_overlap,number_batch);
[window2,id2] = choose_id(tracks2,...
    0,number_overlap);
id_link = id1';

%cal similarity
window1_index = find(id1>0);
window2_index = find(id2>0);

% inverse_order = zeros(size(id2));
% a = id2(window2_index);
% inverse_order(window2_index) = [1:length(id2)];
% x,y coloumn
window1_eff = window1(:,2:3,window1_index);
window1_eff = reshape(window1_eff,[],size(window1_eff,3)); % col vector space
window2_eff = window2(:,2:3,window2_index);
window2_eff = reshape(window2_eff,[],size(window2_eff,3));


%cal similarity
dist_link = dist(window1_eff',window2_eff);
% link row tail -- cols head
[Link,I] = min(dist_link,[],2);% read the id ; %the unique
%a = inverse_order(I);
a = window2_index(I);
%I((Link > 1e-3)|~no_repeat_item(I)) = 0; % and clear the reproducable
a((Link > 1e-3)|~no_repeat_item(I)) = 0;
%a = find(window2_index'==I);

id_link(window1_index) = a;
end

function y = no_repeat_item(x)
y = zeros(size(x));
 [b,m] = unique(x,'first');
 result = sortrows([m,b]);
 y(result(:,1)) = 1;
end

function [y,id_set]= find_link_tracks_id(s,id,id_set)
y=id;
%   if s == 2 && id==10
%       a=1;
%   end
for ii = s:1:numel(id_set)
%      if ii == 2 && id ==10
%         a=1
%      end
    track_ids  = id_set{ii}; 
    if track_ids(id) == -1
        y = [];
        break;
    end
    if track_ids(id) > 0 % -1 read ;0 not link
      y = [y,track_ids(id)];
      id_pre = id;
      id = track_ids(id);
      track_ids(id_pre) = -1;
      %id_set{ii} = track_ids;% readed
      
    else     
      track_ids(id) = -1;
       break;
    end
end
id_set{ii} = track_ids; %update the id table
end

function list_all_trajectory(track_set,id_set,number_batch,number_overlap,imp)
 % -1 readed ;0 not link;others 
 % change the time T
 num = numel(id_set);


for ii = 1:num
    if mod(ii,5) == 1
        figure
        imshow(imp)
        hold on
    end
    for jj = 1:numel(track_set{ii})
        %track_set_temp = track_set{ii};
       A= [];
       [ids_link,id_set] =  find_link_tracks_id(ii,jj,id_set);
       for k = 1:length(ids_link)
           cnt = k + ii-1;
       track_set_temp = track_set{cnt};
       tj = track_set_temp{ids_link(k)};  
       % change time and delete some slices
       if  k>1         
           t_index = (tj(:,1) < number_overlap & tj(:,1) >= 0);
           %change the time
           tj(t_index,:) = [];
           tj(:,1) = tj(:,1)-number_overlap + number_batch*k;
       end
       A = [A;tj];
       end
       if ~isempty(A)
           plot(A(:,2),A(:,3))
       hold on
       end
       
    end
    disp(ii)
end
end


function draw_trajectory(tracks)
figure
hold on
n_tracks = numel(tracks);
c = jet(n_tracks);
for s = 1 : n_tracks
x = tracks{s}(:, 2);
y = tracks{s}(:, 3);
plot(x, y, '.-', 'Color', c(s, :))
end
axis equal
xlabel( 'x' )
ylabel( 'y' )
end