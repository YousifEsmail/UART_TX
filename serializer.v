module serializer (
    input wire[7:0] P_DATA,
    input wire ser_en,
    input wire clk,
    input wire rst,
    output reg ser_done,
    output reg ser_data

);

reg [3:0] ser_Count;
reg [7:0] P_DATA_reg;

always @(negedge clk or negedge rst ) 
    begin
        if (~rst) 
        begin
            ser_Count<=0;
        end
    else
    begin
        if (ser_en) 
        begin
        ser_data<=P_DATA_reg[ser_Count];
        ser_Count<=ser_Count+1;            
        end
        else 
        begin
            ser_done<=0;

        end
    end
    end
    always @(*) 
    begin
        if (ser_Count==4'b1000) begin
            ser_Count=0;
            ser_done=1;
        end
        else if ((~|ser_Count)&ser_en) begin
            P_DATA_reg=P_DATA;
            ser_done=0;

        end
    end

endmodule
