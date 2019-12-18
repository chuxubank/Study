#include <cmath>
#include <iostream>
#include <stack>
#include <string>
using namespace std;
const float MIN = 1e-5;
const int maxSize = 50;

//判别运算符优先级
int getPriority(char op)
{
	if (op == '+' || op == '-')
		return 0;
	else
		return 1;
}

//子表达式求值
int calSub(float opand1, char op, float opand2, float &result)
{
	if (op == '+')
		result = opand1 + opand2;
	if (op == '-')
		result = opand1 - opand2;
	if (op == '*')
		result = opand1 * opand2;
	if (op == '/')
	{
		if (fabs(opand2) < MIN)
		{
			return 0;
		}
		else
			result = opand1 / opand2;
	}
	return 1;
}

//计算完结果后判断是否满足要求
int calStackTopTwo(float s1[], int &top1, char s2[], int &top2)
{
	float opnd1, opnd2, result;
	char op;
	int flag;
	opnd2 = s1[top1--]; //先出在右
	opnd1 = s1[top1--]; //后出在左
	op = s2[top2--];
	flag = calSub(opnd1, op, opnd2, result);
	if (flag == 0)
		cout << "ERROR" << endl;
	s1[++top1] = result;
	return flag;
}

//中缀表达式求值
float calInfix(char exp[])
{
	float s1[maxSize]; //存操作数
	int top1 = -1;
	char s2[maxSize]; //存操作符
	int top2 = -1;
	int i = 0;
	//从左往右遍历中缀字符串
	while (exp[i] != '\0')
	{
		//操作数入结果栈
		if ('0' <= exp[i] && exp[i] <= '9')
		{
			s1[++top1] = exp[i] - '0';
			++i;
		}
		//左括号入辅助栈
		else if (exp[i] == '(')
		{
			s2[++top2] = exp[i];
			++i;
		}
		//操作符准备入辅助栈
		else if (exp[i] == '+' ||
				 exp[i] == '-' ||
				 exp[i] == '*' ||
				 exp[i] == '/')
		{
			//栈空或 栈顶为左括号或 优先级大于栈顶时入栈
			if (top2 == -1 ||
				s2[top2] == '(' ||
				getPriority(exp[i]) > getPriority(s2[top2]))
			{
				s2[++top2] = exp[i];
				++i;
			}
			//否则取两个操作数计算
			else
			{
				int flag = calStackTopTwo(s1, top1, s2, top2);
				if (flag == 0)
					return 0;
			}
		}
		//右括号则一直出栈到第一个左括号并计算
		else if (exp[i] == ')')
		{
			while (s2[top2] != '(')
			{
				int flag = calStackTopTwo(s1, top1, s2, top2);
				if (flag == 0)
					return 0;
			}
			--top2; //出栈左括号
			++i;	//跳过右括号
		}
	}

	//遍历结束后若辅助栈非空则全部出栈并计算
	while (top2 != -1)
	{
		int flag = calStackTopTwo(s1, top1, s2, top2);
		if (flag == 0)
			return 0;
	}
	//此时的结果在结果栈的栈顶
	return s1[top1];
}

//后缀表达式求值
float calPostFix(char exp[])
{
	float s[maxSize];
	int top = -1;
	for (int i = 0; exp[i] != '\0'; i++)
	{
		if (exp[i] >= '0' && exp[i] <= '9')
			s[++top] = exp[i] - '0';
		else
		{
			float opnd1, opnd2, result;
			char op;
			int flag;
			opnd2 = s[top--]; //先出在右
			opnd1 = s[top--]; //后出在左
			op = exp[i];
			flag = calSub(opnd1, op, opnd2, result);
			if (!flag)
			{
				cout << "ERROR" << endl;
				break;
			}
			s[++top] = result;
		}
	}
	return s[top];
}

//前缀表达式求值
float calPreFix(char exp[], int len)
{
	float s[maxSize];
	int top = -1;
	for (int i = len - 1; i >= 0; --i)
	{
		if (exp[i] >= '0' && exp[i] <= '9')
			s[++top] = exp[i] - '0';
		else
		{
			float opnd1, opnd2, result;
			char op;
			int flag;
			opnd1 = s[top--]; //先出在左
			opnd2 = s[top--]; //后出在右
			op = exp[i];
			flag = calSub(opnd1, op, opnd2, result);
			if (!flag)
			{
				cout << "ERROR" << endl;
				break;
			}
			s[++top] = result;
		}
	}
	return s[top];
}

//中缀转后缀
//类比中缀表达式求值
void infixToPostFix(char infix[], char s1[], int &top1)
{
	char s2[maxSize]; //辅助栈存放操作符
	int top2 = -1;
	int i = 0;
	//从左往右遍历中缀字符串
	while (infix[i] != '\0')
	{
		//数字入结果栈
		if ('0' <= infix[i] && infix[i] <= '9')
		{
			s1[++top1] = infix[i];
			++i;
		}
		//左括号入辅助栈
		else if (infix[i] == '(')
		{
			s2[++top2] = '(';
			++i;
		}
		//操作符准备入辅助栈
		else if (infix[i] == '+' ||
				 infix[i] == '-' ||
				 infix[i] == '*' ||
				 infix[i] == '/')
		{
			//栈空或 栈顶为左括号或 优先级大于栈顶时入栈
			if (top2 == -1 ||
				s2[top2] == '(' ||
				getPriority(infix[i]) > getPriority(s2[top2]))
			{
				s2[++top2] = infix[i];
				++i;
			}
			//否则取辅助栈栈顶运算符入结果栈
			else
				s1[++top1] = s2[top2--];
		}
		//右括号则一直出栈到第一个左括号并压入结果栈
		else if (infix[i] == ')')
		{
			while (s2[top2] != '(')
				s1[++top1] = s2[top2--];
			--top2; //出栈左括号
			++i;	//跳过右括号
		}
	}
	//遍历结束后辅助栈非空则依次压入结果栈
	while (top2 != -1)
		s1[++top1] = s2[top2--];
}

//后缀转前缀
string postfixToPreFix(char postfix[])
{
	string s2[maxSize];
	int top2 = -1;
	int i = 0;
	for (i = 0; postfix[i] != '\0'; i++)
	{
		//数字直接入结果栈
		if ('0' <= postfix[i] && postfix[i] <= '9')
			s2[++top2] = string(1, postfix[i]);
		//弹出两个子式并将操作符放到其前方后入栈
		else
		{
			string p2 = s2[top2--];
			string p1 = s2[top2--];
			s2[++top2] = postfix[i] + p1 + p2;
		}
	}
	return s2[top2];
}

//中缀转前缀
void infixToPreFix(char infix[], int len, char s1[], int &top1)
{
	char s2[maxSize]; //辅助栈存放操作符
	int top2 = -1;
	int i = len - 1;
	//从右往左遍历中缀字符串
	while (i >= 0)
	{
		//数字入结果栈
		if ('0' <= infix[i] && infix[i] <= '9')
		{
			s1[++top1] = infix[i];
			--i;
		}
		//右括号入辅助栈
		else if (infix[i] == ')')
		{
			s2[++top2] = ')';
			--i;
		}
		//操作符准备入辅助栈
		else if (infix[i] == '+' ||
				 infix[i] == '-' ||
				 infix[i] == '*' ||
				 infix[i] == '/')
		{
			//栈空或 栈顶为右括号或 优先级大于等于栈顶时入栈
			if (top2 == -1 ||
				s2[top2] == ')' ||
				getPriority(infix[i]) >= getPriority(s2[top2]))
			{
				s2[++top2] = infix[i];
				--i;
			}
			//否则取辅助栈栈顶运算符入结果栈
			else
				s1[++top1] = s2[top2--];
		}
		//左括号则一直出栈到第一个右括号并压入结果栈
		else if (infix[i] == '(')
		{
			while (s2[top2] != ')')
				s1[++top1] = s2[top2--];
			--top2; //出栈右括号
			--i;	//跳过左括号
		}
	}
	//遍历结束后辅助栈非空则依次压入结果栈（逆序）
	while (top2 != -1)
		s1[++top1] = s2[top2--];
}

void reverseStack(char input[], int size)
{
	char tmp;
	for (int i = 0; i <= size / 2; i++)
	{
		tmp = input[i];
		input[i] = input[size - i - 1];
		input[size - 1 - i] = tmp;
	}
}

void printStack(char result[], int top)
{
	for (int i = 0; i <= top; i++)
	{
		cout << result[i];
	}
	cout << endl;
}

int getLength(char input[])
{
	int length = 0;
	while (input[length] != '\0')
		length++;
	return length;
}

int main()
{
	char exp[maxSize] = "2/(1-2)*4";
	int length = getLength(exp);
	char result[maxSize];
	int top = -1;
	cout << "infix:\t" << exp << endl;
	cout << "-----result-----\n";
	//中缀求值
	cout << "infix value:\t" << calInfix(exp) << endl;
	//中缀转后缀
	infixToPostFix(exp, result, top);
	cout << "postfix:\t";
	printStack(result, top);
	//后缀求值
	cout << "postfix value:\t" << calPostFix(result) << endl;
	//后缀转前缀
	cout << "post->pre:\t" << postfixToPreFix(result) << endl;
	//中缀转前缀
	cout << "prefix:\t\t";
	memset(result, 0, sizeof result);
	top = -1;
	infixToPreFix(exp, length, result, top);
	reverseStack(result, top + 1);
	printStack(result, top);
	//前缀求值
	length = getLength(result);
	cout << "prefix value:\t" << calPreFix(result, length) << endl;
	return 0;
}