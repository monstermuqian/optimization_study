# Author : Muqian Chen
# Data   : 18.05.2020
# Purpose: Realisation of algorithms for sequential quadratic programming for python version
# I hope i can success.

# 27.01.2021
# After cross testing with MATLAB is proved that the algorithm EQP can work fine.


import numpy as np
from EQP_Solution import EQP_Solution as eqp
import compare_blocking as com_bl


def main():

    G = np.array([[2, 0],
                  [0, 2]])
    # 在python中定义 2 x 1 向量也是要打上方括号的
    d = np.array([[-2],
                  [-5]])
    theta = np.array([[0],
                        [1]])
    #print(np.shape(d))

    A_equation = np.array([[], []])
    b_equation = np.array([[], []])
    A_inequation = np.array([[ 1, -2],
                             [-1, -2],
                             [-1, 2],
                             [ 1, 0],
                             [ 0, 1]])
    b_inequation = np.array([[-2],
                             [-6],
                             [-2],
                             [ 0],
                             [ 0]])

    A = np.vstack((A_inequation[3, :], A_inequation[0, :]))
    b = np.vstack((b_inequation[3, :], b_inequation[0, :]))


    #[step_length, lambda_star] = eqp(A, b, G, d, theta)
    #print(step_length)
    #print(lambda_star)

    #inequation = {1: b_inequation[0, :].reshape(1, 1)}

    b_working = np.empty((1, 1))
    print(b_working)
    b_working = np.vstack((b, b_working))
    print(b_working)
    b_working = np.delete(b_working, 1, axis=0)
    print(b_working)

    dict = {}
    list = []



    while True:
        [step_length, lambda_star] = eqp(A, b, G, d, theta)

        if step_length.all() == 0:
            if lambda_star.all() > 0:
                return 0
            else:
                return 0
        else:
            return 0




if __name__ == '__main__':
    main()

