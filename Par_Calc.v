module Par_Calc (
    input wire PAR_TYP,
    input wire Data_Valid,
    input wire PAR_Calc_en,
    input wire [7:0] P_DATA ,
    output reg PAR_bit
    
);

reg [7:0] P_Data_reg;

always @(posedge PAR_Calc_en )
 begin
    
        
        P_Data_reg=P_DATA;
        if (PAR_TYP) 
        begin
        //1 :odd parity
            PAR_bit=~^P_Data_reg; 
        end
        else 
        //0 :even parity
        PAR_bit=^P_Data_reg; 


end
    
endmodule
