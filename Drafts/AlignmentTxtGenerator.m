function [file_names] = AlignmentTxtGenerator(dim,imExt)

%Navigate to the folder with the images to stich
clear
dim = 3;
imExt = 'jpg';
%Only align one of the cytoplamic channels and then use that alignment on
%the other images
file_specs = dir(['*.' imExt]);
file_names = {file_specs(:).name};
im = imread(file_names{1});
lenX = size(im,1);
lenY = size(im,2);

%Based on stack:
%http://stackoverflow.com/questions/3706219/algorithm-for-iterating-over-an-outward-spiral-on-a-discrete-2d-grid-from-the-or

dx = 1; %First step is to the left starting at the top corner
dy = 0; 
seg_pass = 0;
seg_len = dim;

for j = 1:dim^2
    if j == 1
        x = 0;
        y = 0; 
        seg_pass = seg_pass+1;
    else
        x = x+dx;
        y = y+dy;
        seg_pass = seg_pass+1;

        if(seg_pass == seg_len)
            seg_pass = 0;
            temp = dx;
            dx = -dy;
            dy = temp; %Turn to the right clockwise
            if(dx == 0)
                seg_len = seg_len-1;
            end
        end
    end
   coor(j,1) = x;
   coor(j,2) = y;
end

coor(:,1) = coor(:,1)*lenX;
coor(:,2) = coor(:,2)*lenY;
mkdir('Alignment_txt_files');

for i = 1:(size(file_names,2))/dim^2
    subFileNames = file_names(((i-1)*(dim^2)+1):(i*dim^2));
    nm = char(subFileNames(1));
    foo = strfind(nm, '-');
    %Store the row and column names from the filename
    rw = nm(foo(2)+1:foo(2)+3);
    cl = nm(foo(3)+1:foo(3)+3);
    str = sprintf('Well-%s-%s.txt',rw,cl);
    fid = fopen(['Alignment_txt_files/' str],'w');
    %Only align one of the cytoplamic channels and then use that alignment on
    %the other images
    str = 'dim = 2'
    fprintf(fid,'%s\n',str);
    cnt = 1;
    for j = size(subFileNames,2):(-1):1
        str = GetFullPath(subFileNames{j});
        fprintf(fid,'%s ; ; (%.1f,%.1f)\n',str,coor(cnt,1),coor(cnt,2));
        cnt = cnt+1;
    end
    fclose(fid);
end

    
    