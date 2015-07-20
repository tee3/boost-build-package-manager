#include <iostream>

#include "a/a.hpp"
#include "b/b.hpp"

int
main ()
{
   std::cout << a::a () << "\n";
   std::cout << b::b () << "\n";

   return 0;
}
