mov 3 dat
ls:mov 3 acc
l:
mov dat x1 #X
mov acc x1 #Y
mov x0 x1
mov -1 x1
add 1
tlt acc 16
+ jmp l
tlt dat 11
+ mov 11 dat
+ jmp ls
teq dat 15
- mov 15 dat
- jmp ls
mov 4 x1
mov 8 x1
mov 5 acc
l2:mov x0 x1
sub 1
tgt acc 0
+jmp l2