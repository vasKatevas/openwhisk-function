pkg load statistics
load results.csv
x = results(1:3)'
y = results(1:3,2)
[B, BINT, R, RINT, STATS] = regress (y, x)
