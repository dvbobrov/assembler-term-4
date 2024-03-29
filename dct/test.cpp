#include <iostream>

extern "C" {
    void calculate_dct_matrix();
    void _fdct(float * in, float * out, int n);
    void _idct(float * in, float * out, int n);
}

float test[128] = { -16342, 2084, -10049, 10117, 2786, -659, -4905, 12975,
10579, 8081, -10678, 11762, 6898, 444, -6422, -15892,
-13388, -4441, -11556, -10947, 16008, -1779, -12481, -16230,
-16091, -4001, 1038, 2333, 3335, 3512, -10936, 5343,
-1612, -4845, -14514, 3529, 9284, 9916, 652, -6489,
12320, 7428, 14939, 13950, 1290, -11719, -1242, -8672,
11870, -9515, 9164, 11261, 16279, 16374, 3654, -3524,
-7660, -6642, 11146, -15605, -4067, -13348, 5807, -14541, -16342, 2084, -10049, 10117, 2786, -659, -4905, 12975,
10579, 8081, -10678, 11762, 6898, 444, -6422, -15892,
-13388, -4441, -11556, -10947, 16008, -1779, -12481, -16230,
-16091, -4001, 1038, 2333, 3335, 3512, -10936, 5343,
-1612, -4845, -14514, 3529, 9284, 9916, 652, -6489,
12320, 7428, 14939, 13950, 1290, -11719, -1242, -8672,
11870, -9515, 9164, 11261, 16279, 16374, 3654, -3524,
-7660, -6642, 11146, -15605, -4067, -13348, 5807, -14541 };

float res[128];

int main()
{
//    for (int i = 0; i < 8; i++)
//    {
//        for (int j = 0; j < 8; j++)
//        {
//            test[i * 8 + j] = j;
//        }
//    }
//
    _fdct(test, res, 2);

    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            std::cout << res[i * 8 + j] << " ";
        }
        std::cout << "\n";
    }
    std::cout << "---\n\n";

    float *second = res + 64;
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            std::cout << second[i * 8 + j] << " ";
        }
        std::cout << "\n";
    }
    std::cout << "---\n\n";

    _idct(res, test, 2);
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            std::cout << test[i * 8 + j] << " ";
        }
        std::cout << "\n";
    }
    std::cout << "----\n\n";

    second = test + 64;
    for (int i = 0; i < 8; i++)
    {
        for (int j = 0; j < 8; j++)
        {
            std::cout << second[i * 8 + j] << " ";
        }
        std::cout << "\n";
    }
    std::cout << "---\n\n";

}

