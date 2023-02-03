#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include "mapreduce.h"
#include "hashmap.h"
#include <pthread.h>
#include <time.h>

struct kv {
    char* key;
    char* value;
};

struct kv_list {
    struct kv** elements;
    size_t num_elements;
    size_t size;
    int count;
};

//Our stuff
int debug = 0;
int next_job =1;
int numFiles=0;
int array_size;
struct kv_list* array;
pthread_mutex_t lock;
pthread_mutex_t* partition_lock;
char **fileArray;
Partitioner partitioner_global;

struct arg_struct{
    
    Mapper map;
};
struct arg_struct2{
    int partition_num;
    Reducer reducer;
    
};

void *worker(void* args);
void *redworker(void *args);

void init_array(size_t size){ //called by init_array(num_reducers) num-reducers=threads; each parition points to a kv_list
      array = (struct kv_list*)malloc(array_size * sizeof(struct kv_list));
      for(int i=0;i<array_size;i++){
         
            array[i].elements =(struct kv**) malloc(size * sizeof(struct kv*));
            array[i].num_elements = 0;
            array[i].size = size;
            array[i].count = 0;
           
        
     }
}
void add_to_array(int partition,struct kv* elt){
    
    if (array[partition].num_elements == array[partition].size) {
	array[partition].size *= 2;
    array[partition].elements = realloc(array[partition].elements, array[partition].size * sizeof(struct kv*));
    }
    array[partition].elements[array[partition].num_elements++] = elt;
    

}

char* get_func(char* key, int partition_number) {
 
    if (array[partition_number].count >= array[partition_number].num_elements) {
	return NULL;
    }
    struct kv *curr_elt = array[partition_number].elements[array[partition_number].count];
  
    if (!strcmp(curr_elt->key, key)) {
	array[partition_number].count++;
	return curr_elt->value;
    }
    return NULL;
}

int cmp(const void* a, const void* b) {
    char* str1 = (*(struct kv **)a)->key;
    char* str2 = (*(struct kv **)b)->key;
    return strcmp(str1, str2);
}

void MR_Emit(char* key, char* value)
{   
    
    long partition_number = partitioner_global(key, array_size);
    
    struct kv *elt =  malloc(sizeof(struct kv*));
    elt->key = strdup(key);
    elt->value = strdup(value);
    
        
    pthread_mutex_lock(&partition_lock[partition_number]);
    add_to_array(partition_number,elt);
    pthread_mutex_unlock(&partition_lock[partition_number]);
}

void *worker(void *args){
struct arg_struct *arg_in = (struct arg_struct*)args;
    while (next_job <= numFiles){
            pthread_mutex_lock(&lock);
            int myjob = next_job;
            if(myjob>numFiles){
                pthread_mutex_unlock(&lock);
                pthread_exit(NULL);
            }
            
            next_job++;
            pthread_mutex_unlock(&lock);
            (*arg_in->map)(fileArray[myjob]);

            	

    }
    pthread_exit(NULL);
}
void *redworker(void *args2){
  
    struct arg_struct2 *arg2_in = (struct arg_struct2*)args2;
    while (array[arg2_in->partition_num].count < array[arg2_in->partition_num].num_elements) {
        (*arg2_in->reducer)(array[arg2_in->partition_num].elements[array[arg2_in->partition_num].count]->key,get_func,arg2_in->partition_num);
           
    }
    
    
    

pthread_exit(NULL);


}



void printDataStruct(){
    printf("================START=======%d======================\n",array_size);
    for(int i = 0; i<array_size;i++){
        for(int j=0;j<array[i].num_elements;j++){
            if(array[i].num_elements!=0)
                printf("[PARTITION[%d,%d]KEY=%s,Value=%s]\n",i,j,array[i].elements[j]->key,array[i].elements[j]->value);
        }
    }

    printf("==============END================================\n");
}

unsigned long MR_DefaultHashPartition(char *key, int num_partitions) {
   unsigned long hash = 5381;
    int c;
    while ((c = *key++) != '\0')
        hash = hash * 33 + c;
    return hash % num_partitions;

}

void MR_Run(int argc, char *argv[], Mapper map, int num_mappers,
	    Reducer reduce, int num_reducers, Partitioner partition)
{
    partition_lock = (pthread_mutex_t*) malloc(num_reducers * sizeof(pthread_mutex_t));
    for(int i =0; i <num_reducers; i++){
        pthread_mutex_init(&partition_lock[i], NULL);
    }
    pthread_mutex_init(&lock, NULL);

   
    array_size = num_reducers;
    partitioner_global= partition;
    numFiles = argc-1;
    init_array(10);
    fileArray = argv;
    
    
    pthread_t *thread_map;
    pthread_t *thread_red;
    thread_red = (pthread_t *) malloc (num_reducers*sizeof(pthread_t)); 
    thread_map = (pthread_t *) malloc (num_mappers*sizeof(pthread_t));  
    
    
    
    
        for (int i =0; i<num_mappers;i++){
            struct arg_struct *args = malloc(sizeof(struct arg_struct));
            args->map = map;
            pthread_create(&thread_map[i],NULL,worker,(void *)args);
           
            
        }
        for(int i=0;i<num_mappers;i++){
        pthread_join(thread_map[i],NULL);
        }

        if(debug == 1){
            printDataStruct();
        }
    for(int i=0;i<array_size;i++){
        qsort(array[i].elements,array[i].num_elements,sizeof(struct kv*),cmp);
    }

if(debug == 1){
printDataStruct();
}

for(int i = 0; i<num_reducers;i++){
    struct arg_struct2 *args2 = malloc(sizeof(struct arg_struct2));
    args2->reducer=reduce;
    args2->partition_num = i;
    pthread_create(&thread_red[i],NULL,redworker,(void *)args2);

    }
for(int i=0;i<num_reducers;i++){
        pthread_join(thread_red[i],NULL);
    }

    if(debug == 1){
        printDataStruct();
    }
        numFiles = 0;
        next_job = 1;


}


