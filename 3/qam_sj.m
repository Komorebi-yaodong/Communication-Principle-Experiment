function out = qam_sj(s,fs)
% 抽样判决
%------------------------输入参数 
% t：时间
% s1：原始信号
% fs：判断时间（1s）
%---------------------输出(返回)参数
% out：输出信号
N = length(s)/fs;
out = zeros(1,N);
gate1 = -2;
gate2 = 0;
gate3 = 2;
for i = 1 : N
    if s((i-1)*fs+fs/2)<gate1
        out(i) = -3;
    elseif s((i-1)*fs+fs/2)>=gate1 && s((i-1)*fs+fs/2)<gate2
        out(i) = -1;
    elseif s((i-1)*fs+fs/2)>=gate2 && s((i-1)*fs+fs/2)<gate3
        out(i) = 1;
    elseif s((i-1)*fs+fs/2)>=gate3
        out(i) = 3;
    end
end

end