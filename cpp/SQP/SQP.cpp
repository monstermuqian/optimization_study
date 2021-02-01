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
	//for debug
	//cout << "[INFO]Current KKT Matrix is:" << endl << K << endl;
	//cout << "[INFO]Current g_h is:" << endl << g_h << endl;

	//calculate KKT-Equation 
	VectorXd result(G_row + A_row, 1);
	result = K.inverse() * g_h;
	
	return result;
	};

//implementation of a function template for removing a specific row from MatrixXf or VectorXf
//After validation, this function could work at situation MatrixXf or VectorXf
template <typename T1, typename T2> void removeRow(T1& a, T2 b) {
	// a: Matrix or Vector which need to remove the row
	// b: the row number of the removed row.

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
	// a: the target Matrix or Vector 
	// b: added row into target
	// column number should be unchanged.

	int newRow = a.rows() + 1;
	int newCol = b.cols();

	a.conservativeResize(newRow, newCol);
	a.block(newRow - 1, 0, 1, newCol) = b;
};


//Implementation of a fucntion template 
void setInitial(MatrixXd A, MatrixXd& A_working,  MatrixXd& A_deactive, VectorXd b, VectorXd& b_working, 
			    VectorXd& b_deactive, VectorXd  initialTheta, int f) {
	//f: amount of inequations
	VectorXd result(f ,1);
	result = A * initialTheta - b;
	ArrayXd resultArray;
	resultArray = result.array();
	for (int i = 0; i < f; i++) {
		if ( result(i, 0) < 1e-7) {
			//add the matched constraints into working set
			addRow(A_working, A.row(i));
			addRow(b_working, b.row(i));
		}
		else {
			//add the unmatched constraints into deacitve set
			addRow(A_deactive, A.row(i));
			addRow(b_deactive, b.row(i));
		}
	}
}


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
	//define G and d of objective function
	MatrixXd G(2,2);
	G << 2.0, 0.0, 
		 0.0, 2.0;
	VectorXd d(2,1);
	d << -2.0, 
		 -5.0;

	//define initialized theta
	VectorXd theta(2, 1);
	theta(0) = 2.0;
	theta(1) = 0.0;
	int ParameterNum = theta.rows();

	//define equation constraints
	MatrixXd AEquation(0, ParameterNum);
	VectorXd bEquation(0, 1);


	//define inequation constraints
	MatrixXd AInequation(5, ParameterNum);
	AInequation << 1.0, -2.0, 
				  -1.0, -2.0, 
				  -1.0,  2.0, 
				   1.0,  0.0,
				   0.0,  1.0;

	int AInitialRowNum = AInequation.rows();

	VectorXd bInequation(5, 1);
	bInequation << -2.0, 
				   -6.0, 
				   -2.0, 
				    0.0, 
				    0.0;




	//define working set
	MatrixXd A_working(0, ParameterNum);
	VectorXd b_working(0, 1);

	A_working = AEquation;
	b_working = bEquation;


	MatrixXd A_deactive(0, ParameterNum);
	VectorXd b_deactive(0, 1);

	setInitial(AInequation, A_working, A_deactive, bInequation, 
			   b_working, b_deactive, theta, AInitialRowNum);

	//for debug
	//cout << "[INFO]Current A inequation constraints is:" << endl << A_working << endl;
	//cout << "[INFO]Current b inequation constraints is:" << endl << b_working << endl;
	//define the main variable during the calculating loop
	Index constraintsNumber = b_working.rows();
	Index thetaNumber = theta.rows();
	
	VectorXd result(thetaNumber+constraintsNumber, 1);
	VectorXd stepLength(thetaNumber, 1);
	VectorXd lambdaStar(constraintsNumber, 1);

	int i = 1;

	while (true) {
		

		result = eqpCalculation(A_working, b_working, G, d, theta);

		constraintsNumber = b_working.rows();
		stepLength << -result.head(thetaNumber);
		lambdaStar = result.tail(constraintsNumber);
		//for debug
		//cout << "[INFO]: current lambdaStar is:"<<endl<< lambdaStar << endl;

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
				cout << "[INFO] " << i << ". loop. A constraint is deleted from working set and added in deactive set." << endl;
				i++;
			}
		}
		else {
			float alpha = 0.0;
			alpha = calculationAlpha(A_working, b_working, A_deactive, b_deactive, stepLength, theta);
			theta = theta + alpha * stepLength;
			cout << "[INFO]" << i << ". loop.Current Theta is :" <<endl << theta << endl;
			i++;
		}
	}
	


}
