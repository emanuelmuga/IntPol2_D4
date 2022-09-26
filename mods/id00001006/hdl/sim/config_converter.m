clc;
clear
close all;
set(0,'DefaultFigureWindowStyle','docked');

Design         = 1;

M_bits         = 31;
DATA_WIDTH     = 32;

DATA_WIDTH_MAX = 32;
SF = 2^(-M_bits);

%  samp fijos D1 & D2:  5 = 3'b000;
%                       10 = 3'b001;
%                       20 = 3'b010;
%                       50 = 3'b011;
%                       100 = 3'b100;

%  samp fijos D3     : 2  = 3'b000;
%                      4  = 3'b001;
%                      8  = 3'b010;
%                      16 = 3'b011;
%                      32 = 3'b100;
%                      64 = 3'b101;
%                     128 = 3'b110;

%      sel_Frac    :  1/2  = 2'b00;
%                     1/5  = 2'b01;
%                     2/5  = 2'b10;
%                     4/5  = 2'b11;
%     

paso     = 10;
samp     = 3;
bypass   = 0;
mode     = 0;
xread    = 0;
xfactor  = (1/paso)/SF;
x2factor = ((1/paso)^2)/SF;
xfactor_max  = uint32(xfactor);
x2factor_max = uint32(x2factor);


conf0_1     = bitor(bypass,bitshift(mode,1));
conf0_2     = bitor(conf0_1,bitshift(samp,2));
conf0_3     = bitor(conf0_2,bitshift(xread,26));

config_reg0 = uint32(conf0_3);
config_reg1 = ((xfactor_max));
config_reg2 = ((x2factor_max));
config_reg3 = (uint32(paso));

config_reg = [config_reg0; config_reg1; config_reg2; config_reg3];
config_reg_S = num2str(dec2hex(config_reg));
[col,fil] = size(config_reg_S);
M1 = zeros(1,3);

iter = 4;
for i = 1:iter
    x=0:(1/paso):20;
    y=sin(2*pi*(1/10)*x);
    stem(x,y)
%     m0=y(find(x==(i-1)))
%     m1=y(find(x==(i))) 
%     m2=y(find(x==(i+1)))
    m0=y(1,i);
    m1=y(1,i+1); 
    m2=y(1,i+2);
    
    M1 = [m0 m1 m2]

%     hold on; stem([0,1,2],[m0,m1,m2],'r');
%     hold on; stem([0,1,2],[m0,m1,m2]);
    p0=m0; 
    p2=(m2+m0)/2-m1;
    p1=2*m1-m0-(m2+m0)/2;
    
    yfilt=p0+p1*x+p2*x.^2;
    % stem(x,yfilt,'g');
    % hold off;
    EC=sum((yfilt-y).^2)/sum((yfilt).^2); %= 2.0187e-04 para una energia de Ey=sum((yfilt).^2); %=8.0442;
    result = yfilt(1:paso)'
end

signal_test = y(1,1:100);

config_reg_S;
fpr = fipref;
fpr.NumberDisplay = 'hex';
M = fi(M1',1,DATA_WIDTH,M_bits);
R = fi(result,1,DATA_WIDTH,M_bits);
Y = fi(signal_test',1,DATA_WIDTH,M_bits);

Data_out_matlab = R.hex;
DATA2TEST = Y.hex;

[col,fil] = size(Data_out_matlab);
k = 1;
fileID = fopen('Data_out_matlab.txt','w');
for ii = 1:col
    for jj = 1:(fil+2)
        if (k==1)
            fprintf(fileID,'%s','0');
             k = k + 1;
        elseif (k==fil+2)
             k = 1;
        else
            fprintf(fileID,'%s',Data_out_matlab(ii,k-1));
             k = k + 1;
        end
    end
    fprintf(fileID,'\n');
end
fclose(fileID);



%%
[col,fil] = size(config_reg_S);
k = 1;
fileID = fopen('config.ipd','w');
for ii = 1:col
    for jj = 1:(fil+2)
        if (k==1)
            fprintf(fileID,'%s','0');
             k = k + 1;
        elseif (k==fil+2)
             k = 1;
        else
            fprintf(fileID,'%s',config_reg_S(ii,k-1));
             k = k + 1;
        end
    end
    fprintf(fileID,'\n');
end
fclose(fileID);


Data_in_to_HW = M.hex;

[col,fil] = size(Data_in_to_HW);

fileID = fopen('Mem_in.ipd','w');
for ii = 1:col
    for jj = 1:fil
        fprintf(fileID,'%s',Data_in_to_HW(ii,jj));
    end
    fprintf(fileID,'\n');
end
fclose(fileID);

%% Signal test to file
[col,fil] = size(DATA2TEST);

fileID = fopen('signal_test.ipd','w');
for ii = 1:col
    for jj = 1:fil
        fprintf(fileID,'%s',DATA2TEST(ii,jj));
    end
    fprintf(fileID,'\n');
end
fclose(fileID);