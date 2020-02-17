import math
a=b=c=1
while a<1000:
    b=a+1
    while b<1000 and a+b+c<1000 :
        apow=int(math.pow(a,2))
        bpow=int(math.pow(b,2))
        c=int(math.sqrt(apow+bpow))
        cpow=int(math.pow(c,2))
        if c%1==0 and c>b and apow+bpow==cpow and  int(a+b+c)==1000:
            print(a*b*c)
        b+=1
    a+=1