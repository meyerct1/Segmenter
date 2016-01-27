load('Compiled Segmentation Results.mat')
%conditions = {'2uL 18S','SC','KRT19','Neg Control'};
conditions = {'VU109','VU109 rep','G8.8', 'G8.8 rep','Neg Control'};
numCh = 3; %Number of fluorescent channels excluding nuclear
%channel
q = 1;
fontsz = 20;
%Look at all conditions together
figure(1)
clf
columns = unique(Seg.CL,'rows')
conditions = columns
for j = 1:length(columns)
    col = columns(j,:); %sprintf('C0%i',j)
    idx = [];temp = [];to_remove = [];
    row = 'R03';
    %col = 'C03';
    for i = 1:length(Seg.RW)
        temp(i,1) = strcmp(Seg.RW(i,:),row);
        temp(i,2) = strcmp(Seg.CL(i,:),col);
    end
    idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
     to_remove = intersect(idx,[find(Seg.class.under==1); find(Seg.class.debris==1)]);%; find(Seg.NucArea <2200)]);
%    to_remove = intersect(idx,[find(Seg.cellcount<40)]);

     idx = idx(~ismember(idx,to_remove));
    str = sprintf('%s-%s',row,col);
    %look at epcam stain
    chnm = ['CH_' num2str(q)];

    %subplot(2,2,1)
    
     avg(j) = mean(Seg.(chnm).IntperA(idx))
     sd(j) = std(Seg.(chnm).IntperA(idx))
     images = unique(Seg.ImNum(idx));im_idx = [];
     for i = 1:length(images)
        im_idx = [im_idx; find(Seg.ImNumSingle==images(i))];
     end
     back(j) = mean(Seg.(chnm).Background(im_idx));
     hold on
     [x,y] = ksdensity(Seg.(chnm).IntperA(idx));
     plot(y,x,'linewidth',4);
     title(str,'fontsize',fontsz)
     xlabel('Intensity per unit Area Uptake Control','fontsize',fontsz)
     ylabel('Frequency','fontsize',fontsz)
end


legend(conditions)
set(gca,'fontsize',fontsz)



%Plot all points together
idx = []; idx = 1:length(Seg.NucArea);
to_remove = []; temp = [];
row = 'R02';col = 'C08';tempdata = [];
%Remove the control condition
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end 
to_remove = intersect(idx,[find(Seg.class.under==1); find(Seg.class.debris==1); find(temp(:,1)==1 & temp(:,2)==1)]);
idx = idx(~ismember(idx,to_remove));
for q = 1:numCh
    chnm = ['CH_' num2str(q)]
    tempdata(:,q) = Seg.(chnm).IntperA(idx)
end
options = statset('MaxIter',10000,'Display','final','TolFun',10.^-20);
for i = 2:10
    GMdist = fitgmdist(tempdata,i,'options',options)
    BIC(i) = GMdist.BIC
    AIC(i) = GMdist.AIC
end
clf
plot(2:10,BIC(2:end)) 
GMdist = fitgmdist(tempdata,4,'options',options)
clust_data = cluster(GMdist,tempdata);

figure(1)
clf
hold on
col = jet(max(clust_data));
for i = 1:max(clust_data)
    plot3(tempdata(clust_data == i,1),tempdata(clust_data == i,2),tempdata(clust_data == i,3),'.','color',col(i,:),'linewidth',4)
end
xlabel('EpCAM')
ylabel('CD29')
zlabel('Vim')
set(gca,'fontsize',14)
whitebg(1,'k')

%Look at any one condition specifically with control
figure()
idx = [];temp = [];to_remove = [];
row = 'R03';col = 'C02';
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
     to_remove = intersect(idx,[find(Seg.class.under==1); find(Seg.class.debris==1); find(Seg.NucArea <2200)]);
     idx = idx(~ismember(idx,to_remove));
str = sprintf('%s-%s',row,col);
%look at epcam stain
chnm = ['CH_' num2str(q)];
hold on
[x,y] = ksdensity(Seg.(chnm).IntperA(idx));
plot(y,x,'linewidth',4);
title(str,'fontsize',fontsz)
xlabel('Intensity per unit Area EpCAM','fontsize',fontsz)
ylabel('Frequency','fontsize',fontsz)
axis([0 max(y) 0 max(x)])

%Look at the scatter plot
figure()
idx = [];temp = [];to_remove = [];
for i = 1:length(Seg.RW)
    temp(i,1) = strcmp(Seg.RW(i,:),row);
    temp(i,2) = strcmp(Seg.CL(i,:),col);
end
idx = [idx, find(temp(:,1) == 1 & temp(:,2) == 1)]; %Index of all the images for R03
     to_remove = intersect(idx,[find(Seg.class.under==1); find(Seg.class.debris==1); find(Seg.NucArea <2200)]);
     %to_remove = intersect(idx,[find(Seg.cellcount<40)]);
idx = idx(~ismember(idx,to_remove));
str = sprintf('%s-%s',row,col);
hold on
plot(Seg.NucArea(idx),Seg.(chnm).Intensity(idx),'.')
title(str,'fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)
ylabel('Cytoplasm Intensity','fontsize',fontsz)

figure()
hold on
plot(Seg.NucArea(idx),Seg.(chnm).IntperA(idx),'.')
title(str,'fontsize',fontsz)
xlabel('Nuclear Area','fontsize',fontsz)
ylabel('Cytoplasm Intensity per Unit Area','fontsize',fontsz)


%Build a mixed gaussian model for each condition
fontsz = 12;
options = statset('MaxIter',10000,'Display','final','TolFun',10.^-20);
columns = unique(Seg.CL,'rows')


for k = 1:length(columns)
    col = columns(k,:);
    row = 'R02';%col = 'C03';
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
    GMmodel = fitgmdist(tempdata(1,:)',2,'options',options); %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    
    figure('Units','normalized','Position',[.1 .6 .35 .5])
    hold on
    plot(tempdata(2,cluster_idx == 1),tempdata(1,cluster_idx==1),'.','linewidth',5)
    plot(tempdata(2,cluster_idx == 2),tempdata(1,cluster_idx==2),'.','linewidth',5)
    str = sprintf('\\begin{tabular}{c|c|c} & Group 1 & Group 2\\\\ percent & %.2f & %.2f \\\\ $\\mu$ & %.2f & %.2f \\\\ $\\sigma$ & %.1f & %.1f \\end{tabular}',...
                  GMmodel.ComponentProportion(1)*100,GMmodel.ComponentProportion(2)*100,GMmodel.mu(1),GMmodel.mu(2), std(tempdata(1,cluster_idx==1)), std(tempdata(1,cluster_idx==2)))
    ylim=get(gca,'ylim');xlim=get(gca,'xlim');
    h = annotation('textbox','Interpreter','LaTex')
    set(h,'String',str,'fontsize',fontsz)
    set(h,'Position',[.6-h.Position(3),.9-h.Position(4),h.Position(3),h.Position(4)])
    str = sprintf('20X Imaging,%s-%s,%s',row,col,conditions(k,:));
    title(str);xlabel('Nuclear Area'); ylabel('EpCAM intensity/area');
    set(gca,'fontsize',fontsz)
    
    figure('Units','normalized','Position',[.1 .1 .7 .5])
    subplot(1,2,1)
    hold on
    [x,y] = ksdensity(Seg.(chnm).IntperA(idx));
    plot(y,x,'linewidth',4);
    x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
    plot(x_ran,pdf(GMmodel,x_ran),'linewidth',4)
    str = sprintf('20X Imaging,%s-%s,%s',row,col,conditions(k,:));
    title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
    legend('Orig Data','GM model')
    set(gca,'fontsize',fontsz)
    subplot(1,2,2)
    hold on
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    OVL = trapz(x_ran, min([dist1,dist2],[],2));
    %CohenD = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
    plot(x_ran,dist1,'linewidth',4)
    plot(x_ran,dist2,'linewidth',4)
    str = sprintf('Percent Overlap: %.2f%%',OVL*100);
    title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
    legend('Pop 1','Pop 2')
    set(gca,'fontsize',fontsz)
    
end
    


%Build a mixed gaussian model for each condition
fontsz = 12;
options = statset('MaxIter',10000,'Display','final','TolFun',10.^-20);
columns = unique(Seg.CL,'rows')


for k = 1:length(columns)
    col = columns(k,:);
    row = 'R02';%col = 'C03';
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
         to_remove = intersect(idx,[find(Seg.class.under==1); find(Seg.class.debris==1); find(Seg.NucArea <800)]);
    idx = idx(~ismember(idx,to_remove));
    tempdata = tempdata(:,idx);
    GMmodel = fitgmdist(tempdata(1,:)',2,'options',options); %Fit a mixed gaussian model
    cluster_idx = cluster(GMmodel,tempdata(1,:)');
    dx = (-min(tempdata(1,:))+max(tempdata(1,:)))./10^6;
    x_ran = [min(tempdata(1,:)):dx:max(tempdata(1,:))]';
    dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
    dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
    [Im.Mean1(k), id(1)] = max(GMmodel.mu);
    [Im.Mean2(k), id(2)] = min(GMmodel.mu);
    Im.std1(k) = std(tempdata(1,cluster_idx==id(1)));
    Im.std2(k) = std(tempdata(1,cluster_idx==id(2)));
    Im.Pop1(k) = GMmodel.ComponentProportion(1);
    Im.Pop2(k) = GMmodel.ComponentProportion(2);
    Im.OVL(k) = trapz(x_ran,min([dist1,dist2],[],2));
    Im.CohenD(k) = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
    Im.NumCellsUsed(k) = length(tempdata);
end



 

figure()
bar(1:length(conditions),[Im.Pop1.*100;Im.Pop2.*100]',.45,'stacked')
axis([0,length(conditions)+1,0,120]);
legend('Imaging, EpCAM low','Imaging, EpCAM hi')
ylabel('Percent'); title('Imaging Population Distribution')
set(gca,'XTickLabel',conditions,'fontsize',fontsz)

figure()
hold on
plot(1:length(conditions),Im.OVL*100,'linewidth',4)
legend('Imaging')
ylabel('Percent Overlapping')
title('Percentage Overlap by Ab conc.')
set(gca,'XTickLabel',conditions,'fontsize',fontsz)


figure()
hold on
errorbar(1:length(conditions),Im.Mean1,Im.std1,'linewidth',4)
errorbar(1:length(conditions),Im.Mean2,Im.std2,'linewidth',4)
legend('EpCAM hi','EpCAM lo')
ylabel('Mean group')
title('Mean intensity by Ab conc. Imaging')
set(gca,'XTick', [1:length(conditions)], 'XTickLabel',conditions,'fontsize',fontsz)




%Build a mixed gaussian model for each condition
fontsz = 12; Im = [];
options = statset('MaxIter',10000,'Display','final','TolFun',10.^-20);
columns = unique(Seg.CL,'rows')

figure()
for p = 1:4
    Im = [];
    for k = 1:length(columns)-4
        col = columns(k,:);
        row = 'R02';%col = 'C03';
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
        GMmodel = fitgmdist(tempdata(1,:)',2,'options',options); %Fit a mixed gaussian model
        cluster_idx = cluster(GMmodel,tempdata(1,:)');
        dx = (-min(tempdata(1,:))+max(tempdata(1,:)))./10^6;
        x_ran = [min(tempdata(1,:)):dx:max(tempdata(1,:))]';
        dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
        dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
        [Im.Mean1(k), id(1)] = max(GMmodel.mu);
        [Im.Mean2(k), id(2)] = min(GMmodel.mu);
        Im.std1(k) = std(tempdata(1,cluster_idx==id(1)));
        Im.std2(k) = std(tempdata(1,cluster_idx==id(2)));
        Im.Pop1(k) = GMmodel.ComponentProportion(1);
        Im.Pop2(k) = GMmodel.ComponentProportion(2);
        Im.OVL(k) = trapz(x_ran,min([dist1,dist2],[],2));
        Im.CohenD(k) = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
        Im.NumCellsUsed(k) = length(tempdata);
    end
    subplot(1,2,1)
    hold on
    plot(1:length(conditions)-4,Im.Mean1,'linewidth',2)
    title('High')
    subplot(1,2,2)
    hold on
    plot(1:length(conditions)-4,Im.Mean2,'linewidth',2)
    title('Low')
end


%Signal to noise plot:
columns = unique(Seg.CL,'rows')

figure()
for k = 1:length(columns)
    col = columns(k,:);
    row = 'R02';%col = 'C03';
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
    Signal(k) = mean(tempdata(1,:));
    Noise(k) = mean(Seg.CH_1.Background((k-1)*37+1:k*37));
end



figure()
plot(Signal./Noise,'linewidth',3)
title('Signal to noise Vim ab dilution')
xlabel('Condition')
ylabel('SNR')
set(gca,'fontsize',16)
set(gca,'fontsize',16)
set(gca,'XTick',[1:length(columns)],'XTickLabel',columns)



%Build a mixed gaussian model for each optimum condition
k = 2;
fontsz = 12;
options = statset('MaxIter',10000,'Display','final','TolFun',10.^-20);
columns = unique(Seg.CL,'rows');

col = columns(k,:);
row = 'R02';%col = 'C03';
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
GMmodelFun = @(X,K) fitgmdist(X,K,'options',options); %Fit a mixed gaussian model
for i = 2:10
    GMmodel = GMmodelFun(tempdata(1,:)',i)
    BIC(i-1) = GMmodel.BIC;
end

plot(BIC)

GMmodel = GMmodelFun(tempdata(1,:)',3);
%GMmodel = fitgmdist(tempdata(1,:)',2,'options',options); %Fit a mixed gaussian model
cluster_idx = cluster(GMmodel,tempdata(1,:)');





figure('Units','normalized','Position',[.1 .6 .35 .5])
hold on
plot(tempdata(2,cluster_idx == 1),tempdata(1,cluster_idx==1),'.','linewidth',5)
plot(tempdata(2,cluster_idx == 2),tempdata(1,cluster_idx==2),'.','linewidth',5)
plot(tempdata(2,cluster_idx == 3),tempdata(1,cluster_idx==3),'.','linewidth',5)

str = sprintf('\\begin{tabular}{c|c|c} & Group 1 & Group 2\\\\ percent & %.2f & %.2f \\\\ $\\mu$ & %.2f & %.2f \\\\ $\\sigma$ & %.1f & %.1f \\end{tabular}',...
              GMmodel.ComponentProportion(1)*100,GMmodel.ComponentProportion(2)*100,GMmodel.mu(1),GMmodel.mu(2), std(tempdata(1,cluster_idx==1)), std(tempdata(1,cluster_idx==2)))
ylim=get(gca,'ylim');xlim=get(gca,'xlim');
h = annotation('textbox','Interpreter','LaTex')
set(h,'String',str,'fontsize',fontsz)
set(h,'Position',[.6-h.Position(3),.9-h.Position(4),h.Position(3),h.Position(4)])
str = sprintf('20X Imaging,%s-%s,%s',row,col,conditions(k,:));
title(str);xlabel('Nuclear Area'); ylabel('EpCAM intensity/area');
set(gca,'fontsize',fontsz)

figure('Units','normalized','Position',[.1 .1 .7 .5])
subplot(1,2,1)
hold on
[x,y] = ksdensity(Seg.(chnm).IntperA(idx));
plot(y,x,'linewidth',4);
x_ran = [min(tempdata(1,:)):max(tempdata(1,:))]';
plot(x_ran,pdf(GMmodel,x_ran),'linewidth',4)
str = sprintf('20X Imaging,%s-%s,%s',row,col,conditions(k,:));
title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
legend('Orig Data','GM model')
set(gca,'fontsize',fontsz)
subplot(1,2,2)
hold on
dist1 = pdf('Normal',x_ran,GMmodel.mu(1),std(tempdata(1,cluster_idx==1)));
dist2 = pdf('Normal',x_ran,GMmodel.mu(2),std(tempdata(1,cluster_idx==2)));
OVL = trapz(x_ran, min([dist1,dist2],[],2));
%CohenD = (GMmodel.mu(2)-GMmodel.mu(1))./sqrt((sum((tempdata(1,cluster_idx==1)-GMmodel.mu(1)).^2)+sum((tempdata(1,cluster_idx==2)-GMmodel.mu(2)).^2))/(sum(cluster_idx==1)+sum(cluster_idx==2)-2));
plot(x_ran,dist1,'linewidth',4)
plot(x_ran,dist2,'linewidth',4)
str = sprintf('Percent Overlap: %.2f%%',OVL*100);
title(str);ylabel('Frequency'); xlabel('EpCAM intensity/area');
legend('Pop 1','Pop 2')
set(gca,'fontsize',fontsz)
