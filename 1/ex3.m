clear all;

t = linspace(0,0.6,1024);

x = 0.4*sin(100*pi*t)+0.4*sin(640*pi*t);
u = randn(1,1024);
y = x+u;

Nf = length(t);
[f,Y] = T2F(t,y);

subplot(211);
plot(t,y);
title("x(t)+u(n)");
xlabel("x");
ylabel("x(t)+u(n)");
grid on;

subplot(212);
plot(f,abs(Y));
title("频谱");
xlabel("频率（Hz）");
grid on;