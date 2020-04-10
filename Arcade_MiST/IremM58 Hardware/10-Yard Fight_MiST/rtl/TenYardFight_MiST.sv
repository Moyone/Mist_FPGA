//============================================================================
//  Arcade: TenYardFight top-level for MiST
//
//  This program is free software; you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation; either version 2 of the License, or (at your option)
//  any later version.
//
//  This program is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
//  FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
//  more details.
//
//  You should have received a copy of the GNU General Public License along
//  with this program; if not, write to the Free Software Foundation, Inc.,
//  51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//============================================================================

module TenYardFight_MiST(
	output        LED,						
	output  [5:0] VGA_R,
	output  [5:0] VGA_G,
	output  [5:0] VGA_B,
	output        VGA_HS,
	output        VGA_VS,
	output        AUDIO_L,
	output        AUDIO_R,	
	input         SPI_SCK,
	output        SPI_DO,
	input         SPI_DI,
	input         SPI_SS2,
	input         SPI_SS3,
	input         CONF_DATA0,
	input         CLOCK_27,

	output [12:0] SDRAM_A,
	inout  [15:0] SDRAM_DQ,
	output        SDRAM_DQML,
	output        SDRAM_DQMH,
	output        SDRAM_nWE,
	output        SDRAM_nCAS,
	output        SDRAM_nRAS,
	output        SDRAM_nCS,
	output  [1:0] SDRAM_BA,
	output        SDRAM_CLK,
	output        SDRAM_CKE
);

`include "rtl/build_id.v" 

localparam CONF_STR = {      
	"TENYARD;ROM;",
	"O2,Rotate Controls,Off,On;",
	"O1,Video Timing,Original,Pal 50Hz;",
	"O34,Scanlines,Off,25%,50%,75%;",
	"O5,Blending,Off,On;",
	"O6,Service,Off,On;",
	"O7,Flip,Off,On;",
	"O8,Invulnerability,Off,On;",
	"T0,Reset;",
	"V,v1.0.",`BUILD_DATE
};

wire        palmode   = status[1];
wire        rotate    = status[2];
wire  [1:0] scanlines = status[4:3];
wire        blend     = status[5];
wire        service   = status[6];
wire        flip      = status[7];
wire        invuln    = status[8];

assign LED = ~ioctl_downl;
assign SDRAM_CLK = clk_sd;
assign SDRAM_CKE = 1; 

wire clk_sys, clk_aud, clk_sd;
wire pll_locked;
pll_mist pll(
	.inclk0(CLOCK_27),
	.areset(0),
	.c0(clk_sys),
	.c1(clk_aud),
	.c2(clk_sd),
	.locked(pll_locked)
	);

wire [31:0] status;
wire  [1:0] buttons;
wire  [1:0] switches;
wire  [7:0] joystick_0;
wire  [7:0] joystick_1;
wire        scandoublerD;
wire        ypbpr;
wire [10:0] audio;
wire        hs, vs;
wire        blankn;
wire  [2:0] g,b;
wire  [1:0] r;
wire        key_pressed;
wire  [7:0] key_code;
wire        key_strobe;

wire [14:0] rom_addr;
wire [15:0] rom_do;
wire [15:0] snd_addr;
wire [14:0] snd_rom_addr;

wire [15:0] snd_do;
wire        snd_vma;
wire [14:0] sp_addr;
wire [31:0] sp_do;

wire        ioctl_downl;
wire  [7:0] ioctl_index;
wire        ioctl_wr;
wire [24:0] ioctl_addr;
wire  [7:0] ioctl_dout;

/* ROM structure
00000 - 07FFF main CPU    32k  yf-a-3p-b + yf-a-3n-b + yf-a-3m-b + yf-a-3m-b
08000 - 0FFFF  snd CPU    32k  yf-s.3b + yf-s.1b + yf-s.3a + yf-s.1a
10000 - 15FFF gfx1        24k  yf-a.3e + yf-a.3d + yf-a.3c
16000 - 21FFF gfx2        48k  yf-b.5b + yf-b.5c + yf-b.5f + yf-b.5e + yf-b.5j + yf-b.5k
22000 - 220FF radar pal lo 256b  yard.2n
22100 - 221FF radar pal hi 256b  yard.2m
22200 - 222FF chr pal lo 256b  yard.1c
22300 - 223FF chr pal hi 256b  yard.1d
22400 - 224FF spr lut    256b  yard.2h
22500 - 2251F spr pal     32b  yard.1f
*/

data_io data_io(
	.clk_sys       ( clk_sd       ),
	.SPI_SCK       ( SPI_SCK      ),
	.SPI_SS2       ( SPI_SS2      ),
	.SPI_DI        ( SPI_DI       ),
	.ioctl_download( ioctl_downl  ),
	.ioctl_index   ( ioctl_index  ),
	.ioctl_wr      ( ioctl_wr     ),
	.ioctl_addr    ( ioctl_addr   ),
	.ioctl_dout    ( ioctl_dout   )
);

wire [24:0] sp_ioctl_addr = ioctl_addr - 17'h16000;

reg port1_req, port2_req;
sdram sdram(
	.*,
	.init_n        ( pll_locked   ),
	.clk           ( clk_sd      ),

	// port1 used for main + sound CPU
	.port1_req     ( port1_req    ),
	.port1_ack     ( ),
	.port1_a       ( ioctl_addr[23:1] ),
	.port1_ds      ( {ioctl_addr[0], ~ioctl_addr[0]} ),
	.port1_we      ( ioctl_downl ),
	.port1_d       ( {ioctl_dout, ioctl_dout} ),
	.port1_q       ( ),

	.cpu1_addr     ( ioctl_downl ? 16'hffff : {2'b00, rom_addr[14:1]} ),
	.cpu1_q        ( rom_do ),
	.cpu2_addr     ( ioctl_downl ? 16'hffff : (snd_addr) ),
	.cpu2_q        ( snd_do ),

	// port2 for sprite graphics
	.port2_req     ( port2_req ),
	.port2_ack     ( ),
	.port2_a       ( {sp_ioctl_addr[23:16], sp_ioctl_addr[13:0], sp_ioctl_addr[15]} ), // merge sprite roms to 32-bit wide words
	.port2_ds      ( {sp_ioctl_addr[14], ~sp_ioctl_addr[14]} ),
	.port2_we      ( ioctl_downl ),
	.port2_d       ( {ioctl_dout, ioctl_dout} ),
	.port2_q       ( ),

	.sp_addr       ( ioctl_downl ? 15'h7fff : sp_addr ),
	.sp_q          ( sp_do )
);

// ROM download controller
always @(posedge clk_sd) begin
	reg        ioctl_wr_last = 0;
	reg        snd_vma_r, snd_vma_r2;
	ioctl_wr_last <= ioctl_wr;
	if (ioctl_downl) begin
		if (~ioctl_wr_last && ioctl_wr) begin
			port1_req <= ~port1_req;
			port2_req <= ~port2_req;
		end
	end
		// async clock domain crossing here (clk_snd -> clk_sys)
	snd_vma_r <= snd_vma; 
	snd_vma_r2 <= snd_vma_r;
	if (snd_vma_r2) snd_addr <= snd_rom_addr + 15'h8000;
end

// reset signal generation
reg reset = 1;
reg rom_loaded = 0;
always @(posedge clk_sys) begin
	reg ioctl_downlD;
	reg [15:0] reset_count;
	ioctl_downlD <= ioctl_downl;

	if (status[0] | buttons[1] | ~rom_loaded) reset_count <= 16'hffff;
	else if (reset_count != 0) reset_count <= reset_count - 1'd1;

	if (ioctl_downlD & ~ioctl_downl) rom_loaded <= 1;
	reset <= reset_count != 16'h0000;

end
/*
static INPUT_PORTS_START( yard )
	PORT_INCLUDE(m58)

	PORT_MODIFY("DSW2")
	PORT_DIPNAME( 0x08, 0x08, "Slow Motion (Cheat)" ) PORT_DIPLOCATION("SW2:4")  Listed as "Unused" 
	PORT_DIPSETTING(    0x08, DEF_STR( Off ) )
	PORT_DIPSETTING(    0x00, DEF_STR( On ) )
	// In stop mode, press 2 to stop and 1 to restart 
	PORT_DIPNAME( 0x10, 0x10, "Stop Mode (Cheat)") PORT_DIPLOCATION("SW2:5")  Listed as "Unused" 
	PORT_DIPSETTING(    0x10, DEF_STR( Off ) )
	PORT_DIPSETTING(    0x00, DEF_STR( On ) )
	PORT_DIPNAME( 0x20, 0x20, "Level Select (Cheat)" ) PORT_DIPLOCATION("SW2:6")  Listed as "Unused" 
	PORT_DIPSETTING(    0x20, DEF_STR( Off ) )
	PORT_DIPSETTING(    0x00, DEF_STR( On ) )

	PORT_START("DSW1")
	PORT_DIPUNUSED_DIPLOC( 0x01, IP_ACTIVE_LOW, "SW1:1" )
	PORT_DIPUNUSED_DIPLOC( 0x02, IP_ACTIVE_LOW, "SW1:2" )
	PORT_DIPNAME( 0x0c, 0x0c, "Time Reduced by Ball Dead" ) PORT_DIPLOCATION("SW1:3,4")
	PORT_DIPSETTING(    0x0c, DEF_STR( Normal ) )
	PORT_DIPSETTING(    0x08, "x1.3" )
	PORT_DIPSETTING(    0x04, "x1.5" )
	PORT_DIPSETTING(    0x00, "x1.8" )
	IREM_Z80_COINAGE_TYPE_1_LOC(SW1)
INPUT_PORTS_END*/

wire [7:0] dip1 = ~8'b00000010;
wire [7:0] dip2 = ~{ 1'b0, invuln, 1'b0, 1'b0/*stop*/, 3'b010, flip };

TenYardFight TenYardFight(
	.clock_36     ( clk_sys         ),
	.clock_0p895  ( clk_aud         ),
	.reset        ( reset           ),

	.palmode      ( palmode         ),

	.video_r      ( r               ),
	.video_g      ( g               ),
	.video_b      ( b               ),
	.video_hs     ( hs              ),
	.video_vs     ( vs              ),
	.video_blankn ( blankn          ),

	.audio_out    ( audio           ),

	.cpu_rom_addr ( rom_addr       	),
	.cpu_rom_do   ( rom_addr[0] ? rom_do[15:8] : rom_do[7:0] ),
	.snd_rom_addr ( snd_rom_addr),
	.snd_rom_do   ( snd_rom_addr[0] ? snd_do[15:8] : snd_do[7:0] ),
	.snd_vma(snd_vma),
	.sp_addr      ( sp_addr         ),
	.sp_graphx32_do( sp_do          ),

	.dip_switch_1 ( dip1            ),  
	.dip_switch_2 ( dip2            ),
	.input_0      ( ~{4'd0, m_coin1, service, m_two_players, m_one_player} ),
	.input_1      ( ~{m_fireA, 1'b0, m_fireB, 1'b0, m_up, m_down, m_left, m_right} ),
	.input_2      ( ~{m_fire2A, 1'b0, m_fire2B, m_coin2, m_up2, m_down2, m_left2, m_right2} ),

	.dl_clk       ( clk_sd          ),
	.dl_addr      ( ioctl_addr[17:0]),
	.dl_data      ( ioctl_dout      ),
	.dl_wr        ( ioctl_wr        )
);

mist_video #(.COLOR_DEPTH(3), .SD_HCNT_WIDTH(10)) mist_video(
	.clk_sys        ( clk_sys          ),
	.SPI_SCK        ( SPI_SCK          ),
	.SPI_SS3        ( SPI_SS3          ),
	.SPI_DI         ( SPI_DI           ),
	.R              ( blankn ? {r, r[1] } : 0 ),
	.G              ( blankn ? g : 0   ),
	.B              ( blankn ? b : 0   ),
	.HSync          ( hs               ),
	.VSync          ( vs               ),
	.VGA_R          ( VGA_R            ),
	.VGA_G          ( VGA_G            ),
	.VGA_B          ( VGA_B            ),
	.VGA_VS         ( VGA_VS           ),
	.VGA_HS         ( VGA_HS           ),
	.rotate         ( { 1'b1, rotate } ),
	.scandoubler_disable( scandoublerD ),
	.scanlines      ( scanlines        ),
	.blend          ( blend            ),
	.ypbpr          ( ypbpr            )
	);

user_io #(
	.STRLEN(($size(CONF_STR)>>3)))
user_io(
	.clk_sys        (clk_sys        ),
	.conf_str       (CONF_STR       ),
	.SPI_CLK        (SPI_SCK        ),
	.SPI_SS_IO      (CONF_DATA0     ),
	.SPI_MISO       (SPI_DO         ),
	.SPI_MOSI       (SPI_DI         ),
	.buttons        (buttons        ),
	.switches       (switches       ),
	.scandoubler_disable (scandoublerD	  ),
	.ypbpr          (ypbpr          ),
	.key_strobe     (key_strobe     ),
	.key_pressed    (key_pressed    ),
	.key_code       (key_code       ),
	.joystick_0     (joystick_0     ),
	.joystick_1     (joystick_1     ),
	.status         (status         )
	);

wire dac_o;
assign AUDIO_L = dac_o;
assign AUDIO_R = dac_o;

dac #(
	.C_bits(11))
dac(
	.clk_i(clk_aud),
	.res_n_i(1),
	.dac_i(audio),
	.dac_o(dac_o)
	);

wire m_up, m_down, m_left, m_right, m_fireA, m_fireB, m_fireC, m_fireD, m_fireE, m_fireF;
wire m_up2, m_down2, m_left2, m_right2, m_fire2A, m_fire2B, m_fire2C, m_fire2D, m_fire2E, m_fire2F;
wire m_tilt, m_coin1, m_coin2, m_coin3, m_coin4, m_one_player, m_two_players, m_three_players, m_four_players;

arcade_inputs inputs (
	.clk         ( clk_sys     ),
	.key_strobe  ( key_strobe  ),
	.key_pressed ( key_pressed ),
	.key_code    ( key_code    ),
	.joystick_0  ( joystick_0  ),
	.joystick_1  ( joystick_1  ),
	.rotate      ( rotate      ),
	.orientation ( 2'b10       ),
	.joyswap     ( 1'b0        ),
	.oneplayer   ( 1'b1        ),
	.controls    ( {m_tilt, m_coin4, m_coin3, m_coin2, m_coin1, m_four_players, m_three_players, m_two_players, m_one_player} ),
	.player1     ( {m_fireF, m_fireE, m_fireD, m_fireC, m_fireB, m_fireA, m_up, m_down, m_left, m_right} ),
	.player2     ( {m_fire2F, m_fire2E, m_fire2D, m_fire2C, m_fire2B, m_fire2A, m_up2, m_down2, m_left2, m_right2} )
);

endmodule 
