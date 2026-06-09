module debouncer (
    input wire clk,
    input wire btn_in,
    output reg btn_out
);
    reg [19:0] counter; 
    reg btn_sync_0, btn_sync_1;

    always @(posedge clk) begin
        btn_sync_0 <= btn_in;
        btn_sync_1 <= btn_sync_0; 

        if (btn_sync_1 == btn_out) begin
            counter <= 0;
        end else begin
            counter <= counter + 1;
            if (counter == 20'd500000) begin 
                btn_out <= btn_sync_1;
                counter <= 0;
            end
        end
    end
endmodule