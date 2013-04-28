#include <iostream>

extern "C" {
    void calculate_dct_matrix();
    void dct8x8(float * in, float * out, int n);
    void idct8x8(float * in, float * out, int n);
    void print_dct_matrix();
}

int main()
{
    calculate_dct_matrix();
    print_dct_matrix();
}

