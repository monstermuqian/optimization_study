function [J] = scenario_function(G, d)
%SCENARIO_FUNCTION 此处显示有关此函数的摘要
%   G 为一个 n X n 的矩阵
%   d 为一个 n X 1 的列向量
%   输入的变量theta应该为一个 n X 1 的列向量
J = @(theta) (1/2 * theta' * G * theta + theta' * d);
end

