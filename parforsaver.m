function [] = parforsaver(rw,cl,CO,i)
    save(['Segmented/' rw '_' cl '_' num2str(i) '.mat'], 'CO')
end