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
- [Sistema Completo](#-sistema-completo-conectado)
- [Conclusão](#-conclusão)

---

## 🗺️ Visão Geral do Projeto

O sistema foi projetado com a seguinte arquitetura em blocos:

```
┌───────────────┐      ┌─────────────┐      ┌─────────────┐
│   MÓDULO A    │────▶│   MÓDULO B   │────▶│  MÓDULO C   │
│(Entradas/Main)│      │    (ULA)    │      │  (Saídas)   │
└───────────────┘      └─────────────┘      └─────────────┘
```
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
<img width="1469" height="812" alt="image" src="https://github.com/user-attachments/assets/20cae781-54b5-4fe6-8c83-e7bf66e6c900" />
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

<details>
<summary>🖥️ Circuito do Analisador</summary>
<br>
<div align="center">
<img width="1412" height="921" alt="image" src="https://github.com/user-attachments/assets/b19317a1-9a93-41c0-9509-9b2bd2f85caf" />
</div>
<br>
</details>

---

<br>

- `Decod_2x` — Os Decodificadores tem a função de receber o vetor dado pelos Analisadores e o ENABLE da ULA (Esse ENABLE é para barrar o decodificador caso a operação não seja soma ou subtração na ULA) e soltar nos 7 segmentos. Os decodificadores foram usados em aproximadamente 6 instâncias no projeto, 4 para os inputs, sendo 2 para cada vetor(A e B) e por fim 2 para o resultado da soma ou subtração feita nos vetores A e B. A saída do decodificador são A,B,C,D,E,F,G que serão conectadas diretamente aos pinos do 7 segmentos na placa.

<div align="center">
<img width="117" height="163" alt="image" src="https://github.com/user-attachments/assets/95badb6f-b7f8-4279-a86c-421a6eb585bf" />
</div>

<details>
<summary>🖥️ Circuito do Decodificador</summary>
<br>
<div align="center">
<img width="979" height="582" alt="image" src="https://github.com/user-attachments/assets/98e69589-a283-4ac8-bb0c-535e9f84d89c" />
</div>
<br>
</details>

</details>

---

<details>
<summary><strong>🔷 Módulo B — ULA</strong></summary>

<br>

**Descrição:**  
Explique aqui o que este módulo faz, qual sua função no sistema e como ele se integra com os demais.

**Entradas:**
- `entrada_1` — Descrição da entrada
- `entrada_2` — Descrição da entrada

**Saídas:**
- `saida_1` — Descrição da saída

**Observações:**  
Qualquer detalhe relevante sobre o funcionamento interno deste módulo.

<br>

</details>

---

<details>
<summary><strong>🔷 Módulo C — Saídas</strong></summary>

<br>

**Descrição:**  
Explique aqui o que este módulo faz, qual sua função no sistema e como ele se integra com os demais.

**Entradas:**
- `entrada_1` — Descrição da entrada
- `entrada_2` — Descrição da entrada

**Saídas:**
- `saida_1` — Descrição da saída

**Observações:**  
Qualquer detalhe relevante sobre o funcionamento interno deste módulo.

<br>

</details>

---

## 📊 Tabelas da Verdade e Cálculos

### Tabelas Verdade

---

### Mapas de Karnaugh 

**Equações simplificadas:**

---

## 🔧 Circuitos e Simulações

### Módulo A — Circuito Projetado

<div align="center">

![Circuito Módulo A](./assets/circuito_modulo_a.png)

*Figura 1 — Circuito lógico do Módulo A projetado no Logisim / Proteus / (software utilizado)*

</div>

---

### Módulo A — Simulação (Waveform)

<div align="center">

![Waveform Módulo A](./assets/waveform_modulo_a.png)

*Figura 2 — Simulação do Módulo A: forma de onda das entradas e saídas*

</div>

---

### Módulo B — Circuito Projetado

<div align="center">

![Circuito Módulo B](./assets/circuito_modulo_b.png)

*Figura 3 — Circuito lógico do Módulo B projetado no Logisim / Proteus / (software utilizado)*

</div>

---

### Módulo B — Simulação (Waveform)

<div align="center">

![Waveform Módulo B](./assets/waveform_modulo_b.png)

*Figura 4 — Simulação do Módulo B: forma de onda das entradas e saídas*

</div>

---

### Módulo C — Circuito Projetado

<div align="center">

![Circuito Módulo C](./assets/circuito_modulo_c.png)

*Figura 5 — Circuito lógico do Módulo C*

</div>

---

### Módulo C — Simulação (Waveform)

<div align="center">

![Waveform Módulo C](./assets/waveform_modulo_c.png)

*Figura 6 — Simulação do Módulo C: forma de onda das entradas e saídas*

</div>

---

## 🔗 Sistema Completo Conectado

### Circuito Integrado

<div align="center">

![Sistema Completo](./assets/sistema_completo.png)

*Figura 7 — Todos os módulos integrados e conectados formando o sistema final*

</div>

---

### Simulação do Sistema Completo (Waveform)

<div align="center">

![Waveform Sistema Completo](./assets/waveform_sistema_completo.png)

*Figura 8 — Simulação do sistema completo: verificação do comportamento integrado*

</div>

---

## 🏁 Conclusão

-

**Principais aprendizados:**
- ✅ Aprendizado 1 — 
- ✅ Aprendizado 2 — 
- ✅ Aprendizado 3 — 

**Dificuldades encontradas:**  


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
