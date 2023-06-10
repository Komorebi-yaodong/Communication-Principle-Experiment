%����δ����ͽ��У�7,4��Hamming��ı����QPSK����ͨ��AWGN�ŵ������������ܱȽ�
clear;
close all;
clc;
N = 1000000;               %��Ϣ��������
M = 4;                    %QPSK����
n = 7;                    %Hamming�������鳤��
m = 3;                    %Hamming��ලλ����
graycode = [0,1,3,2];     %���ױ������

msg = randi([0,1],N,n-m);      %��Ϣ��������
msg1 = reshape(msg',log2(M),N*(n-m)/log2(M))';    %������Ϣ��������
msg1_de = bi2de(msg1,'left-msb');                 %��Ϣ��������ת��λʮ������ʽ
msg1 = graycode(msg1_de+1);                       %���ױ���
msg1 = pskmod(msg1,M);                            %4QPSK����
Eb1 = norm(msg1).^2/(N*(n-m));                    %�����������
msg2 = encode(msg,n,n-m,'hamming/binary');        %Himming����
msg2 = reshape(msg2',log2(M),N*n/log2(M))';       %���ܱ��������
msg2 = bi2de(msg2,'left-msb');                    %��������ת��λʮ������ʽ
msg2 = graycode(msg2+1);                          %���ױ���
msg2 = pskmod(msg2,M);                            %Himming�������ݽ���4PSK����
Eb2 = norm(msg2).^2/(N*(n-m));                    %�����������
EbNo = 0:10;                                      %�����
EbNo_lin = 10.^(EbNo/10);                         %ת��Ϊ����ֵ
for index = 1:length(EbNo)
    sigma1 = sqrt(Eb1/(2*EbNo_lin(index)));       %δ�����������׼��
    %�����˹������
    rx1 = msg1 + sigma1*(randn(1,length(msg1))+1i*randn(1,length(msg1)));    
    y1 = pskdemod(rx1,M);                         %δ����4PSK���
    y1_de = graycode(y1+1);                       %δ����ĸ�����ӳ��
    [err ber1(index)] = biterr(msg1_de',y1_de,log2(M));   %δ������������
    
    sigma2 = sqrt(Eb2/(2*EbNo_lin(index)));       %�����������׼��
    %�����˹������
    rx2 = msg2 + sigma2*(randn(1,length(msg2))+1i*randn(1,length(msg2)));    
    y2 = pskdemod(rx2,M);                         %����4PSK���
    y2_de = graycode(y2+1);                       %����ĸ�����ӳ��
    y2_de = de2bi(y2_de,'left-msb');              %ת��Ϊ��������ʽ
    y2_de = reshape(y2_de',n,N)';                 %���ܾ���
    y2_de = decode(y2_de,n,n-m,'hamming/binary'); %����
    [err ber2(index)] = biterr(msg,y2_de);        %������������
end
figure();
% plot(EbNo,ber2,'-*');
semilogy(EbNo,ber1,'-bo',EbNo,ber2,'-r*');
legend('δ����','Hamming(7,4)�����4PSK��AWGN�µ�����');
xlabel('EbNo/dB');
ylabel('�������');
