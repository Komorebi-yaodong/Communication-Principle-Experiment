fs = 1000;
t = 0:1/fs:1-1/fs;
m_power = 1;  % 功率
A = sqrt(2*m_power);  % 振幅
x = A*cos(2*pi*B*t);  % 余弦信源

c_f = 100;  % 载波频率
c = cos(2*pi*c_f*t);  % 载波

% DSB调制
x = x.*c;  % DSB调制

% 求解功率谱密度
N = length(x);
xdft = fft(x);
xdft = xdft(1:N/2+1);
psdx = (1/(fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:fs/length(x):fs/2;

plot(freq,psdx)
grid on
title("Periodogram Using FFT")
xlabel("Frequency (Hz)")
ylabel("Power/Frequency")