`timescale 1ns/1ps
module UART_TX_tb ();
    
// interfaces
reg [7:0]  P_DATA_tb;
reg Data_Valid_tb;
reg PAR_EN_tb;
reg PAR_TYP_tb;
reg clk_tb;
reg rst_tb;
wire TX_OUT_tb;
wire busy_tb;

// clk period of freq 200 MHz
parameter  CLK_PERIOD = 5;
parameter  even_PAR=0;
parameter  odd_PAR=1;
parameter  PAR_ON=1;
parameter  PAR_OFF=0;
parameter  frame_length=8;


reg [frame_length-1+3:0] frame_wtPar;
reg [frame_length-1+2:0] frame_wtoutPar;

//intial block 
initial
begin

    initialize();
    #(4*CLK_PERIOD)
    reset();
    #(4*CLK_PERIOD)


    //==============================  Test case 1====================
    //==============================================================

    //check frame with  odd parity 
    //8'b 11001001
    PAR_Config(PAR_ON,odd_PAR);
    Load_Data(8'b11001101);
    //assert Data valid to start transmission
    Data_Valid_tb=1'b1;
    #CLK_PERIOD
    Data_Valid_tb=1'b0;
    //the expected op frame |1|0|11001101|0
    check_Frame_wt_Par(frame_wtPar);
  
    if (frame_wtPar==11'b10110011010) begin
         $display("Testcase_1: checking frame with  odd parity  passed");

    end
    else $display("Testcase_1:checking frame with  odd parity  Faild");


#(4*CLK_PERIOD)


//==============================  Test case 2====================
//==============================================================
    
//check frame with  even parity 
    //11001001
    frame_wtPar=11'b0;
    PAR_Config(PAR_ON,even_PAR);
    Load_Data(8'b11001001);
    //assert Data valid to start transmission
    Data_Valid_tb=1'b1;
    #CLK_PERIOD
    Data_Valid_tb=1'b0;
    //the expected op frame |1|0|11001001|0
   check_Frame_wt_Par(frame_wtPar);
    
    if (frame_wtPar==11'b10110010010) begin
         $display("Testcase_2:checking frame with  even parity  passed");

    end
    else $display("Testcase_2:checking frame with  even parity  Faild");

   

#(4*CLK_PERIOD)


//==============================  Test case 3====================
//==============================================================
    
//check frame with out parity 
    //11001101
    frame_wtoutPar=10'b0;
    PAR_Config(PAR_OFF,even_PAR); //2nd Argument is dont care 
    Load_Data(8'b11001101);
    Data_Valid_tb=1'b1;
    #CLK_PERIOD
    Data_Valid_tb=1'b0;
    //the expected op frame |1||11001101|0
    check_Frame_wtout_Par(frame_wtoutPar);
    
    if (frame_wtoutPar==10'b1110011010) begin
      $display("Testcase_3: checking frame without parity  passed");

    end
    else
    $display("Testcase_3: checking frame without parity  Faild");

//==============================  Test case 4====================
//==============================================================



//check 2 Cascaded frames
PAR_Config(PAR_ON,even_PAR);
    Load_Data(8'b11001001);
    Data_Valid_tb=1'b1;
    #CLK_PERIOD
    Data_Valid_tb=1'b0; 
    #(10*CLK_PERIOD)
    Load_Data(8'b11001001);
    Data_Valid_tb=1'b1;
    #CLK_PERIOD
    Data_Valid_tb=1'b0;
$display("Testcase_4: Cascaded frames is verified in waveform");

#(14*CLK_PERIOD)


//==============================  Test case 5====================
//==============================================================
    

//check datachange  during busy is up

//due to the change of the data if the change affect the blocks which is not required 
// the parity bit will change so to check the isolation of the data and the parity 
// parity bit will be checked   

PAR_Config(PAR_ON,even_PAR);
    Load_Data(8'b11001001);
    Data_Valid_tb=1'b1;
    #CLK_PERIOD
    Data_Valid_tb=1'b0; 
    #(5*CLK_PERIOD)
    Load_Data(8'b11011001);
    Data_Valid_tb=1'b1;
    #CLK_PERIOD
    Data_Valid_tb=1'b0;
    #(3.5*CLK_PERIOD)
  if (TX_OUT_tb==0) begin
    $display("Test_case_5: changing data& valid during busy is high is passed");
    end
    else 
    $display("Test_case_5: changing data&valid during busy is high is Faild");
    
    
end







//================tasks===============
task initialize;
begin
  clk_tb=1'b0;
  Data_Valid_tb=1'b0;
  rst_tb=1'b1; 
  frame_wtPar=0;
  frame_wtoutPar=0;
end
endtask

task reset;
begin
rst_tb=1'b0;
#CLK_PERIOD
rst_tb=1'b1; 
end

endtask

// load test data to the parllell data reg
task Load_Data;
input [frame_length-1:0] data;
begin
    P_DATA_tb=data;
end

endtask

// set Parity config's
task PAR_Config;
input  PAR_EN_Task,
       PAR_TYP_Task; 

begin
    PAR_EN_tb=PAR_EN_Task;
    PAR_TYP_tb=PAR_TYP_Task;

end
endtask


//checking the frame is it as the desierd one or not?
task check_Frame_wt_Par(
 output  reg [(frame_length+2):0] expectedframe);
  
integer   loop ;
begin
  #CLK_PERIOD
  for(loop=0;loop<=(frame_length+2);loop=loop+1)
   begin
    expectedframe[loop]=(TX_OUT_tb)&busy_tb;
    #CLK_PERIOD; 
        end
        loop=0;
   end
     
endtask    




task check_Frame_wtout_Par(
 output  reg [(frame_length+1):0] expectedframe);
  
integer   loop ;
begin
  #CLK_PERIOD
  for(loop=0;loop<=(frame_length+1);loop=loop+1)
   begin
    expectedframe[loop]=(TX_OUT_tb)&busy_tb;
    #CLK_PERIOD; 
        end
        loop=0;
   end
     
endtask     



// ==========Clk Generator=============
always #(0.5*CLK_PERIOD) clk_tb=~clk_tb;




// ==========Dut instantiation========
UART_TX_top DUT(
    .P_DATA     (P_DATA_tb     ),
    .Data_Valid (Data_Valid_tb ),
    .PAR_EN     (PAR_EN_tb     ),
    .PAR_TYP    (PAR_TYP_tb    ),
    .clk        (clk_tb        ),
    .rst        (rst_tb        ),
    .TX_OUT_top (TX_OUT_tb ),
    .busy_top   (busy_tb   )
);





endmodule