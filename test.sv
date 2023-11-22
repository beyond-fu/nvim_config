`timescale 1ns / 1ps

import params_pkg::*;

module MVM_tb ();

    parameter CLK100_PEROID = 10;
    parameter CLK200_PEROID = 5;

    bit clk, clk_ddr;
    bit rst;  //active high
    logic [IC_N-1:0] strobe_i;
    logic load_mode_i;
    logic signed [WINDOW_SIZE-1:0][DATA_WIDTH-1:0] vector_i[IC_N];
    logic valid_i;
    logic ready_i;
    logic valid_o;
    logic ready_o;
    logic signed [DATA_WIDTH-1:0] mvm_o[OC_N];
    logic signed [WINDOW_SIZE-1:0][DATA_WIDTH-1:0] weights_record[WEIGHT_CYCLES][IC_N];
    logic signed [WINDOW_SIZE-1:0][DATA_WIDTH-1:0] vector_record[CALC_CYCLES][IC_N];
    logic signed [DATA_WIDTH-1:0] result[CALC_CYCLES][OC_N];
    integer seed;
    int ic_idx, wd_idx;
    int wght_cycle, calc_cycle;
    int cur_calc_cycle;

    wire valid;
    wire signed [DATA_WIDTH-1:0] data[OC_N];
    assign valid = MVM_inst.funnel_inst_7.valid_o;
    assign data  = MVM_inst.funnel_inst_7.data_o;

    MVM_if mvm_if (
        .clk(clk),
        .clk_ddr(clk_ddr),
        .rst(rst)
    );

    MVM MVM_inst (.*);

    initial begin
        // for (wght_cycle = 0; wght_cycle < WEIGHT_CYCLES; wght_cycle++) begin : WEIGHTS_REC_INIT
        //     for (ic_idx = 0; ic_idx < IC_N; ic_idx++) begin : WEIGHTS_REC_IC_INIT
        //         weights_record[wght_cycle][ic_idx] = '0;
        //     end
        // end
        // for (calc_cycle = 0; calc_cycle < CALC_CYCLES; calc_cycle++) begin : VECTOR_REC_INIT
        //     for (ic_idx = 0; ic_idx < IC_N; ic_idx++) begin : VECTOR_REC_IC_INIT
        //         vector_record[calc_cycle][ic_idx] = '0;
        //     end
        // end
        seed = 5;
        rst  = 1;
        #200;
        rst = 0;
    end

    initial begin
        clk = 0;
        forever begin
            #(CLK100_PEROID / 2) clk = ~clk;
        end
    end
    initial begin
        clk_ddr = 0;
        forever begin
            #(CLK200_PEROID / 2) clk_ddr = ~clk_ddr;
        end
    end

    initial begin
        $fsdbDumpfile("./wave/wave.fsdb");
        $fsdbDumpvars();
        $fsdbDumpMDA();
    end

    // sample weights and vector
    always_ff @(posedge clk) begin
        if (rst)
            for (int i = 0; i < WEIGHT_CYCLES; i++) begin
                for (int j = 0; j < IC_N; j++) begin
                    weights_record[i][j] <= '0;
                end
            end
        else if (valid_i & (~load_mode_i)) begin
            for (int i = 1; i < WEIGHT_CYCLES; i++) begin
                weights_record[i] <= weights_record[i-1];
            end
            weights_record[0] <= vector_i;
        end
    end
    always_ff @(posedge clk) begin
        if (rst)
            for (int i = 0; i < CALC_CYCLES; i++) begin
                for (int j = 0; j < IC_N; j++) begin
                    vector_record[i][j] <= '0;
                end
            end
        else if (valid_i & load_mode_i) begin
            for (int i = 0; i < CALC_CYCLES - 1; i++) begin
                vector_record[i] <= vector_record[i+1];
            end
            vector_record[CALC_CYCLES-1] <= vector_i;
        end
    end

    initial begin
        // init
        ready_i <= 1'b1;
        strobe_i <= {IC_N{1'b0}};
        load_mode_i <= 1'b0;
        for (int i = 0; i < 8; i++) begin : VECTOR_INIT
            vector_i[i] <= {VECTOR_IC_WIDTH{1'b0}};
        end
        valid_i <= 1'b0;
        #300;

        // deliver weights
        for (wght_cycle = 0; wght_cycle < WEIGHT_CYCLES; wght_cycle++) begin : DELIVER_WEIGHTS
            @(posedge clk);
            for (ic_idx = 0; ic_idx < IC_N; ic_idx++) begin : VECTOR_IC_ASSIGN
                for (wd_idx = 0; wd_idx < WINDOW_SIZE; wd_idx++) begin : VECTOR_WIDNDOW_ASSIGN
                    vector_i[ic_idx][wd_idx] <= {$urandom()} % 6;
                end
            end
            strobe_i <= {IC_N{1'b1}};
            load_mode_i <= 1'b0;
            valid_i <= 1'b1;
            seed <= seed + 1;
        end
        disable_deliver_weights();
        for (int i = 0; i < 3; i++) begin
            @(posedge clk);
        end

        // deliver input vector and start calc
        // 1st
        for (int test_iter = 0; test_iter < 5; test_iter++) begin : TEST_TIMES
            cur_calc_cycle = $urandom_range(CALC_CYCLES, 1);
            $display("This time calculation cycles: %d\n", cur_calc_cycle);
            // cur_calc_cycle = CALC_CYCLES;
            for (
                calc_cycle = 0; calc_cycle < cur_calc_cycle; calc_cycle++
            ) begin : DELIVER_VECTOR_CALC_1st
                @(posedge clk);
                for (ic_idx = 0; ic_idx < IC_N; ic_idx++) begin : VECTOR_IC_ASSIGN
                    for (wd_idx = 0; wd_idx < WINDOW_SIZE; wd_idx++) begin : VECTOR_WIDNDOW_ASSIGN
                        vector_i[ic_idx][wd_idx] <= {$urandom()} % 6;
                    end
                end
                strobe_i <= {IC_N{1'b1}};
                load_mode_i <= 1'b1;
                valid_i <= 1'b1;
                seed <= seed + 1;
            end
            disable_deliver_calc();
            #500;
            // #500;
            // // deliver input vector and start calc
            // // 2nd
            // cur_calc_cycle = 8;
            // for (
            //     calc_cycle = 0; calc_cycle < cur_calc_cycle; calc_cycle++
            // ) begin : DELIVER_VECTOR_CALC_2nd
            //     @(posedge clk);
            //     for (ic_idx = 0; ic_idx < IC_N; ic_idx++) begin : VECTOR_IC_ASSIGN
            //         for (wd_idx = 0; wd_idx < WINDOW_SIZE; wd_idx++) begin : VECTOR_WIDNDOW_ASSIGN
            //             vector_i[ic_idx][wd_idx] <= {$urandom()} % 6;
            //         end
            //     end
            //     strobe_i <= {IC_N{1'b1}};
            //     load_mode_i <= 1'b1;
            //     valid_i <= 1'b1;
            //     seed <= seed + 1;
            // end
            // disable_deliver_calc();

            // #500;
            // cur_calc_cycle = 5;
            // for (
            //     calc_cycle = 0; calc_cycle < cur_calc_cycle; calc_cycle++
            // ) begin : DELIVER_VECTOR_CALC_3rd
            //     @(posedge clk);
            //     for (ic_idx = 0; ic_idx < IC_N; ic_idx++) begin : VECTOR_IC_ASSIGN
            //         for (wd_idx = 0; wd_idx < WINDOW_SIZE; wd_idx++) begin : VECTOR_WIDNDOW_ASSIGN
            //             vector_i[ic_idx][wd_idx] <= {$urandom()} % 6;
            //         end
            //     end
            //     strobe_i <= {IC_N{1'b1}};
            //     load_mode_i <= 1'b1;
            //     valid_i <= 1'b1;
            //     seed <= seed + 1;
            // end
            // disable_deliver_calc();
        end

        #2000;

        $finish;
    end

    always begin
        validate_result();
    end

    // task static update_vector(input integer seed,
    //                           output [WINDOW_SIZE-1:0][DATA_WIDTH-1:0] vector[IC_N]);
    //     @(posedge clk);
    //     for (int ic_idx = 0; ic_idx < IC_N; ic_idx++) begin : VECTOR_IC_ASSIGN
    //         for (int wd_idx = 0; wd_idx < WINDOW_SIZE; wd_idx++) begin : VECTOR_WIDNDOW_ASSIGN
    //             random_num <= {$random(seed)} % 6;
    //             vector[ic_idx][wd_idx] <= random_num[7:0];
    //         end
    //     end
    // endtask

    task automatic disable_deliver_weights();
        @(posedge clk);
        strobe_i <= {IC_N{1'b0}};
        load_mode_i <= 1'b0;
        valid_i <= 1'b0;
    endtask

    task automatic disable_deliver_calc();
        @(posedge clk);
        strobe_i <= {IC_N{1'b0}};
        load_mode_i <= 1'b0;
        valid_i <= 1'b0;
    endtask

    task automatic validate_result();
        int cycle_index;
        wait (valid == 1'b1);
        cycle_index = CALC_CYCLES - cur_calc_cycle; // NOTE:`cur_calc_cycle` should not be passed in task as a port if used in real time
        calculate();
        $display("\nMVM output valid!\n");
        @(negedge clk);
        while (valid != 1'b0) begin
            for (int i = 0; i < OC_N; i++) begin
                if (result[cycle_index][i] != data[i]) begin
                    // $display("\nresult[%d][%d]: %h, data[i]: %h\n", cycle_index, i,
                    //          result[cycle_index][i], i, data[i]);
                    $display("\n Test fail!!!\n");
                    $display("current time: %t\n", $realtime);
                    // $display("current time: %t, current data_o: %h\n", $realtime, {
                    //          data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]
                    //          });
                end
            end
            // $display("current time: %t, current data_o: %h\n", $realtime, data);
            @(negedge clk);
            cycle_index++;
        end
    endtask

    task automatic calculate();
        int res_temp = 0;
        for (int cycle = 0; cycle < CALC_CYCLES; cycle++) begin
            for (int o = 0; o < OC_N; o++) begin
                res_temp = 0;
                for (int ic = 0; ic < IC_N; ic++) begin
                    for (int wd = 0; wd < WINDOW_SIZE; wd++) begin
                        res_temp += weights_record[o][ic][wd] * vector_record[cycle][ic][wd];
                    end
                end
                // $display("\nEach output channel res_temp: %h\n", res_temp);
                result[cycle][o] = res_temp;
            end
        end
    endtask

endmodule

