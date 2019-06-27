def null(a,b,p):
    return a

def mul(a,b,p):
    return (a*b+p) % p

def add(a,b,p):
    return (a+b+p) % p

def sub(a,b,p):
    return (a-b+p) % p

names=["p ","a ","b ",
        "X1","Y1","Z1",
        "X2","Y2","Z2",
        "X3","Y3","Z3",
        "t0","t1","t2","t3","t4","t5","t6","t7"]
p=0
a=1
b=2
X1=3
Y1=4
Z1=5
X2=6
Y2=7
Z2=8
X3=9
Y3=10
Z3=11
t0=12
t1=13
t2=14
t3=15
t4=16
t5=17
t6=18
t7=19



ops=["NULL","*","+","-"]
funcs=[null,mul,add,sub]
N=0
M=1
A=2
S=3

P=0x7F

point_add=[
        (M,t0,X1,X2,P),
        (M,t1,Y1,Y2,P),
        (M,t2,Z1,Z2,P),
        (A,t3,X1,Y1,P),
        (A,t4,X2,Y2,P),
        (M,t3,t3,t4,P),
        (A,t4,t0,t1,P),
        (S,t3,t3,t4,P)]

ram = [0 for i in range(20)]

def exe(op,to_addr,l_addr,r_addr,prime):
    l,r = ram[l_addr],ram[r_addr]
    out = funcs[op](l,r,prime)
    print( "{} = {}{}{}  ".format(names[to_addr],names[l_addr],ops[op],names[r_addr]),
            "{:02X} = {:02X}{}{:02X}  (mod {})".format(out,l,ops[op],r,prime),
            "{:02X} <- {:02X}{}{:02X}  ".format(to_addr,l_addr,ops[op],r_addr),
            "{} <- {}{}{}  ".format(to_addr,l_addr,ops[op],r_addr))
    ram[to_addr]=out

def run(code):
    for x in code:
        exe(*x)

ram[0]=0x7f
ram[1]=0x7c
ram[2]=0x05
ram[3]=0x31
ram[4]=0x0a
ram[5]=0x0f
ram[6]=0x04
ram[7]=0x5b
ram[8]=0x3c
