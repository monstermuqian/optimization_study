function [result, ai, bi] = compare_blocking(theta, p, A_inequation, working_inequation_A, b_inequation, working_inequation_b)
%COMPARE_BLOCKING �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
%   �������뷨�ǣ����ﷵ�ص��� (bi - ai' * theta)/(ai' * p) �����з���
%   ai' * p < 0 �Ľ��������������ʽ
%   �������������1.
%   �����뷨�ǣ���A_inequation��������Ȼ����ÿ����working set�е�{2,1}�Ƚ�
%   ��һ���ľ��޳���ȥ��ʣ�µľ���������Ҫ�Ĳ���working set�е�constraints
%   �������������2.
%   �ͣ��򵥵ضԱ�һ��A_temp��ʣ�µ����� p �ĳ˻����������г˻�С�����

%   A_inequation �����в���ʽconstraint��ϵ������
%   working_inequation ��������working set�еĲ���ʽconstraints��ϵ������

% ���������в���ʽconstraints��ϵ���ľ���A���浽 A_temp �������Ĳ���
A_temp = A_inequation;
b_temp = b_inequation;
size_A = size(A_temp);

% ���ｫ��Щ��������working set�еĲ���ʽconstraints��ϵ������浽temp��
% ����������
size_working = size(working_inequation_A);
working_A = working_inequation_A;
working_b = working_inequation_b;


% ���for֮��A_temp�н�ʣ�²��ڵ�ǰworking set�еĲ���ʽconstraints��ϵ��
% ����ɵľ���
delete_position = zeros(size(working_b))';
for i = 1:size_working(1,1)
    for j = 1:size_A(1,1)
        
        % ֻҪɨ�赽working set��ĳһ������ǰ��A�е�����ͬ���У���ɾ������
        % ��ͬʱҲ�� A �н�����ɾ��
        % �漴�Ϳ��Բ��ù�working set�еı��Ԫ����
        if A_temp(j, :) == working_A(i, :)
            delete_position(1 ,i) = j ;
            break;
        end
    end
end
% ��ȫ������ʽconstraints�У�ɾ����Щworking set���еĲ���ʽconstraints
if delete_position ~= zeros(size(working_b))'
    A_temp(delete_position, :) = [];
    b_temp(delete_position, :) = [];
end



% �������for֮��A_temp, b_temp�е�Ӧ���ǣ�����working set���� ai' * p С����
% ��constraints������֮��Ķ�������
size_row = size(A_temp(1,:));
for i = 1:size(A_temp)
    result = A_temp(i,:) * p ;
    if result > 0
        A_temp(i, :) = zeros(size_row);
        b_temp(i, 1) = 0 ;
    end
end

% �����е�����ɾ������ʣ�����ǵ�Ŀ�겻��ʽconstraints��
A_temp(~any(A_temp, 2), :) = [];
b_temp(~any(b_temp, 2), :) = [];


result_temp = zeros(size(b_temp));

% ��������е����� ( bi - ai' * theta ) / (ai' * p)
for i = 1:size(b_temp)
    result_temp(i, 1) = (b_temp(i, 1) - A_temp(i, :) * theta)/(A_temp(i, :) * p);
end

%result = 0;
result = min(result_temp);
aim = find(result == min(result_temp));
ai = A_temp(aim, :);
bi = b_temp(aim, 1);

end




















