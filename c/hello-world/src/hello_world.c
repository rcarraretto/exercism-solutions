#include <stdio.h>
#include "hello_world.h"

void hello(char *buffer, const char *name)
{
	sprintf(buffer, "Hello, %s!", name ? name : "World");
}
