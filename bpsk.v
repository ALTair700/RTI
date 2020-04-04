module bpsk #(
		parameter N = 8 //ответ из условия задачи: N >= 4
)(
		// Input interface
		input  			   clk		,
		input  			   ce		,
		input			   reset	,
		// Output interface
		output reg   [9:0] sin_out	,
		output wire  [9:0] tx_out
);
//*****LOCAL PARAMETER******//
localparam LUT_SIZE  = 4; // 8	Размер таблицы значений для генератора синуса
localparam NUMB_SIZE = 7; // длина информационного сигнала

reg  [9:0] LUT [LUT_SIZE-1:0]; 	//  Таблица (я бы и сразу хотел тут таблицу в одну строку уместить, но только в системверилоге можно)

//*****COUNTER******//
reg  [1:0] CNT_LUT = 2'b0;		//	Счётчик для пробежки по таблице // reg  [2:0] CNT_LUT = 3'b0; для восьми
reg  [LOG(N-1):0] CNT_CLK = 0;	//	Счётчик для отсчитывания тактов от 0 до N-1
reg  [2:0] CNT_NUMB = 0;		//	Счётчик для пробежки по заданному сигналу (три счётчика почему-то меня смущают)
//******************//

reg  [6:0] NUMB = 7'b0110101;	//	Информационный сигнал
reg  [9:0] TX_OUT = 10'b0;		//	Выходной модулированный сигнал
wire [9:0] TEMP_WIRE;			//  Значение из LUT[CNT_LUT]
//reg CHECK_NUMB_BIN;				// 	Для симуляции посмотреть, правильно ли изменяется фаза


always @(posedge clk or posedge reset)	// Через сигнал reset инициализируем таблицу
	begin                               // также обнуляем выход sin_out и счётчик CNT_LUT 
		if (reset) begin                // и считаем 
			CNT_LUT <=  3'b0;
			sin_out <=  10'b0;
			LUT[0]  <=  10'd0;
			//LUT[1]  <=  10'd358;
			LUT[1]  <=  10'd511;
			//LUT[3]  <=  10'd358;
			LUT[2]  <=  10'd0;
			//LUT[5]  <= -10'd358;
			LUT[3]  <= -10'd511;
			//LUT[7]  <= -10'd358; 
		end
		else if (ce) begin
			CNT_LUT <= CNT_LUT + 1'b1;
			sin_out <= LUT[CNT_LUT];
		end
	end

always @(posedge clk or posedge reset)		// В данном блоке с помощью reset инициализируем счётчики и TX_OUT
	begin                                   // отсчитываем сначала тактовый сигнал до N-1, инкрементируем разряд передаваемого сигнала
		if (reset) begin                    // в зависимости от значения передаваемого информационного бита, устанавливаем фазу выходного сигнала
			CNT_CLK  <= 0;
			CNT_NUMB <= 0;
			TX_OUT	 <= 0;
		end
		else if (ce) begin
				if (CNT_CLK == N-1) begin
					CNT_CLK  <= 0;
					CNT_NUMB <= CNT_NUMB + 1'b1;
						if (CNT_NUMB == NUMB_SIZE-1) 
							CNT_NUMB <= 0;
						else
							CNT_NUMB <= CNT_NUMB + 1'b1;
				end
				else
					CNT_CLK  <= CNT_CLK + 1'b1;
						if (NUMB[CNT_NUMB])
							TX_OUT <=  TEMP_WIRE; 
						else begin
							TX_OUT <= -TEMP_WIRE;
						end
						
			//CHECK_NUMB_BIN <= NUMB[CNT_NUMB];	// Только для симуляции, посмотреть как меняется
			
		end
	end
	
	assign TEMP_WIRE = LUT[CNT_LUT];
	assign tx_out = TX_OUT;			   // Выход для промодулированного сигнала
	
function integer LOG(input [31:0]ARG); // $clog2(ARG)	Функция для расчёта логарифма
	integer i;
	for (i = 0; 2**i < ARG; i = i + 1)
		LOG = i + 1;
	endfunction

endmodule
