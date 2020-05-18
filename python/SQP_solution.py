# Author : Muqian Chen
# Data   : 18.05.2020
# Purpose: Realisation of algorithms for sequential quadratic programming for python version
# I hope i can success.


import numpy as np
import EQP_Solution as eqp
import compare_blocking as com_bl


G = np.array([[2, 0], [0, 2]])
# 在python中定义 2 x 1 向量也是要打上方括号的
d = np.array([[-2], [-5]])

#print(np.shape(d))

A_equation = np.empty((2,2))
b_equation = np.array([[], []])
A_inequation = np.array([[1, -2], [-1, -2], [-1, 2], [1, 0], [0, 1]])
b_inequation = np.array([[-2], [-6], [-2], [0], [0]])


print(np.shape(A_equation))