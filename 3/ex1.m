clear all;

%% 初始参数
N = 256;  % 256bit
Ts = 1;  % 持续时间为1s
A = 1;  % 载波幅值为1
c_f = 20;  % 载波频率为20Hz
gate = 0 ;  % 判决门限为0
fs = 200;  % 基带信号中每个码元的采样点数
dt = Ts/fs;  % 抽样速率
T = 1;  % 抽样时间1s
t = 0:dt:N-dt;  % 总时间

show_num = 10;  % 展示多少码元的信号；

%% 基带信号与载波
binary_source = randi([0, 1], 1, N);  % 生成0和1的随机序列
bs = sigexpand(binary_source,fs);  % 信号拓展
carryer = A*cos(2*pi*c_f*t);  % 载波

subplot(511);
plot(t,bs);
title("调制信号");
xlabel("t");
ylabel("幅度");
axis([-0.2,show_num+0.2,-0.2,1.2]);

%%  BPSK调制
bpsk = carryer.*(bs*2-1);
subplot(512);
plot(t,bpsk);
title("已调信号");
xlabel("t");
ylabel("幅度");
axis([-0.2,show_num+0.2,-1.2,1.2]);

%% 噪声
snr_db = 0;  % 信噪比（分贝）
snr = SNR(snr_db);  % 信噪比
B_bpsk = 1;  % 基带信号带宽为1
B_bpf = 2*c_f+2*B_bpsk;  % 理想带通滤波器带宽
power_bpsk = POWER(bpsk(1:fs));  % 求解平均功率
n0 = power_bpsk/snr/B_bpf;
sigma = sqrt(n0*fs*c_f/2);
noise = sigma*randn(1,fs*N);  % 噪声
bpsk_noise = bpsk+noise;  % 信号与加性噪声

%% 滤波器接收
[f,BPSK_NOISE] = T2F(t,bpsk_noise);   % 转换到频域
bpf = BPF(f,-c_f-B_bpsk,c_f+B_bpsk,1);  % 带通滤波器
BPF_BPSK_NOISE = bpf .* BPSK_NOISE;  % 经过带通滤波器后
[t1,bpf_bpsk_noise] = F2T(f,BPF_BPSK_NOISE);  % 变换为时域
carryer_bpsk_noise = bpf_bpsk_noise.*carryer ;  % 乘上本地载波
[f,CARRYER_BPSK_NOISE] = T2F(t1,carryer_bpsk_noise) ;  % 变换到频域
lpf = LPF(B_bpsk,f,1);  % 低通滤波器
LPF_BPSK_NOISE = lpf .* (CARRYER_BPSK_NOISE);  % 经过低通滤波器

subplot(513);
plot(f,LPF_BPSK_NOISE);
title("低通滤波器输出信号");
xlabel("f");
ylabel("幅度");
axis([-2,2,-0.08,0.08]);


%% 解调信号——对输出信号进行抽样判决
[t3,lpf_bpsk_noise] = F2T(f,LPF_BPSK_NOISE);  % 变换到时域
unbpsk = SampleJudge(lpf_bpsk_noise,fs,gate);  % 进行抽样判决
subplot(514);
plot(t3,unbpsk);
hold on;
plot(t3,lpf_bpsk_noise);
title("解调信号");
xlabel("t");
ylabel("幅度");
legend(["抽样判决后","抽样判决前"]);
axis([-0.2,show_num+0.2,-1.2,1.5]);

%% 计算信噪比
begins = -15;  % 最小信噪比
ends = 5;  % 最大信噪比
times = 30;  % 测试次数
n = begins:ends;  % 信噪比轴
Pe = 0.5*erfc(sqrt(SNR(n)));  % 理论误码率
pe = zeros(1,length(n));  % 实际误码率
for sdb = begins : ends
    for i = 1:times
        a = randi([0, 1], 1, N);  % 生成0和1的随机序列
        a = sigexpand(a,fs);  % 信号拓展
        out = run_bpsk(t,a,A,c_f,fs,gate,B_bpsk,sdb);  % 进行调制解调
        out = out - a;  % 信号差
        pe(-begins+sdb+1) = pe(-begins+sdb+1) + (sum(abs(out),"all")/fs/N);  % 误码累计
    end
    pe(-begins+sdb+1) = pe(-begins+sdb+1)/times;  % 平均误码率
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
% axis([begins,ends,-0.1,0.6]);
axis([-15 5 0.001 1]);