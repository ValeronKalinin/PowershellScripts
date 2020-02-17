import math

 def issimple(var):
     massiv=[]
     ii=1
     iter=int(math.sqrt(var))
     while ii<iter+1:
         if var%ii==0 and ii!=1:        
             break
         if ii==iter and var!=1:
             massiv.append(var)
             print(massiv)
             return int(var)
         #print(ii)
         ii+=1
 i=1
 summ=0
 while i<20:
     res=issimple(i)
     if res is not None:
         #print(res)
         summ+=res
     if i%100000==0:
         print(i)
     i+=1
 print(res,summ,)
#massiv=[]
#massiv.append(int(2))
#def issimple(var):
#    iter=int(math.sqrt(var))
#    for m in massiv:
#        if var%m==0 :        
#            break
#        if m==massiv[-1] and var!=1:
#            massiv.append(var)
#            #print(var)
#            return int(var)
#        #print(ii)
#i=2
#summ=0
#while i<2000000:
#    res=issimple(i)
#    if res is not None:
#        #print(res)
#        summ+=res
#    if i%100000==0:
#        print(i)
#    i+=1
#print(res,summ,)
#i=2
#while i<200:
#    issimple(i)
#    i+=1
#


