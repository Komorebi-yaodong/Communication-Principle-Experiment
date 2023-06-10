function out_bit = run_qam(t2,binary_source,A,c_f,fs,B_qam,N,snr_db)
%% qam调制解调
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

%% QAM调制
qam = bs1.*c1+bs2.*c2;

%% 噪声
snr = SNR(snr_db);  % 信噪比
B_bpf = 2*c_f+2*B_qam;  % 理想带通滤波器带宽
power_qam = POWER(qam);  % 求解平均功率
n0 = power_qam/snr/B_bpf;
sigma = sqrt(n0*fs*c_f/2);
noise = sigma*randn(1,fs*(N/4));  % 噪声
qam_noise = qam+noise;  % 信号与加性噪声

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

%% 解调信号——对输出信号进行抽样判决
[~,lpf_real_qam] = F2T(f,LPF_REAL_QAM);  % 变换到时域
[~,lpf_imag_qam] = F2T(f,LPF_IMAG_QAM);  % 变换到时域
real_unqam = qam_sj(lpf_real_qam,fs);  % 进行抽样判决
imag_unqam = qam_sj(lpf_imag_qam,fs);  % 进行抽样判决
out_bit = zeros(1,N);  % 初始化
for i = 1:1:round(N/4)  % 串并转换
    if real_unqam(i) == -3
         out_bit(4*i-3) = 0;
         out_bit(4*i-1) = 0;
    elseif real_unqam(i) == -1
        out_bit(4*i-3) = 0;
        out_bit(4*i-1) = 1;
    elseif real_unqam(i) == 1
        out_bit(4*i-3) = 1;
        out_bit(4*i-1) = 0;
    else
        out_bit(4*i-3) = 1;
        out_bit(4*i-1) = 1;
    end
    
    if imag_unqam(i) == -3
         out_bit(4*i-2) = 0;
         out_bit(4*i) = 0;
    elseif imag_unqam(i) == -1
        out_bit(4*i-2) = 0;
        out_bit(4*i) = 1;
    elseif imag_unqam(i) == 1
        out_bit(4*i-2) = 1;
        out_bit(4*i) = 0;
    else
        out_bit(4*i-2) = 1;
        out_bit(4*i) = 1;
    end
end