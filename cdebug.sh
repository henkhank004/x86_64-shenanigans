if [ -e "../debug/obj/main_debug.o" ]; then
    rm ../debug/obj/main_debug.o
fi

assemble.sh -d ./**/*.asm
gcc -g -o c_main main.c ../debug/obj/*.o

./c_main
