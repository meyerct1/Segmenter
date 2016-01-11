%Bin the CIDRE map
cnt_i = 0; s_v = zeros(1024);
for i = 1:2:2048
    cnt_i = cnt_i+1;
    cnt_j = 0;
    for j = 1:2:2048
        cnt_j = cnt_j+1;
        s_v(cnt_i,cnt_j) = mean([v(i,j),v(i+1,j+1),v(i,j+1),v(i+1,j)]);
    end
end

%Bin the CIDRE map
cnt_i = 0; s_z = zeros(1024);
for i = 1:2:2048
    cnt_i = cnt_i+1;
    cnt_j = 0;
    for j = 1:2:2048
        cnt_j = cnt_j+1;
        s_z(cnt_i,cnt_j) = mean([z(i,j),z(i+1,j+1),z(i,j+1),z(i+1,j)]);
    end
end
