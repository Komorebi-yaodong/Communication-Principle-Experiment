clear all;
clc;

fs = 1000;
dt = 1/fs;
t = 0:dt:5-dt;
t1 = 0:dt:2-dt;
t2 = 0:dt:3-dt;

x = cos(2*pi*10*t1);
y = -sin(2*pi*10*t2);

x_c = cos(2*pi*10*t);
y_c = -sin(2*pi*10*t);

z = [x,y];
subplot(411);
plot(t,z);
title("z");

[f,Z] = T2F(t,z);

[~,z2] = F2T(f,Z);

subplot(412);
plot(f,Z);
title("Z");

lpf = LPF(2,f,2);  % 低通滤波器

subplot(413);
plot(t,z2.*x_c);
title("z_r");

subplot(414);
plot(t,z2.*y_c);
title("z_i");
