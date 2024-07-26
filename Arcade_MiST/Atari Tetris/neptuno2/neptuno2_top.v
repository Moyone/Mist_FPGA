
module neptuno2_top(
  input wire CLK_50,

  output wire [7:0] VGA_R,
  output wire [7:0] VGA_G,
  output wire [7:0] VGA_B,
  output wire VGA_HS,
  output wire VGA_VS,

  output wire SPI_DO,
  input wire SPI_DI,
  input wire SPI_SCK,
  input wire CONF_DATA0,
  input wire SPI_SS2,
  input wire SPI_SS3,
  input wire SPI_SS4,
  output wire SDRAM_CLK,
  output wire SDRAM_CKE,
  output wire SDRAM_DQMH,
  output wire SDRAM_DQML,
  output wire SDRAM_nCAS,
  output wire SDRAM_nRAS,
  output wire SDRAM_nWE,
  output wire SDRAM_nCS,
  output wire[1:0] SDRAM_BA,
  output wire[12:0] SDRAM_A,
  inout wire[15:0] SDRAM_DQ,

 // Delta sigma audio
 output          AUDIO_L,
 output          AUDIO_R,
 //I2S audio
 output          I2S_BCLK,
 output          I2S_LRCLK,
 output          I2S_DATA,

 output wire LED,

  // SD card
  // output       SD_CS,
  input           SD_SCK,     //SD_SCK is being driven by middleboard
  // output       SD_MOSI,
  input           SD_MISO,
	
	
  //  input wire EAR,

  // forward JAMMA DB9 data
  output          JOY_CLK,
  output          JOY_LOAD,
  input           JOY_DATA,
  output          JOY_SELECT,
  input           XJOY_CLK,
  input           XJOY_LOAD,
  output          XJOY_DATA

 `ifdef SIMULATION
  ,output         sim_pxl_cen,
  output          sim_pxl_clk,
  output          sim_vb,
  output          sim_hb,
  output          sim_dwnld_busy
 `endif
	);

// JAMMA interface
assign JOY_CLK    = XJOY_CLK;
assign JOY_LOAD   = XJOY_LOAD;
assign XJOY_DATA  = JOY_DATA;
assign JOY_SELECT = 1'b1;

assign VGA_R[1:0] = VGA_R[7:6];
assign VGA_G[1:0] = VGA_G[7:6];
assign VGA_B[1:0] = VGA_B[7:6];

Tetris_MiST Tetris (
   .CLOCK_27(CLK_50),
   .SPI_DO(SPI_DO),
   .SPI_DI(SPI_DI),
   .SPI_SCK(SPI_SS4 ? SPI_SCK : SD_SCK),
   .CONF_DATA0(CONF_DATA0),
   .SPI_SS2(SPI_SS2),
   .SPI_SS3(SPI_SS3),
	.SPI_SS4(SPI_SS4),
   .VGA_HS(VGA_HS),
   .VGA_VS(VGA_VS),
   .VGA_R(VGA_R[7:2]),
   .VGA_G(VGA_G[7:2]),
   .VGA_B(VGA_B[7:2]),
   .LED(LED),
   .SDRAM_A(SDRAM_A), 
   .SDRAM_DQ(SDRAM_DQ),  
   .SDRAM_DQML(SDRAM_DQML), 
   .SDRAM_DQMH(SDRAM_DQMH), 
   .SDRAM_nWE(SDRAM_nWE), 
   .SDRAM_nCAS(SDRAM_nCAS), 
   .SDRAM_nRAS(SDRAM_nRAS),
   .SDRAM_nCS(SDRAM_nCS), 
   .SDRAM_BA(SDRAM_BA), 
   .SDRAM_CLK(SDRAM_CLK), 
   .SDRAM_CKE(SDRAM_CKE), 
   .AUDIO_L(AUDIO_L),
   .AUDIO_R(AUDIO_R),
   .I2S_BCK(I2S_BCLK),
   .I2S_LRCK(I2S_LRCLK),
   .I2S_DATA(I2S_DATA),
//   .AUDIO_IN(),
//   .UART_RX(1'b1),
//   .UART_TX()
);

endmodule
