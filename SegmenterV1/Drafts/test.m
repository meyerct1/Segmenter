function [] = test(t,x)

end

num = 500;
ParallelPoolInfo = Par(num);
parfor_progress(num,[])
parfor i = 1:num
    Par.tic
    ran_net = rand(num)^-1;
    ParallelPoolInfo(i) = Par.toc;
    t = ParallelPoolInfo(i).ItStop-ParallelPoolInfo(i).ItStart
    parfor_progress([],t)
end
stop(ParallelPoolInfo)
parfor_progress(0,[]);