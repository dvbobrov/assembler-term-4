#include <iostream>

extern "C" {
    void calculate_dct_matrix();
    void fdct(float * in, float * out, int n);
    void idct(float * in, float * out, int n);
    void print_dct_matrix();
}

float test[64];
float res[64];

int main()
{
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            test[i * 8 + j] = j;
        }
    }

    fdct(test, res, 1);

    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            std::cout << res[i * 8 + j] << " ";
        }
        std::cout << "\n";
    }
    std::cout << "---\n\n";

    idct(res, test, 1);
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            std::cout << test[i * 8 + j] << " ";
        }
        std::cout << "\n";
    }
}

