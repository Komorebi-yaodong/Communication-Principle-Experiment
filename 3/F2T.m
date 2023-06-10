function [t,st] = F2T(f,sf)
% f—离散的频率；sf—信号的频谱
df = f(2)-f(1);  % 频率分辨率
Fmx = f(end)-f(1)+df;  % 频率区间长度
dt = 1/Fmx ; % 已知频率区间长度时，求时间分辨率
N = length(sf);
T = dt*N;  % 信号持续时间
t = 0:dt:T-dt;  % 离散傅立叶反变换，是T2F的逆过程
sff = fftshift(sf);  % 把对称的频谱进行平移，平移后同T2F中的sf 
%st = Fmx*ifft(sff);
st = Fmx*ifft(sff)*T;
% 由于T2F中求信号频谱在DFT基础上乘了一个因子T/N，反变换求信号时要乘以其倒数即N/T＝1/dt，正好等于Fmx
end