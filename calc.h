#ifndef TABLE_SIZE_ESTIMATOR_CALC_H
#define TABLE_SIZE_ESTIMATOR_CALC_H

#include <string.h>
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


long atolong(char *str);
long calcSize(char *str, int opt1, int opt2);

#endif //TABLE_SIZE_ESTIMATOR_CALC_H
