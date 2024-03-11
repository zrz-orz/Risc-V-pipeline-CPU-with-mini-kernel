import struct
class Compress_elf:
    def __init__(self,filename,hexfilename,binfilename):
        self.filename=filename
        self.hexfilename=hexfilename
        self.binfilename=binfilename
        file=open(filename,"rt")
        self.textlines=file.readlines()
        for i in range(len(self.textlines)):
            self.textlines[i]=self.textlines[i].strip()
        file.close()

    def compress(self):
        self.segment=0
        self.writecode=[]
        self.index=0
        self.addr=0x80000000
        while self.index<len(self.textlines):
            self.get_segment()
        self.writecode.insert(0,self.segment)
        if(len(self.writecode)%2!=0):
            self.writecode.append(0)
        
        file=open(self.hexfilename,"wt")
        file.write("@00000000\n")
        for code in self.writecode:
            textline="%016X"%code+'\n'
            file.write(textline)
        file.close()

        file=open(self.binfilename,"wb")
        for writecode in self.writecode:
            file.write(struct.pack('Q',writecode))
        file.close()

    def get_segment(self):
        self.segment+=1
        base=self.addr
        binary=[]
        while(self.index<len(self.textlines)):
            textline=self.textlines[self.index]
            text=textline.split()
            if(len(text)==1):
                text.append("0000000000000000")
            data1=int(text[0],16)
            data2=int(text[1],16)
            if(data1==0 and data2==0):
                break
            else:
                binary.append(data1)
                binary.append(data2)
                self.addr+=16
                self.index+=1
        while(self.index<len(self.textlines)):
            textline=self.textlines[self.index]
            text=textline.split()
            if(len(text)==1):
                text.append("0000000000000000")
            data1=int(text[0],16)
            data2=int(text[1],16)
            if(data1!=0 or data2!=0):
                break
            else:
                self.addr+=16
                self.index+=1
        
        length=len(binary)
        self.writecode.append(base)
        self.writecode.append(length)
        self.writecode.extend(binary)

compress=Compress_elf("mini_sbi.hex","elf.hex","elf.bin")
compress.compress()