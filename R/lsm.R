import scipy.stats
xvalues = (1, 3, 2.5, 3.9)
yvalues = (2.1, 3.7, 3.4, 3.1)
slope, intercept, r_value, p_value, std_err = scipy.stats.linregress(xvalues,yvalues)
print "Intercept: %f, Slope: %f" % (intercept, slope)