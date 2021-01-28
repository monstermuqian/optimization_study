# A has a dimension of (m,n) m row, n column.
# Each row contain parameters of constraints. There are totally m constraints.
# b has a dimension of (m,1) m row, 1 column
# G has a dimension of (n,n) n row, n column
# d has a dimension of (n,1) n row, 1 column
# theta has a dimension of (n,1) n row, 1 column

import numpy as np

def EQP_Solution (A, b, G, d, theta):
    g = np.dot(G, theta) + d
    print("current g is :{}".format(g))
    h = np.dot(A, theta) - b
    print("current h is :{}".format(h))

    # concatenate the matrix into a KKT-Matrix and [g;h] vector
    [row, col] = np.shape(A)
    K_temp1 = np.concatenate((G, np.transpose(A)), axis=1)
    zeros_matrix = np.zeros([row, row])
    K_temp2 = np.concatenate((A, zeros_matrix), axis=1)

    K = np.concatenate((K_temp1, K_temp2), axis=0)
    print("current K is : {}".format(K))
    g_h = np.concatenate((g, h), axis=0)

    # calculation the step length and lambda number
    K_inv = np.linalg.inv(K)
    result = np.dot(K_inv, g_h)

    # from result separate the step length and lambda value
    step_length = -result[0:col, 0].reshape(col, 1)
    lambda_star = result[col:, 0].reshape(row, 1)

    return step_length, lambda_star