
# MyC compiler

A mini compiler that compiles standard C code into Pcode similar to assembly language.




## Checklist
The compiler handles these operations: 

    1. Arbitrary arithmetic expression such as calculator.
    2. Explicit variable declaration. 
    3. If-Else instructions.
    4. While loops.
    5. Blocks, nested block, the problems of visibility and local variables.
    6. Functions.
    7. Recursive functions.

our compiler handles additional errors, such as double declarations, or using undeclared variables. 
The compiler will yield an error during compilation, see examples below.

#### Double declaration

```c
int main() {
    int x; 
    int x;
    return 0;
}
```
output:
```
    x is already declared!
```

#### Using undeclared variables

```c
int main() {
    x = 1; 
    return 0;
}
```
output: 
```
    x is not declared!
```
#### Functions

```c
int main() {
    undeclared_function();
    return 0;
} 
```
ouput: 
```
undeclared_function is not declared!

```

```c
int main() {
    int x; 
    x();
    return 0;
}
```
output: 
```
x is not a function!
```

passing wrong number of argument
```c
int sum (int x, int y) {
  return y + x;
}

int main() {
  return sum(14);
}

```
output 
```
too few arguments in sum.

```
similar result for the code below
```c
int main() {
  return sum(1,2,3);
}
```

output 
```
too many arguments in sum.
```

## Documentation
#### Repository structure: 

```
- Repository
    | + tst
    | + src
    | + Makefile
    | + Readme.md
```

- The ```src``` directory contains files to build the compiler.  
- The ```tst``` directory contains files to test the compiler.
- Makefile: used to compile and execute our project.

#### Execution:
- The command ```make``` build the compiler. 
- The command ```make test``` compile the set of sample files into Pcode, the compiled files will be in src/PCode directory.
- The command ```make clean``` removes the compiled files. 