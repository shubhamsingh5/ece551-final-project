module rom_tb_2 (
  input [9:0] addr,
  input clk,
  output logic q);

  // Declare the ROM variable
  reg rom[2**10-1:0];
  initial
      $readmemh("./Files/input\ samples/ram_input_contents_sample_2.txt", rom);

  always @(posedge clk) begin
      q <= rom[addr];
  end