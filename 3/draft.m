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
t2 = 0:dt:N/4-dt;

show_num = 8;  % 展示多少码元的信号；

%% 基带信号与载波
binary_source = randi([0, 1], 1, N);  % 生成0和1的随机序列
bs = sigexpand(binary_source,fs);

subplot(321);
plot(t,bs);
title("调制信号");
xlabel("t");
ylabel("幅度");
axis([-0.2,show_num+0.2,-0.2,1.2]);

%% QAM调制
bs1 = zeros(1,N/4);  % _0与_1
bs2 = zeros(1,N/4);  % 0_与1_
for i = 4 : 4 : N  % 串并转换 和 2-4电平转换
    if binary_source(i-3)==0 && binary_source(i-1)==0
        bs1(round(i/4)) = -3;
    elseif binary_source(i-3)==0 && binary_source(i-1)==1
        bs1(round(i/4)) = -1;
    elseif binary_source(i-3)==1 && binary_source(i-1)==0
        bs1(round(i/4)) = 1;
    else
        bs1(round(i/4)) = 3;
    end
    
    if binary_source(i-2)==0 && binary_source(i)==0
        bs2(round(i/4)) = -3;
    elseif binary_source(i-2)==0 && binary_source(i)==1
        bs2(round(i/4)) = -1;
    elseif binary_source(i-2)==1 && binary_source(i)==0
        bs2(round(i/4)) = 1;
    else
        bs2(round(i/4)) = 3;
    end
end

bs1 = sigexpand(bs1,fs);
bs2 = sigexpand(bs2,fs);

c1 = A*cos(2*pi*c_f*t2);  % 载波1
c2 = -A*sin(2*pi*c_f*t2);  % 载波2

qam = bs1.*c1+bs2.*c2;
subplot(323);
plot(t2,qam);
title("16QAM已调信号");
xlabel("t");
ylabel("幅度");
axis([-0.2,show_num+0.2,-4.6,4.6]);

%% 噪声
snr_db = 0;  % 信噪比（分贝）
snr = SNR(snr_db);  % 信噪比
B_qam = 4;  % 信号带宽
B_bpf = 2*c_f+2*B_qam;  % 理想带通滤波器带宽
power_qam = POWER(qam);  % 求解平均功率
n0 = power_qam/snr/B_bpf;
sigma = sqrt(n0*fs*c_f/2);
noise = sigma*randn(1,fs*(N/4));  % 噪声
qam_noise = qam+noise;  % 信号与加性噪声
% qam_noise = qam;  % 信号与加性噪声

%% 滤波器接收
[f,QAM_NOISE] = T2F(t2,qam_noise);  % 转换到频域
bpf = BPF(f,-c_f-B_qam,c_f+B_qam,1);  % 带通滤波器
BPF_QAM = bpf.*QAM_NOISE;  % 经过带通滤波器后
[~,bpf_qam] = F2T(f,BPF_QAM);  % 变换为时域
c_real_qam = bpf_qam.*c1 ;  % 乘上本地载波
c_imag_qam = bpf_qam.*c2 ;  % 乘上本地载波
[~,C_REAL_QAM] = T2F(t2,c_real_qam) ;  % 变换到频域
[~,C_IMAG_QAM] = T2F(t2,c_imag_qam) ;  % 变换到频域
lpf = LPF(B_qam,f,2);  % 低通滤波器
LPF_REAL_QAM = lpf .* (C_REAL_QAM);  % 经过低通滤波器
LPF_IMAG_QAM = lpf .* (C_IMAG_QAM);  % 经过低通滤波器
[~,lpf_real_qam] = F2T(f,LPF_REAL_QAM);  % 变换到时域
[~,lpf_imag_qam] = F2T(f,LPF_IMAG_QAM);  % 变换到时域

subplot(324);
plot(t2,lpf_real_qam);
hold on;
plot(t2,lpf_imag_qam);
title("16QAM低通滤波器输出信号(abs)");
xlabel("t");
ylabel("幅度");
legend(["同向分量","正交分量"]);
axis([-0.2,show_num+0.2,-8,8]);

%% 解调信号——对输出信号进行抽样判决
real_unqam = qam_sj(lpf_real_qam,fs);  % 进行抽样判决
imag_unqam = qam_sj(lpf_imag_qam,fs);  % 进行抽样判决
r_ = sample(lpf_real_qam, fs);
i_ = sample(lpf_imag_qam, fs);
% 16QAM星座点
constellation = [-(3+3i), -(3+1i), -(3-3i), -(3-1i), ...
                 -(1+3i), -(1+1i), -(1-3i), -(1-1i), ...
                 (3+3i), (3+1i), (3-3i), (3-1i), ...
                 (1+3i), (1+1i), (1-3i), (1-1i)];

% 绘制星座图
subplot(322);
scatter(real(constellation), imag(constellation), 'filled');
hold on;
scatter(r_, i_);
grid on;
axis([-7,7,-3.5,3.5]);
title('16QAM 星座图');
xlabel('I');
ylabel('R');
ax = gca;  % 获取当前坐标轴对象
ax.XAxisLocation = 'origin';  % 设置X轴显示在中心
ax.YAxisLocation = 'origin';  % 设置Y轴显示在中心

unqam = zeros(1,N);  % 初始化
for i = 1:1:round(N/4)  % 串并转换
    if real_unqam(i) == -3
         unqam(4*i-3) = 0;
         unqam(4*i-1) = 0;
    elseif real_unqam(i) == -1
        unqam(4*i-3) = 0;
        unqam(4*i-1) = 1;
    elseif real_unqam(i) == 1
        unqam(4*i-3) = 1;
        unqam(4*i-1) = 0;
    else
        unqam(4*i-3) = 1;
        unqam(4*i-1) = 1;
    end
    
    if imag_unqam(i) == -3
         unqam(4*i-2) = 0;
         unqam(4*i) = 0;
    elseif imag_unqam(i) == -1
        unqam(4*i-2) = 0;
        unqam(4*i) = 1;
    elseif imag_unqam(i) == 1
        unqam(4*i-2) = 1;
        unqam(4*i) = 0;
    else
        unqam(4*i-2) = 1;
        unqam(4*i) = 1;
    end
end

unqam = sigexpand(unqam,fs);  % 信号拓展
subplot(325);
plot(t,unqam);
title("QAM解调信号");
xlabel("t");
ylabel("幅度");
axis([-0.2,show_num+0.2,-0.2,1.2]);

%% 计算信噪比
begins = -15;  % 最小信噪比
ends = 5;  % 最大信噪比
times = 30;  % 测试次数
n = begins:ends;  % 信噪比轴
% Pe = 1-(1-0.5.*erfc(sqrt(SNR(n)*sin(pi/4)))).^2;  % 理论误码率
% Pe = (3/8) .* erfc(sqrt(SNR(n)*10^0.4));
Pe = 2*(1-(1/4))*0.5*erfc(sqrt(3*SNR(n)/(16-1))/sqrt(2));
pe = zeros(1,length(n));  % 实际误码率
for sdb = begins : ends
    for i = 1:times
        a = randi([0, 1], 1, N);  % 生成0和1的随机序列
        out = run_qam(t2,a,A,c_f,fs,B_qam,N,sdb);  % 进行调制解调
        out = out - a;  % 信号差
        pe(-begins+sdb+1) = pe(-begins+sdb+1) + (sum(abs(out),"all")/N);  % 误码累计
    end
    pe(-begins+sdb+1) = pe(-begins+sdb+1)/times;  % 平均误码率
%     disp(pe(-begins+sdb+1));
end

subplot(326);
plot(n,Pe);
hold on;
plot(n,pe);
% semilogy(n,Pe);
% hold on;
% semilogy(n,pe);
legend(["理论误码率曲线","实际误码率曲线"]);
title("误码率曲线");
xlabel("信噪比(db)");
ylabel("误码率");
axis([begins,ends,-0.1,1]);
% axis([-15 5 0.00000001 1]);

disp(sum(abs(unqam-bs))/fs/N);