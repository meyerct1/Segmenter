%Mixed Gaussian Model curves
load('Compiled Segmentation Results.mat')
%test = ' EpCAM (G8.8) AF488'
%Chance to ImNum_perWell = sum(Seg.ColSingle == row(1,:)); if test
%conditions are by rows instead of columns
%conditions = {'1:100','1:200','1:400','1:800','1:1600','Control'}
maxNumGMclust = 7;
% q = 1;chnm = ['CH_' num2str(q)];
% fontsz = 20;
% row = unique(Seg.RW,'rows');row = row(1,:);
Im = []; options = statset('MaxIter',100000,'Display','final','TolFun',10.^-20);
columns = unique(Seg.CL,'rows');
%Chance to ImNum_perWell = sum(Seg.ColSingle == row(1,:)); if test
%conditions are by rows instead of columns
temp = [];
for i = 1:length(Seg.ColSingle)
    temp(i) = strcmp(Seg.ColSingle(i,:),columns(1,:));
end
ImNum_perWell = sum(temp)

color = jet(length(conditions)); BIC = [], AIC = [];
for p = 2:length(conditions)
    Im = [];
    p
    col = columns(p,:);
    idx = [];temp = [];to_remove = [];tempdata = [];
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images in specified row and col
    tempdata(1,:) = Seg.(chnm).IntperA';
    tempdata(2,:) = Seg.NucArea;
    to_remove = intersect(idx,[find(Seg.class.under==1); find(Seg.class.debris==1); find(Seg.NucArea ==0)]);
    idx = idx(~ismember(idx,to_remove));
    tempdata = tempdata(:,idx);
    for k = 2:maxNumGMclust       
        try
            GMmodel = fitgmdist(tempdata(1,:)',k,'options',options); %Fit a mixed gaussian model
            BIC(p,k-1) = GMmodel.BIC;
            AIC(p,k-1) = GMmodel.AIC;
        catch
            BIC(p,k-1) = NaN
            AIC(p,k-1) = NaN
        end
    end
end

figure
y = []
for p = 2:length(conditions)
	hold on  
    y = BIC(p,~isnan(BIC(p,:))); x = 2:maxNumGMclust;
    x = x(~isnan(BIC(p,:)));
    y = y./max(y);
    plot(x,y,'linewidth',2,'color',color(p,:))
end
legend({conditions{1:end-1}})
str = ['BIC by dilution' test]
title(str)
ylabel('Normalized BIC')
xlabel('Cluster #')
set(gca,'fontsize',fontsz,'XTick',[2:maxNumGMclust])


id = []
for p = 2:length(conditions)
    y = BIC(p,~isnan(BIC(p,:)))
    [x id(p-1)] = min(y);
end
figure
bar(1:length(conditions)-1,id+1,.5)
str = ['Cluster Number' test]
title(str)
ylabel('Cluster #')
xlabel('Conditions')
set(gca,'fontsize',fontsz,'XTick',[1:length(conditions)-1],'XTickLabel',{conditions{1:end-1}})






