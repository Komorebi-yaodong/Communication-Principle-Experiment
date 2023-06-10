clear;

N = 100;
t = linspace(0,0.6,N);
y = cos(300*pi*t);

subplot(131);
plot(t,y) ;
xlabel("t");
ylabel("已调信号时域谱");

[f,Y] = T2F(t,y);

subplot(132);
plot(f,abs(Y)) ;
xlabel("f");
ylabel("已调信号频域谱");

dt = t(2)-t(1);
fs = 1/dt;
Y1 = BPF(Y,fs , 100, 200, 1);

subplot(133);
plot(f,abs(Y1)) ;
xlabel("f");
ylabel("已调信号频域谱");
