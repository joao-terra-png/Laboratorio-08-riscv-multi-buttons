module testbench();
  logic        clk, reset, memwrite;
  logic [31:0] pc, instr;
  logic [31:0] writedata, addr, readdata;
  logic [9:0] LEDR, SW;
    
  // microprocessor
  riscvmulti cpu(clk, reset, addr, writedata, memwrite, readdata);

  // memory 
  mem ram(clk, memwrite, addr, writedata, readdata);

    // memory-mapped i/o
  wire isIO  = addr[8]; // 0x0000_0100
  wire isRAM = !isIO;
  localparam IO_LEDS_bit = 2; // 0x0000_0104
  localparam IO_HEX_bit  = 3; // 0x0000_0108
  localparam IO_KEY_bit  = 4; // 0x0000_0110 
  localparam IO_SW_bit   = 5; // 0x0000_0120
  reg [23:0] hex_digits; // memory-mapped I/O register for HEX
  dec7seg hex0(hex_digits[ 3: 0], HEX0);
  dec7seg hex1(hex_digits[ 7: 4], HEX1);
  dec7seg hex2(hex_digits[11: 8], HEX2);
  dec7seg hex3(hex_digits[15:12], HEX3);
  dec7seg hex4(hex_digits[19:16], HEX4);
  dec7seg hex5(hex_digits[23:20], HEX5);
  always @(posedge clk)
    if (memwrite & isIO) begin // I/O write 
      if (addr[IO_LEDS_bit])
        LEDR <= writedata;
      if (addr[IO_HEX_bit])
        hex_digits <= writedata;
  end
  assign IO_readdata = addr[IO_KEY_bit] ? {32'b0, KEY} :
                       addr[ IO_SW_bit] ? {32'b0,  SW} : 
                                           32'b0       ;
  assign readdata = isIO ? IO_readdata : MEM_readdata; 
  
  // initialize test
  initial
    begin
      $dumpfile("dump.vcd"); $dumpvars(0);
      reset <= 1; #15 reset <= 0;
      $monitor("LEDR=%b SW=%b, LEDR, SW");
      //$monitor("%3t PC=%h instr=%h aluIn1=%h aluIn2=%h addr=%h writedata=%h memwrite=%b readdata=%h writeBackData=%h", $time, cpu.PC, cpu.instr, cpu.SrcA, cpu.SrcB, addr, writedata, memwrite, readdata, cpu.writeBackData);
      #12000 $writememh("riscv.out", ram.RAM);
      $writememh("cpu_regs.out", cpu.RegisterBank);
      $finish;
    end

  // generate clock to sequence tests
  always
    begin
      clk <= 1; # 5; clk <= 0; # 5;
    end

  // check results
  always @(negedge clk)
    if (memwrite)
      if (writedata === 32'h6d73e55f) begin
        #50 $display("Simulation succeeded!");
        $writememh("riscv.out", ram.RAM);
        $finish;
      end
endmodule
