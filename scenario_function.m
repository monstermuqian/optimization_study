function [J] = scenario_function(G, d)
%SCENARIO_FUNCTION �˴���ʾ�йش˺�����ժҪ
%   G Ϊһ�� n X n �ľ���
%   d Ϊһ�� n X 1 ��������
%   ����ı���thetaӦ��Ϊһ�� n X 1 ��������
J = @(theta) (1/2 * theta' * G * theta + theta' * d);
end

