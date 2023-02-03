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
};

struct kv_list kvl;
size_t kvl_counter;
//size_t kvl_rounder;
//Our stuff
int next_job =0;

int numFiles=0;
int reducer_threads;
struct kv_list* array; //
pthread_mutex_t lockaddtolist;
pthread_mutex_t lock,arrayLock,emitLock,redlock,redhelplock,maplock;
//>[./,F1,F2,four]
//>
//helper*
//knowprogram.com
struct arg_struct{
    
    Mapper map;
    char* Array[];
};
struct arg_struct2{
    
    Reducer reducer;
    
};
void delay(int number_of_seconds)
{
    // Converting time into milli_seconds
    int milli_seconds = 1000 * number_of_seconds;
  
    // Storing start time
    clock_t start_time = clock();
  
    // looping till required time is not achieved
    while (clock() < start_time + milli_seconds)
        ;
}
void init_array(size_t size){ //called by init_array(num_reducers) num-reducers=threads; each parition points to a kv_list
     array = (struct kv_list*)malloc(size * sizeof(struct kv_list*));
     for(int i=0;i<size;i++){
         array[i].elements =(struct kv**) malloc(size * sizeof(struct kv*));
         array[i].num_elements = 0;
        array[i].size = size;
     }
    //struct kv* array = malloc(size * sizeof *array);//need to free
}
void add_to_array(int partition,struct kv* elt){
    pthread_mutex_lock(&lockaddtolist);
    if (array[partition].num_elements == array[partition].size) {
	array[partition].size *= 2;
	array[partition].elements = realloc(array[partition].elements, array[partition].size * sizeof(struct kv*));
    }
    array[partition].elements[array[partition].num_elements++] = elt;
    pthread_mutex_unlock(&lockaddtolist);

}


void init_kv_list(size_t size) {
    kvl.elements = (struct kv**) malloc(size * sizeof(struct kv*));
    kvl.num_elements = 0;
    kvl.size = size;
}

void add_to_list(struct kv* elt) {
    if (kvl.num_elements == kvl.size) {
	kvl.size *= 2;
	kvl.elements = realloc(kvl.elements, kvl.size * sizeof(struct kv*));
    }
    kvl.elements[kvl.num_elements++] = elt;
}

char* get_func(char* key, int partition_number) {
    // printf("GETFUNC [%s,%d]\n",key,partition_number);
    if (kvl_counter == array[partition_number].num_elements) {
	return NULL;
    }
    struct kv *curr_elt = array[partition_number].elements[kvl_counter];
    // printf("$%s,%s$",curr_elt->key,curr_elt->value);
    if (!strcmp(curr_elt->key, key)) {
	kvl_counter++;
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
{   pthread_mutex_lock(&emitLock);
    int partition_number =0;
    
    //partition_number = MR_DefaultHashPartition(key, reducer_threads);
    
struct kv *elt = (struct kv*) malloc(sizeof(struct kv));
elt->key = strdup(key);
    elt->value = strdup(value);
        partition_number = MR_DefaultHashPartition(elt->key, reducer_threads);

    add_to_array(partition_number,elt);
// printf("Partition[%d],%s,%s\n",partition_number,elt->key,elt->value);
    // struct kv *elt = (struct kv*) malloc(sizeof(struct kv));
    // // if (elt == NULL) {
	// // printf("Malloc error! %s\n", strerror(errno));
	// // exit(1);
    // // }
    // elt->key = strdup(key);
    // elt->value = strdup(value);
    // add_to_list(elt);
    pthread_mutex_unlock(&emitLock);
    return;
}

// void worker(char* fileArray,Mapper map){
//    int arrayLength=(sizeof(fileArray))/(sizeof(char *));
//     while (next_job < arrayLength+1){
//             pthread_mutex_lock(&lock);
//             if(next_job>arrayLength){
//                 pthread_mutex_unlock(&lock);
//                 break;
//             }
//             char* myjob;
//             myjob = &fileArray[next_job];
//             next_job++;
//             map(myjob);

//             pthread_mutex_unlock(&lock);
//     }
// }
void worker(void *args){
struct arg_struct *arg_in = args;
   //int arrayLength=(sizeof(arg_in->Array))/(sizeof(char *));
    int arrayLength = numFiles;
    while (next_job < arrayLength){
            pthread_mutex_lock(&lock);
            if(next_job>arrayLength){
                pthread_mutex_unlock(&lock);
                break;
            }
            
            char* myjob;
            myjob = arg_in->Array[next_job];
            next_job++;
    
            pthread_mutex_unlock(&lock);
            arg_in->map(myjob);
            pthread_exit(NULL);	
            //pthread_mutex_unlock(&lock);

    }
}
void redworker(void *args2){
    pthread_mutex_lock(&redhelplock);
    struct arg_struct2 *arg2_in = args2;
    
    kvl_counter =0;
    for(int i =0; i<reducer_threads;i++){
    if(array[i].num_elements!=0){
    //printf("WE IN [%d]\n",i);
    while (kvl_counter < array[i].num_elements) {
        (*arg2_in->reducer)((array[i].elements[kvl_counter]->key),get_func,i);
    //     printf("[kvlCount[%ld/%ld,Key=%s]\n",kvl_counter,array[i].num_elements-1,array[i].elements[kvl_counter]->key);
	// (*reduce)((array[i].elements[kvl_counter])->key, get_func, i);
    }kvl_counter =0;
    
    }
}pthread_mutex_unlock(&redhelplock);


}



void printDataStruct(){
    printf("================START=======%d======================\n",reducer_threads);
    for(int i = 0; i<reducer_threads;i++){
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
    numFiles = argc-1;
    reducer_threads = num_reducers;
    init_array(reducer_threads);
    char* fileArray[argc-1];
    
    pthread_t *thread_map;
    pthread_t *thread_red;
    thread_red = (pthread_t *) malloc (num_reducers*sizeof(pthread_t)); 
    thread_map = (pthread_t *) malloc (num_mappers*sizeof(pthread_t));  
    int rt = 0;
    struct arg_struct *args = malloc(sizeof(struct arg_struct));
    struct arg_struct2 *args2 = malloc(sizeof(struct arg_struct2));
    //printf("yup");
      for(int i =1; i <=argc -1; i++){
          //char* thischar = argv[i];
          //printf("%s\n",thischar);
          //args->Array[i-1]=argv[i];
          fileArray[i-1] = argv[i];
          args->Array[i-1] = fileArray[i-1];
            //printf("%s \n",fileArray[i-1]);
      }
      
    //args->Array=*fileArray;
    
    //printf("\n\narray=%s\n\n",args->Array);
    
    args->map=map;

    
    //printf("num_mappers=%d\n",num_mappers);
        for (int i =0; i<num_mappers;i++){
            pthread_mutex_lock(&maplock);
            rt = pthread_create(&thread_map[i],NULL,(void *)worker,(void *)args);
            if(rt!=0){
                printf("Could not make thread %d\n",i);
                exit(EXIT_FAILURE);
            }
            
            pthread_mutex_unlock(&maplock);
            // for(int i=0;i<num_mappers;i++){
        // pthread_join(thread_map[i],NULL);
        // }
        }
        //printf("yup");
        
        for(int i=0;i<num_mappers;i++){
        pthread_join(thread_map[i],NULL);
        }

//printDataStruct();
for(int i=0;i<num_reducers;i++){
    qsort(array[i].elements,array[i].num_elements,sizeof(struct kv_list*),cmp);
}
kvl_counter = 0;
// for(int i =0; i<num_reducers;i++){
//     if(array[i].num_elements!=0){
//     //printf("WE IN [%d]\n",i);
//     while (kvl_counter < array[i].num_elements) {
//         printf("[kvlCount[%ld/%ld,Key=%s]\n",kvl_counter,array[i].num_elements-1,array[i].elements[kvl_counter]->key);
// 	(*reduce)((array[i].elements[kvl_counter])->key, get_func, i);
//     }kvl_counter =0;
//     }
// }


//printDataStruct();



kvl_counter = 0;

args2->reducer=reduce;

//args2->get_func=get_func;

for(int i = 0; i<num_reducers;i++){
    pthread_mutex_lock(&redlock);
    rt = pthread_create(&thread_red[i],NULL,(void *)redworker,(void *)args2);
//             if(rt!=0){
//                 printf("Could not make thread %d\n",i);
//                 exit(EXIT_FAILURE);
//             }
pthread_mutex_unlock(&redlock);
}
// for (int i =7; i<num_reducers;i++){
//     printf("WE%d IN",i);
//     // pthread_mutex_lock(&redlock);
//     if(array[i].num_elements!=0){
//     args2->key=array[i].elements[kvl_counter]->key;
//     args2->partition=i;
    
//         while (kvl_counter < array[i].num_elements) {
//             rt = pthread_create(&thread_red[i],NULL,(void *)reduce,(void *)args2);
//             if(rt!=0){
//                 printf("Could not make thread %d\n",i);
//                 exit(EXIT_FAILURE);
//             }
//         }kvl_counter =0;
    
//      }pthread_mutex_unlock(&redlock);
// }

//         }
//         //printf("yup");
        for(int i=0;i<num_reducers;i++){
        pthread_join(thread_red[i],NULL);
        }
    // for(int i = 0; ;i++){
//printDataStruct();
  //printf("array=[%ld]",array[7].num_elements);
    // }
// for(int i=0;i<num_reducers;i++){
//     qsort(array[i].elements,array[i].num_elements,sizeof(struct kv*),cmp);
//     qsort(array[i].elements, kvl.num_elements, sizeof(struct kv*), cmp);
// qsort(kvl.elements, kvl.num_elements, sizeof(struct kv*), cmp);
//}
// void qsort (void* base, size_t num, size_t size, 
//             int (*comparator)(const void*,const void*));
    /**
    init_kv_list(10);
    int i;
    for (i = 1; i < argc; i++) {
	(*map)(argv[i]);
    }

    qsort(kvl.elements, kvl.num_elements, sizeof(struct kv*), cmp);
**/
    // note that in the single-threaded version, we don't really have
    // partitions. We just use a global counter to keep it really simple
// kvl_counter = 0;
//     while (kvl_counter < kvl.num_elements) {
//         (*reduce)((array[]))
// 	(*reduce)((kvl.elements[kvl_counter])->key, get_func, 0);
    

//     kvl_counter = 0;
//     while (kvl_counter < kvl.num_elements) {
// 	(*reduce)((kvl.elements[kvl_counter])->key, get_func, 0);
    
   // }
}

