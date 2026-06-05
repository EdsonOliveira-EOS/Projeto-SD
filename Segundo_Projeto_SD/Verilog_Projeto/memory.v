module memory (
    // Inputs que eu vou receber na memória RAM
    input wire           reset,          // botão ligar
    input wire           clear,          // INSTRUÇÃO CLEAR (Que age direto na memória, achei melhor deixar um input só para ele)
    input wire           enable,         // botão enviar
    input wire [3:0]     write_addr,     // 4 bits  — qual registrador escrever
    input wire [15:0]    write_data,     // 16 bits — valor a escrever
    input wire [3:0]     read_addr_1,    // 4 bits  — leitura pra Src1
    input wire [3:0]     read_addr_2,    // 4 bits  — leitura pra Src2 (instruções reg x reg)
    // Outputs
    output wire [15:0] read_data_1,
    output wire [15:0] read_data_2
);

    // Parametros e declaração para a FSM;
    reg estado_atual, proximo_estado;
    parameter IDLE = 1'b0, WRITE = 1'b1; // Meus estadinhos
    reg [15:0] ram [0:15]; // Declaração da RAM

    always @(posedge enable or posedge reset or posedge clear) begin
        if (reset || clear) estado_atual <= IDLE;
        else estado_atual <= proximo_estado;
    end

    always @(*)begin
        case(estado_atual)

            IDLE: begin
                if (enable) proximo_estado = WRITE;
                else proximo_estado = IDLE;
            end
            WRITE: begin
                proximo_estado = IDLE;
            end

            default: proximo_estado = IDLE;
        endcase
    end

    always @(posedge enable or posedge reset or posedge clear) begin
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
        end
        else begin
            case (estado_atual)

                IDLE: begin
                end
                WRITE: begin
                    ram[write_addr] <= write_data;
                end
                default: begin
                end

            endcase
        end
    end
    
    assign read_data_1 = ram[read_addr_1];
    assign read_data_2 = ram[read_addr_2];
endmodule
