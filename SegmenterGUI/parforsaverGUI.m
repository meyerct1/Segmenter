function [] = parforsaverGUI(rw,cl,CO,i,expDir)
    save([expDir filesep 'Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
end