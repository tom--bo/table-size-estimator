#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdbool.h>

#define MAXCOLS 100
#define MAXIDXS 100

// define column node
typedef struct _col {
    char *name;
    char *coltype;
    long maxSize;
    long aveSize;
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
    char *idxType;
    long maxSize;
    long aveSize;
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

bool isVarLen(char *str) {
    if(!strncmp(str,"varvinary",strlen(str))
        || !strncmp(str,"tinyblob",strlen(str))
        || !strncmp(str,"blob",strlen(str))
        || !strncmp(str,"mediumblob",strlen(str))
        || !strncmp(str,"longblob",strlen(str))
        || !strncmp(str,"varchar",strlen(str))
        || !strncmp(str,"tinytext",strlen(str))
        || !strncmp(str,"text",strlen(str))
        || !strncmp(str,"mediumtext",strlen(str))
        || !strncmp(str,"longtext",strlen(str))
    ) {
        return true;
    }
    return false;
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
        c.maxSize = calcSize(coltype, opt1, opt2);
    } else {
        c.maxSize = size;
    }

    if(isVarLen(c.coltype)) {
        c.aveSize = c.maxSize / 2;
    } else {
        c.aveSize = c.maxSize;
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
        ii.maxSize = 0;
        ii.aveSize = 0;
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

void setIdxType(char *type) {
    idxs[nowIdx].idxType = type;
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

long getColMaxSizeByName(char *name) {
    for(int i = 0; i < nowCol; i++) {
        if(strcmp(name, cols[i].name) == 0) {
            return cols[i].maxSize;
        }
    }
    return 0;
}

long getColAveSizeByName(char *name) {
    for(int i = 0; i < nowCol; i++) {
        if(strcmp(name, cols[i].name) == 0) {
            return cols[i].aveSize;
        }
    }
    return 0;
}


// print all array contents
void calcTotalSize(bool debug, long *maxSize, long *aveSize) {
    *maxSize = 0;
    *aveSize = 0;
    int pkSize = 0;
    int skCnt = 0;

    if(debug) {
        printf("\n ====== COLUMN ======\n");
    }
    for(int i = 0; i<nowCol; i++) {
        if(debug) {
            printf("------\n");
            printf("Name:    %s\n", cols[i].name);
            printf("Type:    %s\n", cols[i].coltype);
            printf("MaxSize: %ld\n", cols[i].maxSize);
            printf("AveSize: %ld\n", cols[i].aveSize);
            printf("PK? :    %s\n", (cols[i].hasPk ? "true": "false"));
            printf("Index?:  %s\n", (cols[i].hasIdx ? "true": "false"));
            printf("IsNull?: %s\n", (cols[i].isNull ? "true": "false"));
        }
        // PK, SK judge, count
        if(cols[i].hasPk) {
            pkSize = cols[i].maxSize;
        } else if(cols[i].hasIdx) {
            skCnt += 1;
        }
        *maxSize += cols[i].maxSize;
        *aveSize += cols[i].aveSize;
    }
    if(debug) {
        printf("\n ====== INDEX ======\n");
    }
    for(int i = 0; i<nowIdx; i++) {
        for(int j = 0; j<idxs[i].idxColsLen; j++) {
            idxs[i].maxSize += getColMaxSizeByName(idxs[i].idxCols[j].colName);
            idxs[i].aveSize += getColAveSizeByName(idxs[i].idxCols[j].colName);
        }
        *maxSize += idxs[i].maxSize;
        *aveSize += idxs[i].aveSize;
        if(debug) {
            printf("------\n");
            printf("Name:    %s\n", idxs[i].idxName);
            printf("Max Size:    %ld\n", idxs[i].maxSize);
            printf("Ave Size:    %ld\n", idxs[i].aveSize);
        }

        if(strcmp(idxs[i].idxType, "PK") == 0) {
            pkSize = idxs[i].maxSize;
        } else if(strcmp(idxs[i].idxType, "UK") == 0 || strcmp(idxs[i].idxType, "SK") == 0) {
            skCnt += 1;
        }
    }

    // Consider metadata in 1 record
    //   `nowCol` is same as number of column in table
    //   refer https://dev.mysql.com/doc/internals/en/innodb-overview.html
    if(*maxSize <= 127) {
        *maxSize += nowCol * 1 + 6;
        *aveSize += nowCol * 1 + 6;
    } else {
        *maxSize += nowCol * 2 + 6;
        *aveSize += nowCol * 2 + 6;
    }


    // Consider 2nd index pointer for PK
    *maxSize += pkSize * skCnt;
    *aveSize += pkSize * skCnt;
    return;
}

void printResult(long maxSize, long aveSize) {
        printf("------\n");

        printf("1 row max size = %ld bytes ", maxSize);
        if(maxSize >= 1024) {
            printf("(%ld KB)", maxSize/1024);
        }
        printf(".\n");

        printf("1 row Average size = %ld bytes ", aveSize);
        if(maxSize >= 1024) {
            printf("(%ld KB)", aveSize/1024);
        }
        printf(".\n");
}

