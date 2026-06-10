module lcd_controller (
    input wire        clk,              
    input wire        reset,             
    input wire        system_on,         
    input wire        start_print,       
    input wire        valid_instr,       
    input wire [2:0]  opcode,            
    input wire [3:0]  dest_reg,         
    input wire [15:0] resultvalue,      
    output reg        LCD_RS,           
    output wire       LCD_RW,           
    output reg        LCD_EN,                                     
    output reg  [7:0] LCD_DATA,         
    output reg        lcd_ready
);                                                                                                                  
    assign LCD_RW = 1'b0; 

    reg [19:0] clk_counter;
    reg        tick; 
    reg [3:0]  char_index; 
    reg [3:0]  estado_atual, prox_estado;

    parameter ST_default     = 4'd0,
              ST_init1       = 4'd1,
              ST_init2       = 4'd2,
              ST_init3       = 4'd3,
              ST_iniciar     = 4'd4,
              ST_clr         = 4'd5,
              ST_avancar     = 4'd6,
              ST_escrever_L1 = 4'd7,
              ST_mover_L2    = 4'd8,
              ST_escrever_L2 = 4'd9,
              ST_feito       = 4'd10,
              ST_wait_clr1   = 4'd11,
              ST_wait_clr2   = 4'd12,
              ST_SHUTDOWN    = 4'd13,   
              ST_OFF         = 4'd14;   

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            estado_atual <= ST_init1; 
        end else begin
            if (!system_on && (estado_atual == ST_default || estado_atual == ST_feito)) begin
                estado_atual <= ST_SHUTDOWN;
            end else if (tick) begin
                estado_atual <= prox_estado;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            clk_counter <= 20'b0;
            tick        <= 1'b0;
            char_index  <= 4'b0;
        end else begin
            if (clk_counter == 20'd49999) begin 
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
                    char_index <= 4'b0; 
            end
        end
    end

    wire [7:0] r_bit3 = dest_reg[3] ? 8'h31 : 8'h30;
    wire [7:0] r_bit2 = dest_reg[2] ? 8'h31 : 8'h30;
    wire [7:0] r_bit1 = dest_reg[1] ? 8'h31 : 8'h30;
    wire [7:0] r_bit0 = dest_reg[0] ? 8'h31 : 8'h30;

    wire sinal_negativo = resultvalue[15]; 
    wire [15:0] valor_absoluto = sinal_negativo ? (~resultvalue + 1'b1) : resultvalue;
    
    wire [7:0]  ascii_s = sinal_negativo ? 8'h2D : 8'h2B; 
    wire [15:0] display_val = valor_absoluto;
    
    wire [7:0]  ascii_dm     = 8'h30 + (display_val / 10000);         
    wire [7:0]  ascii_m      = 8'h30 + ((display_val / 1000) % 10);   
    wire [7:0]  ascii_c      = 8'h30 + ((display_val / 100) % 10);    
    wire [7:0]  ascii_d      = 8'h30 + ((display_val / 10) % 10);     
    wire [7:0]  ascii_u      = 8'h30 + (display_val % 10);            

    always @(*) begin
        prox_estado = estado_atual;
        LCD_RS      = 1'b1;   
        LCD_DATA    = 8'h20; 
        lcd_ready   = 1'b0;

        case (estado_atual)
            ST_OFF:       prox_estado = system_on ? ST_init1 : ST_OFF;
            ST_SHUTDOWN:  prox_estado = ST_wait_clr1;
            ST_clr:       prox_estado = ST_wait_clr1;
            ST_wait_clr1: prox_estado = ST_wait_clr2;
            
            ST_wait_clr2: prox_estado = system_on ? ST_avancar : ST_OFF; 
            
            ST_default: begin
                    prox_estado = start_print ? ST_init1 : ST_default;
                    lcd_ready = !start_print;
                end
            ST_init1:   prox_estado = ST_init2;
            ST_init2:   prox_estado = ST_init3;
            ST_init3:   prox_estado = ST_iniciar;
            ST_iniciar: prox_estado = ST_clr;
            ST_avancar:   prox_estado = ST_escrever_L1;
            ST_escrever_L1: if (char_index == 4'd15) prox_estado = ST_mover_L2; 
            ST_mover_L2:                             prox_estado = ST_escrever_L2;
            ST_escrever_L2: if (char_index == 4'd15)  prox_estado = ST_feito;
            
            ST_feito: begin
                    prox_estado = system_on ? (start_print ? ST_feito : ST_default) : ST_OFF;
                    lcd_ready = 1'b1;
                end
            default:  prox_estado = ST_OFF;
        endcase

        case (estado_atual)

            ST_OFF: begin LCD_DATA = 8'h01; end
            ST_init1:    begin LCD_RS = 1'b0; LCD_DATA = 8'h38; end
            ST_init2:    begin LCD_RS = 1'b0; LCD_DATA = 8'h38; end
            ST_init3:    begin LCD_RS = 1'b0; LCD_DATA = 8'h38; end
            
            ST_iniciar:  begin LCD_RS = 1'b0; LCD_DATA = system_on ? 8'h0C : 8'h08; end 
            
            ST_clr:      begin LCD_RS = 1'b0; LCD_DATA = 8'h01; end 
            ST_SHUTDOWN: begin LCD_RS = 1'b0; LCD_DATA = 8'h01; end 
            ST_avancar:  begin LCD_RS = 1'b0; LCD_DATA = 8'h06; end 
            ST_mover_L2: begin LCD_RS = 1'b0; LCD_DATA = 8'hC0; end 

            ST_escrever_L1: begin
                LCD_RS = 1'b1;
                if (!valid_instr) begin
                    if (char_index >= 4'd0 && char_index <= 4'd7)        LCD_DATA = "-";
                    else if (char_index == 4'd10)                        LCD_DATA = "[";
                    else if (char_index >= 4'd11 && char_index <= 4'd14) LCD_DATA = "-";
                    else if (char_index == 4'd15)                        LCD_DATA = "]";
                    else                                                 LCD_DATA = 8'h20;
                end else begin
                    case (char_index)
                        4'd0: case(opcode) 3'b000:LCD_DATA = "L"; 3'b001:LCD_DATA = "A"; 3'b010:LCD_DATA = "A"; 3'b011:LCD_DATA = "S"; 3'b100:LCD_DATA = "S"; 3'b101:LCD_DATA = "M"; 3'b110:LCD_DATA = "C"; 3'b111:LCD_DATA = "D"; default:LCD_DATA = 8'h20; endcase 
                        4'd1: case(opcode) 3'b000:LCD_DATA = "O"; 3'b001:LCD_DATA = "D"; 3'b010:LCD_DATA = "D"; 3'b011:LCD_DATA = "U"; 3'b100:LCD_DATA = "U"; 3'b101:LCD_DATA = "U"; 3'b110:LCD_DATA = "L"; 3'b111:LCD_DATA = "P"; default:LCD_DATA = 8'h20; endcase
                        4'd2: case(opcode) 3'b000:LCD_DATA = "A"; 3'b001:LCD_DATA = "D"; 3'b010:LCD_DATA = "D"; 3'b011:LCD_DATA = "B"; 3'b100:LCD_DATA = "B"; 3'b101:LCD_DATA = "L"; 3'b110:LCD_DATA = "R"; 3'b111:LCD_DATA = "L"; default:LCD_DATA = 8'h20; endcase
                        4'd3: case(opcode) 3'b000:LCD_DATA = "D";                        3'b010:LCD_DATA = "I";                        3'b100:LCD_DATA = "I";                                                                              default:LCD_DATA = 8'h20; endcase
                        4'd10: LCD_DATA = "[";
                        4'd11: LCD_DATA = r_bit3;
                        4'd12: LCD_DATA = r_bit2;
                        4'd13: LCD_DATA = r_bit1;
                        4'd14: LCD_DATA = r_bit0;
                        4'd15: LCD_DATA = "]";
                        default: LCD_DATA = 8'h20; 
                    endcase
                end
            end

            ST_escrever_L2: begin
                LCD_RS = 1'b1;
                case (char_index)
                    4'd10:   LCD_DATA = ascii_s;  
                    4'd11:   LCD_DATA = ascii_dm; 
                    4'd12:   LCD_DATA = ascii_m;  
                    4'd13:   LCD_DATA = ascii_c;  
                    4'd14:   LCD_DATA = ascii_d;  
                    4'd15:   LCD_DATA = ascii_u;  
                    default: LCD_DATA = 8'h20;    
                endcase
            end
        endcase
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            LCD_EN <= 1'b0;
        end
        else begin
            if (estado_atual != ST_default && 
                estado_atual != ST_feito &&
                estado_atual != ST_OFF &&            
                estado_atual != ST_wait_clr1 && 
                estado_atual != ST_wait_clr2) begin
                
                if (clk_counter > 20'd1000 && clk_counter < 20'd2000)
                    LCD_EN <= 1'b1;
                else
                    LCD_EN <= 1'b0;
            end
            else begin
                LCD_EN <= 1'b0;
            end
        end
    end
endmodule