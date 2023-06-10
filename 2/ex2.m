clear all;

N = 1024;
B = 10;  % 频率
T = 1/B;  % 周期
t = linspace(0,5*T,N);
dt = t(2)-t(1);
m_power = 1;  % 功率
A = sqrt(2*m_power);  % 振幅
m = A*cos(2*pi*B*t);  % 余弦信源

c_f = 100;  % 载波频率
c = cos(2*pi*c_f*t);  % 载波

n_power = 0.001;  % 噪声单边功率谱密度。

% DSB调制
dsb = m.*c;  % DSB调制

subplot(311);
plot(t,m);
hold on;
plot(t,dsb);
xlabel("t");
ylabel("时域信号");
title("DSB已调信号时域波形图");
legend("原信号","DSB已调信号");
grid on;

% 求解功率谱密度
[f1,power_density] = PowerDensity(t,dsb);
subplot(312);
plot(f1,power_density);
xlabel("f");
ylabel("功率谱密度");
% axis([0,150,0,0.13]);
title("已调信号的功率谱密度");
grid on;

% 高斯白噪声
sigma = sqrt(n_power*(1/dt)/2);  % 公式求sigma
u = sigma*randn(1, N);  % 高斯白噪声
dsb_u = dsb+u;  % 经过高斯白噪声
[f,DSB_U] = T2F(t,dsb_u);
% 带通滤波器
bpf = BPF(f,-c_f-B,c_f+B,1);
BPF_DSB_U = bpf.*DSB_U;  % 经过带通滤波器
[t,bpf_dsb_u] = F2T(f,BPF_DSB_U);

% 相干解调
udsb = bpf_dsb_u.*c;  % 乘上载波
[f,UDSB] = T2F(t,udsb);
lpf = LPF(B,f,2);  % 低通滤波器
M_OUT = lpf.*UDSB;  % 经过低通滤波器
[t,m_out] = F2T(f,M_OUT);
subplot(313);
plot(t,m_out);
hold on;
plot(t,m);
xlabel("t");
ylabel("时域信号");
legend("解调信号","原信号");
title("相干解调后波形");
grid on;