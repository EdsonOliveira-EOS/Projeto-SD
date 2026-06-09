module module_mini_cpu (
    input wire        clk,           
    input wire        reset,         
    input wire        btn_ligar,     
    input wire        btn_enviar,    
    input wire [17:0] switches,      
    output reg        lcd_rs,
    output reg        lcd_rw,
    output reg        lcd_en,
    output reg [7:0]  lcd_data
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

    memory my_memory (
        .clk(clk), .reset(reset), .clear(mem_clear),
        .write_enabled(mem_write_enabled), .write_addr(mem_write_addr), .write_data(mem_write_data),
        .read_addr_1(mem_read_addr_1), .read_addr_2(mem_read_addr_2),
        .read_data_1(mem_read_data_1), .read_data_2(mem_read_data_2),
        .writedone(mem_writedone)
    );

    alu my_alu (
        .clk(clk), .reset(reset), .operation_enabled(alu_operation_enabled),
        .opcode(alu_opcode), .value1(alu_value1), .value2(alu_value2),
        .resultvalue(alu_resultvalue), .operationdone(alu_operationdone)
    );

    lcd_controller my_lcd (
        .clk(clk),
        .reset(reset),
        .start_print(current_state == STATE_LCD_UPDATE),
        .opcode(opcode),
        .dest_reg(r_dest),
        .resultvalue(mem_read_data_1),
        .LCD_RS(lcd_rs),
        .LCD_RW(lcd_rw),
        .LCD_EN(lcd_en),
        .LCD_DATA(lcd_data)
    );

    wire send_triggered; 
    wire power_triggered;

    localparam STATE_POWERED_OFF = 4'd0, STATE_IDLE = 4'd1, STATE_FETCH = 4'd2, STATE_DECODE = 4'd3, 
    STATE_ALU_START = 4'd4, STATE_ALU_WAIT = 4'd5, STATE_MEM_WRITE = 4'd6, STATE_MEM_WAIT = 4'd7, STATE_LCD_UPDATE = 4'd8;

    reg [3:0] current_state, next_state;
    reg [17:0] instruction_register;
    reg [2:0] opcode;
    reg [3:0] r_dest;
    reg [3:0] r_src1;
    reg [3:0] r_src2;
    reg [15:0] immediate_extended;

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
                // Route execution path based on extracted opcode type 
                if (opcode == 3'b110)      // CLEAR Command [cite: 94, 129]
                    next_state = STATE_MEM_WRITE; 
                else if (opcode == 3'b111) // DISPLAY Command [cite: 94, 131]
                    next_state = STATE_LCD_UPDATE;
                else if (opcode == 3'b000) // LOAD Command [cite: 94, 123]
                    next_state = STATE_MEM_WRITE;
                else                       // Arithmetic Instructions [cite: 96, 106]
                    next_state = STATE_ALU_START;
            end

            STATE_ALU_START: begin
                next_state = STATE_ALU_WAIT;
            end

            STATE_ALU_WAIT: begin
                // Stay until ALU finishes operation pipeline
                next_state = (alu_operationdone) ? STATE_MEM_WRITE : STATE_ALU_WAIT;
            end

            STATE_MEM_WRITE: begin
                next_state = STATE_MEM_WAIT;
            end

            STATE_MEM_WAIT: begin
                // Stay until memory block finishes register changes
                next_state = (mem_writedone || opcode == 3'b110) ? STATE_LCD_UPDATE : STATE_MEM_WAIT;
            end

            STATE_LCD_UPDATE: begin
                if (opcode == 3'b111) begin  
                    mem_read_addr_1 <= r_dest; 
                end
            end

            default: next_state = STATE_POWERED_OFF;
        endcase
    end
    
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= STATE_POWERED_OFF;
            instruction_register <= 18'b0;
            mem_clear <= 0;
            // ... clear operational signals
        end else begin
            current_state <= next_state;
            
            case (current_state)
                STATE_POWERED_OFF: begin
                    mem_clear <= 1; // Zero out variables during shutdown [cite: 6, 75]
                end

                STATE_IDLE: begin
                    mem_clear             <= 0;
                    mem_write_enabled     <= 0;
                    alu_operation_enabled <= 0;
                end

                STATE_FETCH: begin
                    instruction_register <= switches; // Latch inputs safely [cite: 80]
                end

                STATE_DECODE: begin
                    // Extract instruction formats dynamically by verifying opcodes [cite: 88]
                    // You will look into instruction_register to parse fields 
                    // based on Type 1, Type 2, or Type 3 definitions.
                end

                STATE_ALU_START: begin
                    alu_operation_enabled <= 1;
                    alu_opcode            <= opcode;
                    
                    // Route values based on instruction type context
                    mem_read_addr_1       <= r_src1;
                    mem_read_addr_2       <= r_src2;
                    
                    // Assign values to pass directly to your ALU input ports
                    alu_value1            <= mem_read_data_1;
                    // If immediate type, pass immediate_extended; else use mem_read_data_2 [cite: 97, 107]
                end

                STATE_MEM_WRITE: begin
                    alu_operation_enabled <= 0;
                    if (opcode == 3'b110) begin
                        mem_clear <= 1; // Trigger memory clear block directly [cite: 130]
                    end else begin
                        mem_write_enabled <= 1;
                        mem_write_addr    <= r_dest;
                        // Select between raw data from LOAD or processed results from ALU [cite: 99, 124]
                        mem_write_data    <= (opcode == 3'b000) ? immediate_extended : alu_resultvalue;
                    end
                end
                
                STATE_MEM_WAIT: begin
                    mem_write_enabled <= 0;
                    mem_clear         <= 0;
                end
            endcase
        end
    end
endmodule
