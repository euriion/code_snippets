#!/usr/bin/python
# -*- coding: utf-8 -*-
# need to install scipy, numpy

import sys
#from scipy.stats import cov, uniform, norm, scoreatpercentile
import numpy
import scipy.stats

intls = ("tw","hk","kr","vn")

per_range = numpy.arange(1, 100, 0.1):

fd_overview  = open("./overview.duration", "w")

all_duration_list = []
for intl in intls:
    print "processing '%s'" % intl
    duration_list = []

    for line in open("./%s.real.duration" % intl).xreadlines():
        duration_list.append(int(line.strip()))

    all_duration_list.extend(duration_list)

    fd = open("./%s.percentile" % intl, "w")
    for per in per_range:
        percentile = scipy.stats.scoreatpercentile(duration_list, per)
        print "%s\t%s" % (per, percentile)
        fd.write("%s\t%s\n" % (per, percentile))
    fd.close()

    fd_overview.write("intl: %s\n" % intl)
    fd_overview.write("mean: %s\n" % numpy.mean(duration_list));
    fd_overview.write("min: %s\n" % numpy.min(duration_list));
    fd_overview.write("median: %s\n" % numpy.median(duration_list));
    fd_overview.write("max: %s\n" % numpy.max(duration_list));
    fd_overview.write("total: %s\n" % len(duration_list));
    fd_overview.write("==================================================\n");

intl = "all"
fd = open("./%s.percentile" % intl, "w")
for per in per_range:
    percentile = scipy.stats.scoreatpercentile(all_duration_list, per)
    print "%s\t%s" % (per, percentile)
    fd.write("%s\t%s\n" % (per, percentile))
fd.close()

fd_overview.write("intl: %s\n" % intl)
fd_overview.write("mean: %s\n" % numpy.mean(duration_list));
fd_overview.write("min: %s\n" % numpy.min(duration_list));
fd_overview.write("median: %s\n" % numpy.median(duration_list));
fd_overview.write("max: %s\n" % numpy.max(duration_list));
fd_overview.write("total: %s\n" % len(duration_list));
fd_overview.write("==================================================\n");

fd_overview.close()
