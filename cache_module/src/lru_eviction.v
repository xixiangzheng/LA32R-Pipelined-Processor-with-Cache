module lru_eviction #(
    parameter INDEX_WIDTH               = 3,
    parameter WAY_NUM                   = 2
)(
    input                               clk,    
    input                               rstn,
    input       [INDEX_WIDTH-1:0]       index,
    output      reg         [7:0]       eviction
);
  
integer                         i, j, k, age_m;
reg     [INDEX_WIDTH-1:0]       index_reg;
reg     [127:0]                 age [0:(1<<INDEX_WIDTH)-1] [0:WAY_NUM-1];

// 通过 index 的改变判别是否进行访存
always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        index_reg <= 0;
    end 
    else begin
        index_reg <= index;
    end
end

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for(i = 0; i < (1<<INDEX_WIDTH); i = i + 1) begin
            for(j = 0; j < WAY_NUM; j = j + 1) begin
                age[i][j] <= 0;
            end
        end
    end 
    else if (index_reg != index) begin
        for(i = 0; i < (1<<INDEX_WIDTH); i = i + 1) begin
            for(j = 0; j < WAY_NUM; j = j + 1) begin
                age[i][j] <= age[i][j] + 1;     // 每次访存发生时，其余“路”之age均进行增长
            end
        end
    end
    else begin
        for(i = 0; i < (1<<INDEX_WIDTH); i = i + 1) begin
            for(j = 0; j < WAY_NUM; j = j + 1) begin
                age[i][j] <= age[i][j];
            end
        end
    end
end

always @(*) begin
    eviction = 0;
    age_m = 0;      // 保存最大age，用以计算被替换的“路”号
    for(k = 0; k < WAY_NUM; k = k + 1) begin
        if (age[index][k] >= age_m) begin
            eviction = k;
            age_m = age[index][k];
        end
    end

    if (index_reg != index) begin
        age[index][eviction] = 0;   // 每次访存发生时，该次访问的“路”之age清零
    end
end
endmodule