% Experiment 20150710 
%%Christian Meyer 07/19/15

%CH_1 is CD44
%CH_2 is CD24
%CH_3 is EpCAM

numCh = 1;
%Analyze CD24+CD44+EpCAM well
Seg = struct()
seg_file = dir(['Segmented/*5.mat']);
k = 1;
l = 1;
for i = 1:size(seg_file,1)
    load(['Segmented/' seg_file(i).name])
    for j = 1:size(CO.BF.Perimeter,2)
        if CO.BF.Perimeter(j) ~= 0
            Seg.BF.Area(k) = CO.BF.Area(j);
            Seg.BF.Perimeter(k) = CO.BF.Perimeter(j);
            Seg.BF.AtoP(k) = CO.BF.Area(j)./CO.BF.Perimeter(j);
            k = k + 1;
        end
    end
    Seg.numCytowoutNuc(l) = CO.numCytowoutNuc;
    Seg.cellCount(l) = CO.cellCount;
    l = l+1;
end


%Plot in 3D
clear data
for q = 1:numCh
    chnm = ['CH_' num2str(q)];
    %data(:,q) = Seg.BF.IntperA/max(Seg.BF.IntperA);
    %data(:,q) = Seg.BF.Intensity
    %data(:,q) = Seg.BF.Area
    data(:,q) = Seg.BF.IntperA
    %data(:,q) = Seg.BF.AtoP

end

figure()
hold on
plot(data(:,2),data(:,3),'r.','linewidth',4)
xlabel('CD49f','fontsize',14)
ylabel('EpCAM','fontsize',14)


[clust_idx cent_loc] = kmeans(data,3);

figure()
hold on
scatter3(data(clust_idx==1,1),data(clust_idx==1,2),data(clust_idx==1,3),100,'b.')
scatter3(data(clust_idx==2,1),data(clust_idx==2,2),data(clust_idx==2,3),100,'m.')
scatter3(data(clust_idx==3,1),data(clust_idx==3,2),data(clust_idx==3,3),100,'r.')
scatter3(cent_loc(1,1),cent_loc(1,2),cent_loc(1,3),150,'bx');
scatter3(cent_loc(2,1),cent_loc(2,2),cent_loc(2,3),150,'mx');
scatter3(cent_loc(3,1),cent_loc(3,2),cent_loc(3,3),150,'rx');
xlabel('CD44','fontsize',20)
ylabel('CD49f','fontsize',20)
zlabel('EpCAM','fontsize',20)

figure()
d = [data(:,1);data(:,2);data(:,3)];
d(d==Inf) = [];
[x,y] = ksdensity(d,0:.1:50)
plot(y,x,'linewidth',4)


figure()
hold on
col = hsv(3);
bar(1,length(data(clust_idx==1)),'b')
bar(2,length(data(clust_idx==2)),'m')
bar(3,length(data(clust_idx==3)),'r')
title('TNBC Subpopulations','fontsize',20)
axis('off')




figure()
hold on
scatter3(data(:,1),data(:,2),data(:,3),100,'r.')
xlabel('CD44')
ylabel('EpCAM')
zlabel('CD24')
title('Three markers coexpression (CD24 stain corrected')

%Demonstrate cell segmentation on multi channel images
temp = regexp({NUC.filnms.name},'-C09.jpg');
idx = find(cellfun(@isempty,temp)==0);
figure()
clf
subplot(2,2,1)

i = 3;
%First segment the nucleus 
temp = imread([NUC.dir filesep NUC.filnms(idx(i)).name]);
im(:,:,1) = rgb2gray(temp);  %Use if images are in jpg
%im(:,:,1) = imtophat(im2double(im(:,:,1)), strel('disk', tophat_rad));
imshow(im(:,:,1),[])
for q = 1:numCh
    chnm = ['CH_' num2str(q)]
    temp = imread([Cyto.BF.dir filesep Cyto.BF.filnms(idx(i)).name]);
    im(:,:,q+1) = rgb2gray(temp);  %Use if images are in jpg
    %im(:,:,q+1) = imtophat(im2double(im(:,:,q+1)), strel('disk', tophat_rad));
    im(:,:,q+1) = uint16(im(:,:,q+1));
    subplot(2,2,q+1)
    imshow(im(:,:,q+1),[])
end
figure()
col_map = hsv(4);
imshow(im,[],col_map)

figure()
i = 14;
seg_file = dir('Segmented/*C09*.mat')
load(['Segmented/' seg_file(i).name])
subplot(1,2,1)
imshow(label2rgb(CO.Nuc_label),[])
subplot(1,2,2)
imshow(label2rgb(CO.label),[])
