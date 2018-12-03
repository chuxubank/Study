# 栈、队列和向量

## 栈

### 通用函数

{% tabs %}
{% tab title="getPriority" %}
```cpp
int getPriority(char op)
{
	if (op == '+' || op == '-')
		return 0;
	else
		return 1;
}
```
{% endtab %}

{% tab title="calSub" %}
```cpp
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
```
{% endtab %}
{% endtabs %}

### 中缀转后缀

{% tabs %}
{% tab title="文字描述" %}
* 从左往右遍历中缀字符串
  * 数字入结果栈
  * 左括号入辅助栈
  * 操作符准备入辅助栈
    * 栈空或 栈顶为左括号或 优先级**大于**栈顶时入栈
    * 否者取当前运算符直接入结果栈
  * 右括号则一直出栈到第一个左括号并压入结果栈
* 遍历结束后辅助栈非空则依次压入结果栈
{% endtab %}

{% tab title="infixToPostFix" %}
```cpp
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
				getPriority(infix[i] > getPriority(s2[top2])))
			{
				s2[++top2] = infix[i];
				++i;
			}
			//否则取当前运算符直接入结果栈
			else
				s1[++top1] = infix[i];
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
```
{% endtab %}
{% endtabs %}

* 从左往右扫描
* 操作数：打印
* 操作符：
  * 大于或左括号：入栈
  * 当前优先级小于等于栈顶：依次出栈并比较
  * 右括号：一直出栈到第一个左括号

### 中缀转前缀

* 从右往左扫描
* 操作数：打印
* 操作符：
  * 大于等于或右括号：入栈
  * 当前优先级小于栈顶：依次出栈并比较
  * 左括号：一直出栈到第一个右括号

### 后缀转前缀

* 从左往右扫描
* 操作数：入栈
* 操作符：出栈两个操作数并将操作符置于两个操作数（先出栈在右，后出栈在左）之前，然后入栈

### 中缀表达式求值

{% tabs %}
{% tab title="文字描述" %}
* 从左往右遍历中缀字符串
  * 操作数入结果栈
  * 左括号入辅助栈
  * 操作符准备入辅助栈
    * 栈空或 左括号或 优先级**大于**栈顶时入栈
    * 否则取两个操作数计算
  * 右括号则一直出栈到第一个左括号并计算
* 遍历结束后若辅助栈非空则全部出栈并计算
{% endtab %}

{% tab title="calInfix" %}
```cpp
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
```
{% endtab %}

{% tab title="calStackTopTwo" %}
```cpp
int calStackTopTwo(float s1[], int &top1, char s2[], int &top2)
{
	float opnd1, opnd2, result;
	char op;
	int flag;
	opnd2 = s1[top1--]; //先出在右
	opnd1 = s1[top1--]; //后出在左
	op = s2[top2--];
	flag = calSub(opnd2, op, opnd2, result);
	if (flag == 0)
		cout << "ERROR" << endl;
	s1[++top1] = result;
	return flag;
}
```
{% endtab %}
{% endtabs %}

### 后缀表达式求值

* 从左到右扫描
* 操作数：入s
* 操作符：从s中弹出两个操作数（先出在右，后出在左）运算并将结果入s

### 前缀表达式求值

* 从右往左扫描
* 操作数：入s
* 操作符：从s中弹出两个操作数（先出在左，后出在右）运算并将结果入s

