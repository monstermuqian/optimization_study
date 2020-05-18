function [p, lambda] = EQP_Solution(G,A,d,b,theta)
%EQP_SOLUTION �˴���ʾ�йش˺�����ժҪ
%  ������������ÿ��iterate��ͷ��EQP���������֣���ʵÿ��EQP�в�һ���Ķ���
%  ֻ��A��b�е������Ȼ��ֱ����KKT����Ҳ����һ����λ�õ���Ӧ�Ľ⣬Ҳ����
%  �����˵�ǰ��lambdaֵ����Ӧ�Ĳ���
%  G Ϊ n X n ��objective function�еĶ������ϵ��
%  A Ϊ b X n �ĵ�ǰ��active set�е�constraints�ǵ�theta�ϵĲ���
%  d Ϊԭobjective function�е��������˵ĳ����n X 1 ��������
%  b Ϊconstraint�еĳ�����ɵ����������ڵ�ʽ���ұ�
size_A =size(A);

% construction of components of KKT-matrix
g = d + G * theta;
h = A * theta - b ;
K = [G  A';A zeros(size_A(1, 1), size_A(1, 1))];

result = pinv(K)* [ g ; h ];

p = -result(1:size_A(1,2), 1);
lambda = result( size_A(1, 2) + 1 : end, 1);

end

