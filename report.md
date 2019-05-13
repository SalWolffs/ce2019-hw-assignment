# CE Hardware Assignment

## Exercise 4
`modaddn.vhd` was written by copying `modadd4.vhd` and replacing any occurrences
of `3` and `4` by `n-1` resp. `n`, as per the example of `addn.vhd` and
`add4.vhd`. Expanding the test bench was done by adjusting the default width of
the generic tb\_modaddn entity, taking some 128-bit random numbers for a\_i,
b\_i and p\_i, making sure one set requires a subtraction and one doesn't, and
computing appropriate values for `sum_true` in python.
