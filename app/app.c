#include "uart.h"
#include "delay.h"


#include "atom.h"
#include "atomport-private.h"
#include "atomtimer.h"
#include "atommutex.h"


#define IDLE_STACK_SIZE_BYTES 128
#define MAIN_STACK_SIZE_BYTES 256
#define DEFAULT_THREAD_PRIO 16

static uint8_t idle_thread_stack[IDLE_STACK_SIZE_BYTES];
//static ATOM_MUTEX mutex;

static ATOM_TCB task1_tcb;
static uint8_t task1_thread_stack[MAIN_STACK_SIZE_BYTES];

static void task1_func(uint32_t param)
{
    uint32_t used_bytes = 0, free_bytes = 0;
    while (1)
    {
        
//        atomMutexGet(&mutex, 0);
        atomThreadStackCheck(&task1_tcb,&used_bytes,&free_bytes);
        printf("task1 used bytes =%d free bytes=%d\n", used_bytes, free_bytes);
//        atomMutexPut(&mutex);
//        printf("1111\n");
        atomTimerDelay(20);
    }
}

static ATOM_TCB task2_tcb;
static uint8_t task2_thread_stack[MAIN_STACK_SIZE_BYTES];
static void task2_func(uint32_t param)
{
    uint32_t used_bytes = 0, free_bytes = 0;
    while (1)
    {
        
//        atomMutexGet(&mutex, 0);
        atomThreadStackCheck(&task2_tcb,&used_bytes,&free_bytes);
        printf("task2 used bytes =%d free bytes=%d\n", used_bytes, free_bytes);
//        atomMutexPut(&mutex);
//        printf("2222\n");
        atomTimerDelay(30);
    }
}
int TcMain(void)
{
    delay1ms(1000);
    PrintInitUart1(115200);

    int8_t status;
    __NVIC_SetPriority(SysTick_IRQn,0);
    __NVIC_SetPriority(PendSV_IRQn,3);
    status = atomOSInit(&idle_thread_stack[0], IDLE_STACK_SIZE_BYTES, TRUE);

    if (status == ATOM_OK)
    {
        contex_Mx_SystemTickInit();
//        atomMutexCreate(&mutex);
        status = atomThreadCreate(&task1_tcb,
                                  DEFAULT_THREAD_PRIO, task1_func, 0,
                                  &task1_thread_stack[0],
                                  MAIN_STACK_SIZE_BYTES,
                                  TRUE);

        status = atomThreadCreate(&task2_tcb,
                                  DEFAULT_THREAD_PRIO, task2_func, 0,
                                  &task2_thread_stack[0],
                                  MAIN_STACK_SIZE_BYTES,
                                  TRUE);

        atomOSStart();
    }

    return 0;
}

