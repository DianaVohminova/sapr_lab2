`timescale 1ns/1ps

module apb_master (
    // APB interface signals
    input  logic        PCLK,
    input  logic        PRESETn,
    output logic        PSEL,
    output logic        PENABLE,
    output logic        PWRITE,
    output logic [31:0] PADDR,
    output logic [31:0] PWDATA,
    input  logic [31:0] PRDATA,
    input  logic        PREADY,
    input  logic        PSLVERR
);

    // Internal signals for FSM control
    logic [1:0] state;
    logic [31:0] read_data_reg;
    logic transaction_active;
    logic [31:0] current_addr;
    logic read_complete;
    
    // FSM states
    localparam IDLE = 2'b00;
    localparam SETUP = 2'b01;
    localparam ACCESS = 2'b10;

    // APB Master FSM
    always_ff @(posedge PCLK or negedge PRESETn) begin
        if (!PRESETn) begin
            state <= IDLE;
            PSEL <= 1'b0;
            PENABLE <= 1'b0;
            PWRITE <= 1'b0;
            PADDR <= 32'd0;
            PWDATA <= 32'd0;
            read_data_reg <= 32'd0;
            transaction_active <= 1'b0;
            read_complete <= 1'b0;
            $display("APB MASTER: Reset completed - FSM in IDLE state");
        end else begin
            read_complete <= 1'b0;
            case (state)
                IDLE: begin
                    PENABLE <= 1'b0;
                    if (transaction_active) begin
                        PSEL <= 1'b1;
                        state <= SETUP;
                        $display("APB MASTER: IDLE -> SETUP, PSEL=1");
                    end
                end
                
                SETUP: begin
                    PENABLE <= 1'b1;
                    state <= ACCESS;
                    $display("APB MASTER: SETUP -> ACCESS, PENABLE=1");
                end
                
                ACCESS: begin
                    if (PREADY) begin
                        if (!PWRITE) begin
                            read_data_reg <= PRDATA;
                            read_complete <= 1'b1;
                            $display("APB MASTER: Read data captured: 0x%08h", PRDATA);
                        end
                        PSEL <= 1'b0;
                        PENABLE <= 1'b0;
                        state <= IDLE;
                        transaction_active <= 1'b0;
                        $display("APB MASTER: Transaction completed, returning to IDLE");
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end

    // APB Write task
    task apb_write(input [31:0] inp_addr, input [31:0] inp_data);
        begin
            $display("");
            $display("++++++++++++++++++++++++++++++++++++++++++++++++");
            $display("APB MASTER: INITIATING WRITE TRANSACTION");
            $display("++++++++++++++++++++++++++++++++++++++++++++++++");
            $display("Address: 0x%08h", inp_addr);
            $display("Data:    0x%08h", inp_data);
            
            PADDR <= inp_addr;
            PWDATA <= inp_data;
            PWRITE <= 1'b1;
            current_addr <= inp_addr;
            transaction_active <= 1'b1;
            
            $display("APB MASTER: Write signals set, starting transaction...");
            wait(transaction_active == 0);
            
            $display("APB MASTER: WRITE TRANSACTION COMPLETED SUCCESSFULLY");
            $display("++++++++++++++++++++++++++++++++++++++++++++++++");
            $display("");
        end
    endtask

    // APB Read task
    task apb_read(input [31:0] inp_addr, output logic [31:0] out_data);
        begin
            $display("");
            $display("++++++++++++++++++++++++++++++++++++++++++++++++");
            $display("APB MASTER: INITIATING READ TRANSACTION");
            $display("++++++++++++++++++++++++++++++++++++++++++++++++");
            $display("Address: 0x%08h", inp_addr);
            
            PADDR <= inp_addr;
            PWRITE <= 1'b0;
            current_addr <= inp_addr;
            transaction_active <= 1'b1;
            
            $display("APB MASTER: Read signals set, starting transaction...");
            wait(transaction_active == 0);
            @(posedge read_complete);
            
            out_data = read_data_reg;
            $display("APB MASTER: Read data stored: 0x%08h", out_data);
            $display("APB MASTER: READ TRANSACTION COMPLETED SUCCESSFULLY");
            $display("++++++++++++++++++++++++++++++++++++++++++++++++");
            $display("");
        end
    endtask

endmodule