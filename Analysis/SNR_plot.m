%Signal to noise 
load('Compiled Segmentation Results.mat')
test = ' KRT14 (2ab AF647)'
conditions = {'1:100','1:200','1:400','1:800','1:1600','Control'}
q = 1;
fontsz = 20;
row = unique(Seg.RW,'rows');
row = row(1,:);
%Look at all conditions together
figure()
clf
columns = unique(Seg.CL,'rows')
%Chance to ImNum_perWell = sum(Seg.ColSingle == row(1,:)); if test
%conditions are by rows instead of columns
temp = [];
for i = 1:length(Seg.ColSingle)
    temp(i) = strcmp(Seg.ColSingle(i,:),columns(1,:));
end
ImNum_perWell = sum(temp)

for j = 2:length(conditions)
    col = columns(j,:); %sprintf('C0%i',j)
    idx = [];temp = [];to_remove = [];
    %col = 'C03';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
    to_remove = intersect(idx,[find(Seg.class.under==1); find(Seg.class.debris==1); find(Seg.NucArea==0)]);
    %    to_remove = intersect(idx,[find(Seg.cellcount<40)]);

    idx = idx(~ismember(idx,to_remove));
    %str = sprintf('%s-%s',row,col);
    %look at epcam stain
    chnm = ['CH_' num2str(q)];

    %subplot(2,2,1)

%      avg(j) = mean(Seg.(chnm).IntperA(idx))
%      sd(j) = std(Seg.(chnm).IntperA(idx))
%      images = unique(Seg.ImNum(idx));im_idx = [];
%      for i = 1:length(images)
%         im_idx = [im_idx; find(Seg.ImNumSingle==images(i))];
%      end
%      back(j) = mean(Seg.(chnm).Background(im_idx));
     hold on
     [x,y] = ksdensity(Seg.(chnm).IntperA(idx));
     plot(y,x,'linewidth',4);
end
foo(1) = max(x);
foo(2) = mean(Seg.(chnm).Background(Seg.(chnm).Background ~=0))+2*std(Seg.(chnm).Background(Seg.(chnm).Background ~=0));
foo(3) = mean(Seg.(chnm).Background(Seg.(chnm).Background ~=0))-2*std(Seg.(chnm).Background(Seg.(chnm).Background ~=0));
h = area([foo(2),foo(3)],[foo(1),foo(1)],0);
alpha(h,.3)
legend(conditions)
str = ['Dilution Series' test];
title(str)
xlabel('Intensity per unit Area')
ylabel('Frequency')
set(gca,'fontsize',fontsz)

figure()
%Signal to noise plot
Noise = []; Signal = []; 
for k = 2:length(conditions)
    col = columns(k,:);
    idx = [];temp = [];to_remove = [];tempdata = [];
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images in specified row and col
    tempdata(1,:) = Seg.(chnm).IntperA';
    tempdata(2,:) = Seg.NucArea;
    %Remove Outliers 5 std in cytoplasm intensity and 3 std in nuclear area
    %to_remove = (tempdata(1,:)>(mean(tempdata(1,:))+5*std(tempdata(1,:))))+(tempdata(1,:)<(mean(tempdata(1,:))-5*std(tempdata(1,:)))) + (tempdata(2,:)>(mean(tempdata(2,:))+3*std(tempdata(2,:)))) + (tempdata(2,:)<(mean(tempdata(2,:))-3*std(tempdata(2,:))))
    to_remove = intersect(idx,[find(Seg.class.under==1); find(Seg.class.debris==1); find(Seg.NucArea ==0)]);
    idx = idx(~ismember(idx,to_remove));
    tempdata = tempdata(:,idx);
    Signal(k-1) = mean(tempdata(1,:));
    Noise(k-1) = mean(Seg.(chnm).Background((k-1)*ImNum_perWell+1:k*ImNum_perWell));
end
plot(Signal./Noise,'linewidth',3)
str = ['Signal to Noise' test 'dilution']
title(str)
xlabel('Condition')
ylabel('SNR')
set(gca,'fontsize',fontsz)
set(gca,'XTick',[1:length(conditions)-1],'XTickLabel',{conditions{1:end-1}})



