function [constraints_equation] = constraints(E,b_e)
%CONSTRAINTS �˴���ʾ�йش˺�����ժҪ
%   A Ϊ һ�� m X n �ľ�������mΪ������nΪ���������а�����������active set
%   �еĲ�����ϵ��
%   b Ϊһ�� m  X 1 ��������������mΪ���������а�����������active set�е�
%   ��constraints���ڱ�׼��̬�µĳ�����
%   ���constraintsΪһ�� m X 1 ��cell����������m���ұ�Ϊ���constraint


size_E = size(E);
size_b = size(b_e);
if size_E(1) ~= size_b(1)
    error("the rows number of A must be equal to columns number of b !")
end
    
constraints_equation = cell(size_E(1),1);
for i = 1:size_E(1,1)
    c = @(theta) E(i, :)*theta - b_e(i);
    constraints_equation{i,1} = c ;
end
end

