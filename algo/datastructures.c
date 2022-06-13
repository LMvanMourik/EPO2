#include "datastructures.h"

dll dll_init(){
	dll d;
	d.head = NULL;
	d.tail = NULL;
	return d;
}
void dll_push(dll* d, int v){
	node *n = (node*)malloc(sizeof(node));
	n->v = v;
	n->k = 0;
	if(!(d->head)){
		n->left = NULL;
		n->right = NULL;
		d->head = n;
		d->tail = n;
	}else{
		n->left = NULL;						                
		n->right = d->head;
		d->head->left = n;
		d->head = n;
	}
	return;
}

void dll_insert(dll* d, int l, int v){ //insert before
	node *n = (node*)malloc(sizeof(node));
	n->v = v;
	n->k = 0;  
	node*c = d->head;
	if(!(d->head)){
		n->left = NULL;
		n->right = NULL;							               	  
		d->head = n;
		d->tail = n;
	}else{
		for(int i =0; i != l; i++){
			c = c -> right;
			if (c== NULL){
				return;
			}
		}
		c->left->right = n;
		n->left = c->left;
		c->left =n;		
		n->right = c;
	}
}
void dll_append(dll*d, int v){	
	node *n = (node*)malloc(sizeof(node));
	n->v = v;
	n->k = 0;
	node*c = d->head;
	if(!(d->head)){
		n->left = NULL;
		n->right = NULL;
		d->head = n;
		d->tail = n;
	}else{
		n->right = NULL;	
		d->tail->right = n;
		n->left = d->tail;
		d->tail = n;
	}
}

int dll_remove_node(){}

int dll_pop(dll* d){
	int ret = 0;
	node* tmp = NULL;
	if((d->head)){
		if (d->tail == d->head){
			ret = d->tail->v;
			free(d->head);
			d->head = NULL;
			d->tail = NULL;
		}else{
			ret = d->tail->v;
			tmp = d->tail->left;
			free(d->tail);
			d->tail = NULL;
			d->tail = tmp;
			d->tail->right = NULL;
		}
	}
	return ret;
}

int dll_get_val(dll* d, int l){
	int i =0;
	node *c = d->head;
	while(c!= NULL){
		if(i == l){
			break;
		}
		if (c == NULL){
			return -1;
			break;	
		}	
		i++;
		c = c->right;
	}
	return c->v;
}


int dll_get_length(dll* d){
	int ret = 0;
	node *c = d->head;
        while(c!= NULL){
		ret++;
		c = c-> right;
		if (c == NULL){
			break;
		}
	}
	return ret;
}

int* dll_to_arr(dll* d){
}

bool dll_is_empty(dll *d){
	if(!(d-> head)){
		return true;
	}
	return false;
}

void print_dll(dll* d){
	node *c = d->head;
	while(c!= NULL){	
		printf("%d ", c->v);
		c = c-> right;
		if (c == NULL){
			break;
		}
	}	
	printf("\n");
}
void delete_dll(dll* d){
	while(d->head != NULL){
		dll_pop(d);
	}
}

queue q_init(){
	queue q;
	q.q = dll_init();
	return q;
}

void q_enqueue(queue* q, int v){
	dll_push(&(q->q),v);
}
int q_dequeue(queue* q){
	dll_pop(&(q->q));
}

int q_front(queue* q){
	return q->q.tail->v;
}

bool q_is_empty(queue* q){
	return dll_is_empty(&(q->q));
}

void print_queue(queue* q){
	print_dll(&(q->q));
}

void delete_queue(queue* q){
	delete_dll(&(q->q));
}

void swap(h_node *x, h_node *y){
	h_node temp = *x;
	*x = *y;
	*y = temp;
}

heap h_init(int size){
	heap h;
	h.size = size;
	h.used = 0;
	h.data = (h_node*)malloc(size*sizeof(h_node*));
	return h;
}

bool h_is_empty(heap* h){
	if(h->used == 0){
		return true;
	}
	return false;
}

int h_parent(int i){ 
	return (i-1)/2; 
}

int h_left(int i){ 
	return (2*i + 1); 
}
int h_right(int i){ 
	return (2*i + 2); 
}

void h_min_heapify(heap* h, int i){
	int l = h_left(i);
	int r = h_right(i);
	int min;
	int temp;

	if(l >= h->used|| l<0){
		l = -1;
	}	
	if(r>= h->used || r <0){
		r = -1;
	}
	if(l!= -1 && h->data[l].v < h->data[i].v){
		min=l;
	}
	else{
	min = i;
	}	
	if(r != -1 && h->data[r].v < h->data[min].v){
		min = r;
	}
	if(min != i){
		swap(&h->data[min],&h->data[i]);
		h_min_heapify(h, min);
	}
	 
}



void h_insert(heap* h, int v, int x, int y){
	h_node* tmp;
	if(h->used == h->size){
		h->size*=2;
		tmp = (h_node*)malloc(h->size*sizeof(h_node));
		for(int i =0; i<=h->used; i++){
			tmp[i].v = h->data[i].v;
			tmp[i].x = h->data[i].x;
			tmp[i].y = h->data[i].y;
		}
		free(h->data);
		h->data = tmp;
	}
	h->data[h->used].v = v;
	h->data[h->used].x = x;
	h->data[h->used].y = y;
	int i = h->used;
	while (i != 0 && h->data[h_parent(i)].v > h->data[i].v){
		swap(&h->data[i], &h->data[h_parent(i)]);
		i = h_parent(i);
	}
	h->used++;
}

h_node h_pop_min(heap* h){
	h_node ret;
	ret.v =-1;
	ret.x =-1;
	ret.y =-1;
	if(h->used == 0){
		return ret;
	}
	ret = h->data[0];
	h->data[0] = h->data[h->used-1];
	h->used--;
	h_min_heapify(h,0);
	return ret;

}

bool h_contains(heap* h,int x, int y){
	h_node curr;
	for(int i =0; i<= h->used; i++){
		curr = h->data[i];
		if(curr.x-x + curr.y-y == 0){
			return true;
		}
	}
	return false;
}

void print_h(heap* h){
	int t = 1;
	if (h->used<0){
		return;
	}
	printf("size:%d\n",h->size);
	for(int i = 0 ; i< h->used; i++){
		printf("(%d,%d,%d)",h->data[i].v,h->data[i].x,h->data[i].y);
	}
	printf("\n");
}
void delete_heap(heap* h){
	free(h->data);
	h->data = NULL; 
}
