function p=POWER(x) 
%x：输入信号 
%p：返回信号的x功率 
p=(norm(x).^2)./length(x);
end