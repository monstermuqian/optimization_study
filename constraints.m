function [constraints_equation] = constraints(E,b_e)
%CONSTRAINTS 此处显示有关此函数的摘要
%   A 为 一个 m X n 的矩阵，其中m为行数，n为列数，其中包含了所有在active set
%   中的参数的系数
%   b 为一个 m  X 1 的列向量，其中m为行数，其中包含了所有在active set中的
%   的constraints的在标准形态下的常数项
%   输出constraints为一个 m X 1 的cell，共包含了m个右边为零的constraint


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

