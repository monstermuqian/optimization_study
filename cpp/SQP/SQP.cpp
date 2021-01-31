/*
*Topic: Implementation of Sequential Quadratic Programming in C++
*Library: Eigen, a c++ matrix operation library.
*Author: Muqian, Chen
*Current Date: 31.01.2021
*Log: The function to calculate a quadratic optimal programming constrainted by inequation 
*        conditions are totally implemnted. It did take a long time because I am not familiar 
*        with lots of implicit mechamism of c++. But I feel so lucky that I really started to
*        program with it. I think that I am moving towards to the aim that I really implement
*        something based on ROS. The next task is to cover the case of equation constraints
*        and add a function which automatically calculates the initial working set. Over.
*/

#include <iostream>
#include <Eigen>
#include <typeinfo>
#include <iomanip>

using namespace std;
using namespace Eigen;
VectorXd eqpCalculation(MatrixXd A, VectorXd b, MatrixXd G,
						VectorXd d, VectorXd theta);
double calculationAlpha(MatrixXd& A_working, VectorXd& b_working,
						MatrixXd& A_deactive,VectorXd& b_deactive, 
						VectorXd stepLength, VectorXd theta);


//这里若是加上&就会变成按引用传递了亲，已经用test检验过了。
VectorXd eqpCalculation(MatrixXd A, VectorXd b, MatrixXd G, 
	                    VectorXd d, VectorXd theta) {
	VectorXd g, h;
	g = d + G * theta;
	h = A * theta - b;
	Index g_row = g.rows();
	Index h_row = h.rows();

	//catenate the A and G as KKT Matrix
	Index A_row = A.rows();
	Index A_col = A.cols();
	Index G_row = G.rows();

	//first catenate them in horizont direction
	MatrixXd K1(G_row, A_row + G_row);
	K1 << G, A.transpose();
	MatrixXd zeros = MatrixXd::Zero(A_row, A_row);
	MatrixXd K2(A_row, A_col + A_row);
	K2 << A, zeros;
	MatrixXd K(A_row + G_row, A_row + G_row);
	K << K1, K2;

	//then catenate [g;h] 
	VectorXd g_h(g_row + h_row, 1);
	g_h << g, h;

	//calculate KKT-Equation 
	VectorXd result(G_row + A_row, 1);
	result = K.inverse() * g_h;
	
	return result;
	};

//implementation of a function template for removing a specific row from MatrixXf or VectorXf
//After validation, this function could work at situation MatrixXf or VectorXf
template <typename T1, typename T2> void removeRow(T1& a, T2 b) {
	const int newRow = a.rows() - 1;
	const int newCol = a.cols();

	if (b < a.rows()) {
		a.block(b, 0, newRow - b, a.cols()) =
			a.block(b + 1, 0, newRow - b, a.cols());
	}
	else {
		cout << "[INFO] The row to remove is out of boundary of input !" << endl;
	};
	a.conservativeResize(newRow, newCol);
}

//Implementation of a function template for adding a trivial but dimension-matched row into
//MatrixXf or VectorXf
template <typename T1, typename T2> void addRow(T1& a, T2 b) {
	int newRow = a.rows() + 1;
	int newCol = a.cols();

	a.conservativeResize(newRow, newCol);

	a.block(newRow - 1, 0, 1, newCol) = b;
};


//Pass by reference could be used here for updating the working set.
double calculationAlpha(MatrixXd& A_working, VectorXd& b_working, 
					   MatrixXd& A_deactive, VectorXd& b_deactive, VectorXd stepLength, VectorXd theta) {
	double alpha = -1;
	int deactRow = A_deactive.rows();
	int deactCol = A_deactive.cols();

	VectorXd resultAiP(deactRow, 1);
	resultAiP = A_deactive * stepLength;
	
	VectorXd resultAiTheta(deactRow, 1);
	resultAiTheta = b_deactive - A_deactive * theta;

	ArrayXd result(deactRow, 1);
	ArrayXd resultUp(deactRow, 1);
	ArrayXd resultDown(deactRow, 1);
	resultUp = resultAiTheta.array();
	resultDown = resultAiP.array();

	for (int i = 0; i < deactRow; i++) {
		if (resultAiP(i, 0) < 1e-10) {
			result(i, 0) = resultUp(i, 0) / resultDown(i, 0);
		}
		else {
			result(i, 0) = 1000.0;
		}
	}

	Index minRow, minCol;
	double min = 0;
	min = result.matrix().minCoeff(&minRow, &minCol);

	//=============================Attention！！！！======================================
	//这里有个坑，就是c++中除号/出来的结果会直接舍弃小数点后面的数，比如这里min应该是1.429
	//但是只输出1，但是在这个程序中我可以不用管这个问题，因为之后是要拿去跟1做比较的。
	//不对啊，我得管，因为之后alpha若是算出小于一则按照这个规则直接就是零了。。。
	//遭重了，得把所有矩阵都改成double类型。
	//全部都改成也不行，当你使用mat.array()的时候它会自动将类型换掉（或者有别的我不懂的内
	//隐操作），通过实验得出，必须要另外声明ArrayXd变量来储存mat.array()的结果，这样才能在
	//相除操作中得到完美的小数点后面的数。                    
	//-----31.01.2021
	//ArrayXd result(deactRow, 1);
	//ArrayXd resultUp(deactRow, 1);
	//ArrayXd resultDown(deactRow, 1);
	//resultUp = resultAiTheta.array();
	//resultDown = resultAiP.array();
	//result = resultUp / resultDown;
	//cout << "[INFO]Current result is :" << result << endl;
	//=============================Attention！！！！======================================

	if (min < 1) {
		alpha = min;

		//add the blocking constraint into working set
		addRow(A_working, A_deactive.row(minRow));
		addRow(b_working, b_deactive.row(minRow));

		//delete the blocking constraint from deactive set
		removeRow(A_deactive, minRow);
		removeRow(b_deactive, minRow);

		return alpha;
	}
	else {
		alpha = 1;
		return alpha;
	}
}


int main(int argc, char** argv)
{
	//define G and d and inequation constraints
	//typedef Matrix<float, 2, 2> Matrix2f;
	MatrixXd G(2,2);
	G << 2.0, 0.0, 
		 0.0, 2.0;
	//typedef Matrix<float, 2, 1> Vector2f;
	VectorXd d(2,1);
	d << -2.0, 
		 -5.0;

	//typedef Matrix<float, Dynamic, 2> MatrixX2f;
	MatrixXd A(5, 2);
	A << 1.0, -2.0, 
		-1.0, -2.0, 
		-1.0,  2.0, 
		 1.0,  0.0,
		 0.0,  1.0;
	//Map <Matrix<float, 2,5, RowMajor>> M1(A.data());

	//typedef Matrix<float, Eigen::Dynamic, 1> VectorXf;
	VectorXd b(5, 1);
	b << -2.0, 
		 -6.0, 
		 -2.0, 
		  0.0, 
		  0.0;

	//define initialized theta
	VectorXd theta(2,1);
	theta(0) = 0.0;
	theta(1) = 1.0;



	//define working set
	MatrixXd A_working(2, 2);
	VectorXd b_working(2, 1);

	A_working << A.row(0), A.row(3);
	b_working << b.row(0), b.row(3);


	MatrixXd A_deactive(3, 2);
	VectorXd b_deactive(3, 1);

	A_deactive << A.row(1), A.row(2), A.row(4);
	b_deactive << b.row(1), b.row(2), b.row(4);

	//define the main variable during the calculating loop
	Index constraintsNumber = b_working.rows();
	Index thetaNumber = theta.rows();
	
	VectorXd result(thetaNumber+constraintsNumber, 1);
	VectorXd stepLength(thetaNumber, 1);
	VectorXd lambdaStar(constraintsNumber, 1);

	

	while (true) {
		

		result = eqpCalculation(A_working, b_working, G, d, theta);

		constraintsNumber = b_working.rows();
		stepLength << -result.head(thetaNumber);
		lambdaStar = result.tail(constraintsNumber);
		cout << "[INFO]: current lambdaStar is:"<< lambdaStar << endl;

		if ( ( stepLength.array() < 1e-10 ).all() == 1 ) {
			if ((lambdaStar.array() > 0).all() == 1) {
				break;
			}
			else {
				VectorXf::Index minRow, minCol;
				float min_lambda = lambdaStar.minCoeff(&minRow, &minCol);

				//add the deleted constraints into deactive set
				addRow(A_deactive, A_working.row(minRow));
				addRow(b_deactive, b_working.row(minRow));

				//delete the constraints from working set
				removeRow(A_working, minRow);
				removeRow(b_working, minRow);
				cout << "[INFO: A constraint is deleted from working set and added in deactive set.]" << endl;
			}
		}
		else {
			float alpha = 0.0;
			alpha = calculationAlpha(A_working, b_working, A_deactive, b_deactive, stepLength, theta);
			theta = theta + alpha * stepLength;
			cout << "[INFO]Current Theta is :" <<endl << theta << endl;
		}
	}
	


}
