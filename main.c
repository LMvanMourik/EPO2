#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma ide diagnostic ignored "cert-err34-c"
#pragma clang diagnostic pop

#include <stdio.h>
#include <stdlib.h>
#include <Windows.h>
#include <string.h>

#define COMPORT "COM4"
#define BAUDRATE CBR_9600


char flipdir(char dir){
    if (dir=='N'){
        return('S');
    } else
    if (dir=='S'){
        return('N');
    } else
    if (dir=='E'){
        return('W');
    } else
    if (dir=='W'){
        return('E');
    } else return(0);
}

/* Print function for the maze */
void printMaze(int maze[13][13])
{
    int i,y;
    for(i=0;i<13;i++){
        for(y=0;y<13;y++){
            printf("%3d ",maze[i][y]);
        }
        printf("\n\n");
    }
}

void initSio(HANDLE hSerial){

    COMMTIMEOUTS timeouts ={0};
    DCB dcbSerialParams = {0};

    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

    if (!GetCommState(hSerial, &dcbSerialParams)) {
        printf(" Error getting state \n");
    }

    dcbSerialParams.BaudRate = BAUDRATE;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity   = NOPARITY;

    if(!SetCommState(hSerial, &dcbSerialParams)){
        printf(" Error setting state \n");
    }

    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;

    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;

    if(!SetCommTimeouts(hSerial, &timeouts)){
        printf(" Error setting timeout state \n");
    }
}

int readByte(HANDLE hSerial, char *buffRead) {

    DWORD dwBytesRead = 0;

    if (!ReadFile(hSerial, buffRead, 1, &dwBytesRead, NULL))
    {
        printf(" Error reading byte from input buffer \n");
    }
    printf(" Byte read from read buffer is: %c \n", buffRead[0]);
    return(0);
}

int writeByte(HANDLE hSerial, char *buffWrite){

    DWORD dwBytesWritten = 0;

    if (!WriteFile(hSerial, buffWrite, 1, &dwBytesWritten, NULL))
    {
        printf(" Error writing byte to output buffer \n");
    }
    printf(" Byte written to write buffer is: %c \n", buffWrite[0]);

    return(0);
}

int main()
{
    /*Helper Variables*/
    int i=0,y=0,x=0,j=0,k=0,l=0,m=0,n=0,r=0,s=0,t=0;
    int xe=0,ye=0;
    int ntot[6], nsmall, ismall;
    int sx[3], sy[3];
    int sxb = 4,syb = 12;
    int path[40] = {0};
    char commands[21] = {'f', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n', 'n'};
    char current_orientation = 0, new_orientation = 0, flipped_orientation = 0;
    char p,q;
    int delta;

    /*Maze Supplements*/
    int NMine,Start,End,ymine,xmine;
    char dir;
    char beginning_orientation[3], end_orientation[3];

    /*Setting the Default Maze*/
    /*Maze[Vertical][Horizontal]*/

    int maze[13][13] =
            {
                    {-1, -1, -1, -1, 0, -1, 0, -1, 0, -1, -1, -1, -1},
                    {-1, -1, -1, -1, 0, -1, 0, -1, 0, -1, -1, -1, -1},
                    {-1, -1, 0,  0,  0, 0,  0, 0,  0, 0,  0,  -1, -1},
                    {-1, -1, 0,  -1, 0, -1, 0, -1, 0, -1, 0,  -1, -1},
                    {0,  0,  0,  0,  0, 0,  0, 0,  0, 0,  0,  0,  0},
                    {-1, -1, 0,  -1, 0, -1, 0, -1, 0, -1, 0,  -1, -1},
                    {0,  0,  0,  0,  0, 0,  0, 0,  0, 0,  0,  0,  0},
                    {-1, -1, 0,  -1, 0, -1, 0, -1, 0, -1, 0,  -1, -1},
                    {0,  0,  0,  0,  0, 0,  0, 0,  0, 0,  0,  0,  0},
                    {-1, -1, 0,  -1, 0, -1, 0, -1, 0, -1, 0,  -1, -1},
                    {-1, -1, 0,  0,  0, 0,  0, 0,  0, 0,  0,  -1, -1},
                    {-1, -1, -1, -1, 0, -1, 0, -1, 0, -1, -1, -1, -1},
                    {-1, -1, -1, -1, 0, -1, 0, -1, 0, -1, -1, -1, -1},
            };

    int templatemaze[13][13]=
            {
                    { -1, -1, -1, -1, 0, -1, 0, -1, 0, -1, -1,-1, -1},
                    { -1, -1, -1, -1, 0, -1, 0, -1, 0, -1, -1, -1, -1},
                    { -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1},
                    { -1, -1, 0, -1, 0, -1, 0, -1, 0, -1, 0, -1, -1},
                    {  0,  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
                    { -1, -1, 0, -1, 0, -1, 0, -1, 0, -1, 0, -1, -1},
                    {  0,  0, 0,  0, 0,  0, 0,  0, 0,  0, 0,  0,  0},
                    { -1, -1, 0, -1, 0, -1, 0, -1, 0, -1, 0, -1, -1},
                    {  0,  0, 0,  0, 0,  0, 0,  0, 0,  0, 0,  0,  0},
                    { -1, -1, 0, -1, 0, -1, 0, -1, 0, -1, 0, -1, -1},
                    { -1, -1, 0, 0, 0, 0, 0, 0, 0, 0, 0, -1, -1},
                    { -1, -1, -1, -1, 0, -1, 0, -1, 0, -1, -1, -1, -1},
                    { -1, -1, -1, -1, 0, -1, 0, -1, 0, -1, -1, -1, -1},
            };

    /* Setting the mines in the maze */
    printf("Number of mines: ");
    scanf("%d",&NMine); /* Scanning number of Mines and their coordinates */
    for(i=0;i<NMine;i++){
        printf("Y of mine %d: ", i);
        scanf("%d",&ymine);
        printf("X of mine %d: ", i);
        scanf("%d",&xmine); /* Scanning location and direction based on Corner[Vert][Hor] encoding */
        printf("Direction mine %d: ", i);
        scanf(" %c",&dir);

        /* Setting offset of the mine according to entered direction */
        switch(dir){
            case 'n':
                x=0;
                y=-1;
                break;
            case 's':
                x=0;
                y=1;
                break;
            case 'e':
                x=1;
                y=0;
                break;
            case 'w':
                x=-1;
                y=0;
                break;
        }
        maze[2+2*ymine+y][2+2*xmine+x] = -1; /* Placing the mine in the maze on the right location */
    }

    /*Scanning the station and changing them from Corner[Vert][Hor] encoding to Grid.
    (Could be done better, but it will work)*/
    for(i=0;i<3;i++){
        printf("Station %d: ",i+1);
        scanf("%d",&Start);
        switch(Start){
            case 1:
                x=4;
                y=12;
                beginning_orientation[i]='N';
                end_orientation[i]='S';
                break;
            case 2:
                x=6;
                y=12;
                beginning_orientation[i]='N';
                end_orientation[i]='S';
                break;
            case 3:
                x=8;
                y=12;
                beginning_orientation[i]='N';
                end_orientation[i]='S';
                break;
            case 4:
                x=12;
                y=8;
                beginning_orientation[i]='W';
                end_orientation[i]='E';
                break;
            case 5:
                x=12;
                y=6;
                beginning_orientation[i]='W';
                end_orientation[i]='E';
                break;
            case 6:
                x=12;
                y=4;
                beginning_orientation[i]='W';
                end_orientation[i]='E';
                break;
            case 7:
                x=8;
                y=0;
                beginning_orientation[i]='S';
                end_orientation[i]='N';
                break;
            case 8:
                x=6;
                y=0;
                beginning_orientation[i]='S';
                end_orientation[i]='N';
                break;
            case 9:
                x=4;
                y=0;
                beginning_orientation[i]='S';
                end_orientation[i]='N';
                break;
            case 10:
                x=0;
                y=4;
                beginning_orientation[i]='E';
                end_orientation[i]='W';
                break;
            case 11:
                x=0;
                y=6;
                beginning_orientation[i]='E';
                end_orientation[i]='W';
                break;
            case 12:
                x=0;
                y=8;
                beginning_orientation[i]='E';
                end_orientation[i]='W';
                break;
        }
        sx[i] = x;
        sy[i] = y;
    }

    /* Going through all the possible combinations of checkpoint orders, the total distance will be compared */
    for(k=0;k<6;k++){
        ntot[k] = 0;
        /*Setting the start-station and end-station for the first checkpoint */
        maze[sy[k/2]][sx[k/2]] = 1; /* Cell at the destination = 1 */
        y = syb;
        x = sxb; /* Set x and y equal to the coordinates of station number 1 (where the robot starts driving) */

        /* Going from the start station through all three checkpoints */
        for(l=0;l<3;l++){
            n = 1;
            /* Lee algorithm expansion */
            while(maze[y][x]==0){
                for(i=0;i<13;i++){
                    for(j=0;j<13;j++){
                        if(maze[i][j]==n){
                            if(maze[i+1][j]==0&&i!=12){
                                maze[i+1][j] = n+1;
                            }
                            if(maze[i-1][j]==0&&i!=0){
                                maze[i-1][j] = n+1;
                            }
                            if(maze[i][j+1]==0&&j!=12){
                                maze[i][j+1] = n+1;
                            }
                            if(maze[i][j-1]==0&&j!=0){
                                maze[i][j-1] = n+1;
                            }
                        }
                    }
                }
                n++; /* This value holds the amount of steps taken in the algorithm = total distance to a certain checkpoint (at the end of the loop) */
            }

            /* Resetting the maze after applying Lee algorithm, for the next iteration of the algorithm */
            for(i=0;i<13;i++){
                for(j=0;j<13;j++){
                    maze[i][j] = templatemaze[i][j];
                }
            }

            /* ntot holds the total distance for each combination of visited checkpoints --> 123, 132, 213, 231, 312, 321 */
            ntot[k] += n;
            /* When we are going to the last checkpoint, we do not need to iterate over the start/end station as this will be the end */
            if(l==2){
                continue;
            }

            /* Setting new start and end station for the checkpoints */
            if(k/2==2){ /* If k = 4 or k = 5 */

                if(k%2==0){ /* k = 4 */
                    y = sy[l];
                    x = sx[l];
                    maze[sy[2-(l*2)]][sx[2-(l*2)]]=1;
                }
                else{ /* k =  5 */
                    y = sy[1-l];
                    x = sx[1-l];
                    maze[sy[2-l]][sx[2-l]]=1;
                }
            }
            else if(k/2==1){ /* Else if k = 2 or k = 3*/
                if(k%2==0){ /* k = 2 */
                    y = sy[0+(2*l)];
                    x = sx[0+(2*l)];
                    maze[sy[1-l]][sx[1-l]]=1;
                }
                else{ /* k = 3 */
                    y = sy[2-(2*l)];
                    x = sx[2-(2*l)];
                    maze[sy[1+l]][sx[1+l]]=1;
                }
            }
            else{ /* Else k = 0 of k = 1 */
                if(k%2==0){ /* k = 0 */
                    y = sy[1+l];
                    x = sx[1+l];
                    maze[sy[l]][sx[l]]=1;
                }
                else{ /* k = 1 */
                    y = sy[2-l];
                    x = sx[2-l];
                    maze[sy[l*2]][sx[l*2]]=1;
                }
            }
        }
    }

    /* Check bij alle verschillende combinaties (6) van volgorde checkpoints de totale lengte (afstand) */
    /* Check all 6 combinations of the checkpoint order, compare the total distance (length) and select the right order */
    nsmall = ntot[0]; /* Set the smallest distance to the first element of the array */
    ismall = 0; /* The index of this value is 0 (first element) */
    for(i=1;i<6;i++){
        if(ntot[i]<nsmall){ /* If the value we iterate over is smaller than the current smallest value, update the smallest value */
            ismall = i;
            nsmall = ntot[i];
        }
    }

    /* Switch statement to put the stations and their begin/end orientation in the right order */
    switch(ismall){
        case 0:
            break;

        case 1:
            x = sx[1];
            y = sy[1];
            sx[1] = sx[2];
            sy[1] = sy[2];
            sx[2] = x;
            sy[2] = y; /* Swap de volgorde van de stations gebaseerd op de totale afstand */

            p=beginning_orientation[1]; /* Swap ook volgorde van de orientaties zodat het overeenkomt met de volgorde van de stations */
            q=end_orientation[1];
            beginning_orientation[1]=beginning_orientation[2];
            end_orientation[1]=end_orientation[2];
            beginning_orientation[2]=p;
            end_orientation[2]=q;
            break;

        case 2:
            x = sx[0];
            y = sy[0];
            sx[0] = sx[1];
            sy[0] = sy[1];
            sx[1] = x;
            sy[1] = y;
            p=beginning_orientation[0];
            q=end_orientation[0];
            beginning_orientation[0]=beginning_orientation[1];
            end_orientation[0]=end_orientation[1];
            beginning_orientation[1]=p;
            end_orientation[1]=q;
            break;

        case 3:
            x = sx[0];
            y = sy[0];
            sx[0] = sx[1];
            sy[0] = sy[1];
            sx[1] = x;
            sy[1] = y;

            p=beginning_orientation[0];
            q=end_orientation[0];
            beginning_orientation[0]=beginning_orientation[1];
            end_orientation[0]=end_orientation[1];
            beginning_orientation[1]=p;
            end_orientation[1]=q;

            x = sx[1];
            y = sy[1];
            sx[1] = sx[2];
            sy[1] = sy[2];
            sx[2] = x;
            sy[2] = y;

            p=beginning_orientation[1];
            q=end_orientation[1];
            beginning_orientation[1]=beginning_orientation[2];
            end_orientation[1]=end_orientation[2];
            beginning_orientation[2]=p;
            end_orientation[2]=q;
            break;

        case 4:
            x = sx[1];
            y = sy[1];
            sx[1] = sx[2];
            sy[1] = sy[2];
            sx[2] = x;
            sy[2] = y;

            p=beginning_orientation[1];
            q=end_orientation[1];
            beginning_orientation[1]=beginning_orientation[2];
            end_orientation[1]=end_orientation[2];
            beginning_orientation[2]=p;
            end_orientation[2]=q;

            x = sx[0];
            y = sy[0];
            sx[0] = sx[1];
            sy[0] = sy[1];
            sx[1] = x;
            sy[1] = y;

            p=beginning_orientation[0];
            q=end_orientation[0];
            beginning_orientation[0]=beginning_orientation[1];
            end_orientation[0]=end_orientation[1];
            beginning_orientation[1]=p;
            end_orientation[1]=q;
            break;

        case 5:
            x = sx[0];
            y = sy[0];
            sx[0] = sx[2];
            sy[0] = sy[2];
            sx[2] = x;
            sy[2] = y;

            p=beginning_orientation[0];
            q=end_orientation[0];
            beginning_orientation[0]=beginning_orientation[2];
            end_orientation[0]=end_orientation[2];
            beginning_orientation[2]=p;
            end_orientation[2]=q;
            break;
    }

    /* Route with the shortest path = for example 1,3,2 */
    s = 0;
    /*Running the algorithm in the quickest order to print the output*/
    for(k=0;k<3;k++){ /* k is hetzelfde als nummer van checkpoint waar we heenwillen */
        /*Maze reset*/
        for(i=0;i<13;i++){
            for(j=0;j<13;j++){
                maze[i][j] = templatemaze[i][j];
            }
        }
        /*Setting Start, End stations*/
        if(k==0){ /* Hier starten we om naar eerste checkpoint te gaan */
            x = sxb;
            y = syb; /* Dit zijn de coordinaten van start = station 1 (4,12) */
        }
        else{ /* Als het niet om de eerste checkpoint gaat... */
            x = sx[k-1];
            y = sy[k-1]; /* Dit zijn de coordinaten van checkpoint k-1 */
        }
        xe = sx[k]; /* Eerste destination x */
        ye = sy[k]; /* Eerste destination y */
        maze[sy[k]][sx[k]] = 1; /* Cell bij die station^ wordt 1 */
        n = 1;

        /*Lee Algorithm*/
        while(maze[y][x]==0){
            for(i=0;i<13;i++){
                for(j=0;j<13;j++){
                    if(maze[i][j]==n){
                        if(maze[i+1][j]==0&&i!=12){
                            maze[i+1][j] = n+1;
                        }
                        if(maze[i-1][j]==0&&i!=0){
                            maze[i-1][j] = n+1;
                        }
                        if(maze[i][j+1]==0&&j!=12){
                            maze[i][j+1] = n+1;
                        }
                        if(maze[i][j-1]==0&&j!=0){
                            maze[i][j-1] = n+1;
                        }
                    }
                }
            }
            n++;
        }

        /*Looping back,see chapter 5.3*/
        path[s]=10*(y/2-1)+x/2-1;
        s++;
        while(maze[y][x]!=1){
            if(maze[y][x]%2!=0 && maze[y][x]!= n && maze[y][x]!= 1){
                path[s] = 10*(y/2-1) + x/2-1;
                s++;
            }

            if(maze[y+1][x]<maze[y][x] && maze[y+1][x]!=-1 && y!=12){
                y++;
                continue;
            }

            if(maze[y-1][x]<maze[y][x] && maze[y-1][x]!=-1 && y!=0){
                y--;
                continue;
            }

            if(maze[y][x+1]<maze[y][x] && maze[y][x+1]!=-1 && x!=12){
                x++;
                continue;
            }

            if(maze[y][x-1]<maze[y][x] && maze[y][x-1]!=-1 && x!=0){
                x--;
                continue;
            }
        }
        path[s]=10*(ye/2-1) + xe/2-1;
        s++;
    }
    path[s] = 99;

    /*for(i=0;i<40;i++){
        printf("%d  ", path[i]);
    }
    printf("\n");*/

    /* Converting path array to command array */
    i = 1;
    r = 0;

    while (path[i+1] != 99) {
        delta = path[i-1] - path[i];
        if (delta == 10){
            current_orientation = 'N';
        } else if (delta == 1) {
            current_orientation = 'W';
        } else if (delta == -1){
            current_orientation = 'E';
        } else if (delta == -10) {
            current_orientation = 'S';
        } else if (delta == 0){
            current_orientation = flipped_orientation;
            i++;
            continue;
        }

        delta = path [i] - path [i+1];
        if (delta == 10){
            new_orientation = 'N';
        } else if (delta ==1) {
            new_orientation = 'W';
        } else if (delta == -1){
            new_orientation = 'E';
        } else if (delta == -10) {
            new_orientation = 'S';
        } else if (delta == 0){
            commands[r] = 'u';
            r++;
            i++;
            flipped_orientation = flipdir(current_orientation);
            continue;
        }

        if ((current_orientation == 'N') && (new_orientation == 'W')){
            commands[r] = 'l';
        } else if (current_orientation == 'N' && new_orientation == 'E'){
            commands[r] = 'r';
        } else if (current_orientation == 'N' && new_orientation == 'N'){
            commands[r] = 'f';
        } else if (current_orientation == 'E' && new_orientation == 'N'){
            commands[r] = 'l';
        } else if (current_orientation == 'E' && new_orientation == 'E'){
            commands[r] = 'f';
        } else if (current_orientation == 'E' && new_orientation == 'S'){
            commands[r] = 'r';
        } else if (current_orientation == 'W' && new_orientation == 'S'){
            commands[r] = 'l';
        } else if (current_orientation == 'W' && new_orientation == 'W'){
            commands[r] = 'f';
        } else if (current_orientation == 'W' && new_orientation == 'N'){
            commands[r] = 'r';
        } else if (current_orientation == 'S' && new_orientation == 'E'){
            commands[r] = 'l';
        } else if (current_orientation == 'S' && new_orientation == 'S'){
            commands[r] = 'f';
        } else if (current_orientation == 'S' && new_orientation == 'W'){
            commands[r] = 'r';
        }

        i++;
        r++;
    }

    /* Print the commands array */
    for(i=0;i<21;i++){
        printf("%c", commands[i]);
    }
    printf("\n");


    HANDLE hSerial;
    int length = sizeof(commands) / sizeof(commands[0]);
    char byteBuffer[BUFSIZ+1];



    printf(" Opening "COMPORT" \n");

    hSerial = CreateFile(COMPORT,
        GENERIC_READ | GENERIC_WRITE,
        0,
        0,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL,
        0
    );

    if(hSerial == INVALID_HANDLE_VALUE){
        if(GetLastError()== ERROR_FILE_NOT_FOUND){
            printf(" Serial port does not exist \n");
        }
        printf(" Unknown error occured.\n");
    }
    else
    {
        printf(" "COMPORT" opened successfully\n");
    }

    initSio(hSerial);


    for(i=0;i<length;i++) {

        byteBuffer[0] = commands[i];



        //gets(byteBuffer);

        if (byteBuffer[0] == 'q') {
            break;
        }

        writeByte(hSerial, byteBuffer);
        readByte(hSerial, byteBuffer);




    }

    printf(" ZIGBEE IO DONE!\n");


    printf(" closing "COMPORT"\n");
    CloseHandle(hSerial);

    return 0;

}
