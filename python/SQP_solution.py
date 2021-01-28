# Author : Muqian Chen
# Data   : 18.05.2020
# Purpose: Realisation of algorithms for sequential quadratic programming for python version
# I hope i can success.

# 27.01.2021
# After cross testing with MATLAB is proved that the algorithm EQP can work fine.

# 28.01.2021
# Basic functions are totally implemented. The rest work is improvement of the program
# to adapt with equation constraints.


import numpy as np
from EQP_Solution import EQP_Solution as eqp
from compare_blocking import calculation_alpha
import os


def main():

    G = np.array([[2.0, 0.0],
                  [0.0,  2.0]])
    d = np.array([[-2.0],
                  [-5.0]])
    theta = np.array([[0.0],
                      [1.0]])

    A_equation = np.zeros(shape= (0,2))
    b_equation = np.zeros(shape= (0,1))
    A_inequation = np.array([[ 1.0, -2.0],
                             [-1.0, -2.0],
                             [-1.0,  2.0],
                              [1.0,  0.0],
                              [0.0,  1.0]])
    b_inequation = np.array([[-2.0],
                             [-6.0],
                             [-2.0],
                             [ 0.0],
                             [ 0.0]])

    A = np.vstack((A_inequation[0, :], A_inequation[3, :]))
    b = np.vstack((b_inequation[0, :], b_inequation[3, :]))

    A_working = np.vstack((A_equation, A))
    b_working = np.vstack((b_equation, b))



    while True:
        [step_length, lambda_star] = eqp(A_working, b_working, G, d, theta)

        judge_step_length = np.array([step_length < 10e-13])
        if judge_step_length.all():
            # to determine whether all lambdas are all biggest than zeros
            judge_lambda = np.array([lambda_star > 0])
            if judge_lambda.all():
                break
                #pass
            else:
                lambda_min_index = np.argmin(lambda_star)
                #print(lambda_min_index)
                b_working = np.delete(b_working, lambda_min_index, axis=0)
                A_working = np.delete(A_working, lambda_min_index, axis=0)
                print("[INFO] delete the constraint represented by the most negative one ")
        else:
            [alpha, b_blocked, A_blocked] = calculation_alpha(A_inequation, A_working,
                                                              b_inequation, b_working,
                                                              step_length, theta)
            # If alpha is unequal to one, it could just be illustrated as that some
            # constraint is blocking the heading direction. So use the returned b
            # and A to update the working set.
            if alpha != 1:
                A_working = np.vstack((A_working, A_blocked))
                b_working = np.vstack((b_working, b_blocked))
                print("[INFO] update the working set with blocking constraint")

            # At the end of the loop, execute gradient descent
            theta = theta + alpha * step_length

    print("The optimal parameter is :{}".format(theta))






if __name__ == '__main__':
    main()


    # use np.empty to prepare an empty array to save
    # but first of all is that you should make it clear
    # in which dimension you want to expand the array.
    # look at this example, actually i want to expand
    # the array in row but not in column. So I initialize
    # the empty array with 0 row. And because the array
    # that I want to add in has a dimension of (n, 1), the
    # dimension of the empty array should be also (n, 1).
    # test = np.empty((0, 1))
    # print(test)
    # test = np.vstack((test, b))
    # print(test)

    #test = np.array([[1]])
    #print(np.shape(test))
    #for i in range(1):
    #    print(i)

    #b_test = np.array([[0]])
    #A_test = np.array([[0, 1]])
    #b_index = np.where(b_inequation == b_test)
    #A_index = np.where(A_inequation == A_test)

    #test = np.zeros(0, dtype=int)
    #print(test)
    #test = np.hstack((test, b_index[0]))
    #print(test)
    #print(type(test))
    #print(b_inequation[b_index[0], :])
    #print(b_inequation[test, :])


    #print(b_index[0])
    #print(A_index[0])

    #exist_index = np.array([A_index[0] == b_index[0][1]])
    #print(exist_index)

    #if exist_index.any():
    #    print("yes")
    #else:
    #    print("no")

    # test = np.delete(A_inequation, np.array([1, 2]), axis=0)
    # print(test)

    #print(index)
    #print(index[0])
    #print(type(index[0]))
    #print(b_inequation[index])#.reshape(-1, 2))
    #b_test = np.delete(b_inequation, index[0], axis=0)
    #print(b_test)



    #b_working = np.delete(b_working, 1, axis=0)
    #print(b_working)
    # use this method to detect the minimal value index
    # and follow this format to locate the values with
    # the same index of another matrix
    # b_working_ineq = b
    # A_working_ineq = A
    # min_index = np.argmin(b_working)
    # print(min_index)
    # print(b_working[min_index, :])
    # print(A[min_index, :])

    # use this method to delete specified row with
    # given index of np.array
    # axis=0 means that the program uses the index
    # as row index to delete the whole row.
    # print(A)
    # print(b)
    # min_index = np.argmin(b)
    # A_test = np.delete(A, min_index, axis=0)
    # b_test = np.delete(b, min_index, axis=0)
    # print(A_test)
    # print(b_test)


