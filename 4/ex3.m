%仿真未编码和进行（7,4）Hamming码的编码的QPSK调制通过AWGN信道后的误比特性能比较
clear;
close all;
clc;
N = 1000000;               %信息比特行数
M = 4;                    %QPSK调制
n = 7;                    %Hamming编码码组长度
m = 3;                    %Hamming码监督位长度
graycode = [0,1,3,2];     %格雷编码规则

msg = randi([0,1],N,n-m);      %信息比特序列
msg1 = reshape(msg',log2(M),N*(n-m)/log2(M))';    %重塑信息比特序列
msg1_de = bi2de(msg1,'left-msb');                 %信息比特序列转换位十进制形式
msg1 = graycode(msg1_de+1);                       %格雷编码
msg1 = pskmod(msg1,M);                            %4QPSK调制
Eb1 = norm(msg1).^2/(N*(n-m));                    %计算比特能量
msg2 = encode(msg,n,n-m,'hamming/binary');        %Himming编码
msg2 = reshape(msg2',log2(M),N*n/log2(M))';       %重塑编码后序列
msg2 = bi2de(msg2,'left-msb');                    %比特序列转换位十进制形式
msg2 = graycode(msg2+1);                          %格雷编码
msg2 = pskmod(msg2,M);                            %Himming编码数据进行4PSK调制
Eb2 = norm(msg2).^2/(N*(n-m));                    %计算比特能量
EbNo = 0:10;                                      %信噪比
EbNo_lin = 10.^(EbNo/10);                         %转换为线性值
for index = 1:length(EbNo)
    sigma1 = sqrt(Eb1/(2*EbNo_lin(index)));       %未编码的噪声标准差
    %加入高斯白噪声
    rx1 = msg1 + sigma1*(randn(1,length(msg1))+1i*randn(1,length(msg1)));    
    y1 = pskdemod(rx1,M);                         %未编码4PSK解调
    y1_de = graycode(y1+1);                       %未编码的格雷逆映射
    [err ber1(index)] = biterr(msg1_de',y1_de,log2(M));   %未编码的误比特率
    
    sigma2 = sqrt(Eb2/(2*EbNo_lin(index)));       %编码的噪声标准差
    %加入高斯白噪声
    rx2 = msg2 + sigma2*(randn(1,length(msg2))+1i*randn(1,length(msg2)));    
    y2 = pskdemod(rx2,M);                         %编码4PSK解调
    y2_de = graycode(y2+1);                       %编码的格雷逆映射
    y2_de = de2bi(y2_de,'left-msb');              %转换为二进制形式
    y2_de = reshape(y2_de',n,N)';                 %重塑矩阵
    y2_de = decode(y2_de,n,n-m,'hamming/binary'); %译码
    [err ber2(index)] = biterr(msg,y2_de);        %编码的误比特率
end
figure();
% plot(EbNo,ber2,'-*');
semilogy(EbNo,ber1,'-bo',EbNo,ber2,'-r*');
legend('未编码','Hamming(7,4)编码的4PSK在AWGN下的性能');
xlabel('EbNo/dB');
ylabel('误比特率');
