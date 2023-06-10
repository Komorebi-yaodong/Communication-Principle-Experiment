clear;
clc;
close all;

%% 参数
fm = 160;  % 仿真频率
fs = 160;
dt = 1/fm;  % 仿真时间间隔
t_start = -1;
t_end = 1;
t = t_start:dt:t_end-dt;  %  时域

%% PCM编码译码
Ac = 1;
x = Ac*sin(2*pi*t);  % 原信号
x_s = sample(t,fm,x,fs);
level = max(abs(x_s));
[n,pcm] = PCM(t,x_s,1,2048);  % 编码
[~,y] = PCM(n,pcm,0,2048);  % 译码

subplot(311);
plot(n,pcm);
title("PCM编码后信号序列");
xlabel("n");
ylabel("幅度");
grid on;

subplot(312);
plot(t,x);
hold on;
plot(t,y);
legend("抽样信号信号","译码信号");
title("PCM编码前后对比");
xlabel("t");
ylabel("幅度");
grid on;

%% 量化信噪比
A_db = -70:0.1:0;
A = 10.^(A_db/10);
signal = zeros(1,length(A));
noise = zeros(1,length(A));

for i=1:1:length(A)
    % 正弦信号
    x = sqrt(A(i))*sin(2*pi*t);
    x_s = sample(t,fm,x,fs) ;
    level = max(abs(x));
    % A律PCM编码
    [n,pcm] = PCM(t,x,1,2048);
    
    % A律PCM译码
    [~,y] = PCM(n,pcm,0,2048);
    noise(i) = mean((x-y).^2);
    signal(i) = mean(y.^2);
end
snr = signal./noise;

subplot(3,1,3);
plot(A_db,10*log10(snr));
% plot(A_db,snr);
% plot(A_db,noise);
title("不同幅度（A_c）下量化信噪比");
xlabel("A_c(dB)");
ylabel("量化信噪比");
