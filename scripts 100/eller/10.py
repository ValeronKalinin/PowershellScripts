import math
def issimple(var):
    ii=1
    iter=int(math.sqrt(var))
    while ii<iter+1:
        if var%ii==0 and ii!=1:        
            break
        if ii==iter and var!=1:
            #print(var,iter)
            return int(var)
        #print(ii)
        ii+=1
i=1
summ=0
while i<2000000:
    res=issimple(i)
    if res is not None:
        #print(res)
        summ+=res
    #if i%100000==0:
     #   print(i)
    i+=1
print(res,summ)



    
    
    
   