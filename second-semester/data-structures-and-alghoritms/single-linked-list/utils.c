#include <string.h>

int sumString(char *str)
{
    int i = 0, strLength = strlen(str);
    long long sum = 0;
    while (*(str + i) != '\0')
    {
        sum += ((strLength - i) * 254) + *(str + i);
        i++;
    }

    return sum;
}