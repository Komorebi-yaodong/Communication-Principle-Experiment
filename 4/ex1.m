clear all;
clc;
close all;

%% 主变量
fm = 1000;  % 仿真频率
dt = 1/fm;  % 仿真时间间隔
t_start = -20;
t_end = 20;
t = t_start:dt:t_end-dt;  %  时域

%% 信号
x = cos(0.15*pi*t) + sin(2.5*pi*t) + cos(4*pi*t);  % 低通信号
f_x = 2;  % 最高信号频率为2

subplot(311);
plot(t,x);
title("低通信号波形");
xlabel("t");
ylabel("幅度");
axis([t_start,t_end,-3,3]);


%% 抽样信号
fs = 4;  % 抽样频率
% [t_s,x_s] = sample(t,fm,x,fs);  % 信号抽样
x_s = sample(t,fm,x,fs);  % 信号抽样
subplot(312);
plot(t,x_s);
% hold on;
% plot(t,x);
% legend("抽样信号","原本信号");
title("抽样信号波形");
xlabel("t");
ylabel("幅度");
axis([t_start,t_end,-3,3]);


%% 信号恢复
t2 = t_start*5:dt:t_end*5;  % 卷积时域
gt = sinc(fs*t2);  % 恢复用的信号
x_r = conv(gt,x_s);
t_3 = t_start*6:dt:t_end*6-dt;

subplot(313);
plot(t_3(ceil(length(x_r)/2)+t_start*fm:ceil(length(x_r)/2)+t_end*fm-1),x_r(ceil(length(x_r)/2)+t_start*fm:ceil(length(x_r)/2)+t_end*fm-1));
hold on;
plot(t,x);
legend("抽样信号","原本信号");
title("还原信号波形");
xlabel("t");
ylabel("幅度");
axis([t_start,t_end,-3,3]);