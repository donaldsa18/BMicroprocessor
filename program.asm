
dispc "Hello world!";

dispc "ADD";
LDR label_a,R0;
LDR label_b,R1;
ADD R0,R1,R2;
disp R2;
dispc " ";

////////////////////// stopped here //////////////////

dispc "SUB";
ST R0,5,R31;
LD R31,5,R1;
SUB R0,R1,R2;
disp R1;
dispc " ";

dispc "MUL";
ST R0,5,R31;
LD R31,5,R1;
MUL R0,R1,R2;
disp R1;
dispc " ";

dispc "DIV";
ST R0,5,R31;
LD R31,5,R1;
DIV R0,R1,R2;
disp R1;
dispc " ";

dispc "CMPEQ";
ST R0,5,R31;
LD R31,5,R1;
CMPEQ R0,R1,R2;
disp R1;
dispc " ";

dispc "CMPLT";
ST R0,5,R31;
LD R31,5,R1;
CMPLT R0,R1,R2;
disp R1;
dispc " ";

dispc "CMPLE";
ST R0,5,R31;
LD R31,5,R1;
CMPLE R0,R1,R2;
disp R1;
dispc " ";

dispc "AND";
ST R0,5,R31;
LD R31,5,R1;
AND R0,R1,R2;
disp R1;
dispc " ";

dispc "OR";
ST R0,5,R31;
LD R31,5,R1;
OR R0,R1,R2;
disp R1;
dispc " ";

dispc "XOR";
ST R0,5,R31;
LD R31,5,R1;
XOR R0,R1,R2;
disp R1;
dispc " ";

dispc "XNOR";
ST R0,5,R31;
LD R31,5,R1;
XNOR R0,R1,R2;
disp R1;
dispc " ";

dispc "SHL";
ST R0,5,R31;
LD R31,5,R1;
SHL R0,R1,R2;
disp R1;
dispc " ";

dispc "SHR";
ST R0,5,R31;
LD R31,5,R1;
SHR R0,R1,R2;
disp R1;
dispc " ";

dispc "SRA";
ST R0,5,R31;
LD R31,5,R1;
SRA R0,R1,R2;
disp R1;
dispc " ";

dispc "ANDC";
ST R0,5,R31;
LD R31,5,R1;
ANDC R0,R1,R2;
disp R1;
dispc " ";

dispc "ORC";
ST R0,5,R31;
LD R31,5,R1;
ORC R0,R1,R2;
disp R1;
dispc " ";

dispc "XORC";
ST R0,5,R31;
LD R31,5,R1;
XORC R0,R1,R2;
disp R1;
dispc " ";

dispc "XNORC";
ST R0,5,R31;
LD R31,5,R1;
XNORC R0,R1,R2;
disp R1;
dispc " ";

dispc "SHLC";
ST R0,5,R31;
LD R31,5,R1;
SHLC R0,R1,R2;
disp R1;
dispc " ";

dispc "SHRC";
ST R0,5,R31;
LD R31,5,R1;
SHRC R0,R1,R2;
disp R1;
dispc " ";

dispc "SRAC";
ST R0,5,R31;
LD R31,5,R1;
SRAC R0,R1,R2;
disp R1;
dispc " ";

label_a: db 10;
label_b: db 12;
