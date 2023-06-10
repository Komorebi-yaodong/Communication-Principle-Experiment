function out = sample(s,fs)
% 抽样判决
%------------------------输入参数 
% t：时间
% s1：原始信号
% fs：判断时间（1s）
%---------------------输出(返回)参数
% out：输出信号
N = length(s)/fs;
out = zeros(1,N);
for i = 1 : N
    out(i) = s((i-1)*fs+fs/2);
end

end