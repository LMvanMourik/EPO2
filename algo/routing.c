#include "maps.h"
#include "datastructures.h"
#include <time.h>


int lee(map* m, int sx, int sy, int ex, int ey){
	int dy[] = {-1, 0, 1, 0};
	int dx[] = {0, 1, 0, -1};
	int cx,cy;
	int w =1;
	if (getcellval(m,sx,sy) == -1 || getcellval(m,ex,ey) == -1){
		return -1;
	}
	queue qx = q_init();
	queue qy = q_init();
	q_enqueue(&qx,sx);
	q_enqueue(&qy,sy);
	setcellval(m,w,sx,sy);
	while(!(q_is_empty(&qx))){
		cx = q_front(&qx);
		cy = q_front(&qy);
		w = getcellval(m,cx,cy) +1;
		for(int i = 0; i < 4; i++){
			if(getcellval(m,cx+dx[i],cy+dy[i]) == 0){
				q_enqueue(&qx,cx+dx[i]);
				q_enqueue(&qy,cy+dy[i]);
				setcellval(m,w,cx+dx[i],cy+dy[i]);
			}
		}
		q_dequeue(&qx);
		q_dequeue(&qy);

	}
	if(getcellval(m,ex,ey) == 0){
		return -1;
	}
}

int mh_lee(map* m, int sx, int sy, int ex, int ey){ // lee but uses a minheap instead of a queue
	int dy[] = {-1, 0, 1, 0};
	int dx[] = {0, 1, 0, -1};
	int cx,cy;
	h_node curr;
	int w =1;
	if (getcellval(m,sx,sy) == -1 || getcellval(m,ex,ey) == -1){
		return -1;	
	}
	heap h = h_init(100);
	h_insert(&h,0,sx,sy);
	setcellval(m,w,sx,sy);
	while(!(h_is_empty(&h))){
		curr = h_pop_min(&h);
		cx = curr.x;
		cy = curr.y;
		w = getcellval(m,cx,cy) +1;
		if((cx+cy)-(ex+ey) ==0){
			setcellval(m,w,cx,cy);
			break;
		};
		for(int i = 0; i < 4; i++){
			if(getcellval(m,cx+dx[i],cy+dy[i]) == 0){
				h_insert(&h,w,cx+dx[i],cy+dy[i]);
				setcellval(m,w,cx+dx[i],cy+dy[i]);	
			}	
		}
	}
	if(getcellval(m,ex,ey) == 0){	
		return -1;	
	}
	delete_heap(&h);
}


dll* back_track(map*m, int x, int y){
	int dy[] = {-1, 0, 1, 0};
	int dx[] = {0, 1, 0, -1};
	dll* ret;
	int s = getcellval(m,x,y);
	int c = s;
	int cr;
	ret = (dll*)malloc(2*sizeof(dll));
	ret[0] = dll_init();
	ret[1] = dll_init();
	dll_push(&ret[0], x);
	dll_push(&ret[1], y);
	for(int i = 0; i<s; i++){
		for(int j = 0; j <4; j++){
			cr = getcellval(m, x+dx[j],y+dy[j]);
			if(cr!= -1 && cr < c ){
				dll_push(&ret[0], x+dx[j]);
				dll_push(&ret[1], y+dy[j]);
				c--;
				x +=dx[j];
				y +=dy[j];
				break;
			}
		}
	}
	return ret;
}


int calc_dist(int x0, int y0, int x1, int y1){
	int dx = abs(x0-x1);
	int dy = abs(y0-y1);
//	printf("%d|%d|%d|%d|%d|%d\n", x0,y0,x1,y1,dx,dy);
	return dy+dx;
}

int dfs (map* m, int sx, int sy, int ex, int ey){		
	int dy[] = {-1, 0, 1, 0};
	int dx[] = {0, 1, 0, -1};
	int dist = 0;
	int ndist =0;
	int cx,cy,nx,ny,cv;
	int c_lim = m->x*m->y;
	int l = 0;
	int set = 1;
	nx = sx;
	ny = sy;
	//add cycle limit
	while(getcellval(m,ex,ey) == 0){
		dist = m->x*m->y*2;
		cx = nx;
		cy = ny;
		if (getcellval(m,cx,cy) == 2){
			l = 1;
			set = 2;
		}
		for(int i = 0; i < 4; i++){
			ndist = calc_dist(cx+dx[i],cy+dy[i], ex, ey);
			cv = getcellval(m,cx+dx[i],cy+dy[i]);
			if (cv == l){ 
				if(dist > ndist){
					nx = cx+dx[i];
					ny = cy+dy[i];
					dist = ndist;
				}
			}
		}
		setcellval(m,set,cx,cy);
		if (nx == cx && ny == cy){
			setcellval(m,2,nx,ny);
		}
		l = 0;
		set = 1;
		//printmap(m);
		//printf("%d , %d\n", nx, ny);
		c_lim--;
		if(c_lim <0){
			return -1;
			break;
		}
	}	
	setcellval(m,1,ex,ey);	
	return 0;
}

		
		
		
		


int gbfs (map* m, int sx, int sy, int ex, int ey){

	int dy[] = {-1, 0, 1, 0};
	int dx[] = {0, 1, 0, -1};

	heap openset = h_init(m->x*m->y);
	h_node curr;
	int dist = 0;

	if (getcellval(m,sx,sy) == -1 || getcellval(m,ex,ey) == -1){
		return -1;
		
	}
	if ((sx-ex)+(sy-ey) == 0){
		return -1;
	}

	h_insert(&openset,0, sx, sy);
	int p = 0;	
	int set = 1;
	setcellval(m,1,sx,sy);
	int f, fn;
	int g,gn;
	int s =0;
	while (!(h_is_empty(&openset))){
		curr = h_pop_min(&openset);
		if(curr.x == ex & curr.y == ey){
			break;
		}
		for(int i =0; i<4; i++){
			if(getcellval(m,curr.x+dx[i],curr.y+dy[i])==0){
				g = calc_dist(curr.x,curr.y,sx,sy)+1;
				gn = calc_dist(curr.x+dx[i],curr.y+dy[i],sx,sy);
				set = getcellval(m,curr.x, curr.y);				
				if(g >=gn ){  // if distance from start is shorter or equal to distance from the current point +1 , store it
					//sort stored node based on distance to end pointt
					h_insert(&openset,calc_dist(curr.x+dx[i],curr.y+dy[i],ex,ey),curr.x+dx[i],curr.y+dy[i]);
					setcellval(m,set+1,curr.x+dx[i],curr.y+dy[i]);
				}
				else{ 
					setcellval(m,(set+1)*-1,curr.x+dx[i],curr.y+dy[i]);
				}
			}
		}
	}
	delete_heap(&openset); //clear up memory
	if(getcellval(m, ex,ey ==0)){
			return -1;
	}
	return 0;
	}

double** benchmark(int(*f)(map*, int,int,int,int)){
	clock_t start,end;
	double** results;
	double res;
	double g;
	double l;
	map** maps; //generate 30*10 maps from size 10 to size 40
	maps = (map**)calloc(30,sizeof(map*));
	results = (double**)calloc(30,sizeof(double*));
	for(int i =0; i <= 30; i++){
		maps[i] = (map*)calloc(10,sizeof(map));		
		results[i] = (double*)calloc(3,sizeof(double));
	}
	
	for(int i =0; i <=30; i++){
		for(int j=0; j <= 10; j++){
			gen_random_maze(&maps[i][j], 10+i,10+i, (10+i)/3, (10+i)/4,2);
		}
	}
	res =0;
	g =0;
	l =0;
	for(int i =0; i <=30; i++){
		for(int j=0; j <= 10; j++){
			start = clock();
			(*f)(&maps[i][j],0,0,10+i,10+i);
			end = clock();
			res += ((double) (end - start)) / CLOCKS_PER_SEC;
			g += maps[i][j].gets;
			l += getcellval(&maps[i][j],10+i,10+i);
		}
		results[i][0] = 10+i;
		results[i][1] = res/11;
		results[i][2] = g/11;
		results[i][3] = l/11;
	}
	//generate new ones if not,repeat till they are
	//generate all permutations of mine placements in the maze, don't test for traversability
	//test and time algos and test if paths are optimal
	//return times and number of gets and sets
	return results;
}

void print_path(map *m, dll* path){
	clear_map(m);
	int s = dll_get_length(&path[0]);
	int x,y;
	for(int i = 0; i < s; i++){
		x = dll_get_val(&path[0],i);
		y = dll_get_val(&path[1],i);
		setcellval(m,1,x,y);
	}
	printmap(m);
	clear_map(m);
}


int main(){
	double** res;
	res = benchmark(&mh_lee);	
	//store res in a csv file
}


