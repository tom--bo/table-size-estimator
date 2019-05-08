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

// define index node
typedef struct _idx {
    char *idxname;
    long size;
    int colId[MAXCOLS];
} idx;

long atoi(char *str);
long calcSize(char *str, int opt1, int opt2);

#endif //TABLE_SIZE_ESTIMATOR_CALC_H
