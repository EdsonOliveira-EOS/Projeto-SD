module module_mini_cpu (
    input wire        clk,           
    input wire        reset,         
    input wire        btn_ligar,     
    input wire        btn_enviar,    
    input wire [17:0] switches,      
    output wire       lcd_rs,        // Mudado para wire pois agora quem controla é o submódulo
    output wire       lcd_rw,        // Mudado para wire
    output wire       lcd_en,        // Mudado para wire
    output wire [7:0] lcd_data,      // Mudado para wire
    output wire[15:0] Temp_mem_1,
    output reg        ON = 0
);
    reg         mem_write_enabled;
    reg  [3:0]  mem_write_addr;
    reg  [15:0] mem_write_data;
    reg  [3:0]  mem_read_addr_1, mem_read_addr_2;
    wire [15:0] mem_read_data_1, mem_read_data_2;
    wire        mem_writedone;
    reg         mem_clear;

    reg         alu_operation_enabled;
    reg  [2:0]  alu_opcode;
    reg  [15:0] alu_value1, alu_value2;
    wire [15:0] alu_resultvalue;
    wire        alu_operationdone;

    // Sinais de controle exclusivos para o LCD
    reg         lcd_start_print;
    wire        lcd_ready;

    module_alu ULA (
        .clk(clk), .reset(reset_triggered), .operation_enabled(alu_operation_enabled),
        .opcode(alu_opcode), .value1(alu_value1), .value2(alu_value2),
        .resultvalue(alu_resultvalue), .operationdone(alu_operationdone)
    );
     
    memory MEMORY (
        .clk(clk), .reset(reset_triggered), .clear(mem_clear),
        .write_enabled(mem_write_enabled), .write_addr(mem_write_addr), .write_data(mem_write_data),
        .read_addr_1(mem_read_addr_1), .read_addr_2(mem_read_addr_2),
        .read_data_1(mem_read_data_1), .read_data_2(mem_read_data_2),
        .writedone(mem_writedone)
    );

    // INSTANCIAÇÃO DO CONTROLADOR DO LCD
    lcd_controller LCD_DRIVER (
        .clk(clk),
        .reset(reset_triggered),
        .start_print(lcd_start_print),
        .opcode(opcode),
        .dest_reg(r_dest),
        .resultvalue((opcode == 3'b000) ? immediate_extended : alu_resultvalue), // Passa o dado correto que foi computado
        .LCD_RS(lcd_rs),
        .LCD_RW(lcd_rw),
        .LCD_EN(lcd_en),
        .LCD_DATA(lcd_data),
        .lcd_ready(lcd_ready) // Nova porta de controle de feedback para a CPU
    );

    wire send_triggered; 
    wire power_triggered;
    wire reset_triggered;

    localparam STATE_POWERED_OFF = 4'd0, STATE_IDLE = 4'd1, STATE_FETCH = 4'd2, STATE_DECODE = 4'd3, 
    STATE_ALU_START = 4'd4, STATE_ALU_WAIT = 4'd5, STATE_MEM_WRITE = 4'd6, STATE_MEM_WAIT = 4'd7, STATE_LCD_UPDATE = 4'd8;

    reg [3:0] current_state = STATE_POWERED_OFF, next_state;
    reg [17:0] instruction_register;
    reg [2:0] opcode;
    reg [3:0] r_dest;
    reg [3:0] r_src1;
    reg [3:0] r_src2;
    reg [15:0] immediate_extended;

    assign Temp_mem_1 = mem_read_data_1;

    // FSM Combinacional (Próximo Estado)
    always @(*) begin
        case (current_state)
            STATE_POWERED_OFF: begin
                next_state = (power_triggered) ? STATE_IDLE : STATE_POWERED_OFF;
            end
            
            STATE_IDLE: begin
                if (power_triggered) 
                    next_state = STATE_POWERED_OFF;
                else 
                    next_state = (send_triggered) ? STATE_FETCH : STATE_IDLE;
            end
            
            STATE_FETCH: begin
                next_state = STATE_DECODE;
            end
            
            STATE_DECODE: begin
                if (instruction_register[17:15] == 3'b110)      // CLEAR
                    next_state = STATE_MEM_WRITE; 
                else if (instruction_register[17:15] == 3'b111) // DISPLAY
                    next_state = STATE_LCD_UPDATE;
                else if (instruction_register[17:15] == 3'b000) // LOAD
                    next_state = STATE_MEM_WRITE;
                else                                            // Aritméticas
                    next_state = STATE_ALU_START;
            end 

            STATE_ALU_START: begin
                next_state = STATE_ALU_WAIT;
            end

            STATE_ALU_WAIT: begin
                next_state = (alu_operationdone) ? STATE_MEM_WRITE : STATE_ALU_WAIT;
            end

            STATE_MEM_WRITE: begin
                next_state = STATE_MEM_WAIT;
            end

            STATE_MEM_WAIT: begin
                next_state = (mem_writedone || opcode == 3'b110) ? STATE_LCD_UPDATE : STATE_MEM_WAIT;
            end

            STATE_LCD_UPDATE: begin
                // A CPU agora espera o sinal de pronto do módulo do LCD para poder voltar ao IDLE
                next_state = (lcd_ready) ? STATE_IDLE : STATE_LCD_UPDATE; 
            end

            default: next_state = STATE_POWERED_OFF;
        endcase
    end
    
    // FSM Sequencial (Lógica de Controle e Sinais de Dados)
    always @(posedge clk or posedge reset_triggered) begin
        if (reset_triggered) begin
            current_state         <= STATE_POWERED_OFF;
            instruction_register  <= 18'b0;
            mem_clear             <= 0;
            opcode                <= 3'b0;
            r_dest                <= 4'b0;
            r_src1                <= 4'b0;
            r_src2                <= 4'b0;
            immediate_extended    <= 16'b0;
            mem_write_enabled     <= 0;
            mem_write_addr        <= 4'b0;
            mem_write_data        <= 16'b0;
            mem_read_addr_1       <= 4'b0;
            mem_read_addr_2       <= 4'b0;
            alu_operation_enabled <= 0;
            alu_opcode            <= 3'b0;
            alu_value1            <= 16'b0;
            alu_value2            <= 16'b0;
            lcd_start_print       <= 0;
        end else begin
            current_state <= next_state;
            
            case (current_state)
                STATE_POWERED_OFF: begin
                    mem_clear <= 1; 
                    ON        <= 0;
                end

                STATE_IDLE: begin
                    mem_clear             <= 0;
                    mem_write_enabled     <= 0;
                    alu_operation_enabled <= 0;
                    lcd_start_print       <= 0; // Garante que o sinal de start caia ao retornar
                    ON                    <= 1;
                end

                STATE_FETCH: begin
                    instruction_register <= switches; 
                end

                STATE_DECODE: begin
                    opcode             <= instruction_register[17:15];
                    r_dest             <= instruction_register[14:11];
                    r_src1             <= instruction_register[10:7];
                    r_src2             <= instruction_register[6:3];
                    immediate_extended <= {9'b0, instruction_register[6:0]};
                    
                    mem_read_addr_1    <= instruction_register[10:7];
                    mem_read_addr_2    <= instruction_register[6:3];
                end

                STATE_ALU_START: begin
                    alu_operation_enabled <= 1;
                    alu_opcode            <= opcode;
                end

                STATE_ALU_WAIT: begin
                    alu_value1            <= mem_read_data_1;
                    if (opcode == 3'b001 || opcode == 3'b011) begin
                        alu_value2        <= mem_read_data_2;
                    end else begin
                        alu_value2        <= immediate_extended;
                    end
                end

                STATE_MEM_WRITE: begin
                    alu_operation_enabled <= 0;
                    if (opcode == 3'b110) begin
                        mem_clear <= 1; 
                    end else begin
                        mem_write_enabled   <= 1;
                        mem_write_addr      <= r_dest;
                        mem_write_data      <= (opcode == 3'b000) ? immediate_extended : alu_resultvalue;
                    end
                end
                
                STATE_MEM_WAIT: begin
                    mem_write_enabled <= 0;
                    mem_clear         <= 0;
                end

                STATE_LCD_UPDATE: begin
                    lcd_start_print <= 1; // Ativa a impressão física na tela
                end
            endcase
        end
    end

    wire clean_btn_ligar;
    wire clean_btn_enviar;
    wire clean_rst;

    debouncer db_ligar  (.clk(clk), .btn_in(btn_ligar),  .btn_out(clean_btn_ligar));
    debouncer db_enviar (.clk(clk), .btn_in(btn_enviar), .btn_out(clean_btn_enviar));
    debouncer db_rst    (.clk(clk), .btn_in(reset),      .btn_out(clean_rst));

    reg btn_ligar_d, btn_enviar_d, btn_reset_d;
    always @(posedge clk or posedge reset_triggered) begin
        if (reset_triggered) begin
            btn_ligar_d  <= 1'b1; 
            btn_enviar_d <= 1'b1;
            btn_reset_d  <= 1'b1;
        end else begin
            btn_ligar_d  <= btn_ligar;
            btn_enviar_d <= btn_enviar;
            btn_reset_d  <= reset;
        end
    end
    
    assign power_triggered = (btn_ligar & !btn_ligar_d);
    assign send_triggered  = (btn_enviar & !btn_enviar_d);
    assign reset_triggered = (reset & !btn_reset_d);
endmodule