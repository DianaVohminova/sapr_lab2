`timescale 1ns/1ps

module apb_slave (
    // APB interface
    input  logic        PCLK,
    input  logic        PRESETn,
    input  logic        PSEL,
    input  logic        PENABLE,
    input  logic        PWRITE,
    input  logic [31:0] PADDR,
    input  logic [31:0] PWDATA,
    output logic [31:0] PRDATA,
    output logic        PREADY,
    output logic        PSLVERR,
    
    // Additional output for sync signal
    output logic        SYNC_OUT
);

    // Register addresses
    localparam REG_CTRL    = 8'h00;
    localparam REG_PERIOD  = 8'h04;  
    localparam REG_STATUS  = 8'h08;

    // Control register bits
    localparam CTRL_START  = 0;
    localparam CTRL_RESET  = 1;

    // Internal registers
    logic [31:0] control_reg;
    logic [31:0] period_reg;
    logic [31:0] counter_reg;
    logic sync_reg;

    // Control signals
    wire start = control_reg[CTRL_START];
    wire reset = control_reg[CTRL_RESET];
    wire [31:0] period = period_reg;

    // Always ready, no errors
    assign PREADY = 1'b1;
    assign PSLVERR = 1'b0;
    assign SYNC_OUT = sync_reg;

    // =========================================================================
    // MAIN SYNC GENERATOR LOGIC
    // =========================================================================
    
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // RESET: Initialize all registers
            counter_reg <= 32'h0;
            sync_reg <= 1'b0;
            $display("");
            $display("================================================");
            $display("SYNC GEN: RESET COMPLETED");
            $display("Counter: 0x00000000, Sync_out: 0");
            $display("================================================");
            $display("");
        end else begin
            // DEBUG: Print values each clock when generator is running
            if (start && (counter_reg == 0)) begin
                $display("SYNC DEBUG: time=%0t, period=%0d", $time, period);
            end
            
            if (reset) begin
                counter_reg <= 32'h0;
                sync_reg <= 1'b0;
            end else if (start) begin
                if (period == 0) begin
                    counter_reg <= 32'h0;
                    sync_reg <= 1'b0;
                end else if (counter_reg >= period - 1) begin
                    counter_reg <= 32'h0;
                    sync_reg <= ~sync_reg;
                    $display("=== SYNC TOGGLE at %0t: counter was %0d, period=%0d ===", 
                             $time, counter_reg, period);
                end else begin
                    counter_reg <= counter_reg + 1;
                end
            end
        end
    end

    // =========================================================================
    // APB WRITE LOGIC - CORRECTED VERSION
    // =========================================================================
    
    always @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            // REGISTER RESET
            control_reg <= 32'h0;
            period_reg <= 32'd5;    // CHANGED: default period = 5 (instead of 10)
            $display("SYNC GEN: Registers reset: control=0x00000000, period=0x00000005");
        end else if (PSEL && PENABLE && PWRITE) begin
            // APB WRITE - CORRECTED: removed extra conditions
            case (PADDR[7:0])
                REG_CTRL: begin
                    control_reg <= PWDATA;
                    $display("");
                    $display("------------------------------------------------");
                    $display("SYNC GEN: CONTROL REGISTER WRITE");
                    $display("------------------------------------------------");
                    $display("Address: 0x%08h", PADDR);
                    $display("Data:    0x%08h", PWDATA);
                    $display("Control register = 0x%08h", PWDATA);
                    $display("Start bit (0) = %b", PWDATA[CTRL_START]);
                    $display("Reset bit (1) = %b", PWDATA[CTRL_RESET]);
                    $display("------------------------------------------------");
                    $display("");
                end
                
                REG_PERIOD: begin
                    period_reg <= PWDATA;
                    $display("");
                    $display("------------------------------------------------");
                    $display("SYNC GEN: PERIOD REGISTER WRITE");
                    $display("------------------------------------------------");
                    $display("Address: 0x%08h", PADDR);
                    $display("Data:    0x%08h", PWDATA);
                    $display("Period register = 0x%08h (%0d ticks)", PWDATA, PWDATA);
                    $display("------------------------------------------------");
                    $display("");
                end
                
                default: begin
                    $display("SYNC GEN: Invalid write address 0x%08h", PADDR);
                end
            endcase
        end
    end

    // =========================================================================
    // APB READ LOGIC
    // =========================================================================
    
    always @(*) begin
        PRDATA = 32'd0;
        if (PSEL && !PWRITE) begin
            case (PADDR[7:0])
                REG_CTRL: begin
                    PRDATA = control_reg;
                    $display("SYNC GEN: Control register read = 0x%08h", control_reg);
                end
                
                REG_PERIOD: begin
                    PRDATA = period_reg;
                    $display("SYNC GEN: Period register read = 0x%08h", period_reg);
                end
                
                REG_STATUS: begin
                    // Status: [31:16] - counter, [1] - sync_out, [0] - period start flag
                    PRDATA = {counter_reg[15:0], 14'h0, sync_reg, counter_reg == 0};
                    $display("");
                    $display("------------------------------------------------");
                    $display("SYNC GEN: STATUS REGISTER READ");
                    $display("------------------------------------------------");
                    $display("Counter value: 0x%04h (%0d)", counter_reg[15:0], counter_reg);
                    $display("Sync_out: %b", sync_reg);
                    $display("Start of period: %b", counter_reg == 0);
                    $display("Status register: 0x%08h", PRDATA);
                    $display("------------------------------------------------");
                    $display("");
                end
                
                default: begin
                    PRDATA = 32'hDEADBEEF;
                    $display("SYNC GEN: Invalid read address 0x%08h, returning 0xDEADBEEF", PADDR);
                end
            endcase
        end
    end

endmodule
