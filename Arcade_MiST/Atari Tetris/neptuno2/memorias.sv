module dpram_8_8_256 (
  input wire clka,
  input wire [0:0] wea,
  input wire [7:0] addra,
  input wire [7:0] dina,
  output reg [7:0] douta,
  input wire clkb,
  input wire [0:0] web,
  input wire [7:0] addrb,
  input wire [7:0] dinb,
  output reg [7:0] doutb
);

  reg [7:0] memory [0:255];
   
  always @(posedge clka) begin
    if (wea) begin
      memory[addra] <= dina;
    end
    douta <= memory[addra];
  end
  
  always @(posedge clkb) begin
    if (web) begin
      memory[addrb] <= dinb;
    end
    doutb <= memory[addrb];
  end
endmodule

module dpram_11_8_2048 (
  input wire clka,
  input wire [0:0] wea,
  input wire [10:0] addra,
  input wire [7:0] dina,
  output reg [7:0] douta,
  input wire clkb,
  input wire [0:0] web,
  input wire [10:0] addrb,
  input wire [7:0] dinb,
  output reg [7:0] doutb
);

  reg [7:0] memory [0:2047];

  always @(posedge clka) begin
    if (wea) begin
      memory[addra] <= dina;
    end
    douta <= memory[addra];
  end
  
  always @(posedge clkb) begin
    if (web) begin
      memory[addrb] <= dinb;
    end
    doutb <= memory[addrb];
  end
endmodule

module dpram_9_8_512 (
  input wire clka,
  input wire [0:0] wea,
  input wire [8:0] addra,
  input wire [7:0] dina,
  output reg [7:0] douta,
  input wire clkb,
  input wire [0:0] web,
  input wire [8:0] addrb,
  input wire [7:0] dinb,
  output reg [7:0] doutb
);

  reg [7:0] memory [0:511];

    initial begin
        for (integer i = 0; i < 511; i = i + 1) begin
            memory[i] <= 8'hFF;
        end
    end
	
  always @(posedge clka) begin
    if (wea) begin
      memory[addra] <= dina;
    end
    douta <= memory[addra];
  end
  
  always @(posedge clkb) begin
    if (web) begin
      memory[addrb] <= dinb;
    end
    doutb <= memory[addrb];
  end
endmodule

module spram_12_8_4096 (
  input wire clka,
  input wire [0:0] wea,
  input wire [11:0] addra,
  input wire [7:0] dina,
  output reg [7:0] douta
);

  reg [7:0] memory [0:4095];

  always @(posedge clka) begin
    if (wea) begin
      memory[addra] <= dina;
    end
    douta <= memory[addra];
  end
  
endmodule

