module module_alu (
    // INPUTS recebidos na ULA
    input wire        clk,                // Clock da FPGA (50MHZ).
    input wire        reset,              // Reset.
    input wire        operation_enabled,  // A ALU só vai mudar de estados caso a CPU deixar.
    input wire [2:0]  opcode,             // 3 bits  — O código da operaçãozinha.
    input wire [15:0] value1,             // 16 bits — Valor 1 iterado.
    input wire [15:0] value2,             // 16 bits — Valor 2 iterado.
    // OUTPUTS
    output reg [15:0] resultvalue,        // 16 bits — Resultado da obra. Por que não aumentar? Porque acima de 16 bits é para dar overflow e mostrar 9999 no display.
    output reg        operationdone       // 1 bit   — Sinaliza pra CPU que a operação foi realizada para ter transparência.
);
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Parametros e declaração para a FSM;
    reg estado_atual, proximo_estado; 
    parameter IDLE       = 1'b0,
              ARITHMETIC = 1'b1;
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Always que controla o fluxo dos estados
    always @(posedge clk or posedge reset) begin
        if (reset) estado_atual <= IDLE;
        else       estado_atual <= proximo_estado;
    end
// Always que controla a mudança dos estados
    always @(*) begin
        case (estado_atual)
            IDLE:       proximo_estado = (operation_enabled) ? ARITHMETIC : IDLE;
            ARITHMETIC: proximo_estado = IDLE;
            default:    proximo_estado = IDLE;
        endcase
    end
// Always da lógica e entrega do resultado dependendo do opcode.
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            resultvalue   <= 16'h0;
            operationdone <= 0;
        end
        else begin
            case(estado_atual)
                ARITHMETIC: begin
                    case (opcode)
                        3'b001: begin resultvalue   <= value1 + value2; operationdone <= 1; end
                        3'b010: begin resultvalue   <= value1 + value2; operationdone <= 1; end
                        3'b011: begin resultvalue   <= value1 - value2; operationdone <= 1; end
                        3'b100: begin resultvalue   <= value1 - value2; operationdone <= 1; end
                        3'b101: begin resultvalue   <= value1 * value2; operationdone <= 1; end
                        default: operationdone      <= 0;
                    endcase
                end
                IDLE:    operationdone <= 0; // Zera o done, mas mantém o resultado
                default: operationdone <= 0;
            endcase
        end
    end
endmodule