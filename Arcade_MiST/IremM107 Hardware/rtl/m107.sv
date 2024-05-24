//============================================================================
//  Irem M107 for MiSTer FPGA - Main module
//
//  Copyright (C) 2023 Martin Donlon
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

import m107_pkg::*;

module m107 (
    input clk_sys,

    input reset_n,
    output reg ce_pix,
    output flipped,

    input board_cfg_t board_cfg,

    output [7:0] R,
    output [7:0] G,
    output [7:0] B,

    output HSync,
    output VSync,
    output HBlank,
    output VBlank,

    output [15:0] AUDIO_L,
    output [15:0] AUDIO_R,

    input [3:0] coin,
    input [3:0] start_buttons,
    
    input [9:0] p1_input,
    input [9:0] p2_input,
    input [9:0] p3_input,
    input [9:0] p4_input,

    input [23:0] dip_sw,

    input pause_rq,
    output cpu_paused,

    input cpu_turbo,

    output [23:0] sdr_ga21_addr,
    input [63:0] sdr_ga21_dout,
    output sdr_ga21_req,
    input sdr_ga21_ack,

    output [23:0] sdr_ga22_addr,
    input [63:0] sdr_ga22_dout,
    output sdr_ga22_req,
    input sdr_ga22_ack,

    output [23:0] sdr_bg_addr_a,
    input [31:0] sdr_bg_data_a,
    output sdr_bg_req_a,
    input sdr_bg_ack_a,

    output [23:0] sdr_bg_addr_b,
    input [31:0] sdr_bg_data_b,
    output sdr_bg_req_b,
    input sdr_bg_ack_b,

    output [23:0] sdr_bg_addr_c,
    input [31:0] sdr_bg_data_c,
    output sdr_bg_req_c,
    input sdr_bg_ack_c,

    output [23:0] sdr_bg_addr_d,
    input [31:0] sdr_bg_data_d,
    output sdr_bg_req_d,
    input sdr_bg_ack_d,

    output reg [24:0] sdr_cpu_addr,
    input [15:0] sdr_cpu_dout,
    output reg [15:0] sdr_cpu_din,
    output reg sdr_cpu_req,
    input sdr_cpu_ack,
    output reg [1:0] sdr_cpu_wr_sel,

    output reg [24:0] sdr_audio_cpu_addr,
    input [15:0] sdr_audio_cpu_dout,
    output reg [15:0] sdr_audio_cpu_din,
    output reg sdr_audio_cpu_req,
    input sdr_audio_cpu_ack,
    output reg [1:0] sdr_audio_cpu_wr_sel,

    output [24:0] sdr_audio_addr,
    input [63:0] sdr_audio_dout,
    output sdr_audio_req,
    input sdr_audio_ack,

    input clk_bram,
    input bram_wr,
    input [7:0] bram_data,
    input [19:0] bram_addr,
    input [4:0] bram_cs,

    input ioctl_download,
    input ioctl_wr,
    input [26:0] ioctl_addr,
    input [7:0] ioctl_dout,

    input ioctl_upload,
    output [7:0] ioctl_upload_index,
    output [7:0] ioctl_din,
    input ioctl_rd,
    output ioctl_upload_req,

    input [3:0] dbg_en_layers,
    input dbg_solid_sprites,
    input en_audio_filters,
    input dbg_fm_en,

    input sprite_freeze,

    input dbg_io_write,
    input [7:0] dbg_io_data,
    output reg dbg_io_wait
);

assign ioctl_upload_index = 8'd1;
assign flipped = NL;

wire [15:0] rgb_color;
assign R = { rgb_color[4:0], rgb_color[4:2] };
assign G = { rgb_color[9:5], rgb_color[9:7] };
assign B = { rgb_color[14:10], rgb_color[14:12] };

reg paused = 0;
assign cpu_paused = paused;

always @(posedge clk_sys) begin
    if (pause_rq & ~paused) begin
        if (~MRD & ~MWR & ~mem_rq_active & vpulse) begin
            paused <= 1;
        end
    end else if (~pause_rq & paused) begin
        paused <= ~vpulse;
    end
end


wire ce_13m;
jtframe_frac_cen #(2) pixel_cen
(
    .clk(clk_sys),
    .cen_in(1),
    .n(10'd1),
    .m(10'd3),
    .cen({ce_pix, ce_13m})
);

wire ce_14m, ce_28m;
jtframe_frac_cen #(2) cpu_cen
(
    .clk(clk_sys),
    .cen_in(1),
    .n(10'd7),
    .m(10'd10),
    .cen({ce_14m, ce_28m})
);

wire dma_busy;

wire [15:0] cpu_mem_out;
wire [19:0] cpu_mem_addr;
wire [1:0] cpu_mem_sel;
wire [15:0] cpu_mem_in;

/* Global signals from schematics */
wire cpu_n_dstb, cpu_busst0, cpu_busst1, cpu_n_bcyst;
wire cpu_n_ube, cpu_r_w, cpu_m_io;

wire IOWR = ~cpu_m_io & ~cpu_r_w & ~cpu_busst1 & cpu_busst0 & ~cpu_n_dstb; // IO Write
wire IORD = ~cpu_m_io & cpu_r_w & ~cpu_busst1 & cpu_busst0; // IO Read
wire MWR = cpu_m_io & ~cpu_r_w & ~cpu_busst1 & cpu_busst0 & ~cpu_n_dstb; // Mem Write
wire MRD = cpu_m_io & cpu_r_w & ~cpu_busst1; // Mem Read

wire INTACK = ~cpu_m_io & cpu_r_w & ~cpu_busst1 & ~cpu_busst0 & ~cpu_n_dstb;

wire [19:0] cpu_word_addr = { cpu_mem_addr[19:1], 1'b0 };

wire cpu_ram_rom_memrq;
wire buffer_memrq;
wire sprite_control_memrq;
wire video_control_memrq;
wire pf_vram_memrq;
wire eeprom_memrq;
wire banked_memrq;
wire timer_memrq;

wire [7:0] snd_latch_dout;
wire snd_latch_rdy;

reg [15:0] cpu_cycle_timer;
reg [15:0] deferred_ce;
reg ce_toggle;
reg ce_1, ce_2;
wire ga23_busy;
wire cpu_ram_rom_ready = !mem_rq_active;
reg  [15:0] cpu_ram_rom_data;
wire [24:0] cpu_region_addr;
wire cpu_region_writable;

wire ce_1_cpu = ce_1 & cpu_ram_rom_ready;
wire ce_2_cpu = ce_2 & cpu_ram_rom_ready;

always @(posedge clk_sys) begin
    if (!reset_n) begin
        ce_1 <= 0;
        ce_2 <= 0;
        ce_toggle <= 0;
        deferred_ce <= 16'd0;
    end else begin
        ce_1 <= 0;
        ce_2 <= 0;

        if (ce_28m) begin
            if (~cpu_ram_rom_ready) begin
                deferred_ce <= deferred_ce + 16'd1;
            end else if (|deferred_ce) begin 
                deferred_ce <= deferred_ce - 16'd1;
            end
        end

        if (~paused & (ce_28m | cpu_turbo | (cpu_ram_rom_ready & |deferred_ce))) begin
            ce_toggle <= ~ce_toggle;
            ce_1 <= ce_toggle;
            ce_2 <= ~ce_toggle;
        end
    end
end

always @(posedge clk_sys) begin
    if (ce_1_cpu) cpu_cycle_timer <= cpu_cycle_timer + 16'd1;
end

reg mem_rq_active = 0;
reg cpu_n_bcyst_d;

always_ff @(posedge clk_sys) begin
    if (!reset_n) begin
        mem_rq_active <= 0;
    end else begin
		cpu_n_bcyst_d <= ~(MRD | MWR) | cpu_n_bcyst;
        if (!mem_rq_active) begin
            if ((MRD | MWR) & cpu_ram_rom_memrq & !cpu_n_bcyst & cpu_n_bcyst_d) begin // sdram request
                sdr_cpu_wr_sel <= 2'b00;
                sdr_cpu_addr <= cpu_region_addr;
                if (MWR & cpu_region_writable ) begin
                    sdr_cpu_wr_sel <= {~cpu_n_ube, ~cpu_mem_addr[0]};
                    sdr_cpu_din <= cpu_mem_out;
                end
                sdr_cpu_req <= ~sdr_cpu_req;
                mem_rq_active <= 1;
            end
        end else if (sdr_cpu_req == sdr_cpu_ack) begin
            mem_rq_active <= 0;
            cpu_ram_rom_data <= sdr_cpu_dout;
        end
    end
end

wire rom0_ce, rom1_ce, ram_cs2;

reg [3:0] bank_select = 4'd0;


wire [7:0] switches_p1 = board_cfg.kick_harness ? { p1_input[4], p1_input[5], p1_input[6], 1'b0,             p1_input[3], p1_input[2], p1_input[1], p1_input[0] }
                                                : { p1_input[4], p1_input[5], p1_input[6], 1'b0,             p1_input[3], p1_input[2], p1_input[1], p1_input[0] };
wire [7:0] switches_p2 = board_cfg.kick_harness ? { p2_input[4], p2_input[5], p2_input[6], 1'b0,             p2_input[3], p2_input[2], p2_input[1], p2_input[0] }
                                                : { p2_input[4], p2_input[5], p2_input[6], 1'b0,             p2_input[3], p2_input[2], p2_input[1], p2_input[0] };
wire [7:0] switches_p3 = board_cfg.kick_harness ? { 1'b0,        1'b0,        1'b0,        1'b0,             1'b0,        1'b0,        1'b0,        1'b0        }
                                                : { p3_input[4], p3_input[5], coin[2],     start_buttons[2], p3_input[3], p3_input[2], p3_input[1], p3_input[0] };
wire [7:0] switches_p4 = board_cfg.kick_harness ? { p2_input[9], p2_input[8], p2_input[7], 1'b0,             p1_input[9], p1_input[8], p1_input[7], 1'b0        }
                                                : { p4_input[4], p4_input[5], coin[3],     start_buttons[3], p4_input[3], p4_input[2], p4_input[1], p4_input[0] };

wire [15:0] switches_p1_p2 = { ~switches_p2, ~switches_p1 };
wire [15:0] switches_p3_p4 = { ~switches_p4, ~switches_p3 };

wire [15:0] flags = { ~dip_sw[23:16], ~dma_busy, 1'b1, 1'b1 /*TEST*/, 1'b1 /*R*/, ~coin[1:0], ~start_buttons[1:0] };

reg [7:0] sys_flags = 0;
wire COIN0 = sys_flags[0];
wire COIN1 = sys_flags[1];
wire SOFT_NL = ~sys_flags[2];
wire CBLK = sys_flags[3];
wire BRQ = ~sys_flags[4];
wire BANK = sys_flags[5];
wire NL = SOFT_NL ^ ~dip_sw[8];

reg sound_reset = 0;

// TODO BANK, CBLK, NL
always @(posedge clk_sys) begin
    if (~reset_n) begin
        sys_flags <= 8'd0;
        bank_select <= 4'd0;
        sound_reset <= 1'd0;
    end else begin
        if (IOWR && cpu_word_addr == 8'h02) sys_flags <= cpu_mem_out[7:0];
        if (IOWR && cpu_word_addr == 8'h06) bank_select <= cpu_mem_out[3:0];
        if (IOWR && cpu_word_addr == 8'hc0) sound_reset <= ~cpu_mem_out[0];
    end
end

reg [15:0] vid_ctrl;
always @(posedge clk_sys or negedge reset_n) begin
    if (~reset_n) begin
        vid_ctrl <= 0;
    end else if (video_control_memrq & MWR) begin
        vid_ctrl <= cpu_mem_out;
    end
end

`ifdef M107_DEBUG_IO
always @(posedge clk_sys or negedge reset_n) begin
    if (~reset_n) begin
        dbg_io_wait <= 0;
        dbg_io_latch <= 8'hff;
    end else begin
        if (IORD && cpu_io_addr == 8'h06) begin
            dbg_io_wait <= 0;
        end

        if (dbg_io_write) begin
            dbg_io_wait <= 1;
            dbg_io_latch <= dbg_io_data;
        end
    end
end
`endif

wire [15:0] ga21_dout, ga23_dout;
wire [7:0] eeprom_dout;

// mux io and memory reads
always_comb begin
    if (INTACK) begin
        cpu_mem_in = { 8'd0, int_vector };
    end else if (MRD) begin
        if (buffer_memrq) cpu_mem_in = ga21_dout;
        else if (pf_vram_memrq) cpu_mem_in = ga23_dout;
        else if (eeprom_memrq) cpu_mem_in = { eeprom_dout, eeprom_dout };
        else if (timer_memrq) cpu_mem_in = cpu_cycle_timer;
        else cpu_mem_in = cpu_ram_rom_data;
    end else if (IORD) begin
        case ({cpu_word_addr[7:0]})
        8'h00: cpu_mem_in = switches_p1_p2;
        8'h02: cpu_mem_in = flags;
        8'h04: cpu_mem_in = ~dip_sw[15:0];
        8'h06: cpu_mem_in = switches_p3_p4;
        8'h08: cpu_mem_in = { snd_latch_dout, snd_latch_dout };
        default: cpu_mem_in = 16'hffff;
        endcase
    end else begin
        cpu_mem_in = 16'hffff;
    end
end

wire int_req;
wire [7:0] int_vector;

V33 v33(
    .clk(clk_sys),
    .ce_1(ce_1_cpu),
    .ce_2(ce_2_cpu),

    // Pins
    .reset(~reset_n),
    .hldrq(0),
    .n_ready(ga23_busy),
    .bs16(0),

    .hldak(),
    .n_buslock(),
    .n_ube(cpu_n_ube),
    .r_w(cpu_r_w),
    .m_io(cpu_m_io),
    .busst0(cpu_busst0),
    .busst1(cpu_busst1),
    .aex(),
    .n_bcyst(cpu_n_bcyst),
    .n_dstb(cpu_n_dstb),

    .intreq(int_req),
    .n_nmi(1),

    .n_cpbusy(1),
    .n_cperr(1),
    .cpreq(0),

    .addr(cpu_mem_addr),
    .dout(cpu_mem_out),
    .din(cpu_mem_in),

    .turbo(cpu_turbo)
);

address_translator address_translator(
    .A(cpu_mem_addr),
    .board_cfg(board_cfg),
    .ram_rom_memrq(cpu_ram_rom_memrq),
    .sdr_addr(cpu_region_addr),
    .writable(cpu_region_writable),

    .buffer_memrq(buffer_memrq),
    .pf_vram_memrq(pf_vram_memrq),
    .sprite_control_memrq(sprite_control_memrq),
    .video_control_memrq(video_control_memrq),
    .eeprom_memrq(eeprom_memrq),
    .timer_memrq(timer_memrq),

    .bank_select(bank_select)
);

wire ga23_vblank, ga23_hblank, ga23_vsync, ga23_hsync, vpulse, hpulse, hint, ga23_color_blank;

m107_pic m107_pic(
    .clk(clk_sys),
    .ce(ce_1_cpu),
    .reset(~reset_n),

    .cs((IORD | IOWR) & ~cpu_mem_addr[7] & cpu_mem_addr[6] & ~cpu_mem_addr[0]), // 0x40-0x43
    .wr(IOWR),
    .rd(0),
    .a0(cpu_mem_addr[1]),
    
    .din(cpu_mem_out[7:0]),

    .int_req(int_req),
    .int_vector(int_vector),
    .int_ack(INTACK),

    .intp({4'd0, snd_latch_rdy, hint, ~dma_busy, VBlank})
);

wire objram_we;
wire [15:0] objram_data, objram_q;
wire [63:0] objram_q64;
wire [10:0] objram_addr;

wire [11:0] ga22_color, ga23_color;
wire ga23_prio;

objram objram(
    .clk(clk_sys),

    .addr(objram_addr),
    .we(objram_we),

    .data(objram_data),

    .q(objram_q),
    .q64(objram_q64)
);

wire bufram_we;
wire [15:0] bufram_data;
wire [11:0] bufram_addr;

wire [15:0] bufram_q;

wire [12:0] ga21_palram_addr;
wire ga21_palram_we, ga21_palram_cs;
wire [15:0] ga21_palram_dout;
wire [15:0] palram_q;
wire [10:0] ga22_obj_idx;


singleport_unreg_ram #(.widthad(12), .width(16), .name("BUFRAM")) bufram(
    .clock(clk_sys),
    .address(bufram_addr),
    .q(bufram_q),
    .wren(bufram_we),
    .data(bufram_data)
);

palram palram(
    .clk(clk_sys),

    .ce_pix(ce_pix),

    .vid_ctrl(vid_ctrl),

    .vblank_in(ga23_vblank),
    .hblank_in(ga23_hblank),
    .vsync_in(ga23_vsync),
    .hsync_in(ga23_hsync),
    .color_blank_in(ga23_color_blank),

    .dma_busy(pal_busy),

    .cpu_addr(cpu_mem_addr[10:1]),

    .ga21_addr(ga21_palram_addr),
    .ga21_we(ga21_palram_we),
    .ga21_req(ga21_palram_cs),
    
    .obj_color(ga22_color[10:0]),
    .obj_prio(ga22_color[11]),
    .obj_active(|ga22_color[3:0]),

    .pf_color(ga23_color),
    .pf_prio(~ga23_prio),

    .din(ga21_palram_dout),
    .dout(palram_q),

    .rgb_out(rgb_color),
    .vblank_out(VBlank),
    .hblank_out(HBlank),
    .vsync_out(VSync),
    .hsync_out(HSync)
);

wire sdr_ga22_refresh;
wire pal_busy, obj_busy;

GA21 ga21(
    .clk(clk_sys),

    .ce(ce_14m),

    .reset(),

    .direct_sprites(board_cfg.direct_sprites),

    .addr(cpu_mem_addr[12:1]),
    .din(cpu_mem_out),
    .dout(ga21_dout),

    .reg_cs(IOWR && (cpu_word_addr == 16'h0004)),
    .buf_cs(buffer_memrq & ~IOWR),
    .wr(MWR | IOWR),

    .busy(dma_busy),
    .pal_busy,
    .obj_busy,

    .obj_dout(objram_data),
    .obj_din(objram_q),
    .obj_addr(objram_addr),
    .obj_we(objram_we),

    .buffer_dout(bufram_data),
    .buffer_din(bufram_q),
    .buffer_addr(bufram_addr),
    .buffer_we(bufram_we),

    .obj_idx(ga22_obj_idx),

    .pal_addr(ga21_palram_addr),
    .pal_dout(ga21_palram_dout),
    .pal_din(palram_q),
    .pal_we(ga21_palram_we),
    .pal_cs(ga21_palram_cs),

    .sdr_data(sdr_ga21_dout),
    .sdr_addr(sdr_ga21_addr),
    .sdr_req(sdr_ga21_req),
    .sdr_ack(sdr_ga21_ack)
);

GA22 ga22(
    .clk(clk_sys),

    .ce(ce_13m), // 13.33Mhz

    .ce_pix(ce_pix), // 6.66Mhz

    .reset(~reset_n),

    .color(ga22_color),

    .NL(NL),
    .hpulse(hpulse),
    .vpulse(vpulse),

    .obj_idx(ga22_obj_idx),

    .obj_in(objram_q64),

    .sdr_data(sdr_ga22_dout),
    .sdr_addr(sdr_ga22_addr),
    .sdr_req(sdr_ga22_req),
    .sdr_ack(sdr_ga22_ack),
    .sdr_refresh(sdr_ga22_refresh),

    .dbg_solid_sprites(dbg_solid_sprites)
);

wire [14:0] vram_addr;
wire [15:0] vram_data, vram_q;
wire vram_we;

singleport_unreg_ram #(.widthad(15), .width(16), .name("VRAM")) vram
(
    .clock(clk_sys),
    .address(vram_addr),
    .q(vram_q),
    .wren(vram_we),
    .data(vram_data)
);

GA23 ga23(
    .clk(clk_sys),

    .ce(ce_13m),
    .ce_pix(ce_pix),

    .reset(~reset_n),

    .paused(paused),

    .mem_cs(pf_vram_memrq),
    .mem_wr(MWR),
    .mem_rd(MRD),
    .io_wr(IOWR),

    .busy(ga23_busy),

    .addr(cpu_mem_addr),
    .cpu_din(cpu_mem_out),
    .cpu_dout(ga23_dout),
    
    .vram_addr(vram_addr),
    .vram_din(vram_q),
    .vram_dout(vram_data),
    .vram_we(vram_we),

    .NL(NL),

    .sdr_data_a(sdr_bg_data_a),
    .sdr_addr_a(sdr_bg_addr_a),
    .sdr_req_a(sdr_bg_req_a),
    .sdr_ack_a(sdr_bg_ack_a),

    .sdr_data_b(sdr_bg_data_b),
    .sdr_addr_b(sdr_bg_addr_b),
    .sdr_req_b(sdr_bg_req_b),
    .sdr_ack_b(sdr_bg_ack_b),

    .sdr_data_c(sdr_bg_data_c),
    .sdr_addr_c(sdr_bg_addr_c),
    .sdr_req_c(sdr_bg_req_c),
    .sdr_ack_c(sdr_bg_ack_c),

    .sdr_data_d(sdr_bg_data_d),
    .sdr_addr_d(sdr_bg_addr_d),
    .sdr_req_d(sdr_bg_req_d),
    .sdr_ack_d(sdr_bg_ack_d),

    .vblank(ga23_vblank),
    .hblank(ga23_hblank),
    .vsync(ga23_vsync),
    .hsync(ga23_hsync),
    .hpulse(hpulse),
    .vpulse(vpulse),

    .color_blank(ga23_color_blank),

    .hint(hint),

    .color_out(ga23_color),
    .prio_out(ga23_prio),

    .dbg_en_layers(dbg_en_layers)
);

/*
// Sound board test (select sound with P1 left/right)
reg [7:0] snd_id;
reg snd_wr;
reg left_last, right_last;
wire left = p1_input[1];
wire right = p1_input[0];

always @(posedge clk_sys) begin
	if (!reset_n) begin
		snd_wr <= 0;
		snd_id <= 0;
	end else begin
		snd_wr <= 0;
		left_last <= left;
		right_last <= right;
		if (!left_last & left) begin
			snd_id <= snd_id - 1'd1;
			snd_wr <= 1;
		end
		if (!right_last & right) begin
			snd_id <= snd_id + 1'd1;
			snd_wr <= 1;
		end
	end
	
end
*/
wire [15:0] sound_sample;

sound sound(
    .clk_sys(clk_sys),
    .reset(sound_reset | ~reset_n),
    .filter_en(en_audio_filters),
    .dbg_fm_en(dbg_fm_en),
    .paused(paused),

    .latch_wr(IOWR & cpu_word_addr[7:0] == 8'h00),
    .latch_rd(IORD & cpu_word_addr[7:0] == 8'h08),
    .latch_din(cpu_mem_out[7:0]),
    .latch_dout(snd_latch_dout),
    .latch_rdy(snd_latch_rdy),

    .secure_addr(bram_addr[7:0]),
    .secure_data(bram_data),
    .secure_wr(bram_wr & bram_cs[0]),

    .sample(sound_sample),

    .sdr_cpu_addr(sdr_audio_cpu_addr),
    .sdr_cpu_dout(sdr_audio_cpu_dout),
    .sdr_cpu_din(sdr_audio_cpu_din),
    .sdr_cpu_req(sdr_audio_cpu_req),
    .sdr_cpu_ack(sdr_audio_cpu_ack),
    .sdr_cpu_wr_sel(sdr_audio_cpu_wr_sel),

    .sdr_addr(sdr_audio_addr),
    .sdr_data(sdr_audio_dout),
    .sdr_req(sdr_audio_req),
    .sdr_ack(sdr_audio_ack)
);

assign AUDIO_L = sound_sample;
assign AUDIO_R = sound_sample;

`ifndef NO_EEPROM
eeprom_28C64 eeprom(
    .clk(clk_sys),
    .reset(~reset_n),
    .ce(1),
    
    .rd(MRD & eeprom_memrq),
    .wr(MWR & eeprom_memrq),

    .addr(cpu_mem_addr[13:1]),
    .q(eeprom_dout),
    .data(cpu_mem_out[7:0]),

    .ready(),

    .modified(ioctl_upload_req),
    .ioctl_download(ioctl_download | bram_cs[2]),
    .ioctl_wr(bram_cs[2] ? bram_wr : ioctl_wr),
    .ioctl_addr(bram_cs[2] ? bram_addr[12:0] : ioctl_addr[12:0]),
    .ioctl_dout(ioctl_dout),

    .ioctl_upload(ioctl_upload),
    .ioctl_din(ioctl_din),
    .ioctl_rd(ioctl_rd)
);
`endif

endmodule
