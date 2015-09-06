# cohens_d.py
"""
The cohens_d function will take two arrays and compute Cohen's d.

INPUT
x = ndarray
y = ndarray
DIM = the dimension the samples are along

OUTPUT 
d = Cohen's d

Written by mvlombardo 05.09.2015
"""

def cohens_d(x, y, DIM='rows'):
    
    import numpy as np

    if DIM == 'rows':
        dim = 0
    elif DIM == 'columns':
        dim = 1

	# n-1 for x and y
    lx = x.shape[dim]-1
    ly = y.shape[dim]-1

	# mean difference
    md = np.abs(np.mean(x, axis = dim, dtype = np.float64) - np.mean(y, axis = dim, dtype = np.float64))

	# pooled variance
    csd = (lx * np.var(x, axis = dim, dtype = np.float64)) + (ly * np.var(y, axis = dim, dtype = np.float64))
    csd = np.sqrt(csd/(lx + ly))
	
	# compute cohen's d
    d  = md/csd
    
    return(d)
