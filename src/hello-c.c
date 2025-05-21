#include <stdio.h>
#ifdef _WIN32
#include <windows.h>

DWORD WINAPI sleepSort(LPVOID num) {
  int sleepTime = *((int *)num);
  Sleep(sleepTime);
  printf("%d ", sleepTime);
  return 0;
}

void sleepSortArray(int arr[], int size) {
  HANDLE threads[size];
  DWORD threadIDs[size];
  int i;

  for (i = 0; i < size; i++) {
    threads[i] =
        CreateThread(NULL, 0, sleepSort, (LPVOID)&arr[i], 0, &threadIDs[i]);
  }

  WaitForMultipleObjects(size, threads, TRUE, INFINITE);

  for (i = 0; i < size; i++) {
    CloseHandle(threads[i]);
  }
}
#endif

int main() {
  printf("Sleep sorting\n");

  int arr[] = {9, 40, 10, 1, 6, 45, 23, 50};
  int size = sizeof(arr) / sizeof(arr[0]);

  for (int i = 0; i < size; i++) {
    printf("%d ", arr[i]);
  }
#ifdef _WIN32
  printf("\nSorted numbers: ");
  sleepSortArray(arr, size);
  printf("\n");
#endif

  return 0;
}
