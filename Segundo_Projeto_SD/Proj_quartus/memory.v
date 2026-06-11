module memory (
    // INPUTS que eu vou receber na memória RAM.
    input wire           clk,            // Clock da FPGA (50MHZ).
    input wire           reset,          // Reset assíncrono.
    input wire           clear,          // INSTRUÇÃO CLEAR (Síncrona).
    input wire           write_enabled,  // Controle de escrita da CPU.
    input wire [3:0]     write_addr,     // 4 bits  — qual registrador escrever.
    input wire [15:0]    write_data,     // 16 bits — valor a escrever.
    input wire [3:0]     read_addr_1,    // 4 bits  — 1º endereço para um registrador.
    input wire [3:0]     read_addr_2,    // 4 bits  — 2º endereço para um registrador.
    // OUTPUTS
    output wire [15:0]   read_data_1,    // O valor de um registrador que a CPU precisar.
    output wire [15:0]   read_data_2,    // O valor de um segundo registrador que a CPU precisar.
    output reg           writedone       // Valor para dizer que as memórias foram alocadas.
);  

// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Parametros e declaração para a FSM;
    reg estado_atual, proximo_estado;
    localparam IDLE  = 1'b0, 
               WRITE = 1'b1;  
               
    reg [15:0] ram [0:15];    // Declaração dos 16 registradores de 16-bits
    integer i;                // Variável auxiliar para loop de inicialização síncrona

// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// 1. Controle do fluxo de estados (FSM Sequencial)
    always @(posedge clk or posedge reset) begin
        if (reset) 
            estado_atual <= IDLE;
        else if (clear) 
            estado_atual <= IDLE;
        else 
            estado_atual <= proximo_estado;
    end

// 2. Lógica combinacional da FSM
    always @(*) begin
        case(estado_atual)
            IDLE:     proximo_estado = (write_enabled) ? WRITE : IDLE;
            WRITE:    proximo_estado = IDLE;
            default:  proximo_estado = IDLE;
        endcase
    end

// 3. Lógica síncrona de escrita e limpeza da RAM
    always @(posedge clk) begin
        if (clear) begin
            ram[0] <= 16'b0;
            ram[1] <= 16'b0;
            ram[2] <= 16'b0;
            ram[3] <= 16'b0;
            ram[4] <= 16'b0;
            ram[5] <= 16'b0;
            ram[6] <= 16'b0;
            ram[7] <= 16'b0;
            ram[8] <= 16'b0;
            ram[9] <= 16'b0;
            ram[10] <= 16'b0;
            ram[11] <= 16'b0;
            ram[12] <= 16'b0;
            ram[13] <= 16'b0;
            ram[14] <= 16'b0;
            ram[15] <= 16'b0;
            writedone <= 0;
        end
        else begin
            case (estado_atual)
                IDLE: begin
                    writedone <= 0;
                end
                WRITE: begin
                    ram[write_addr] <= write_data;
                    writedone       <= 1;
                end  
                default: begin
                    writedone <= 0;
                end
            endcase
        end
    end

// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Leituras assíncronas (Contínuas)
    assign read_data_1 = (reset) ? 16'b0 : ram[read_addr_1];
    assign read_data_2 = (reset) ? 16'b0 : ram[read_addr_2];

endmodule