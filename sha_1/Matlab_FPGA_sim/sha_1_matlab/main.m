clc
clear

%connect to uart port;
serialportlist;
port = serialport("COM10",9600);

times = 10;   %Test times;
e_flag = 0;   %error times;

for T = 1:1:times
    %gen bits;
    [data, data_512bit] = gen_bits();

    %call matlab function to compare;
    code_matlab = sha_1(data_512bit);

    %data to uart;
    write(port,data,"uint8");
    
    %recieve code from fpga;
    code_dec = read(port,20,"uint8");
    code_hex = dec2hex(code_dec);
    code_str = mat2str(code_hex);
    code_fpga = erase(code_str, [";","[","]","'"]);
    
    %cmp matlab/FPGA result;
    if ~isequal(code_fpga,code_matlab)
        e_flag = e_flag + 1;
    end

    %remove independent var;
    clear code_dec code_hex code_str data_hex data_str i ans data data_512bit
end

%algorithm running results;
if e_flag
    msgbox(["Error",e_flag],"SHA_1_CMP");
els
    msgbox("Success","SHA_1_CMP");
end
