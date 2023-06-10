clear;
N=500000;
sigma = sqrt(0.1);
u = sigma*randn(1,N);

u_meam = mean(u);
u_var = var(u);

subplot(211);
plot(u(1:100));
grid on;
ylabel('u(n)');
xlabel('n');

subplot(212);
hist(u,50);
grid on;
ylabel('histogram of u(n)');