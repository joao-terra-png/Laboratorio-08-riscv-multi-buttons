cd tests
echo "Testando $1..." 
cp ../$1.asm riscv.asm                          # Copia o arquivo de teste
rm -f a.out riscv.out riscv_data.out            # Limpa arquivos antigos      
make                                            # Simula o processador
./a.out                                         # Executa o teste       
grep 0x00000040 -A50 riscv.out > riscv_data.out # Extrai a saída relevante (.data)

