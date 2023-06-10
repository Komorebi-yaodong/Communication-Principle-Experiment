clear all;

N = 1024;  % 采样总数
T = 1;  % 调制信号周期
t = linspace(0,5,N);  % 时域
dt = t(2)-t(1);   % 时域微分
B = 1;  % 调制信号带宽
A = 2;  % 直流分量

c_f = 10;  % 载波频率
m = cos(2*pi*t);  % 调制信号
c = cos(2*pi*c_f*t);  % 载波信号

n_power = 0.01;  % 噪声单边功率谱密度。

am = (A+m).*c; % AM调制
[f,AM] = T2F(t,am); % 已调信号的频域谱

subplot(311);
plot(t,am);
hold on;
plot(t,m);
xlabel("t");
ylabel("am");
title("AM已调信号的时域波形");
legend(["调制后信号","原信号"]);
grid on;

subplot(312);
plot(f,abs(AM));
xlabel("f");
ylabel("AM");
axis([-20,20,0,1.2])
title("已调信号的频谱");
grid on;

%  噪声
sigma = sqrt(n_power*(1/dt)/2);  % 公式求sigma
%sigma = sqrt(n_power);
u = sigma*randn(1, N);  % 高斯白噪声
am_u= am + u;  % 已调信号+高斯白噪声
[f1,AM_U] = T2F(t,am_u);  % 求频率谱；

% 经过带通滤波器
bpf = BPF(f,-c_f-B,c_f+B,1);  % 带通滤波器
BPF_AM_U = bpf.*AM_U;  % 经过带通滤波器
[t,bpf_am_u] = F2T(f,BPF_AM_U);
% 相干解调
uam_u = bpf_am_u.*c;  % 乘上载波
%uam_u = am_u.*c;  % 乘上载波
[f,UAM_U] = T2F(t,uam_u);
lpf = LPF(B,f,2);  % 低通滤波器
M_OUT = lpf.*UAM_U;  % 经过带通滤波器

[t,m_out] = F2T(f,M_OUT);
% 过滤直流分量
%m_out = m_out - A;
%[f,M_OUT] = T2F(t,m_out);

subplot(313);
plot(t,m_out);
hold on;
plot(t,m);
xlabel("t");
ylabel("时域信号");
legend(["解调后信号（保留直流分量）","原信号"]);
title("相干解调后的波形与原信号");
grid on;
