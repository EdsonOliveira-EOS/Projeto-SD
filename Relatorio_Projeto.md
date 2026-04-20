<div align="center">

![Banner do Projeto](https://preview.redd.it/every-oneshot-world-machine-edition-desktop-wallpaper-v0-i92kid9nw2q91.png?width=1920&format=png&auto=webp&s=d025b1377600f3359e4fe3db95a820506acb6282)

---

# 🔌 Projeto ULA (Unidade Lógica e Aritmética)

> *Nosso projeto 1 da disciplina de Sistema Digitais, no qual fazemos uma ULA funcionar numa FPGA e realizar operações distintas.*

**Disciplina:** Sistemas Digitais &nbsp;|&nbsp; **Instituição:** Universidade Federal de Pernambuco - Centro de Informática.
**Período:** 2026.01 &nbsp;|&nbsp; **Turma:** CIN0007

---

### 👥 Integrantes

| Nome Completo | Matrícula |
|---|---|
| Edson Oliveira da Silva <eos> | 20250026227 |
| Eduardo Celestino Leal Belian <eclb> | 20250054910 |
| Miguel Henrique Ramos da Silva <mhrs> | 20250026272 |
| Renan Adson Feliciano de Melo Silva <rafms> | 20250026399 |

---

</div>

## 📋 Índice

- [Visão Geral do Projeto](#️-visão-geral-do-projeto)
- [Tabelas da Verdade e Cálculos](#-tabelas-da-verdade-e-cálculos)
- [Circuitos e Simulações](#-circuitos-e-simulações)
- [Conclusão](#-conclusão)

---

## 🗺️ Visão Geral do Projeto
O sistema foi projetado com a seguinte arquitetura em blocos:

<div align ="center">
<img width="861" height="444" alt="image" src="https://github.com/user-attachments/assets/3a5d996c-4e34-45e5-aec4-4c3d962aa677" />
</div>

---

### 📦 Módulos Desenvolvidos

<details>
<summary><strong>🔷 Módulo A — Entradas e Funcionamento da Main</strong></summary>

<br>

**Descrição:**
Nesse módulo, vamos explicar como nossas entradas estão sendo configuradas e usadas no decorrer do nosso projeto e seus respectivos funcionamentos.

---

- `Entrada A` — Esse é o primeiro vetor que vamos utilizar no nosso projeto, tendo 1 bit de sinal e 4 de magnitude, totalizando um vetor de 5 bits. Esse vetor será constantemente utilizado junto ao vetor B em diversas operações.

- `Entrada B` — Esse é o segundo vetor do projeto, também com 1 bit de sinal e 4 de magnitude (5 bits). Além das operações com o vetor A, receberá especialmente a operação de **Complemento a 2**.

- `Entrada S` — Terceiro e último vetor, com 3 bits. Decide qual operação o projeto executará com os vetores A e B, conforme a tabela abaixo.

<div align="center">

| S₂ | S₁ | S₀ | Função |
|:--:|:--:|:--:|:-------|
| 0  | 0  | 0  | F = A + B |
| 0  | 0  | 1  | F = A - B |
| 0  | 1  | 0  | F = Complemento a 2 de B |
| 0  | 1  | 1  | F = A = B |
| 1  | 0  | 0  | F = A > B |
| 1  | 0  | 1  | F = A < B |
| 1  | 1  | 0  | F = A AND B |
| 1  | 1  | 1  | F = A XOR B |

</div>

<br>

---

**⚙️ Funcionamento da Main**

- `Manejo dos Vetores A e B com seleção pelo vetor S` — Dependendo do seletor configurado, o circuito executará a operação correspondente. Em nossa main possuímos três blocos principais: o `Projeto_Quartus` (nossa ULA), o `Analisador_7seg` e o `Decod_2x`, todos explicados abaixo com suas respectivas funções.

<details>
<summary>🖥️ Circuito Main</summary>
<br>
<div align="center">
<img width="1634" height="912" alt="image" src="https://github.com/user-attachments/assets/f95de27d-ba04-4842-a789-d8a230dbdc34" />
</div>
<br>
</details>

<br>

---

**🔗 Blocos do Circuito**

- `Projeto_Quartus (ULA)` — Núcleo principal que recebe os vetores A e B juntamente do seletor S para realizar as operações lógicas e aritméticas *(explicação aprofundada da ULA no Módulo B)*. As saídas são:
  - Vetor **F** — 1 bit de sinal + 5 bits de magnitude com o resultado de A+B ou A-B (6 bits total).
  - Saída **STATUS** — para operações booleanas como A=B, A>B e A<B.
  - Saída **Enable_7seg** — barra o display de 7 segmentos quando a operação não for soma ou subtração.

<div align="center">
<img width="228" height="140" alt="image" src="https://github.com/user-attachments/assets/83887eb8-0e22-464a-a964-e2e49ac7663e" />
</div>

---

<br>

- `Analisador_7seg` — Presente em 3 instâncias, separa o sinal do vetor de entrada para a saída **SINAL** e analisa a magnitude fazendo 3 comparações: **A<10**, **A<20** e **A<30**. As 3 booleanas resultantes alimentam os MUXes de dezena e unidade.

  <details>
  <summary>📟 MUX — Dezena</summary>
  <br>

  O MUX pegará as booleanas retornadas pelas 3 comparações e, de acordo com o seletor, retornará um vetor `In` de 4 bits contendo um dos números `0, 1, 2, 3` convertidos para binário, que será enviado ao `Decod_2x` para exibição no dígito de dezena nos 7 segmentos.

  <br>
  </details>

  <details>
  <summary>📟 MUX — Unidade</summary>
  <br>

  O MUX da unidade também usa as 3 booleanas das comparações, mas suas entradas representam o vetor com as operações **-10, -20 ou -30** aplicadas dependendo do seletor. Por exemplo, se o seletor indicar que o número é >30, o MUX retornará o vetor subtraído de 30 para extrair apenas a unidade do resultado.

  <br>
  </details>


<div align="center">
<img width="228" height="99" alt="image" src="https://github.com/user-attachments/assets/13148b26-4ebb-490d-8bff-3e1e72f6f6ed" />
</div>

- As Saídas do Analisador são: Um vetor SAIDA de 4 bits com o vetor em binário que representa a DEZENA que será enviada para o decodificador para ser mostrada no 7 segmentos, um bit de SINAL que será enviada diretamente para a pinagem do 7 segmentos para exibir o sinal do vetor analisado e por fim um vetor SAIDA com o vetor em binário que representa a UNIDADE que será enviada para o decodificador para ser mostrada nos 7 segmentos.

---

<br>

- `Decod_2x` — Os Decodificadores tem a função de receber o vetor dado pelos Analisadores e o ENABLE da ULA (Esse ENABLE é para barrar o decodificador caso a operação não seja soma ou subtração na ULA) e soltar nos 7 segmentos. Os decodificadores foram usados em aproximadamente 6 instâncias no projeto, 4 para os inputs, sendo 2 para cada vetor(A e B) e por fim 2 para o resultado da soma ou subtração feita nos vetores A e B. A saída do decodificador são A,B,C,D,E,F,G que serão conectadas diretamente aos pinos do 7 segmentos na placa.

<div align="center">
<img width="117" height="163" alt="image" src="https://github.com/user-attachments/assets/95badb6f-b7f8-4279-a86c-421a6eb585bf" />
</div>

</details>

---

<details>
<summary><strong>🔷 Módulo B — ULA</strong></summary>

<br>

**Descrição:**  


**Entradas:**
- `entrada_1` — 
- `entrada_2` — 

**Saídas:**
- `saida_1` — 

**Observações:**  


<br>

</details>

## 📊 Tabelas da Verdade e Cálculos

### Tabelas Verdade

https://docs.google.com/spreadsheets/d/1GwQhS2KhMPrCed8Xh1fbPW_qNAjKwrB1wZnr1iYnCpg/edit?pli=1&gid=125472174#gid=125472174

---

### Mapas de Karnaugh 

**Equações simplificadas:**

---

## 🔧 Circuitos e Simulações

### Módulo A — MAIN — Circuito Projetado

<details>
<summary>🖥️ Circuito Main</summary>
<br>
<div align="center">
<img width="1634" height="912" alt="image" src="https://github.com/user-attachments/assets/f95de27d-ba04-4842-a789-d8a230dbdc34" />
</div>
<br>
</details>

<details>
<summary>🖥️ Circuito do Analisador_7Seg</summary>
<br>
<div align="center">
<img width="1403" height="922" alt="image" src="https://github.com/user-attachments/assets/af600fb8-b66b-40d3-9b64-e3fd30844160" />
</div>
<br>
</details>

<details>
<summary>🖥️ Circuito A maior B cinco bits </summary>
<br>
<div align="center">
<img width="1242" height="820" alt="image" src="https://github.com/user-attachments/assets/f3148e15-43da-4d41-a1e1-722000bd34c8" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Subtrator 10-20-30 </summary>
<br>
<div align="center">
<img width="1381" height="901" alt="image" src="https://github.com/user-attachments/assets/db2c95a1-d520-4c25-820c-04da56565f72" />
<img width="1332" height="911" alt="image" src="https://github.com/user-attachments/assets/b340abee-5e89-4b92-a8fd-13c3832fc0e2" />
<img width="1385" height="895" alt="image" src="https://github.com/user-attachments/assets/a2875468-20c0-4e9c-89f6-9351f308ccac" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito do Decodificador</summary>
<br>
<div align="center">
<img width="979" height="582" alt="image" src="https://github.com/user-attachments/assets/98e69589-a283-4ac8-bb0c-535e9f84d89c" />
</div>
<br>
</details>
</div>

---

### Módulo A — Simulação (Waveform)

<details>
<summary>🖥️ Waveform Saídas S da Main</summary>
<br>
<div align="center">
<img width="1600" height="763" alt="image" src="https://github.com/user-attachments/assets/7581aba2-310f-481d-b20c-f0e0f4b4553c" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Waveform STATUS </summary>
<br>
<div align="center">
<img width="1893" height="169" alt="image" src="https://github.com/user-attachments/assets/ec2c4fd8-5734-45ba-adef-799413673eba" />
</div>
  
- Logo no começo do seletor 100 (A>B), eu forcei a saída 00000 em A pois como todos os valores de A estavam negativos, estava sempre dando 0, então eu forcei uma saída que desse 1.
<br>
</details>
</div>

<details>
<summary>🖥️ Waveform Saídas 7 segmentos</summary>
<br>
<div align="center">
<img width="1282" height="648" alt="image" src="https://github.com/user-attachments/assets/92277ddf-9ec6-4888-bf00-0e9dbdd22b26" />
</div>
  
- Há mais saídas de Segmento a 7 no nosso waveform, que são no total 9 (3 para sinal do vetor A, B e resultado e 6 com dois para A, B e resultado). Mas para não ficar algo absurdamente massivo, eu só deixei uma saída dos 7 segmentos no waveform junto da saída dos sinais (Que eu percebi agora que no fim nunca vão mudar porque na hora de colocar o clock, eu fiz o vetor A e B terem os mesmos valores)
<br>
</details>
</div>

</div>

<details>
<summary>🖥️ Waveform Analisador_7segmentos </summary>
<br>
<div align="center">
<img width="1828" height="497" alt="image" src="https://github.com/user-attachments/assets/fa888724-cd1e-49fa-9f99-03f355b3bc5f" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Waveform Decodificador_2x</summary>
<br>
<div align="center">
<img width="1899" height="869" alt="image" src="https://github.com/user-attachments/assets/cce11483-4dec-4a2b-9996-d8cd6bfb3e94" />
</div>
<br>
</details>
</div>

---

### Módulo B — ULA — Circuito Projetado

<details>
<summary>🖥️ Circuito Geral da ULA </summary>
<br>
<div align="center">
<img width="1382" height="786" alt="image" src="https://github.com/user-attachments/assets/9819086c-67b4-4a68-b46f-b5e24242a2ca" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito A XOR B </summary>
<br>
<div align="center">
<img width="1275" height="507" alt="image" src="https://github.com/user-attachments/assets/93368ee3-0795-436e-b10f-8dd98c4d29e0" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito A AND B </summary>
<br>
<div align="center">
<img width="1281" height="459" alt="image" src="https://github.com/user-attachments/assets/28155895-996c-4198-b845-29fea67ce1c0" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito A menor que B </summary>
<br>
<div align="center">
<img width="1505" height="909" alt="image" src="https://github.com/user-attachments/assets/e07c9982-467a-401f-b178-9e7ef4c6aa43" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito A maior que B </summary>
<br>
<div align="center">
<img width="1160" height="820" alt="image" src="https://github.com/user-attachments/assets/53b0192e-7615-4ef7-aecc-d05e2a82ff69" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito A igual B </summary>
<br>
<div align="center">
<img width="1110" height="550" alt="image" src="https://github.com/user-attachments/assets/442ccc7a-08b7-4b40-8ce1-3d3506df4648" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito complementador a 2 </summary>
<br>
<div align="center">
<img width="1070" height="544" alt="image" src="https://github.com/user-attachments/assets/49a422d9-5d6c-4879-bb9f-5b3c2503a43d" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito A mais B </summary>
<br>
<div align="center">
<img width="1208" height="894" alt="image" src="https://github.com/user-attachments/assets/eb0afbe4-0d51-41f1-b198-f2568d80c4a2" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Somadores </summary>
<br>
<div align="center">
<img width="1240" height="411" alt="image" src="https://github.com/user-attachments/assets/2e010c02-e908-49f6-b8e4-54e2e8854a21" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Full Adder </summary>
<br>
<div align="center">
<img width="704" height="577" alt="image" src="https://github.com/user-attachments/assets/12fce186-238b-43e6-b2b3-1a0b3ded4d68" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito A menos B </summary>
<br>
<div align="center">
<img width="1221" height="907" alt="image" src="https://github.com/user-attachments/assets/b0b0c388-4bb5-4bc0-9ed1-6b6fed06d0d2" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito Selecionador de Complemento a 2 </summary>
<br>
<div align="center">
<img width="1200" height="366" alt="image" src="https://github.com/user-attachments/assets/cbf8b0f3-174c-4c0d-8498-4a61ac01e0c8" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito Complemento a 2 somador </summary>
<br>
<div align="center">
<img width="1067" height="426" alt="image" src="https://github.com/user-attachments/assets/86d6aa69-052a-4b06-89e6-278a9d377a28" />
</div>
<br>
</details>
</div>


<details>
<summary>🖥️ 5 bits seletor </summary>
<br>
<div align="center">
<img width="1215" height="372" alt="image" src="https://github.com/user-attachments/assets/cb0ab46c-3835-4a79-a64d-ee612b0926e0" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito MUX 2x1 total </summary>
<br>
<div align="center">
<img width="818" height="910" alt="image" src="https://github.com/user-attachments/assets/13cee370-b026-4369-818a-bc9f40fa3e63" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito MUX 2x1 </summary>
<br>
<div align="center">
<img width="744" height="550" alt="image" src="https://github.com/user-attachments/assets/ae17fb07-d854-4a76-a13f-b5f709841a46" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito MUX total 8x1 </summary>
<br>
<div align="center">
<img width="522" height="914" alt="image" src="https://github.com/user-attachments/assets/068f234e-2c69-43d3-9737-6527d921ef8f" />
</div>
<br>
</details>
</div>

<details>
<summary>🖥️ Circuito MUX 8x1 </summary>
<br>
<div align="center">
<img width="1054" height="812" alt="image" src="https://github.com/user-attachments/assets/c9cd46a1-5546-4851-bde0-b74968b718d3" />
</div>
<br>
</details>
</div>

---

### Módulo B — Simulação (Waveform)


---

## 🏁 Conclusão

- Esse foi realmente um projeto **muito interessante** de se fazer, teve muito trabalho em equipe, muita luta, muitas aulas perdidas (tivemos que ficar faltando um monte de aula de outras matérias para fazer esse projeto mas fazer o que né), mas no fim, tudo isso foi essencial para nosso aprendizado em Sistemas Digitais, que foi um projeto bem legal de se fazer e que rendeu muitos momentos de pensamento, companheirismo e assim vai. Se for para eu descrever a experiência de fazer esse projeto em uma palavra, eu diria... satisfatório, ver um circuito sendo feito realmente é muito legal.

**Principais aprendizados:**
- ✅ Aprendizado 1 — Reforçamos nosso aprendizado em Portas Lógicas, Tabelas da Verdade, Mapas K, já que precisamos usar das mais variadas portas lógicas e circuitos para conseguir fazer o projeto.
- ✅ Aprendizado 2 — Nosso trabalho em equipe realmente melhorou bastante, cada um fez sua parte, se ajudamos, reestruturamos, testamos, tudo isso em equipe.
- ✅ Aprendizado 3 — Aprendemos que quem faz circuitos sofre na vida.

**Dificuldades encontradas:**  
Tivemos muitos problemas que a gente encontrou pelo caminho tipo quando era A > B e ambos eram zero mas B tinha sinal negativo, isso fazia o progama ''entender'' que A era maior que B no nosso sistema, isso foi um errinho que a gente teve que corrigir.

Outro problema que a gente encontrou também foi a **contagem de Bits**, muitos circuitos nossos estavam prontos só para uma bitagem específica, o que fez a gente precisar refazer vários blocos que já estavam feitos só para adicionar ou diminuir os bits, o que custou um tempo **enorme** para refazer tudo, mas no fim, deu para resolver né.

---

<div align="center">

*"Não tenho nenhum talento especial. Apenas sou apaixonadamente curioso"*  
— Albert Eistein.

<br>

![Made with](https://img.shields.io/badge/Feito%20com-suor%20e%20caf%C3%A9-brown?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Conclu%C3%ADdo-success?style=for-the-badge)

</div>

---

<div align="center">
<sub>Projeto desenvolvido para fins acadêmicos • UFPE • 2026.2</sub>
</div>
