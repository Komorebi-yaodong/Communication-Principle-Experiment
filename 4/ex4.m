clear;
close all;
clc;
EbNo = 1:0.5:10;             %����ȷ�Χ
N = 1000000;              %��Ϣ���ظ���
M = 2;                   %BPSK����
L = 7;                   %Լ������
trel = poly2trellis(L,[171,133]);         %��������ɶ���ʽ
tblen = 6*L;                              %Viterbi�������������
msg = randi([0,1],1,N);                   %��Ϣ��������
msg1 = convenc(msg,trel);                 %�������
x1 = pskmod(msg1,M);                      %BPSK����
for i = 1:length(EbNo)
    %�����˹����������Ϊ����Ϊ1/2������ÿһ�����ŵ�����Ҫ�ȱ���������3dB
    y = awgn(x1,EbNo(i)-3);
    y1 = pskdemod(y,M);                                   %Ӳ�о�
    y2 = vitdec(y1,trel,tblen,'cont','hard');             %Viterbi����
    [err ber1(i)] = biterr(y2(tblen+1:end),msg(1:end-tblen)); %�����������
    
    y3 = vitdec(real(y),trel,tblen,'cont','unquant');     %���о�
    [err ber2(i)] = biterr(y3(tblen+1:end),msg(1:end-tblen)); %�����������
end
ber = berawgn(EbNo,'psk',2,'nodiff');                  %BPSK���������������
figure();
% plot(EbNo,ber1,'-b',EbNo,ber2,'-r');grid on;
% legend('Ӳ�о����������','���о����������');
semilogy(EbNo,ber,'-bd',EbNo,ber1,'-go',EbNo,ber2,'-r*');
legend('BPSK�����������','Ӳ�о����������','���о����������');
xlabel('EbNo');
ylabel('�������');
