module alu (
    // INPUTS recebidos na ULA
    input wire        enable,         // Botão enviar.
    input wire [2:0]  opcode,         // 3 bits  — O código da operaçãozinha.
    input wire [15:0] value1,         // 16 bits — Valor 1 iterado.
    input wire [15:0] value2,         // 16 bits — Valor 2 iterado.
    // OUTPUTS
    output reg [15:0] resultvalue     // 16 bits — Resultado da obra. Por que não aumentar? Porque acima de 16 bits é para dar overflow e mostrar 9999 no display.
);
    // Parametros e declaração para a FSM;
    reg estado_atual, proximo_estado; 
    parameter IDLE = 1'b0,
              ARITHMETIC = 1'b1;

    // Forçar o estado para IDLE
    initial begin
        estado_atual = IDLE;
    end
    // Always que controla o fluxo dos estados, eu uso a mesma ideia da memória, o posedge é para já minha máquina já transicionar o estado quando o botão for PRESSIONADO.
    always @(posedge enable) begin  
        estado_atual <= proximo_estado;
    end
    // Always que controla a mudança dos estados
    always @(*) begin
        case (estado_atual)
            IDLE: proximo_estado = ARITHMETIC;
            ARITHMETIC: proximo_estado = IDLE;
            default: proximo_estado = IDLE;
        endcase
    end
    // Always da lógica e entrega do resultado dependendo do opcode.
    always @(negedge enable) begin
        case(estado_atual)
            ARITHMETIC: begin
                case (opcode)
                3'b001: resultvalue <= value1 + value2;
                3'b010: resultvalue <= value1 + value2;
                3'b011: resultvalue <= value1 - value2;
                3'b100: resultvalue <= value1 - value2;
                3'b101: resultvalue <= value1 * value2;
                default: resultvalue <= 16'd0;
                endcase
            end
            default: resultvalue <= 16'd0;
        endcase
    end
endmodule