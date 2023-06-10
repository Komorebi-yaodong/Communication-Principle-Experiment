% function [t_out,x_out] = sample(t,fm,x,fs)  
function x_out = sample(t,fm,x,fs)  
% 抽样函数
%------------------------输入参数
% t：时域
% fs：抽样频率
% fm：模拟频率
% x：信号
%---------------------输出(返回)参数
% x_out：抽样信号
gap = ceil(fm/fs);
n = length(t);
x_out = zeros(1,n);
x_out(1:gap:n) = x(1:gap:n);
% t_out = t(1:gap:n);
% x_out = x(1:gap:n);

end

