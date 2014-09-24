# -*- coding: utf-8 -*-
# Original source: http://stackoverflow.com/questions/17784587/gradient-descent-using-python-and-numpy

"""
Gradient descent (Steepest descent)
최적화 문제 해결에 사용하는 방법
"""

import numpy as np
import random

# m denotes the number of examples here, not the number of features
# m은 example의 수를 말하며 feature(즉 차원의 수)를 말하는 것이 아님
import sys

def gradientDescent(x, y, theta, alpha, m, numIterations):
    print "="*50
    print "x is :"
    print x
    print "x transpose is :"
    print x.transpose()
    print "theta is :"
    print theta
    print "="*50

    xTrans = x.transpose()  # 행렬전치, 행과 열을 바꾼다. 테트리스 맛살 블럭을 옆으로 회전하는 것이라고 생각

    for i in range(0, numIterations):
        hypothesis = np.dot(x, theta)  # 내적을 구합니다. 데이터의 레코드 수만큼 나오구요. 값은 각각 스칼라 하나씩들어 있습니다.
        print "hypothesis is :"
        print hypothesis
        print y
        sys.exit()
        loss = hypothesis - y
        # avg cost per example (the 2 in 2*m doesn't really matter here.
        # But to be consistent with the gradient, I include it)
        cost = np.sum(loss ** 2) / (2 * m)
        print("Iteration %d | Cost: %f" % (i, cost))
        # avg gradient per example
        gradient = np.dot(xTrans, loss) / m
        # update
        theta = theta - alpha * gradient
    return theta

# 데이티 생성 함수
# @numPoints: 데이터의 개수, x는 2개의 값으로 된 feature이며  y는 target variable이다
# @bias: 바이어스
# @variance: 분산
def genData(numPoints, bias, variance):
    x = np.zeros(shape=(numPoints, 2))  # 2개의 서브 array를 가진 array를 생성. 사실상 2열의 행렬. 0으로 채워진다.
    y = np.zeros(shape=numPoints)  # 벡터, 한줄짜리 행렬
    # basically a straight line
    for i in range(0, numPoints):
        # bias feature
        x[i][0] = 1
        x[i][1] = i
        # our target variable
        # 타겟변수 (종속변수)
        y[i] = (i + bias) + random.uniform(0, 1) * variance  # 한쪽으로 기울게 유니폼으로 랜덤값을 생성. 분산을 곱하고 한쪽으로 스큐시킨다.
    return x, y

# gen 100 points with a bias of 25 and 10 variance as a bit of noise
x, y = genData(100, 25, 10)
print "=" * 50
print x  # 독립변수
print y  # 종속변수
print "=" * 50

m, n = np.shape(x)  # 디멘젼구하기  100행, 2열짜리 데이터이다.
print m
print n

print "=" * 50

numIterations = 100000  # Iteration을 십만번 수행
alpha = 0.0005  # learning rate가 0.0005로 설정. 즉 0.0005만큼 이동한다는 말
theta = np.ones(n)  # 1,1로 초기 쎄타를 정한다.  1, 1에서 시작하는 SGD
print theta
print "=" * 50

theta = gradientDescent(x, y, theta, alpha, m, numIterations)
sys.exit()
print(theta)
