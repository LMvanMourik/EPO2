#ifndef __DATASTRUCTURES_H_INCLUDED__
#define __DATASTRUCTURES_H_INCLUDED_

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <math.h>

typedef struct node{	
	struct node* right; //next
	struct node* left; //prev
	int v; //value 
	int k; //key
} node;

typedef struct{
	node* head;	
	node* tail;
} dll; //doubly linked list

typedef struct{
	dll q;
} queue;

typedef struct{
	int v;
	int x;
	int y;
}h_node;

typedef struct{
	h_node* data;
	int size; //size of available memory
	int used; //size of memory used
} heap; //binary heap

dll dll_init();
void dll_push(dll* d, int v);
void dll_insert(dll* d, int l, int v);
void dll_append(dll*d, int v);

int dll_remove_node();
int dll_pop(dll* d);
int dll_get_val(dll* d, int l);
int dll_get_length(dll*d);

bool dll_is_empty(dll *d);

void print_dll(dll* d);
void delete_dll(dll*d);

queue q_init();
void q_enqueue(queue* q, int v);
int q_dequeue(queue* q);
int q_front(queue* q);
int q_rear(queue* q);
bool q_is_empty(queue *q);

void print_queue(queue* q);
void delete_queue(queue*q);

heap h_init(int size);
bool h_is_empty(heap* h);
void h_insert(heap* h, int v, int x, int y);
h_node h_pop_min(heap* h);
bool h_contains(heap* h,int x, int y);
void print_h(heap* h);
void delete_heap(heap* h);
#endif
