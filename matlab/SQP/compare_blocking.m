function [result, ai, bi] = compare_blocking(theta, p, A_inequation, working_inequation_A, b_inequation, working_inequation_b)
%COMPARE_BLOCKING 此处显示有关此函数的摘要
%   此处显示详细说明
%   初步的想法是，这里返回的是 (bi - ai' * theta)/(ai' * p) 的所有符合
%   ai' * p < 0 的结果，以向量的形式
%   现在来解决问题1.
%   初步想法是，把A_inequation传进来，然后其每行与working set中的{2,1}比较
%   有一样的就剔除出去，剩下的就是我所需要的不在working set中的constraints
%   现在来解决问题2.
%   就，简单地对比一下A_temp中剩下的行与 p 的乘积，挑出其中乘积小于零的

%   A_inequation 是所有不等式constraint的系数矩阵
%   working_inequation 是所有在working set中的不等式constraints的系数矩阵

% 将包含所有不等式constraints的系数的矩阵A换存到 A_temp 方便后面的操作
A_temp = A_inequation;
b_temp = b_inequation;
size_A = size(A_temp);

% 这里将那些包含着在working set中的不等式constraints的系数矩阵存到temp中
% 方便后面操作
size_working = size(working_inequation_A);
working_A = working_inequation_A;
working_b = working_inequation_b;


% 这个for之后，A_temp中将剩下不在当前working set中的不等式constraints的系数
% 所组成的矩阵
delete_position = zeros(size(working_b))';
for i = 1:size_working(1,1)
    for j = 1:size_A(1,1)
        
        % 只要扫描到working set中某一个跟当前的A中的行相同的行，就删除该行
        % 并同时也在 A 中将这行删除
        % 随即就可以不用管working set中的别的元素了
        if A_temp(j, :) == working_A(i, :)
            delete_position(1 ,i) = j ;
            break;
        end
    end
end
% 从全部不等式constraints中，删除这些working set中有的不等式constraints
if delete_position ~= zeros(size(working_b))'
    A_temp(delete_position, :) = [];
    b_temp(delete_position, :) = [];
end



% 经过这个for之后，A_temp, b_temp中的应该是，不在working set中且 ai' * p 小于零
% 的constraints，除此之外的都是零行
size_row = size(A_temp(1,:));
for i = 1:size(A_temp)
    result = A_temp(i,:) * p ;
    if result > 0
        A_temp(i, :) = zeros(size_row);
        b_temp(i, 1) = 0 ;
    end
end

% 将其中的零行删除，就剩下我们的目标不等式constraints了
A_temp(~any(A_temp, 2), :) = [];
b_temp(~any(b_temp, 2), :) = [];


result_temp = zeros(size(b_temp));

% 计算出其中的所有 ( bi - ai' * theta ) / (ai' * p)
for i = 1:size(b_temp)
    result_temp(i, 1) = (b_temp(i, 1) - A_temp(i, :) * theta)/(A_temp(i, :) * p);
end

%result = 0;
result = min(result_temp);
aim = find(result == min(result_temp));
ai = A_temp(aim, :);
bi = b_temp(aim, 1);

end




















