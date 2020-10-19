/******** Gray Code Generator ********/
/********     2020.10.19      ********/
/******** By apachiww@github.com ********/

#include <stdio.h>

int main() {
	int len;		//Gray code length
	int count;		//The number of gray code to generate later
	int vlt;		//Volatile, used in the generating process later
	printf("Please input your Gray code length\n> ");
	scanf("%d", &len);
	if(len < 1) {
		printf("Invalid length\n");
		return 0;
	}
	else {
		count = 1 << len;					// 2^len outputs in all
		for(int i = 0; i < count; i++) {
			for(int j = len; j >= 1; j--){
				vlt = i%(1 << (j+1))/(1 << (j-1));	// Generate the code 
				switch(vlt) {
					case 0: printf("0");break;
					case 1: printf("1");break;
					case 2: printf("1");break;
					default: printf("0");
				}	
			}
			printf("\n");					// One line finished  
		}
		return 0;
	}
}
