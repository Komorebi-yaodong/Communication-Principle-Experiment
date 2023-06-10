function y = BPF(x, fs, f1, f2, order)
% x: 输入信号
% fs: 采样率
% f1: 通带下限频率
% f2: 通带上限频率
% order: 滤波器阶数

% 计算归一化通带边界频率
w1 = f1 / (fs/2);
w2 = f2 / (fs/2);

% 设计带通滤波器系数
b = fir1(order, [w1 w2], 'bandpass');

% 应用滤波器
y = filter(b, 1, x);
end