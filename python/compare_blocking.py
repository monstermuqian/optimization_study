'''
28.01.2021 by Muqian Chen
I would like to use this package to include two functions

1. calculation_alpha accepts the current parameter in the working set
to calculate alpha parameter used to multiply with step length for
reaching a gradient descent.


'''



import numpy as np

def calculation_alpha(A_inequation, A_working, b_inequation, b_working, step_length, theta):
    # firstly thinking about situation with only unequaled constraints
    [row, col] = np.shape(b_working)
    exist_index = np.zeros(0, dtype=float)
    for i in range(row):
        b_temp = b_working[i, :]
        A_temp = A_working[i, :]

        # find the index of the same parameters inside
        # unequaled constraints
        b_index = np.where(b_inequation == b_temp)
        A_index = np.where(A_inequation == A_temp)

        # determine the right index from the result
        for j in range(len(b_index)):
            if_exist = np.array([A_index == b_index[i]])
            if if_exist.any():
                exist_index = np.hstack((exist_index, b_index[i]))
        # save the right index in np.array exist_index

    # delete all in the working set existed constraints from all unequaled constraints
    # so that the rest parameters are all not in working set.
    A_inequation = np.delete(A_inequation, exist_index, axis=0)
    b_inequation = np.delete(b_inequation, exist_index, axis=0)

    # pick out the parameters that satisfy inequation a_i' * p < 0
    b_result = np.zeros((0, 1), dtype=float)
    A_result = np.zeros((0, 2), dtype=float)

    index_list = []
    # please be careful, I would like to make b_result as a column vector
    for i in range(len(b_inequation)):
        if np.dot(A_inequation[i, :], step_length) < 0:
            b_result = np.vstack((b_result, b_inequation[i, :]))
            A_result = np.vstack((A_result, A_inequation[i, :]))
            index_list.append(i)

    # if there are not any satisfied constraints parameter inside b_result
    # It could just be said that the alpha parameter is one.
    # else, just save the b_i - a_i'*theta / a_i' * p results in the list
    # calc_result and then get the minimal value
    calc_result = []
    length = len(b_result)
    print(np.shape(b_result))
    if length == 0:
        alpha = 1
        b_blocked = np.zeros((0, 1), dtype=float)
        A_blocked = np.zeros((0, 2), dtype=float)
        return alpha, b_blocked, A_blocked
    else:
        for i in range(len(b_result)):
            temp = (b_result[i, 0] - np.dot(A_result[i, :], theta)) / np.dot(A_result[i, :], step_length)
            calc_result.append(temp)
        min_calc = min(calc_result)
        min_index = calc_result.index(min_calc)
        if min_calc < 1:
            alpha = min_calc
            b_blocked = b_result[min_index, 0]
            A_blocked = A_result[min_index, :]
            # return the b_i and a_i' of blocking constraint
            return alpha, b_blocked, A_blocked
        else:
            alpha = 1
            b_blocked = np.zeros((0, 1), dtype=float)
            A_blocked = np.zeros((0, 2), dtype=float)
            return alpha,  b_blocked, A_blocked


