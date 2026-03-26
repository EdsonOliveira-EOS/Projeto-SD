# Projeto-SD

# Integrantes: 
Edson Oliveira da Silva <eos>, 
Eduardo Celestino Leal Belian <elcb>, 
Miguel Henrique Ramos da Silva <mhrs>, 
Renan Adson Feliciano de Melo Silva <rafms>
# Professor:

Abel Guilhermino
------------------------------------------------------------------------------
# Visão Geral
- O Projeto de Sistemas Digitais se consistirá na formação de uma ULA que fará oito operações:
1. [0 0 0]  |  F = A + B
2. [0 0 1]  |  F = A - B 
3. [0 1 0]  |  F = Complemento a 2 de B
4. [0 1 1]  |  F = A = B
5. [1 0 0]  |  F = A > B
6. [1 0 1]  |  F = A < B
7. [1 1 0]  |  F = A AND B
8. [1 1 1]  |  F = A XOR B 
------------------------------------------------------------------------------
- Entrada
1. Dois vetores A e B de 5 bits (1 para o sinal e 4 para a magnitude)  representando os operandos. O formato é sempre este na entrada. O  usuário não deve ser preocupar com complemento de 2. Se o número for  negativo, o bit de sinal deve ser 1 caso contrário 0. 
2. Um vetor S de 3 bits representando o seletor da operação segundo a tabela  anterior.

- Saída
1. Um vetor F de 6 bits (5 para magnitude e 1 para o sinal) representando o  resultado da operação (para os casos em que a operação retorna um vetor),  como indicado na figura abaixo. Este dado deve ser binário e não  complementado a dois. Qualquer complementação necessária deve ser  feita internamento na ULA. 
2. 1 (LED) representando o status (para as operações que retornam um  booleano, ou seja, “=” “>” e “<” ). 
3. 7 LEDs para replicar a saída F. O resultado da operação aritmética deve ser  mostrada nos displays de 7 segmentos e também replicada nesses 6 leds.  Nesses leds devem também ser mostrados as operações de AND e XOR bit a  bit, assim como complemento 2, soma e subtração.
------------------------------------------------------------------------------
 

