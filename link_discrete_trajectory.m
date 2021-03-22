path = '.\result\';
file_names = dir([path, '*.xml']);
number_batch = 200;number_overlap = 10;
tracks1 = importTrackMateTracks([path,file_names(1).name],true);
tracks2 = importTrackMateTracks([path,file_names(2).name],true);% read one 
%choose the window_data
%interp to 10 frame
%cal the similarity
link_frame(tracks1,tracks2,number_batch,number_overlap)


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
      if size(new_tj) < number_overlap
        window_overlap(:,:,ii) = overlap_padding(new_tj,tail-head,...
            head); 
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
    vq = interp1(t,v,xq);
    new_A(:,ii) = vq;
end
end

function link_frame(tracks1,tracks2,number_batch,number_overlap)%return the id link
%number_batch = 200;number_overlap = 10;
% 1 pre 2 after
[window1,id1] = choose_id(tracks1,...
    number_batch-number_overlap,number_batch);
[window2,id2] = choose_id(tracks2,...
    0,number_overlap);
%cal similarity

for ii = 1:num_link
    
end
end

function cal_similarity(A,B) %length A<B
 for a = A %Ã¶¾Ù
     %pist2
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