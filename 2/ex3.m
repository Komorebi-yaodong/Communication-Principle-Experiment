clear all;

N = 1024;  % 采样总数
B = 20;  % 频率
T = 1/B;  % 周期
t = linspace(0,5*T,N);  % 时域
dt = t(2)-t(1);
m_power = 1;  % 功率
A = sqrt(2*m_power);  % 振幅
m = A*cos(2*pi*B*t);  % 余弦信源

c_f = 100;  % 载波频率
c = cos(2*pi*c_f*t);  % 载波信号

n_power = 0.001;  % 噪声单边功率谱密度。

dsb = m.*c;  % DSB调制
[f,DSB] = T2F(t,dsb);
% 用带通滤波器保留下边带LSB
bpf_lsb = BPF(f,-c_f,c_f,1);  % 边带滤波器
SSB = DSB.*bpf_lsb;  % 保留下边带LSB
[t1,ssb] = F2T(f,SSB);

subplot(411);
plot(t,ssb);
hold on;
plot(t,m);
title("SSB已调信号时域波形图");
xlabel("y");
ylabel("时域");
legend("SSB调制后信号","原信号");
grid on;

subplot(412);
plot(f,SSB);
title("已调信号的下边带调制频谱图");
xlabel("f");
ylabel("频域");
axis([-150,150,0,0.4]);
grid on;

subplot(413);
plot(f,DSB-SSB);
title("已调信号的上边带调制频谱图");
xlabel("f");
ylabel("频域");
axis([-150,150,0,0.4]);
grid on;

% 高斯白噪声
sigma = sqrt(n_power*(1/dt)/2);  % 公式求sigma
u = sigma*randn(1, N);  % 高斯白噪声
ssb_u = ssb+u;  % 经过高斯白噪声
[f,SSB_U] = T2F(t,ssb_u);
% 带通滤波器
bpf = BPF(f,-c_f,c_f,1);
BPF_SSB_U = bpf.*SSB_U;  % 经过带通滤波器
[t,bpf_ssb_u] = F2T(f,BPF_SSB_U);

% 相干解调
ussb = bpf_ssb_u.*c;  % 乘上载波
[f,USSB] = T2F(t,ussb);
lpf = LPF(B,f,4);  % 低通滤波器
M_OUT = lpf.*USSB;  % 经过低通滤波器
[t,m_out] = F2T(f,M_OUT);
subplot(414);
plot(t,m_out);
hold on;
plot(t,m);
xlabel("t");
ylabel("时域信号");
legend("解调信号","原信号");
title("相干解调后波形");
grid on;