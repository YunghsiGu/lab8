/**
 *
 * @author : 409410037, 409410100
 * @latest change : 2022/5/8 12:34
 */

`define length 6

module lab8(input clk,
            input reset,
            input give_valid,
            input [7:0]dataX,
            input [7:0]dataY,
            output reg [7:0]ansX,
            output reg [7:0]ansY,
            output reg out_valid);

    integer i;
    reg [7:0]inX[0:`length-1];          // store input
    reg [7:0]inY[0:`length-1];
    reg [7:0]negcount[0:`length-1];     // 順時針方向有幾個人
    reg signed [7:0]tempX[0:`length-1]; // store output
    reg signed [7:0]tempY[0:`length-1];

    reg [3:0]count[0:`length - 1];

    reg [3:0]state;
    reg [7:0]ix;                        //紀錄輸第幾筆資料
    reg [7:0]jx;
    reg [7:0]kx;

    initial begin
        $dumpfile("Lab.vcd");
        $dumpvars(0, lab8tb);
        for (i = 0; i < `length; i = i + 1)
            $dumpvars(1, inX[i], inY[i], tempX[i], tempY[i], count[i]);
    end

    always@(posedge clk or posedge reset) begin
        /*系統 reset 時，圍籬系統應將 out_valid 設為 low*/
        if (reset) begin    // 初始化
            out_valid <= 0;
            state <= 1;
            for (i = 0; i < `length; i = i + 1) begin
                inX[i] <= 0;
                inY[i] <= 0;
                tempX[i] <= 0;
                tempY[i] <= 0;
                count[i] <= i;
                negcount[i] <= 0;   //順時針有幾個人
            end
            ix <= 0;    
            jx <= 0;
            kx <= 0;
        end 
        else begin
            case (state)
                4'd0:begin      // initial state
                    out_valid <= 0;
                    state <= 1;
                    for (i = 0; i < `length; i = i + 1) begin
                        inX[i] <= 0;
                        inY[i] <= 0;
                        tempX[i] <= 0;
                        tempY[i] <= 0;
                        count[i] <= i;
                        negcount[i] <= 0;
                    end
                    ix <= 0;
                    jx <= 0;
                    kx <= 0;
                end
                4'd1:begin      // receive input state
                    out_valid <= 0;
                    if (ix == `length)      //已經輸6筆座標
                        state <= 2;
                    else if (give_valid) begin
                        inX[ix] <= dataX;
                        inY[ix] <= dataY;
                        ix <= ix + 1;
                    end
                end
                4'd2:begin      // calculate vector from inputs
                    out_valid <= 0;
                    state <= 3;
                    tempX[5] <= inX[5] - inX[0];
                    tempY[5] <= inY[5] - inY[0];
                    tempX[4] <= inX[4] - inX[0];
                    tempY[4] <= inY[4] - inY[0];
                    tempX[3] <= inX[3] - inX[0];
                    tempY[3] <= inY[3] - inY[0];
                    tempX[2] <= inX[2] - inX[0];
                    tempY[2] <= inY[2] - inY[0];
                    tempX[1] <= inX[1] - inX[0];
                    tempY[1] <= inY[1] - inY[0];
                    tempX[0] <= inX[0] - inX[0];
                    tempY[0] <= inY[0] - inY[0];
                end
                4'd3:begin      // S3_compare each vector
                    out_valid <= 0; 
                    if (jx == `length-1) begin      //比到第5個接收器 
                        if(kx == `length-1) state <= 4; 
                        else                kx <= kx+1;
                        jx <= 0;
                    end else
                        jx <= jx+1;         

                    if ((tempX[kx] * tempY[jx] - tempX[jx] * tempY[kx]) < 0)
                        negcount[kx] <= negcount[kx] + 1;                   
                end
                4'd4:begin      // S4_sort the position of vectors(bubble sort)
                    out_valid <= 0;
                    if (jx == `length-1) begin      //雙層迴圈
                        if(kx == `length-1) state <= 5; 
                        else                kx <= kx+1;
                        jx <= 0;
                    end else
                        jx <= jx+1;

                    if (negcount[jx] > negcount[jx + 1]) begin//swap
                        tempX[jx] <= tempX[jx + 1];
                        tempX[jx + 1] <= tempX[jx];
                        tempY[jx] <= tempY[jx + 1];
                        tempY[jx + 1] <= tempY[jx];
                    end
                end
                /*每次輸出結果後，將 out_valid 再復歸為 low*/
                4'd5:begin      // output answer and back to initial state
                    out_valid <= 1;
                    if (ix == `length) begin 
                        state <= 1;
                        for (i = 0; i < `length; i = i + 1) begin
                            inX[i] <= 0;
                            inY[i] <= 0;
                            tempX[i] <= 0;
                            tempY[i] <= 0;
                            count[i] <= i;
                            negcount[i] <= 0;
                        end
                        ix <= 0;
                        jx <= 0;
                        kx <= 0;
                        ansX <= 0;
                        ansY <= 0;
                    end else if (out_valid) begin
                        ansX <= tempX[ix];
                        ansY <= tempY[ix];
                        ix <= ix + 1;
                    end
                end
            endcase
        end
    end

endmodule

/*==================================*/