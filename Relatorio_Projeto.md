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
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  MÓDULO A   │────▶│  MÓDULO B  │────▶│  MÓDULO C   │
│ (Entradas)  │     │    (ULA)    │     │  (Saídas)   │
└─────────────┘     └─────────────┘     └─────────────┘
```
---

### 📦 Módulos Desenvolvidos

<details>
<summary><strong>🔷 Módulo A — Entradas</strong></summary>

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

### Módulo A — Tabela da Verdade

| Entrada A | Entrada B | Saída Y |
|:---------:|:---------:|:-------:|
| 0 | 0 | 0 |
| 0 | 1 | 1 |
| 1 | 0 | 1 |
| 1 | 1 | 0 |

> 🗒️ *Adicione ou remova colunas/linhas conforme a necessidade do módulo.*

---

### Mapa de Karnaugh — Módulo A

```
        B=0   B=1
  A=0 |  0  |  1  |
  A=1 |  1  |  0  |
```

**Equação simplificada:**

```
Y = A'B + AB'  →  Y = A ⊕ B
```

---

### Módulo B — Tabela da Verdade

| Entrada A | Entrada B | Entrada C | Saída Y |
|:---------:|:---------:|:---------:|:-------:|
| 0 | 0 | 0 | 0 |
| 0 | 0 | 1 | 0 |
| 0 | 1 | 0 | 0 |
| 0 | 1 | 1 | 1 |
| 1 | 0 | 0 | 0 |
| 1 | 0 | 1 | 1 |
| 1 | 1 | 0 | 1 |
| 1 | 1 | 1 | 1 |

**Equação simplificada:**

```
Y = AB + AC + BC
```

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
