BEQ R1,start_label,R2;
DISPC "\nPassed all tests\n";
trap;

start_label:

DISPC "Hello world!";
LDR label_a,R0;
LDR label_b,R1;

DISPC "\nADD 17=";
ADD R0,R1,R2;
DISP R2,int;
LDR label_add,R3;
CMPEQ R2,R3,R4
BEQ R4,failedADD,R3;

DISPC "\nSUB 13=";
SUB R0,R1,R2;
DISP R2,int;
LDR label_sub,R3;
CMPEQ R2,R3,R4
BEQ R4,failedSUB,R3;

DISPC "\nMUL 30=";
MUL R0,R1,R2;
DISP R2,int;
LDR label_mul,R3;
CMPEQ R2,R3,R4
BEQ R4,failedMUL,R3;

DISPC "\nDIV 7=";
DIV R0,R1,R2;
DISP R2,int;
LDR label_div,R3;
CMPEQ R2,R3,R4
BEQ R4,failedDIV,R3;

DISPC "\nCMPEQ 0=";
CMPEQ R0,R1,R2;
DISP R2,int;
LDR label_0,R3;
CMPEQ R2,R3,R4
BEQ R4,failedCMPEQ,R3;

DISPC "\nCMPEQ 1=";
CMPEQ R1,R1,R2;
DISP R2,int;
LDR label_1,R3;
CMPEQ R2,R3,R4
BEQ R4,failedCMPEQ,R3;

DISPC "\nCMPLT 0=";
CMPLT R0,R1,R2;
DISP R2,int;
LDR label_0,R3;
CMPEQ R2,R3,R4
BEQ R4,failedCMPLT,R3;

DISPC "\nCMPLT 1=";
CMPLT R1,R0,R2;
DISP R2,int;
LDR label_1,R3;
CMPEQ R2,R3,R4
BEQ R4,failedCMPLT,R3;

DISPC "\nCMPLE 0=";
CMPLE R0,R1,R2;
DISP R2,int;
LDR label_0,R3;
CMPEQ R2,R3,R4
BEQ R4,failedCMPLE,R3;

DISPC "\nCMPLE 1=";
CMPLE R0,R0,R2;
DISP R2,int;
LDR label_1,R3;
CMPEQ R2,R3,R4
BEQ R4,failedCMPLE,R3;

DISPC "\nCMPLE 1=";
CMPLE R1,R0,R2;
DISP R2,int;
LDR label_1,R3;
CMPEQ R2,R3,R4
BEQ R4,failedCMPLE,R3;

DISPC "\nAND 2=";
AND R0,R1,R2;
DISP R2,int;
LDR label_and,R3;
CMPEQ R2,R3,R4
BEQ R4,failedAND,R3;

DISPC "\nOR 15=";
OR R0,R1,R2;
DISP R2,int;
LDR label_or,R3;
CMPEQ R2,R3,R4
BEQ R4,failedOR,R3;

DISPC "\nXOR 13=";
XOR R0,R1,R2;
DISP R2,int;
LDR label_xor,R3;
CMPEQ R2,R3,R4
BEQ R4,failedXOR,R3;

DISPC "\nXNOR -14=";
XNOR R0,R1,R2;
DISP R2,int;
LDR label_xnor,R3;
CMPEQ R2,R3,R4
BEQ R4,failedXNOR,R3;

DISPC "\nSHL 60=";
SHL R0,R1,R2;
DISP R2,int;
LDR label_shl,R3;
CMPEQ R2,R3,R4
BEQ R4,failedSHL,R3;

DISPC "\nSHR 3=";
SHR R0,R1,R2;
DISP R2,int;
LDR label_shr,R3;
CMPEQ R2,R3,R4
BEQ R4,failedSHR,R3;

DISPC "\nSRA 3=";
SRA R0,R1,R2;
DISP R2,int;
LDR label_shr,R3;
CMPEQ R2,R3,R4
BEQ R4,failedSRA,R3;

LDR label_neg,R0;

DISPC "\nSRA -4=";
SRA R0,R1,R2;
DISP R2,int;
LDR label_sra_neg,R3;
CMPEQ R2,R3,R4
BEQ R4,failedSRA,R3;

LDR label_a,R0;

DISPC "\nANDC 2=";
ANDC R0,2,R2
DISP R2,int;
LDR label_and,R3;
CMPEQ R2,R3,R4
BEQ R4,failedANDC,R3;

DISPC "\nORC 15=";
ORC R0,2,R2
DISP R2,int;
LDR label_or,R3;
CMPEQ R2,R3,R4
BEQ R4,failedORC,R3;

DISPC "\nXORC 13=";
XORC R0,2,R2;
DISP R2,int;
LDR label_xor,R3;
CMPEQ R2,R3,R4
BEQ R4,failedXORC,R3;

DISPC "\nXNORC -14=";
XNORC R0,2,R2;
DISP R2,int;
LDR label_xnor,R3;
CMPEQ R2,R3,R4
BEQ R4,failedXNORC,R3;

DISPC "\nSHLC 60=";
SHLC R0,2,R2;
DISP R2,int;
LDR label_shl,R3;
CMPEQ R2,R3,R4
BEQ R4,failedSHLC,R3;

DISPC "\nSHRC 3=";
SHRC R0,2,R2;
DISP R2,int;
LDR label_shr,R3;
CMPEQ R2,R3,R4
BEQ R4,failedSHRC,R3;

LDR label_a,R0;

DISPC "\nSRAC 3=";
SRAC R0,2,R2;
DISP R2,int;
LDR label_sra,R3;
CMPEQ R2,R3,R4
BEQ R4,failedSRAC,R3;

LDR label_neg,R0;

DISPC "\nSRAC -4=";
SRAC R0,2,R2;
DISP R2,int;
LDR label_sra_neg,R3;
CMPEQ R2,R3,R4;
BEQ R4,failedSRAC,R3;

DISPC "\nST -15=";
ST R0,4000,R31;
LD R31,4000,R1;
DISP R1,int;
CMPEQ R0,R1,R4;
BEQ R4,failedST,R3;


LDR label_1,R1;
JMP R31,R0;

trap;

failedLD: DISPC "\nFailed LD\n";
trap;
failedST: DISPC "\nFailed ST\n";
trap;
failedJMP: DISPC "\nFailed JMP\n";
trap;
faileDBEQ: DISPC "\nFailed BEQ\n";
trap;
faileDBNE: DISPC "\nFailed BNE\n";
trap;
failedLDR: DISPC "\nFailed LDR\n";
trap;
failedADD: DISPC "\nFailed ADD\n";
trap;
failedSUB: DISPC "\nFailed SUB\n";
trap;
failedMUL: DISPC "\nFailed MUL\n";
trap;
failedDIV: DISPC "\nFailed DIV\n";
trap;
failedCMPEQ: DISPC "\nFailed CMPEQ\n";
trap;
failedCMPLT: DISPC "\nFailed CMPLT\n";
trap;
failedCMPLE: DISPC "\nFailed CMPLE\n";
trap;
failedAND: DISPC "\nFailed AND\n";
trap;
failedOR: DISPC "\nFailed OR\n";
trap;
failedXOR: DISPC "\nFailed XOR\n";
trap;
failedXNOR: DISPC "\nFailed XNOR\n";
trap;
failedSHL: DISPC "\nFailed SHL\n";
trap;
failedSHR: DISPC "\nFailed SHR\n";
trap;
failedSRA: DISPC "\nFailed SRA\n";
trap;
failedADDC: DISPC "\nFailed ADDC\n";
trap;
failedSUBC: DISPC "\nFailed SUBC\n";
trap;
failedMULC: DISPC "\nFailed MULC\n";
trap;
failedDIVC: DISPC "\nFailed DIVC\n";
trap;
failedCMPEQC: DISPC "\nFailed CMPEQC\n";
trap;
failedCMPLTC: DISPC "\nFailed CMPLTC\n";
trap;
failedCMPLEC: DISPC "\nFailed CMPLEC\n";
trap;
failedANDC: DISPC "\nFailed ANDC\n";
trap;
failedORC: DISPC "\nFailed ORC\n";
trap;
failedXORC: DISPC "\nFailed XORC\n";
trap;
failedXNORC: DISPC "\nFailed XNORC\n";
trap;
failedSHLC: DISPC "\nFailed SHLC\n";
trap;
failedSHRC: DISPC "\nFailed SHRC\n";
trap;
failedSRAC: DISPC "\nFailed SRAC\n";
trap;
failedST: DISPC "\nFailed ST\n";
trap;

label_a: DB 15;
label_b: DB 2;
label_neg: DB -15;
label_or: DB 15;
label_and: DB 2;
label_add: DB 17;
label_sub: DB 13;
label_mul: DB 30;
label_div: DB 7;
label_xor: DB 13;
label_shl: DB 60;
label_shr: DB 3;
label_sra: DB 3;
label_sra_neg: DB -4;
label_xnor: DB -14;
label_0: DB 0;
label_1: DB 1;
