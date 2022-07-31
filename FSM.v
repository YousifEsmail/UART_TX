module FSM (
    input wire Data_Valid,
    input wire rst,
    input wire PAR_EN,
    input wire ser_done,
    input wire clk,
    output reg ser_en,
    output reg PAR_Calc_en,
    output reg [1:0] mux_sel,
    output reg busy

);

// state decleration 
localparam  [2:0]Idle =3'b000 ,
                Start =3'b001 ,
                Serial =3'b010 ,
                Parity =3'b011 ,
                Stop =3'b100 ;



reg    [2:0]         curent_state,
                     next_state ;

//state transation 
always @(negedge clk or negedge rst) 
begin
    if(~rst)
    begin  
    curent_state<=Idle;
    ser_en=0;
    busy=0;
    PAR_Calc_en=0;
    end
    else
    curent_state<=next_state;

end


always @(*) 
begin
case (curent_state)
    Idle:
    begin
        if (Data_Valid)
         begin
            //wake the uart up
            next_state=Start;
        end
        else
            next_state=Idle;
            busy=0;
    end

    Start:
    begin
            
            mux_sel=2'b00; //lunch start bit 
            ser_en=1; //serilazer activator
            busy=1;
            PAR_Calc_en=1; //to avoid parity calculation in undiserd state "during busy is high"
            next_state=Serial;
        
    end

    Serial:
    begin
    PAR_Calc_en=0;      //to avoid parity calculation in undiserd state "during busy is high"
    if (ser_done) 
    begin
        ser_en=0;       //Stop serilizer after the counter exceed its limmit

        if (PAR_EN) 
        begin
            // According to parity config's the frame size is changed and parity is added or not
            next_state=Parity;
        end
        else
            next_state=Stop;

    end
    else

        next_state=Serial;//lunch serial data for 8 clock's
        mux_sel=2'b01;
     
    end

    Parity:
    begin
        mux_sel=2'b10;
        next_state=Stop;
    end

    Stop:
    begin
        mux_sel=2'b11;
        if (Data_Valid) begin
        next_state=Start;// for cascded frames feature
        end
        else
        next_state=Idle;

    end

    default:next_state=Idle;

endcase


end
  



endmodule
