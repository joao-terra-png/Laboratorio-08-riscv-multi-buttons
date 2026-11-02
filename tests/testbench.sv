module testbench();
  logic        clk, reset, memwrite;
  logic [31:0] writedata, addr, readdata;
  logic [31:0] MEM_readdata, IO_readdata;
  logic [9:0]  LEDR;
  logic [3:0]  KEY = 4'b1111;   // botoes soltos = 1

  // microprocessor
  riscvmulti cpu(clk, reset, addr, writedata, memwrite, readdata);

  // memory-mapped i/o
  wire isIO  = addr[8]; // 0x0000_0100
  wire isRAM = !isIO;
  localparam IO_LEDS_bit = 2; // 0x0000_0104
  localparam IO_KEY_bit  = 4; // 0x0000_0110

  // memory
  mem ram(clk, memwrite & isRAM, addr, writedata, MEM_readdata);

  always @(posedge clk)
    if (memwrite & isIO & addr[IO_LEDS_bit])
      LEDR <= writedata[9:0];

  assign IO_readdata = addr[IO_KEY_bit] ? {28'b0, KEY} : 32'b0;
  assign readdata    = isIO ? IO_readdata : MEM_readdata;

  initial begin
    $dumpfile("dump.vcd"); $dumpvars(0);
    $monitor("%6t  LEDR=%b  KEY1=%b", $time, LEDR, KEY[1]);
    reset <= 1; #15 reset <= 0;
    #500  KEY[1] = 0;  #300 KEY[1] = 1;  
    #8000 KEY[1] = 0;  #300 KEY[1] = 1;   
    #8000 $finish;
  end

  always begin
    clk <= 1; #5; clk <= 0; #5;
  end
endmodule