function out_bit = run_qpsk(t2,binary_source,A,c_f,fs,gate,B_qpsk,N,snr_db)
%% qpsk调制解调
%------------------------输入参数 
% t2：时间
% binary_source：原始信号(bit)
% A：载波幅度
% c_f：载波频率
% fs：判断时间（1s）
% gate：判决门限
% B_bpsk：信号带宽
% snr_db：信噪比
%---------------------输出(返回)参数
% out：输出信号

%% 基带信号与载波
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

%% QPSK调制
qpsk = bs1.*c1+bs2.*c2;

%% 噪声
snr = SNR(snr_db);  % 信噪比
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

%% 解调信号——对输出信号进行抽样判决
[~,lpf_real_qpsk] = F2T(f,LPF_REAL_QPSK);  % 变换到时域
[~,lpf_imag_qpsk] = F2T(f,LPF_IMAG_QPSK);  % 变换到时域
real_unqpask = qpsk_sj(lpf_real_qpsk,fs,gate);  % 进行抽样判决
imag_unqpask = qpsk_sj(lpf_imag_qpsk,fs,gate);  % 进行抽样判决
out_bit = zeros(1,N);  % 初始化
for i = 1:1:round(N/2)  % 串并转换
    out_bit(2*(i)-1:2*i) = [real_unqpask(i),imag_unqpask(i)];
end