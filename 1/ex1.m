clear;
x = 0:0.01:2*pi; % 时域
y1 = 2*exp(-0.5*x); % 函数一
y2 = cos(4*pi*x); % 函数二

plot(x,y1);
hold on;
plot(x,y2);
title("y1与y2")
xlabel("x");
ylabel("y");
legend("2e^{-0.5x}","cos(4\pi x)","FontSize",12);