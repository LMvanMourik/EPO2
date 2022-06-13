#ifndef __MAPS_H_INCLUDED__
#define __MAPS_H_INCLUDED__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <stdbool.h>

typedef struct{
        unsigned int x;
	unsigned int y;
	int** cells;
	int gets;
} map;

void genmap(map* m,int x,int y);
void setcellval(map* m,int v,unsigned int x,unsigned int y);
int getcellval(map* m,int x,int y);
void addline(map* m,int v,int t,unsigned int x0,unsigned int y0,unsigned int x1,unsigned int y1);
void addrect(map* m,int v,int x0,int y0,int x1,int y1);

void genmaze(map* m);
void clear_map(map* m);
void gen_random_maze(map* m,int x,int y,int n,int d,int c);
void printmap(map* m);
void deletemap(map* m);

#endif
