function [out]=sigexpand(d,M)   
% 信号拓展
%------------------------输入参数
% d：原信号
% M：信号拓展后一个码元长度
%---------------------输出(返回)参数
% out：拓展后信号
N=length(d);             %基带信号码元长度
out=zeros(1,N*M);
for i = 1 : N
    out((i-1)*M+1:i*M) = repmat(d(i), 1, M);
end
end