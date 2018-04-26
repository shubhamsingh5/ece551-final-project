module snn_core(start, q_input, addr_input_unit, digit, done);

typedef enum reg[2:0] {IDLE, MAC1, MAC2, MAX, DONE} state;
state curr_state, next_state;

output [9:0] addr_input_unit;
input logic q_input;
input logic clk, we, data;
logic [9:0] addr;
logic [14:0] addr_rom_hidden_weight;
logic [7:0] q_extended, rom_hidden_data;
logic [7:0] a, b;
logic [25:0] acc;
logic clr_n, rst_n;
logic [10:0] addr_LUT;
logic select_input;


mac mac(.clk(clk), .(a), .b(b), .acc(acc), .clr_n(clr_n), .rst_n(rst_n));
ram ram_input_unit(.data(data), .addr(addr_input_unit), .we(we), .clk(clk), .q(q_input));
rom rom_hidden_weight(.addr(addr_rom_hidden_weight), .clk(clk), .q(rom_hidden_data));

assign q_extended = (q_input) ? 8'h7F : 8'h0;
addr_input_unit = addr_input_unit  + 1;
assign addr_rom_hidden_weight_max = addr_rom_hidden_weight == 25088 ? 1 : 0;
assign addr_input_unit_max = addr_input_unit == 784 ? 1 : 0;
assign addr_ram_hidden_max = addr_ram_hidden == 32 ? 1 : 0;
assign output_addr_max = output_addr == 320 ? 1 : 0;

if(acc[25]==0 && |acc[24:17] == 1) begin
addr_LUT = 11'h3ff;
end

else if(acc[25]==1 && &acc[24:17] == 0) begin
addr_LUT = 11'h400;
end

else
addr_LUT = acc[17:7];


// FSM
always_comb begin
  //default values
  select_input = 0;
  done = 0;

  case (state)
    IDLE:
      if (start) begin					//start bit detected
        next_state = MAC1;
      end

    MAC1:
      if (addr_rom_hidden_weight_max)					//at middle of start bit
        next_state = MAC2;
      else begin
        next_state = MAC1;
      end

    MAC2:
      select_input = 1;
      if (output_addr_max) begin	//middle of a bit which isn't the stop bit
        next_state = MAX;
      end
      else begin
        next_state = MAC2;
      end

    MAX:
      if (digit_max) begin
        done = 1;
        next_state = DONE;
      end
      else
        next_state = MAX;

    DONE:

    endcase
  end

endmodule
