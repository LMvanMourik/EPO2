#include "maps.h"
#include "datastructures.h"
map copy_map(map* m){
	map ret;
	genmap(&ret,m->x,m->y);
	for(int i =0; i< m->x; i++){
		for(int j =0; j < m->y; j++){
			ret.cells[i] = m->cells[i];
		}
	}
	return ret;
}


void genmap(map* m,int x, int y){
	m->x = x;
	m->y = y;
	m->gets = 0;
	m->cells = (int**)calloc(x,sizeof(int*));
	for(int i =0; i<=x;i++){
		m->cells[i] = (int*)calloc(y,sizeof(int));
	}
}


void setcellval(map* m, int v,unsigned int x, unsigned int y){
	if (x < 0|| y < 0 || x > m->x || y> m->y || m->cells == NULL){
		return;
	}
	else{
		m->cells[x][y] = v;
	}
	return;
}

int getcellval(map* m, int x, int y){
	m->gets +=1;
	if (x < 0|| y < 0 || x >m->x || y >m->y|| m->cells == NULL){
		return -1;
	}
	else{
		return m -> cells[x][y];
	}
}


void addline(map* m, int v,int t,unsigned int x0, unsigned int y0,unsigned int x1,unsigned int y1){
	int dx = abs(x1-x0);
	int sx = x0 < x1 ? 1:-1;
	int dy = -abs(y1-y0);
	int sy = y0 < y1 ? 1 : -1;
	int err = dx+dy;
	int e2 = 0;
	int s =1;
	while(1){
		setcellval(m,v,x0,y0);
		if(t==1){
			setcellval(m,v,x0+1,y0);
		}
		if(t==2){
			setcellval(m,v,x0+1,y0);
			setcellval(m,v,x0-1,y0);
		}
		if (x0 == x1 && y0 == y1){
			break;
		}
		e2 = 2*err;
		if(e2 >= dy){
			if (x0 == x1){
				break;
			}
			err = err+dy;
			x0+=sx;
		}
		if(e2 <= dx){
			if (y0 == y1){
				break;	
			}
			err = err+dx;
			y0+=sy;	
		}
	}

	
}
void addrect(map* m, int v,int x0, int y0, int x1, int y1){
	int dx = (x1-x0)/abs(x1-x0);
	int dy = (y1-y0)/abs(y1-y0);
	for (int i = y0; i != y1+1; i+=dy){
		for(int j = x0; j !=x1; j+=dx){
			setcellval(m,v,j,i);
		}
	}
	return;
}
void add_grid_pattern(map*m,int s){
	int set =1;
	if (s<1){
		s = 1;
	}
	for(int i =0; i<= m->y;i++){
		for(int j =0; j<= m->x;j++){
			setcellval(m,set,j,i);
			if (j%s ==0){
				set*=-1;
			}
		}
	}
	clear_map(m);
}

void genmaze(map* m){
	genmap(m,12,12);
	addrect(m, -1 , 0, 0, 13,13);
	for(int i = 0; i < 3; i++){
		addline(m,0,0,4+i*2,0,4+i*2,12);
		addline(m,0,0,0,4+i*2,12,4+i*2);
	}
	addline(m,0,0, 2, 2, 2,10);	        
	addline(m,0,0, 2, 2,10, 2);		
	addline(m,0,0,2,10, 10,10);			        
	addline(m,0,0,10,2,10,10);
}

void clear_map(map* m){
	for(int i = m->y; i >=0; i--){
		for(int j = 0; j <=m->x; j++){
			if(m->cells[j][i] != -1 && m->cells[j][i] != 0){
				m->cells[j][i] = 0;
			}
		}
	}
	m->gets = 0;
}

int calc_dist_m(int x0, int y0, int x1, int y1){
	return (abs(x0-x1)+abs(y0-y1));
}

void gen_random_maze(map* m,int x,int y,int n,int d,int c){
	genmap(m,x,y);
	int** points;
	bool p;
	int picked =0;
	int dist =0;
	heap h = h_init(100);
	h_node tmp;
	n+=2;
	srand(time(0));
	addrect(m,-1,0,0,x+1,y+1);
	add_grid_pattern(m,rand()% (m->x/10 + 1));
	points = (int**)calloc(n,sizeof(int*));
	for(int i = 0; i <=n; i++){
		points[i] = (int*)calloc(1,sizeof(int*));
	}
	//set start coordinates and end coordinates
	points[0][0] = 0;
	points[0][1] = 0;
	points[1][0] = x;
	points[1][1] = y;
	
	//get random values for points,make sure they have at least d distance between them
	for(int i = 2; i <=n; i++){
		while(1){
			points[i][0] = (rand() % (x + 1));
			points[i][1] = (rand() % (y+ 1));
			p =false;
			for (int j =0; j<i; j++){
				dist = calc_dist_m(points[j][0],points[j][1],points[i][0],points[i][1]);
				if(dist>=d){
					p =true;
					break;
				}
			}
			if(p){
				break;
			}
		}
	}
	for(int i =0; i <2; i++){
		for(int j =2;  j<n; j++){
			//printf("%d\n",points[0][0]);
			dist = calc_dist_m(points[i][0],points[i][1],points[j][0],points[j][1]);
			h_insert(&h,dist,points[j][0],points[j][1]);
		}
		
		tmp = h_pop_min(&h);
		//printf("%d\n",points[0][0]);
		addline(m,0,1,points[i][0],points[i][1],tmp.x,tmp.y);
		
		while (!(h_is_empty(&h))){
			h_pop_min(&h);
		}
	}
	
	for(int i =2; i<=n; i++){
		for(int j =0;  j<c; j++){
			picked = (rand() % (n - 2 + 1)) + 2;
			addline(m,0,1,points[i][0],points[i][1],points[picked][0],points[picked][1]);
		}
	}
	/*
	delete_heap(&h);
	for(int i =0; i<=n; i++){
		free(points[i]);
	}
	free(points);
	*/
}

void printmap(map* m){
	for(int i = m->y; i >=0; i--){
		printf("%d\t ", i);
		for(int j = 0; j <=m->x; j++){
			if( m->cells[j][i] == -1){
				printf("%*s",3,"#");
			}
			else if( m->cells[j][i] == 0){
				printf("%*s",3," ");
			}
			else{
			printf ("%*d",3, m->cells[j][i]);
			}
		}
		printf("\n");
	}
	printf("\n\t ");
	for(int i = 0; i <= m->x; i++){
		printf("%*d",3,i);
	}
	//printf("\n%d \n", m->gets);
	printf("\n\n");
}


void deletemap(map* m){
	for(int i =0; i<=m->x; i++){
		free(m->cells[i]);
	}
	free(m->cells);

}

