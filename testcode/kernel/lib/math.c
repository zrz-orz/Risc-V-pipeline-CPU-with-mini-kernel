#include"math.h"
int int_mod(unsigned int v1,unsigned int v2){
    unsigned long long m1=v1;
    unsigned long long m2=v2;
    m2<<=31;
    while(m1>=v2){
        if(m2<m1){
            m1-=m2;
        }
        m2>>=1;
    }
    return m1;
}

int int_mul(unsigned int v1,unsigned int v2){
    unsigned long long res=0;
    while(v2&&v1){
        if(v2&1){
            res+=v1;
        }
        v2>>=1;
        v1<<=1;
    }
    return res;
}

int int_div(unsigned int v1,unsigned int v2){
    unsigned long long m1=v1;
    unsigned long long m2=v2;
    unsigned long long mask=(unsigned int)1<<31;
    m2<<=31;
    unsigned long long res=0;
    while(m1>=v2){
        if(m2<m1){
            m1-=m2;
            res|=mask;
        }
        m2>>=1;
        mask>>=1;
    }
    return res;
}