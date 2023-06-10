function [f,sf] = T2F(t,st)  
% 该子函数需要两个参数t和st，t—离散时间，st—离散信号

dt = t(2)-t(1);     % 时间分辨率
T = t(end);
df = 1/T;
N = length(st) ;  % 离散傅里叶变换长度
f = -N/2*df:df:N/2*df-df;
sf = fft(st);
%sf = T/N*fftshift(sf);
sf = 1/N*fftshift(sf);
% 信号的频谱与离散傅立叶变换之间的关系
% fftshift(x)是将信号的频谱x进行移位，与原点对称

end