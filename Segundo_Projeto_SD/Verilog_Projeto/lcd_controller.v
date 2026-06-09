module lcd_controller (
    input wire         clk,               // Clock de 50 MHz
    input wire         reset,             // Reset global
    input wire         start_print,       // Sinal da ALU
    input wire [2:0]   opcode,            // Opcode da instrução atual
    input wire [3:0]   dest_reg,          // Registrador de destino [0000]
    input wire [15:0]  resultvalue,       // valor armazenado na memory

    output reg         LCD_RS,            // 0: Comando / 1: Caractere
    output wire        LCD_RW,            // --------------------------------------
    output reg         LCD_EN,            // Sinal de Enable                      |
    output reg  [7:0]  LCD_DATA           // Barramento de dados de 8 bits        |
);                                                                               //
                                                                                //
    assign LCD_RW = 1'b0; // Sempre escrita  <---------------------------------

    // TICK DE 1ms
    reg [19:0] clk_counter;
    reg        tick; 
    reg [3:0]  char_index; // Ponteiro de qual caractere estamos enviando
    reg [3:0] estado_atual, prox_estado;

    parameter ST_default     = 4'd0,
              ST_lcd8b       = 4'd1, // Configura LCD
              ST_iniciar     = 4'd2, // Liga tela, desliga cursor
              ST_clr         = 4'd3, // Limpa display
              ST_avancar     = 4'd4, // Avança cursor
              ST_escrever_L1 = 4'd5, // Escreve os dados em cima
              ST_mover_L2    = 4'd6, // Pula para a segunda linha
              ST_escrever_L2 = 4'd7, // Escreve os dados em baixo
              ST_feito       = 4'd8;

    // Registrador de Estado
    always @(posedge clk or posedge reset) begin
        if (reset) 
            estado_atual <= ST_default;
        else if (tick) 
            estado_atual <= prox_estado;
    end

    // Controle do contador de clock e do char_index
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 20'b0;
            tick        <= 1'b0;
            char_index  <= 4'b0;
        end else begin
            if (clk_counter == 20'd50_000) begin // Gerador de tick de 1ms
                clk_counter <= 20'b0;
                tick        <= 1'b1;
            end else begin
                clk_counter <= clk_counter + 1'b1;
                tick        <= 1'b0;
            end
            if (tick) begin
                if (estado_atual == ST_escrever_L1 || estado_atual == ST_escrever_L2)
                    char_index <= char_index + 1'b1;
                else
                    char_index <= 4'b0; // Zera ao mudar de linha ou sair da escrita
            end
        end
    end

    wire [7:0] r_bit3 = dest_reg[3] ? 8'h31 : 8'h30;
    wire [7:0] r_bit2 = dest_reg[2] ? 8'h31 : 8'h30;
    wire [7:0] r_bit1 = dest_reg[1] ? 8'h31 : 8'h30;
    wire [7:0] r_bit0 = dest_reg[0] ? 8'h31 : 8'h30;

    wire sinal_negativo = resultvalue[15]; // O bit 15 indica se é negativo
    wire [15:0] valor_absoluto = sinal_negativo ? (~resultvalue + 1'b1) : resultvalue;
    wire [7:0]  ascii_s        = sinal_negativo ? 8'h2D : 8'h20; 
    wire [15:0] display_val = (valor_absoluto > 16'd9999) ? 16'd9999 : valor_absoluto;
    
    wire [7:0]  ascii_m      = 8'h30 + ((display_val / 1000) % 10);    // Decodificador B->D
    wire [7:0]  ascii_c      = 8'h30 + ((display_val / 100) % 10);
    wire [7:0]  ascii_d      = 8'h30 + ((display_val / 10) % 10);
    wire [7:0]  ascii_u      = 8'h30 + (display_val % 10);

    always @(*) begin
        prox_estado = estado_atual;
        LCD_RS      = 1'b1;   
        LCD_DATA    = 8'h20;  

        case (estado_atual)
            ST_default: prox_estado = start_print ? ST_lcd8b : ST_default;
            ST_lcd8b:   prox_estado = ST_iniciar;
            ST_iniciar: prox_estado = ST_clr;
            ST_clr:     prox_estado = ST_avancar;
            ST_avancar: prox_estado = ST_escrever_L1;
            
            // Espera escrever todos os 16 caracteres da Linha 1
            ST_escrever_L1: if (char_index == 4'd15) prox_estado = ST_mover_L2; 
            ST_mover_L2:                             prox_estado = ST_escrever_L2;
            
            // Espera escrever todos os 16 caracteres da Linha 2
            ST_escrever_L2: if (char_index == 4'd15)  prox_estado = ST_feito;
            
            ST_feito: prox_estado = start_print ? ST_feito : ST_default;
            default:  prox_estado = ST_default;
        endcase

        // CONTEÚDO DA TELA
        case (estado_atual)
            ST_lcd8b:    begin LCD_RS = 1'b0; LCD_DATA = 8'h38; end 
            ST_iniciar:  begin LCD_RS = 1'b0; LCD_DATA = 8'h0C; end 
            ST_clr:      begin LCD_RS = 1'b0; LCD_DATA = 8'h01; end 
            ST_avancar:  begin LCD_RS = 1'b0; LCD_DATA = 8'h06; end 
            ST_mover_L2: begin LCD_RS = 1'b0; LCD_DATA = 8'hC0; end 

            // Mapeamento da Linha 1
            ST_escrever_L1: begin
                LCD_RS = 1'b1;
                case (char_index)
                    4'd0: case(opcode) 3'b000:"L"; 3'b001:"A"; 3'b010:"A"; 3'b011:"S"; 3'b100:"S"; 3'b101:"M"; 3'b110:"C"; 3'b111:"D"; default:" "; endcase 
                    4'd1: case(opcode) 3'b000:"O"; 3'b001:"D"; 3'b010:"D"; 3'b011:"U"; 3'b100:"U"; 3'b101:"U"; 3'b110:"L"; 3'b111:"P"; default:" "; endcase
                    4'd2: case(opcode) 3'b000:"A"; 3'b001:"D"; 3'b010:"D"; 3'b011:"B"; 3'b100:"B"; 3'b101:"L"; 3'b110:"R"; 3'b111:"L"; default:" "; endcase
                    4'd3: case(opcode) 3'b000:"D";             3'b010:"I";             3'b100:"I";                                     default:" "; endcase
                    // Mostrador do registrador
                    4'd10: LCD_DATA = "[";
                    4'd11: LCD_DATA = r_bit3;
                    4'd12: LCD_DATA = r_bit2;
                    4'd13: LCD_DATA = r_bit1;
                    4'd14: LCD_DATA = r_bit0;
                    4'd15: LCD_DATA = "]";
                    default: LCD_DATA = 8'h20; // Preenche o meio com espaços " "
                endcase
            end

            ST_escrever_L2: begin
                LCD_RS = 1'b1;
                case (char_index)
                    4'd11:   LCD_DATA = ascii_s; // Sinal: '-' ou ' '
                    4'd12:   LCD_DATA = ascii_m; // Milhar
                    4'd13:   LCD_DATA = ascii_c; // Centena
                    4'd14:   LCD_DATA = ascii_d; // Dezena
                    4'd15:   LCD_DATA = ascii_u; // Unidade
                    default: LCD_DATA = 8'h20;   // Preenche o início com espaços " "
                endcase
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            LCD_EN <= 1'b0;
        end else begin
            if (estado_atual != ST_default && estado_atual != ST_feito) begin
                if (clk_counter > 20'd10 && clk_counter < 20'd30_000)
                    LCD_EN <= 1'b1;
                else
                    LCD_EN <= 1'b0;
            end else begin
                LCD_EN <= 1'b0;
            end
        end
    end
endmodule
