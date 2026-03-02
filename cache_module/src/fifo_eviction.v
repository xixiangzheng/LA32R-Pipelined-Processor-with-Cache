module fifo_eviction #(
    parameter INDEX_WIDTH               = 3,
    parameter WAY_NUM                   = 2
)(
    input                               clk,    
    input                               rstn,
    input                               hit,
    input       [INDEX_WIDTH-1:0]       index,
    output      reg         [7:0]       eviction
);
  
integer                         i, j, k, age_m;
reg     [127:0]                 age [0:(1<<INDEX_WIDTH)-1] [0:WAY_NUM-1];

always @(posedge clk or negedge rstn) begin
    if (!rstn) begin
        for(i = 0; i < (1<<INDEX_WIDTH); i = i + 1) begin
            for(j = 0; j < WAY_NUM; j = j + 1) begin
                age[i][j] <= 0;
            end
        end
    end 
    else begin
        for(i = 0; i < (1<<INDEX_WIDTH); i = i + 1) begin
            for(j = 0; j < WAY_NUM; j = j + 1) begin
                age[i][j] <= age[i][j] + 1;     // 时间戳于每个时钟周期均进行增长
            end
        end
    end
end

always @(*) begin
    eviction = 0;
    age_m = 0;
    for(k = 0; k < WAY_NUM; k = k + 1) begin
        if (age[index][k] >= age_m) begin
            eviction = k;
            age_m = age[index][k];
        end
    end

    if (!hit) begin     // 与lru的区别在于，先进先出不考虑最近是否被访问，只关心被替换的先后顺序
        age[index][eviction] = 0;
    end
end
endmodule