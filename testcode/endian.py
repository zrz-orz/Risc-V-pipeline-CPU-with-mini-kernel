import sys
filename=sys.argv[1]
fread=open(filename,"rt")
codes=fread.readlines()
fread.close()

code_new=[]
for code in codes:
    if code[0]=='@':
        num=int(code[1:],base=16)
        num=num//8
        num=hex(num)[2:]
        num='0'*(8-len(num))+num
        code_new.append('@'+num+'\n')
    else:
        code=list(code.strip().split(' '))
        c_new=[]
        for c in code:
            l=[c[i:i+2] for i in range(0,len(c),2)]
            l.reverse()
            newstr=''.join(l)
            c_new.append(newstr)
        newcode=' '.join(c_new)+'\n'
        code_new.append(newcode)

fwrite=open(filename,"wt")
fwrite.writelines(code_new)
fwrite.close()

