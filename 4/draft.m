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

%% 量化信噪比
A_db = -70:0.1:0;
A = 10.^(A_db/10);
signal = zeros(1,length(A));
signal1 = zeros(1,length(A));
noise = zeros(1,length(A));
noise1 = zeros(1,length(A));

for i=1:1:length(A)
    % 正弦信号
    x = sqrt(A(i))*sin(2*pi*t);
    x_s = sample(t,fm,x,fs) ;
    level = max(abs(x));
    
%     x=floor(x*2048)/2048;
    
    % A律PCM编码
    [n,pcm] = PCM(t,x,1,2048);
    pcm1=PCMcoding(x);
    
    % A律PCM译码
    [~,y] = PCM(n,pcm,0,2048);
    y1 = PCMdecoding(pcm1,level);
    noise(i) = mean((x-y).^2);
    noise1(i) = mean((x-y1).^2);
    signal(i) = mean(y.^2);
    signal1(i) = mean(y1.^2);
end
snr = signal./noise;
snr1 = signal1./noise1;

% figure;
% plot(A,noise);
% hold on;
% plot(A,noise1);
% grid on;
% legend("me","her");

% figure;
% plot(A_db,signal);
% hold on;
% plot(A_db,signal1);
% grid on;
% legend("me","her");

figure;
plot(A_db,10*log10(snr));
hold on;
plot(A_db,10*log10(snr1));
grid on;
legend("me","her");

% figure;
% plot(t,y);
% hold on;
% plot(t,y1);
% grid on;
% legend("me","her");

