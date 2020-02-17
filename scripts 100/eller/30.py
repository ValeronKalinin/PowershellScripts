import math
result=0
i=2
while i<10000000:
    lst=list(str(i))
    summ=int(0)
    for b in lst:
        b=int(b)
        summ+=math.pow(b,5)
    if i==summ:
        result+=summ
        print(i,lst,summ,result)
    i+=1