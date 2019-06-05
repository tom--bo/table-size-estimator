#ifndef TABLE_SIZE_ESTIMATOR_CALC_H
#define TABLE_SIZE_ESTIMATOR_CALC_H

#include <string.h>
#include <stdbool.h>

void resetOpt();
void newCol(char *coltype, long size);
void addColName(char *name);
void addIdxCol(char *name, char *s, char *isAsc);
void addIdxName(char *name);
void incNowCol();
void incNowIdx();
void iniNowIdxCol();
void setColsNull(bool b);
void setHasIdx(bool b);
void setHasPk(bool b);
void setOpt1(long l);
void setOpt2(long l);

bool isVarLen(char *str);
long atolong(char *str);
char *extractBackQuote(char *s);
long getColSizeByName(char *name);
long calcSize(char *str, int opt1, int opt2);
void calcTotalSize(bool debug, long *maxSize, long *aveSize);
void printResult(long maxSize, long aveSize);

#endif //TABLE_SIZE_ESTIMATOR_CALC_H
