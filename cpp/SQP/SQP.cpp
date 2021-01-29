

#include <iostream>
#include <Eigen>

using namespace std;
using namespace Eigen;


	VectorXf eqpCalculation(MatrixXf A, VectorXf b, MatrixXf G, VectorXf d, VectorXf theta) {
		VectorXf g, h;
		g = d + G * theta;
		h = A * theta - b;
		Index g_row = g.rows();
		Index h_row = h.rows();

		//catenate the A and G as KKT Matrix
		Index A_row = A.rows();
		Index A_col = A.cols();
		Index G_row = G.rows();

		//first catenate them in horizont direction
		MatrixXf K1(G_row, A_row + G_row);
		K1 << G, A.transpose();
		MatrixXf zeros = MatrixXf::Zero(A_row, A_row);
		MatrixXf K2(A_col, A_col + A_row);
		K2 << A, zeros;
		MatrixXf K(A_col + G_row, A_row + G_row);
		K << K1, K2;

		//then catenate [g;h] 
		VectorXf g_h(g_row + h_row, 1);
		g_h << g, h;

		//calculate KKT-Equation 
		VectorXf result(G_row + A_col, 1);
		result = K.inverse() * g_h;

		return result;
	};



int main(int argc, char** argv)
{
	//define G and d and inequation constraints
	typedef Matrix<float, 2, 2> Matrix2f;
	Matrix2f G;
	G << 2, 0, 
		 0, 2;
	typedef Matrix<float, 2, 1> Vector2f;
	Vector2f d;
	d << -2, 
		 -5;

	typedef Matrix<float, Dynamic, 2> MatrixX2f;
	MatrixX2f A(5, 2);
	A << 1, -2, 
		-1, -2, 
		-1,  2, 
		 1,  0,
		 0,  1;
	Map <Matrix<float, 2,5, RowMajor>> M1(A.data());

	typedef Matrix<float, Eigen::Dynamic, 1> VectorXf;
	VectorXf b(5, 1);
	b << -2, 
		 -6, 
		 -2, 
		  0, 
		  0;

	VectorXf b_working(2, 1);
	MatrixXf A_working(2, 2);
	b_working << b(0, 0), b(3, 0);
	A_working << A.row(0), A.row(3);

	cout << b_working << endl << A_working << endl;


	//define initialized theta
	Vector2f theta;
	theta(0) = 0;
	theta(1) = 1;


	VectorXf result;
	result = eqpCalculation(A_working, b_working, G, d, theta);
	cout << result << endl;

}
