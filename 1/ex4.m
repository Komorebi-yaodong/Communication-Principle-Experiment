clear all;

N = 1024; % 采样数
t = linspace(0,0.6,N); % 时域
m = 0.1*cos(15*pi*t)+1.5*sin(25*pi*t)+0.5*cos(40*pi*t);
c = cos(250*pi*t);
dt = t(2)-t(1);
fs = 1/dt;
A = 3; % 正交分量
snr_dB = 10; % 信噪比(分贝)
snr = 10^(snr_dB/10); % 信噪比
pni = 1; % 接收噪声功率
psi = 10; % 接收信号功率
B = 40; % 滤波器的带宽为两倍的基带带宽 2*（20）

% 进入信道前
am = (A+m).*c; % AM调制
[f,AM] = T2F(t,am); % 已调信号的频域谱

% 情况一，进入信道后

sigma = sqrt(pni); % 高斯噪声标准差
u = sigma*randn(1, N); % 噪声

% 求ps原本大小
ps = sum(abs(am).^2)/length(am); % 发送功率
% 衰减系数
L = psi/ps; % 衰减系数

subplot(421);
plot(t,am*sqrt(L));
xlabel("t");
ylabel("am");
title("调制后的时域波形图(不考虑解调器)");
grid on;

subplot(422);
plot(f,abs(AM*sqrt(L)));
xlabel("f");
ylabel("AM");
title("调制后的频域谱(不考虑解调器)");
grid on;

y = am*sqrt(L)+u; % 接收的信号（时域）
[f,Y] = T2F(t,y); %  接收的信号（频域）

subplot(423);
plot(t,y);
xlabel("t");
ylabel("y");
title("awgn后的时域波形图(不考虑解调器)");
grid on;

subplot(424);
plot(f,abs(Y));
xlabel("f");
ylabel("Y");
title("awgn后的频域谱(不考虑解调器)");
grid on;

% 情况二，忽略信道中功率的衰减
subplot(425);
plot(t,am);
xlabel("t");
ylabel("am");
title("调制后的时域波形图(考虑解调器)");
grid on;

subplot(426);
plot(f,abs(AM));
xlabel("f");
ylabel("AM");
title("调制后的频域谱(考虑解调器)");
grid on;

% 根据给的公式求解n0
n0 = (sum(abs(am).^2)/length(am))/(snr*B);
% 根据给的公式求解白噪声的标准差
sigma_1 = sqrt(n0*fs/2);
sigma_2 = n0*fs/2;
u_1 = sigma_1*randn(1, N);
y1 = am+u_1; % 接收的信号（时域）
[f1,Y1] = T2F(t,y1); %  接收的信号（频域）

subplot(427);
plot(t,y1);
xlabel("t");
ylabel("y");
title("awgn后的时域波形图(考虑解调器)");
grid on;

subplot(428);
plot(f1,abs(Y1));
xlabel("f");
ylabel("Y");
title("awgn后的频域谱(考虑解调器)");
grid on;