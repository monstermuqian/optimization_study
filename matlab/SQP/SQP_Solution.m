% Author: Muqian Chen
% Data  : 12.05.2020
% Purple: Implementation of Algorithmn for Sequential Quadratic Programming
% 
% i hope i can success

%%
% 
% ��ʼ�����㷨ǰ��׼������
% 
clear;
clc;


% construction of test scenario
% ���ɵ���νԭobject function������function handle����ʽֱ�ӽ���һ��������
% Ҳ���� n X 1 ��theta

% Scenario one
%G = [ 4 -3 ; -3 4];
%d = [ 0 ; 0 ];

% Scenario two
G = [2 0; 0 2];
d = [-2 ; -5];

% ��theta������������ʽ��ȥ�ͺ�J(theta)
J = scenario_function(G, d);

% construction of constraints including equation and inequation
% ��ȻҲ�������ʲô�취���Խ�����function handleֱ�Ӻϳ�һ���µ�function
% handle��������ϸһ�룬�Һ�����Ҫ��ô������Ϊ��ֻ����Ҫ��������������
% ������Ҫ��ô������ΪҪ����һ���󵼣�Ŀǰ���Ҳ鵽һ�ַ���������symbol�
% ��function handle��ͷ���õ��Ľ������Ϊsymbol��Ȼ����matlabFunction(jacobian())
% ���ɿ����������ʵ���ֵ�function handle��
% ����˭֪���أ�˵������ʱ����Էֿ����ٺϳɣ���˵�� 12.05.2020
% ����һ�䣬������symbols��handle����ʱ��

% ���ﴢ��Ķ�����������ʽ���ֵ�constraints
% A * theta = || >= b ;

% Scenario one
%A_equation = [1 1];
%b_equation = [1 1];
%A_inequation = [-1 0];
%b_inequation = 1;

% Scenario two
A_equation = [];
b_equation = [];
A_inequation = [1 -2 ; -1 -2 ; -1 2 ; 1 0; 0 1];
b_inequation = [-2 ; -6; -2; 0; 0];

%������ʽ�ľ������ӱ������ǲ���Ҫ��
%constr_equation = constraints(A_equation, b_equation);
%constr_inequation = constraints(A_inequation, b_inequation);

% ������ʼ��
theta_0 = [0;2];

% ȷ��acitve set�е�constraints 
% ֻ��ȷ����active set�е����������֪����ʲô���ݽṹ�������Ǵ���EQP�� 12.05.2020
% ����һ�£���ʵ�þ��󴫽�ȥEQP������õģ���Ϊÿһ�ε�����Ҫ��������Ҳֻ��
% �ж���Щ����Ҫ���ӵ���Щ���Ŷ���  13.05.2020

% �����뷨����һ����ά��ϸ��ȥ����working set����һά��theta�ǵ�ϵ�����ڶ�
% ά��constraints�еĳ���������ʱ��ô�������� 13.05.2020

working_set = cell(4,1);

% put the constraints in the working set represented by the initial point
% �⼸�д���˳����equation constraints�еĲ�������ӽ�working set���ˣ�����
% A��b��ά���Ƕ��ٶ����� 13.05.2020

% ���ﴢ�����е�ʽconstraints
for i = 1:size(A_equation) % ���õ��ģ�����ֱ��ʹ��size��A��ֻ���õ���������
    working_set{1,1} = [working_set{1,1} ; A_equation(i, :)];
    working_set{2,1} = [working_set{2,1} ; b_equation(i, 1)];
end

% ���ﴢ����initial theta����working set�Ĳ���ʽconstraints
for i = 1:size(A_inequation)
    result_temp = A_inequation(i, :) * theta_0 - b_inequation(i);
    if result_temp == 0
        working_set{3,1} = [working_set{3,1} ; A_inequation(i, :)];
        working_set{4,1} = [working_set{4,1} ; b_inequation(i, 1)];
    end
end

% ���������ǲ���ȥ�ж�ÿһ��ѭ����inequation����������ˣ���������Ϻã���
% ������ working set �еľ���A������b��EQP_Solution��ͷ�õ������ 13.05.2020



%%
% 
% ִ���㷨
% 
theta = theta_0;
position_min_lambda = 0;
alpha = 0;
while 1
    
    working_coefficient = [working_set{1,1}; working_set{3,1}];
    working_constant = [working_set{2,1}; working_set{4,1}];
    
    
    [p, lambda] = EQP_Solution(G, working_coefficient, d, working_constant,theta);
    if p <= 1.0e-16 * ones(size(theta_0))
        
        if lambda >= zeros(size(lambda))
            break
        else
            
            % �ҵ��lambda��λ�ã�������˵������lambda������λ�ü�ȥequation
            % �� A �� b ���������Ϳ��Եõ����lambda�����inequationȻ����ɾ��
            % ��working_set{3,1}��������A_inequation
            % {4,1},������b_inequation �е�λ�ã��ҵ��ͽ���ɾ��
            
            position_min_lambda = find(lambda == min(lambda));
            size_A_equation = size(working_set{1,1});
            size_b_equation = size(working_set{2,1});
            working_set{3,1}(position_min_lambda - size_A_equation(1,1), :) = [];
            working_set{4,1}(position_min_lambda - size_b_equation(1,1), :) = [];
        end
        
    else
        % ����һ��Ҫ����������ǣ�����ôȥ���ֳ���
        % 1. ��working set�Ͳ������еĲ���ʽconstraint
        % 2. a' * p < 0 �ĸ��Դ˲������Ĳ���ʽconstraint
        % �Ѿ�ȫ���������comapre�����У����صĽ���ǣ�
        % result��
        [ result, the_aim_ai, the_aim_bi ] = compare_blocking(theta, p, A_inequation,.....
                        working_set{1,1}, b_inequation, working_set{3,1});
        if result < 1
            alpha = result;
        else
            alpha = 1;
        end
        theta = theta + alpha * p;
        if alpha ~= 1
            working_set{3,1} = [working_set{3,1} ; the_aim_ai];
            working_set{4,1} = [working_set{4,1} ; the_aim_bi];
        end
    end
    disp('This is one loop')
end



disp('The constrainted minimum of J is')
disp(theta)
% ��д���ˣ���ʵ���붼������������������ж��ˣ�ֻҪ���öϵ�ȥһ�����߾�֪
% ���ǲ�֪��Ϊʲô��һֱ����������ʽconstraints�ı߽磬�����ٺú�debugһ��
% 16.05.2020

% bug�Ѿ����޲�����ʵ������ʹ��KKT�����ʱ��Ҫע������������Ľ������
% p��ʱҪ�Ӹ��ţ���������task����֤�������Ѿ���׼ȷ�ؼ����constrainted min
% ֮��Ĺ�����������һЩ����raise����� 18.05.2020















