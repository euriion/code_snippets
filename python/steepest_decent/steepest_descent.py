__author__ = 'aiden.hong'
# -*- coding: utf-8 -*-

"""
이하의 파이선 언어로 작상한 경사 하강법 알고리즘은 f(x)=x^4−3x^3+2 함수의 극값을 미분값인 f'(x)=4x^3−9x^2 를 통해 찾는 예를 보여준다.
From calculation, we expect that the local minimum occurs at x=9/4
"""

print "Expected local minimum: ", 9.0/4.0

x_old = 0
x_new = 6  # The algorithm starts at x=6
eps = 0.01  # step size
precision = 0.00001


def f_prime(x):
    return 4 * x**3 - 9 * x**2

step = 1
while abs(x_new - x_old) > precision:  # 차가 precision 만큼이 될 때까지 피팅
    print "step[%s] x_new = %s , x_old = %s, eps = %s" % (step, x_new, x_old, eps)
    x_old = x_new
    x_new = x_old - eps * f_prime(x_old)
    print "f_prime: %s" % f_prime(x_old), "eps * f_prime: %s" % (eps * f_prime(x_old)), " = new x: %s" % x_new
    step += 1


print "Local minimum occurs at ", x_new