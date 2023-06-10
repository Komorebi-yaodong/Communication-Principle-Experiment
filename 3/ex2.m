clf;
clear all;
clc

%% 初始参数
N = 256;  % 256bit
Ts = 1;  % 持续时间为1s
A = 1;  % 载波幅值为1
c_f = 20;  % 载波频率为20Hz
gate = 0 ;  % 判决门限为0
fs = 1000;  % 基带信号中每个码元的采样点数
dt = Ts/fs;  % 抽样速率
T = 1;  % 抽样时间1s
t = 0:dt:N-dt;  % 总时间
t2 = 0:dt:N/2-dt;

show_num = 10;  % 展示多少码元的信号；

%% 基带信号与载波
binary_source = randi([0, 1], 1, N);  % 生成0和1的随机序列
bs = sigexpand(binary_source,fs);
bs1 = zeros(1,N/2);  % _0与_1
bs2 = zeros(1,N/2);  % 0_与1_
for i = 2 : 2 : N  % 串并转换
    if binary_source(i-1)==0
        bs1(round(i/2)) = -1;
    else
        bs1(round(i/2)) = 1;
    end
    if binary_source(i)==0
        bs2(round(i/2)) = -1;
    else
        bs2(round(i/2)) = 1;
    end
end
bs1 = sigexpand(bs1,fs);
bs2 = sigexpand(bs2,fs);

c1 = A*cos(2*pi*c_f*t2);  % 载波1
c2 = -A*sin(2*pi*c_f*t2);  % 载波2

subplot(511);
plot(t,bs);
title("调制信号");
xlabel("t");
ylabel("幅度");
axis([-0.2,show_num+0.2,-0.2,1.2]);

%% QPSK调制
qpsk = bs1.*c1+bs2.*c2;
subplot(512);
plot(t2,qpsk);
title("QPSK已调信号");
xlabel("t");
ylabel("幅度");
axis([-0.2,show_num+0.2,-1.6,1.6]);

%% 噪声
snr_db = 0;  % 信噪比（分贝）
snr = SNR(snr_db);  % 信噪比
B_qpsk = 2;  % 基带信号带宽
B_bpf = 2*c_f+2*B_qpsk;  % 理想带通滤波器带宽
power_qpsk = POWER(qpsk);  % 求解平均功率
n0 = power_qpsk/snr/B_bpf;
sigma = sqrt(n0*fs*c_f/2);
noise = sigma*randn(1,fs*(N/2));  % 噪声
qpsk_noise = qpsk+noise;  % 信号与加性噪声

%% 滤波器接收
[f,QPSK_NOISE] = T2F(t2,qpsk_noise);   % 转换到频域
bpf = BPF(f,-c_f-B_qpsk,c_f+B_qpsk,1);  % 带通滤波器
BPF_QPSK_NOISE = bpf .* QPSK_NOISE;  % 经过带通滤波器后

[~,bpf_qpsk] = F2T(f,BPF_QPSK_NOISE);  % 变换为时域
c_real_qpsk = bpf_qpsk.*c1 ;  % 乘上本地载波
c_imag_qpsk = bpf_qpsk.*c2 ;  % 乘上本地载波
[~,C_REAL_QPSK] = T2F(t2,c_real_qpsk) ;  % 变换到频域
[~,C_IMAG_QPSK] = T2F(t2,c_imag_qpsk) ;  % 变换到频域
lpf = LPF(B_qpsk,f,2);  % 低通滤波器
LPF_REAL_QPSK = lpf .* (C_REAL_QPSK);  % 经过低通滤波器
LPF_IMAG_QPSK = lpf .* (C_IMAG_QPSK);  % 经过低通滤波器
[~,lpf_real_qpsk] = F2T(f,LPF_REAL_QPSK);  % 变换到时域
[~,lpf_imag_qpsk] = F2T(f,LPF_IMAG_QPSK);  % 变换到时域

subplot(513);
plot(t2,lpf_real_qpsk);
hold on;
plot(t2,lpf_imag_qpsk);
title("低通滤波器输出信号");
xlabel("t");
ylabel("幅度");
legend(["同向分量","正交分量"]);
axis([-0.2,show_num+0.2,-4,4]);

%% 解调信号——对输出信号进行抽样判决
real_unqpask = qpsk_sj(lpf_real_qpsk,fs,gate);  % 进行抽样判决
imag_unqpask = qpsk_sj(lpf_imag_qpsk,fs,gate);  % 进行抽样判决
unqpask = zeros(1,N);  % 初始化
for i = 1:1:round(N/2)  % 串并转换
    unqpask(2*(i)-1:2*i) = [real_unqpask(i),imag_unqpask(i)];
end
unqpask = sigexpand(unqpask,fs);
subplot(514);
plot(t,unqpask);
title("QPSK解调信号");
xlabel("t");
ylabel("幅度");
axis([-0.2,show_num+0.2,-0.2,1.2]);

%% 计算信噪比
begins = -15;  % 最小信噪比
ends = 5;  % 最大信噪比
times = 30;  % 测试次数
n = begins:ends;  % 信噪比轴
% Pe = 1-(1-0.5*erfc(sqrt(SNR(n)/2))).^2;  % 理论误码率
Pe = 0.5*erfc(sqrt(SNR(n)/2));  % 理论误码率(解调后)
pe = zeros(1,length(n));  % 实际误码率
for sdb = begins : ends
    for i = 1:times
        a = randi([0, 1], 1, N);  % 生成0和1的随机序列
        out = run_qpsk(t2,a,A,c_f,fs,gate,B_qpsk,N,sdb);  % 进行调制解调
        out = out - a;  % 信号差
        pe(-begins+sdb+1) = pe(-begins+sdb+1) + (sum(abs(out),"all")/N);  % 误码累计
    end
    pe(-begins+sdb+1) = pe(-begins+sdb+1)/times;  % 平均误码率
%     disp(pe(-begins+sdb+1));
end

subplot(515);
% plot(n,Pe);
% hold on;
% plot(n,pe);
semilogy(n,Pe);
hold on;
semilogy(n,pe);
legend(["理论误码率曲线","实际误码率曲线"]);
title("误码率曲线");
xlabel("信噪比(db)");
ylabel("误码率");
% axis([begins,ends,-0.1,1]);
axis([-15 5 0.001 1]);

disp(sum(abs(unqpask-bs))/fs/N);