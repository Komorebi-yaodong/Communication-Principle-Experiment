function out = SampleJudge(s1,fs,gate)
% 抽样判决
%------------------------输入参数 
% t：时间
% s1：原始信号
% fs：判断时间（1s）
%---------------------输出(返回)参数
% out：输出信号
N = length(s1)/fs;
out = zeros(1,N);
for i = 1 : N
    if s1((i-1)*fs+fs/2)>gate
        out((i-1)*fs+1:i*fs) = ones(1,fs);
    else
        out((i-1)*fs+1:i*fs) = zeros(1,fs);
    end
end

end
