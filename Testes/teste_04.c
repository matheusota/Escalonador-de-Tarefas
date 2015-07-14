// Esse teste é equivalente ao teste 1, mas é em C
#include "cabecalho.h"

int main(){
	int filho, pid;
	
	filho = fork();
	
	//filho
	if (filho == 0){
		pid = getpid();
		write(1, "Sou o filho!\n", 13);
		
		exit();
	}
		
	//pai
	else{
		pid = getpid();
		write(1, "Sou o pai!\n", 11);
		exit();
	}
	
	return 0;
}
