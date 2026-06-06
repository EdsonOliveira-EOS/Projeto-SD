module memory (
    // INPUTS que eu vou receber na memória RAM
    input wire           clk,            // Clock da FPGA (50MHZ).
    input wire           reset,          // Reset.
    input wire           clear,          // INSTRUÇÃO CLEAR (Que age direto na memória, achei melhor deixar um input só para ele ao invés de fazer a lógica na CPU).
    input wire [3:0]     write_addr,     // 4 bits   — qual registrador escrever.
    input wire [15:0]    write_data,     // 16 bits  — valor a escrever.
    input wire [3:0]     read_addr_1,    // 4 bits   — 1º endereço para um registrador.
    input wire [3:0]     read_addr_2,    // 4 bits   — 2º endereço para um registrador.
    // OUTPUTS
    output wire [15:0]   read_data_1,    // O valor de um registrador que a CPU precisar.
    output wire [15:0]   read_data_2,    // O valor de um segundo registrador que a CPU precisar.
    output reg           memoryalocated  // Valor para dizer que as memórias foram alocadas, bom para deixar transparente.
);  
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
    // Parametros e declaração para a FSM;
    reg estado_atual, proximo_estado;
    parameter IDLE  = 1'b0, 
              WRITE = 1'b1; // Meus estadinhos
    reg [15:0] ram [0:15];  // Declaração da RAM
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
    // Always que controla o fluxo dos estados.
    always @(posedge clk or posedge reset) begin
        if (reset || clear) estado_atual <= IDLE; // reset ou CLEAR volta pro IDLE, pronto pra escrever
        else                estado_atual <= proximo_estado;
    end
    // Always que controla a mudança dos estados
    always @(*) begin
        case(estado_atual)
            IDLE:     proximo_estado = WRITE;
            WRITE:    proximo_estado = IDLE;
            default:  proximo_estado = IDLE;
        endcase
    end
    // Always da lógica e inserção de dados na RAM
    always @(posedge clk or posedge reset) begin
        // Zerar a memória caso reset ou o comando CLEAR
        if (reset || clear) begin
            ram[0]  <= 16'b0;
            ram[1]  <= 16'b0;
            ram[2]  <= 16'b0;
            ram[3]  <= 16'b0;
            ram[4]  <= 16'b0;
            ram[5]  <= 16'b0;
            ram[6]  <= 16'b0;
            ram[7]  <= 16'b0;
            ram[8]  <= 16'b0;
            ram[9]  <= 16'b0;
            ram[10] <= 16'b0;
            ram[11] <= 16'b0;
            ram[12] <= 16'b0;
            ram[13] <= 16'b0;
            ram[14] <= 16'b0;
            ram[15] <= 16'b0;
            memoryalocated <= 0;
        end
        else begin
            case (estado_atual)
                WRITE: begin
                    ram[write_addr]      <= write_data;
                    memoryalocated       <= 1;
                end  
                default: memoryalocated  <= 0;
            endcase
        end
    end
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
    // Entregar a memória que o sistema pode pedir para a RAM
    assign read_data_1 = ram[read_addr_1];
    assign read_data_2 = ram[read_addr_2];
endmodule