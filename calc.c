#include <string.h>

long atoi(char *str) {
    long ans = 0;
    int len = strlen(str);
    int i;
    long j = 1;
    for(i = len-1; i>=0; i--) {
        ans += (str[i] - '0') * j;
        j *= 10;
    }
    return ans;
}

long calcSize(char *str, int opt1, int opt2) {
    long ret = 0;
    if(!strncmp(str,"dec",strlen(str)) || !strncmp(str,"decimal",strlen(str)) || !strncmp(str,"numeric",strlen(str))) {
        long intpart = opt1 - opt2;
        long fracpart = opt2;

        ret += (intpart/9)*4 + (fracpart/9)*4;
        int rem1 = intpart%9;
        int rem2 = fracpart%9;
        ret += (rem1+1)/2 + (rem2+1)/2;
    } else if(!strncmp(str,"float",strlen(str))) {
        if(opt1 <= 24) {
            ret = 4;
        } else {
            ret = 8;
        }
    } else if(!strncmp(str,"bit",strlen(str))) {
        ret = (opt1+7)/8;
    } else if(!strncmp(str,"datetime",strlen(str))) {
        ret = 5;
        if(opt1 != -1) {
            ret += opt1 / 2;
        }
    } else if(!strncmp(str,"timestamp",strlen(str))) {
        ret = 4;
        if(opt1 != -1) {
            ret += opt1 / 2;
        }
    } else if(!strncmp(str,"time",strlen(str))) {
        ret = 3;
        if(opt1 != -1) {
            ret += opt1 / 2;
        }
    } else if(!strncmp(str,"blob",strlen(str))) {
        ret = 65537;
        if(opt1 != -1) {
            ret = opt1;
        }
    } else if(!strncmp(str,"char",strlen(str))) {
        ret = opt1 * 4;
    } else if(!strncmp(str,"varchar",strlen(str))) {
        if(opt1 * 4 < 255) {
            ret = opt1 * 4 + 1;
        } else {
            ret = opt1 * 4 + 2;
        }
    } else if(!strncmp(str,"binary",strlen(str))) {
        ret = opt1;
    } else if(!strncmp(str,"varbinary",strlen(str))) {
        if(opt1 < 255) {
            ret = opt1 + 1;
        } else {
            ret = opt1 + 2;
        }
    } else if(!strncmp(str,"text",strlen(str))) {
        ret = 65535+3;
        if(opt1 != -1) {
            ret = opt1*4+3;
        }
    }
    return ret;
}
