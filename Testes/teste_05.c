// Esse teste é equivalente ao teste 3, mas é em C
#include "cabecalho.h"

unsigned int2string(char *dst, int num);
unsigned str2str(char *dst, char *src);
int fib(int n, int pid);
void processo1(int i);
void processo2(int i);

int main(){
	int filho, pid;
	int i_fib1, i_fib2;
	i_fib1 = 0;
	i_fib2 = 1;
	
	filho = fork();
	
	while(1){
		pid = getpid();
		
		//processo 1 computa fibonacci comecando em 0
		if (pid == 1){
			processo1(i_fib1);
			
			i_fib1++;
		}
			
		//processo 2 computa fibonacci comecando em 1
		else{
			processo2(i_fib2);
			
			i_fib2++;
		}
	}
	
	return 0;
}

int fib(int n, int pid) 
{
	if (n < 2)
		return 1;
	else
		return fib(n-1, pid) + fib(n-2, pid);
}

/* Converte um inteiro para string. Retorna o número de bytes escritos no
   buffer de destino. */
unsigned int2string(char *dst, int num) {
  char buf[256];
  int p = 0, i;
  unsigned num_bytes = 0;
  if (num < 0) {
    *(dst++) = '-';
    num = ~num + 1;
    ++num_bytes;
  }	
  do {
    int rem = num % 10;
    num = num / 10;
    char c = '0' + rem;
    buf[p++] = c;
  } while (num != 0);
  for (i = 0; i < p; ++i) {
    *(dst++) = buf[p-1-i];
    ++num_bytes;
  }
  return num_bytes;
}

/* Copia uma string para outra string de destino. Retorna o número de bytes
   escritos no buffer de destino. */
unsigned str2str(char *dst, char *src) {
  unsigned num_bytes = 0;
  while (*src != '\0') {
    *(dst++) = *(src++);
    ++num_bytes;
  }
  return num_bytes;
}

void processo1(int i){
	char buf[200];
	char *pbuf = buf;
	
	pbuf += str2str(pbuf, "FIBONACCI-1(");
	pbuf += int2string(pbuf, i);
	pbuf += str2str(pbuf, "):");
	pbuf += int2string(pbuf, fib(i, 1));
	pbuf += str2str(pbuf, "\n");
	write(1, buf, (int) (pbuf - buf));
}

void processo2(int i){
	char buf[200];
	char *pbuf = buf;
	
	pbuf += str2str(pbuf, "FIBONACCI-2(");
	pbuf += int2string(pbuf, i);
	pbuf += str2str(pbuf, "):");
	pbuf += int2string(pbuf, fib(i, 2));
	pbuf += str2str(pbuf, "\n");
	write(1, buf, (int) (pbuf - buf));

}
