function [p, lambda] = EQP_Solution(G,A,d,b,theta)
%EQP_SOLUTION 此处显示有关此函数的摘要
%  这个函数负责解每个iterate里头的EQP，分析发现，其实每个EQP中不一样的东西
%  只有A与b中的内容物，然后直接用KKT矩阵也可以一步到位得到相应的解，也就是
%  返回了当前的lambda值和相应的步长
%  G 为 n X n 的objective function中的二次项的系数
%  A 为 b X n 的当前在active set中的constraints们的theta上的参数
%  d 为原objective function中的与参数相乘的常数项，n X 1 的列向量
%  b 为constraint中的常数组成的列向量，在等式的右边
size_A =size(A);

% construction of components of KKT-matrix
g = d + G * theta;
h = A * theta - b ;
K = [G  A';A zeros(size_A(1, 1), size_A(1, 1))];

result = pinv(K)* [ g ; h ];

p = result(1:size_A(1,2), 1);
lambda = result( size_A(1, 2) + 1 : end, 1);

end

