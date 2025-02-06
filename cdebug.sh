assemble.sh -d *.asm

if [ -e "./debug/obj/main_debug.o" ]; then
    rm ./debug/obj/main_debug.o
fi

gcc -g -o c_main main.c ./debug/obj/*.o

./c_main
