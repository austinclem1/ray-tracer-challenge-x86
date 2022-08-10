#include <stddef.h>
#include <stdio.h>

struct V3 {
    float r;
    float g;
    float b;
};

struct V3 a_color = {1, 2, 3};

struct V3 canvas[8] = {{1, 2, 3}, {1, 2, 3}, {1, 2, 3}, {1, 2, 3}, {1, 2, 3}, {1, 2, 3}, {1, 2, 3}, {1, 2, 3}};

struct V4 {
    float x;
    float y;
    float z;
    float w;
};

/* struct V4 getV4() { */
/*     struct V4 result = { 1, 2, 3, 4 }; */
/*     return result; */
/* } */

int main() {
    for (float *p = canvas; p < &canvas[8]; p++) {
        printf("%f\n", *p);
    }

    return 0;
}
