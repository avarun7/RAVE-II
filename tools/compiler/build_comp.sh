#!bash/bin

#execute from within the rscv gnu tolchain submodule
configure --prefix=../gcc_riscv --with-arch=rv32imac --with-abi=ilp32

#submodule has many '\r' chars which will cause the make to fail for various issues and more of these chars are created with the intermediate files that are generated so
#need to loop the make and dos2unix until successful build
until make linux
do
    find . -type f -print0 | xargs -0 -n 1 -P 4 dos2unix -f    
done
