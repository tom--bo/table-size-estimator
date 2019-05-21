#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>

const int MAXCOLS = 100;
const int MAXIDXS = 100;

// define column node
typedef struct _col {
    char *name;
    char *coltype;
    long size;
    bool hasIdx;
    bool hasPk;
    bool isNull;
} col;

// define cols in index
typedef struct _idxCol {
    char *colName;
    long prefixSize;
    bool isAsc;
} idxCol;

// define index node
typedef struct _idx {
    char *idxName;
    long size;
    int idxColsLen;
    idxCol idxCols[MAXCOLS];
} idx;

// define nodes array
col cols[MAXCOLS] = {};
idx idxs[MAXIDXS] = {};

int nowCol = 0;
int nowIdx = 0;
int nowIdxCol = 0;

long opt1 = -1;
long opt2 = -1;

void resetOpt() {
    opt1 = -1;
    opt2 = -1;
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

// extract `` quote from name if exists
char *extractBackQuote(char *s) {
    if(s[0] == '`' && s[strlen(s)-1] == '`') {
        long l = strlen(s);
        char *t = (char*)malloc(sizeof(char)*(l-1));;
        strncpy(t, s+1, l-2);
        t[l-2] = '\0';
        return t;
    }
    return s;
}

long atolong(char *str) {
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

void newCol(char *coltype, long size) {
    col c;
    c.name = "";
    c.coltype = coltype;
    c.hasPk = false;
    c.hasIdx = false;
    c.isNull = false;

    if(size == -1) {
        c.size = calcSize(coltype, opt1, opt2);
    } else {
        c.size = size;
    }

    cols[nowCol] = c;

    return;
}

void addColName(char *name) {
    cols[nowCol].name = extractBackQuote(name);
}

void addIdxCol(char *name, char *s, char *isAsc) {
    if(nowIdxCol == 0) {
        idx ii;
        ii.size = 0;
        idxs[nowIdx] = ii;
    }
    idxCol ic;
    ic.prefixSize = atolong(s);
    ic.colName = extractBackQuote(name);
    ic.prefixSize = atolong(s);
    ic.isAsc = (strcmp(isAsc, "asc")) == 0 ? true:false;

    idxs[nowIdx].idxCols[nowIdxCol] = ic;
    nowIdxCol += 1;
    idxs[nowIdx].idxColsLen = nowIdxCol;
}

void addIdxName(char *name) {
    idxs[nowIdx].idxName = extractBackQuote(name);
}

void incNowCol() {
    nowCol += 1;
}

void incNowIdx() {
    nowIdx += 1;
}

void iniNowIdxCol() {
    nowIdxCol = 0;
}

void setColsNull(bool b) {
    cols[nowCol].isNull = b;
}

void setHasIdx(bool b) {
    cols[nowCol].hasIdx = b;
}

void setHasPk(bool b) {
    cols[nowCol].hasPk = b;
}

void setOpt1(long l) {
    opt1 = l;
}

void setOpt2(long l) {
    opt2 = l;
}




// -----------

long getColSizeByName(char *name) {
    for(int i = 0; i < nowCol; i++) {
        if(strcmp(name, cols[i].name) == 0) {
            return cols[i].size;
        }
    }
    return 0;
}

// print all array contents
long calcTotalSize(bool debug) {
    long sum = 0;
    if(debug) {
        printf("\n ====== COLUMN ======\n");
    }
    for(int i = 0; i<nowCol; i++) {
        if(debug) {
            printf("------\n");
            printf("Name:    %s\n", cols[i].name);
            printf("Type:    %s\n", cols[i].coltype);
            printf("Size:    %ld\n", cols[i].size);
            printf("PK? :    %s\n", (cols[i].hasPk ? "true": "false"));
            printf("Index?:  %s\n", (cols[i].hasIdx ? "true": "false"));
            printf("IsNull?: %s\n", (cols[i].isNull ? "true": "false"));
        }
        sum += cols[i].size;
    }
    if(debug) {
        printf("\n ====== INDEX ======\n");
    }
    for(int i = 0; i<nowIdx; i++) {
        for(int j = 0; j<idxs[i].idxColsLen; j++) {
            printf("colName: %s\n", idxs[i].idxCols[j].colName);
            idxs[i].size += getColSizeByName(idxs[i].idxCols[j].colName);
        }
        sum += idxs[i].size;
        if(debug) {
            printf("------\n");
            printf("Name:    %s\n", idxs[i].idxName);
            printf("Size:    %ld\n", idxs[i].size);
        }
    }
    return sum;
}

