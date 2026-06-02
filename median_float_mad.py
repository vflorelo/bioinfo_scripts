#!/usr/bin/python3
import numpy as np
import statistics
import sys
from scipy import stats
num_str    = sys.argv[1]
mad_factor = int(sys.argv[2])
str_list   = num_str.split(",")
num_list   = list(map(float, str_list))
num_count  = len(num_list)
median     = statistics.median(num_list)
mad        = stats.median_abs_deviation(num_list)
upper      = median + (mad_factor * mad)
lower      = median - (mad_factor * mad)
upper_test = np.all(np.array(num_list) <= upper) # returns True if all elements are smaller than upper limit
lower_test = np.all(np.array(num_list) >= lower) # returns True if all elements are greater than lower limit
if   (upper_test and lower_test):
    status = "within"
elif (upper_test and (not lower_test)):
    status = "left_skewed"
elif ((not upper_test) and lower_test):
    status = "right_skewed"
elif ((not upper_test) and (not lower_test) ):
    status = "symm_skewed"
print(str(median) + "\t" + str(num_count) + "\t" + str(mad) + "\t" + str(lower) + "\t" + str(upper) + "\t" + status)
