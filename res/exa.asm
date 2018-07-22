note Math
copy 10 X
addi x 10 X
subi x 10 X
muli x 10 X
divi x 10 X
modi x 3 X
swizz X 1111 x

note Branching
jump inbranch
!noop
mark inbranch
copy 4 X
mark bloop
subi x 1 x
test x < 3
fjmp bloop
test x < 2
tjmp outbranch
test x = 2
tjmp bloop
mark outbranch

note REPL L
note HALT
note KILL

note LINK R/I
note HOST R

mode
note VOID M
note TEST MRD

note Files
make
copy 10 F
seek -1
file x
drop
grab 0
test 10 = F
test eof
wipe

noop
rand 0 100 x