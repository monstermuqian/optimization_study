% Author: Muqian Chen
% Data  : 12.05.2020
% Purple: Implementation of Algorithmn for Sequential Quadratic Programming
% 
% i hope i can success

%%
% 
% 开始运行算法前的准备工作
% 

% construction of test scenario
% 生成的所谓原object function，它以function handle的形式直接接受一个列向量
% 也就是 n X 1 的theta

G = [ 4 -3 ; -3 4];
d = [ 0 ; 0 ];

% 把theta以列向量的形式怼进去就好J(theta)
J = scenario_function(G, d);

% construction of constraints including equation and inequation
% 虽然也曾想过有什么办法可以将两个function handle直接合成一个新的function
% handle，但是仔细一想，我好像不需要这么做，因为我只是需要将其运算结果合在
% 好像还是要这么做，因为要整个一起求导，目前姑且查到一种方法是先用symbol怼
% 进function handle里头，得到的结果储存为symbol，然后用matlabFunction(jacobian())
% 生成可以往里怼真实数字的function handle。
% 但是谁知道呢，说不定到时候可以分开求导再合成，再说吧 12.05.2020
% 啰嗦一句，在生成symbols往handle里怼的时候，

% 这里储存的都是以下面形式呈现的constraints
% A * theta = || >= b ;

A_equation = [1 1];
b_equation = 2;
A_inequation = [-1 0];
b_inequation = 1;

constr_equation = constraints(A_equation, b_equation);
constr_inequation = constraints(A_inequation, b_inequation);

% 设置起始点
theta_0 = [-2;4];

% 确定acitve set中的constraints 
% 只有确定了active set中的内容物才能知道以什么数据结构将矩阵们传入EQP中 12.05.2020
% 想了一下，其实用矩阵传进去EQP中是最好的，因为每一次迭代中要做的事情也只是
% 判断哪些条件要被扔掉哪些留着而已  13.05.2020

% 初步想法是用一个二维的细胞去储存working set，第一维存theta们的系数，第二
% 维存constraints中的常数，先暂时这么做做看看 13.05.2020

working_set = cell(4,1);

% put the constraints in the working set represented by the initial point
% 这几行代码顺利将equation constraints中的参数都添加进working set中了，不管
% A和b的维度是多少都可以 13.05.2020

% 这里储存所有等式constraints
for i = 1:size(A_equation) % 不用担心，这里直接使用size（A）只会用到它的行数
    working_set{1,1} = [working_set{1,1} ; A_equation(i, :)];
    working_set{2,1} = [working_set{2,1} ; b_equation(i, 1)];
end

% 这里储存以initial theta进入working set的不等式constraints
for i = 1:size(A_inequation)
    result_temp = A_inequation(i, :) * theta_0 - b_inequation(i);
    if result_temp == 0
        working_set{3,1} = [working_set{3,1} ; A_inequation(i, :)];
        working_set{4,1} = [working_set{4,1} ; b_inequation(i, 1)];
    end
end

% 接下来就是不断去判断每一次循环中inequation的满足情况了，把重新组合好，并
% 储存在 working set 中的矩阵A和向量b怼进EQP_Solution里头得到解就行 13.05.2020



%%
% 
% 执行算法
% 
theta = theta_0;
position_min_lambda = 0;
alpha = 0;
while 1
    
    working_coefficient = [working_set{1,1}; working_set{3,1}];
    working_constant = [working_set{2,1}; working_set{4,1}];
    
    
    [p, lambda] = EQP_Solution(G, working_coefficient, d, working_constant,theta);
    if p == zeros(size(theta))
        
        if lambda >= zeros(size(lambda))
            break
        else
            
            % 找到最负lambda的位置，按理来说，它在lambda向量中位置减去equation
            % 的 A 和 b 的行数，就可以得到这个lambda代表的inequation然后将其删除
            % 在working_set{2,1}{4,1}中的位置，找到就将它删除
            
            position_min_lambda = find(lambda == min(lambda));
            size_A_equation = size(working_set{1,1});
            size_b_equation = size(working_set{2,1});
            working_set{2,1}(postion_min_lambda - size_A_equation(1,1)) = [];
            working_set{4,1}(postion_min_lambda - size_b_equation(1,1)) = [];
        end
        
    else
        % 在这一步要解决的问题是，该怎么去区分出：
        % 1. 在working set和不在其中的不等式constraint
        % 2. a' * p < 0 的跟对此不成立的不等式constraint
        % 已经全部解决，在comapre函数中，返回的结果是：
        % result：
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


% 编写至此，其实代码都按照我所想的那样来行动了，只要设置断点去一步步走就知
% 但是不知道为什么它一直碰不到不等式constraints的边界，明天再好好debug一下
% 16.05.2020













