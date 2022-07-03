pkg load statistics
load results.csv
y = results(:, 1)
x = results(:, 2)
[B, BINT, R, RINT, STATS] = regress (y, x)
Y = BINT(1) + BINT(2)*x