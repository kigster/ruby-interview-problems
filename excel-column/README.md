
# Excel Column Name Problem

Given a column number, convert it to the corresponding excel sheet column name using a typical Excel naming scheme.

#### Input Format:

The first and the only argument is an integer number, num.

###  Output Format:

Return a string, representing the corresponding excel sheet column.


#### Constraints:

1 <= len(num)

Example 1:

 * Input 1: 1
 * Output 1: A
 * Explanation 1: 1 corresponds to the first index of the sheet columns i.e A

Example 2:   

 * Input 2: 27
 * Output 2: AA
 * Explanation 2: => 27 corresponds to the 27th index of the sheet columns i.e AA
 
 
## Excel Columns: 

```
A, B, C, D...Z, AA, AB, AC...., .. ZZ, AAA, AAB, AAC, ....
```

```
A B C D E F G H I J K L M N O P Q R S T U V W X Y  Z
1 2 3 4 5 6 7                                     26
```

# Solution

## Formulae

We need to devise the relationship between the column index and the label. 

Let's say the column name is `AAA`. How does that translate into an index?

Let's also use smaller base 3: so only `A,B,C` are allowed.
```
       3^2       3^1       3^0 |
-------------------------------|-------
A   =>  0         0         1  | =  1
AA  =>  0         1         1  | =  4
AC  =>  0         1         3  | =  6
BC  =>  0         2         3  | =  9 
CC  =>  0         3         3  | = 12
AAA =>  1         1         1  | = 13
AAB =>  1         1         2  | = 14
CCB =>  3         3         2  | = 38



12 % 9 = 4

9*3 + 3*3 + 1*3 [ 1,2,3 ]
9 * 1 + 3 + 1

1 + 3 + 9 = 13!




1    A
2    B
3    C
4   AA
5   AB
6   AC
7   BA
8   BB
9   BC
10  CA
11  CB
12  CC
13 AAA
14 AAB
```

38 / 27
