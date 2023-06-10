function out = run_bpsk(t,bs,A,c_f,fs,gate,B_bpsk,snr_db)
%% bpsk调制解调
%------------------------输入参数 
% t：时间
% bs：原始信号
% carryer：载波信号
% c_f：载波频率
% fs：判断时间（1s）
% gate：判决门限
% B_bpsk：信号带宽
% snr_db：信噪比
%---------------------输出(返回)参数
% out：输出信号

%%  BPSK调制
carryer = A*cos(2*pi*c_f*t);  % 载波
bpsk = carryer.*(bs*2-1);

%% 经过噪声
snr = SNR(snr_db);  % 信噪比
B_bpf = 2*c_f+2*B_bpsk;  % 理想带通滤波器带宽
power_bpsk = POWER(bpsk(1:fs));  % 求解平均功率
n0 = power_bpsk/snr/B_bpf;
sigma = sqrt(n0*fs*c_f/2);
noise = sigma*randn(1,length(bs));  % 噪声
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

%% 解调信号——LPF对输出信号进行抽样判决
[~,lpf_bpsk_noise] = F2T(f,LPF_BPSK_NOISE);  % 变换到时域
out = SampleJudge(lpf_bpsk_noise,fs,gate);

end
