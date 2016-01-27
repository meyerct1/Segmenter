function Plot = MergePlot(ExamineSet, Tracks, CompareSet, PotentialRange, EndFrame)

for YY = 1:length(ExamineSet) 
    Examine = Tracks(Tracks.TrackID == ExamineSet.TrackID(YY),:);

    shapes = char('o', '+', '*', 's','V','p', 'X', 'o', '+', '*', 's','V','p', 'X','o', '+', '*', 's','V','p', 'X'); 
    colors = char('m', 'c', 'g' , 'k', 'b','m','m', 'c', 'g' , 'k', 'b','m', 'c', 'g' , 'k', 'b','m', 'c', 'g' , 'k', 'b');

    scatter3(Examine.Curr_X,Examine.Curr_Y,Examine.CurrentImage, 150, shapes(YY),colors(YY))
    label = cellstr(num2str(Examine.TrackID(1)));
    text((Examine.Curr_X(end)),(Examine.Curr_Y(end)),(Examine.CurrentImage(end)),label, 'FontSize', 14)
    xlim([0 672])
    ylim([0 1024])
    zlim([1 EndFrame])
    title('Merge Tracks By Frame', 'FontSize', 14)
    xlabel('X Coordinates', 'FontSize',14)
    ylabel('Y Coordinates', 'FontSize',14)
    zlabel('Frame', 'FontSize',14)
    hold on

    EF = ExamineSet.StartFrame(1);
    plot3([67 605 605 67 67], [102 102 922 922 102],[EF EF EF EF EF], '--r','LineWidth',2)
    label = cellstr(num2str(ExamineSet.StartFrame(1)));
    text(65,100,label, 'FontSize', 14)
    hold on

    % PotentialRange = 30;

    NOP = 100;
    radius = PotentialRange;
    THETA=linspace(0,2*pi,NOP);
    RHO=ones(1,NOP)*radius;
    [X,Y] = pol2cart(THETA,RHO);
    X=X+Examine.Curr_X(1);
    Y=Y+Examine.Curr_Y(1);
    Z = Examine.CurrentImage(1) * ones(1,length(X));
    plot3(X,Y,Z,'-r', 'LineWidth', 1.25);
end 

for WW = 1: length(CompareSet)
    Compare = Tracks(Tracks.TrackID == CompareSet.TrackID(WW),:);
    shapes_2 = char('<','X', 'o', 'p', 's','*','p', 'X', 'o', 'p', 's','*','p', 'X','o', 'p', 's','*','p', 'X', 'X','o', 'p', 's','*','p', 'X', 'X','o', 'p', 's','*','p', 'X', 'X','o', 'p', 's','*','p', 'X'); 
    colors_2 = char('k','b', 'm', 'c' ,'y', 'k', 'b','m', 'c' ,'y', 'k', 'b','m', 'c' ,'y', 'k', 'b','c' ,'y', 'k', 'b','m', 'c' ,'y', 'k', 'b','m', 'c','c' ,'y', 'k', 'b','m', 'c' ,'y', 'k', 'b','m', 'c');
    scatter3(Compare.Curr_X,Compare.Curr_Y,Compare.CurrentImage, 180, shapes_2(WW),colors_2(WW))
    label = cellstr(num2str(Compare.TrackID(1)));
    text((Compare.Curr_X(1)+1),(Compare.Curr_Y(1)+1),label, 'FontSize', 18)
    
    NOP = 100;
    radius = PotentialRange;
    THETA=linspace(0,2*pi,NOP);
    RHO=ones(1,NOP)*radius;
    [X,Y] = pol2cart(THETA,RHO);
    X=X+Compare.Curr_X(end);
    Y=Y+Compare.Curr_Y(end);
    Z = Compare.CurrentImage(end) * ones(1,length(X));
    plot3(X,Y,Z,'-b', 'LineWidth', 1.45);
    
end



drawnow 
Plot = [];
end