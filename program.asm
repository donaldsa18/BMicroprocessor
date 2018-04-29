<<<<<<< HEAD
BEQ R1,start_label,R2;
DISPC "\nPassed JMP\nPassed all tests\n";
trap;
=======
>>>>>>> dfcfdc1b7f77541e55c19ddee11bd7e39b7c2f6b

dispc "Hello world!";

<<<<<<< HEAD
DISPC "Hello world!";

; Test string printing

DISP label_str,STR;

; Test all registers
ORC R31,1,R0;
DISPC "\nR0 1=";
DISP R0,int;
CMPEQC R0,1,R1;
BEQ R1,failedReg,R3;

ORC R31,2,R1;
DISPC "\nR1 2=";
DISP R1,int;
CMPEQC R1,2,R0;
BEQ R0,failedReg,R3;

ORC R31,3,R2;
DISPC "\nR2 3=";
DISP R2,int;
CMPEQC R2,3,R0;
BEQ R0,failedReg,R3;

ORC R31,4,R3;
DISPC "\nR3 4=";
DISP R3,int;
CMPEQC R3,4,R0;
BEQ R0,failedReg,R3;

ORC R31,5,R4;
DISPC "\nR4 5=";
DISP R4,int;
CMPEQC R4,5,R0;
BEQ R0,failedReg,R3;

ORC R31,6,R5;
DISPC "\nR5 6=";
DISP R5,int;
CMPEQC R5,6,R0;
BEQ R0,failedReg,R3;

ORC R31,7,R6;
DISPC "\nR6 7=";
DISP R6,int;
CMPEQC R6,7,R0;
BEQ R0,failedReg,R3;

ORC R31,8,R7;
DISPC "\nR7 8=";
DISP R7,int;
CMPEQC R7,8,R0;
BEQ R0,failedReg,R3;

ORC R31,9,R8;
DISPC "\nR8 9=";
DISP R8,int;
CMPEQC R8,9,R0;
BEQ R0,failedReg,R3;

ORC R31,10,R9;
DISPC "\nR9 10=";
DISP R9,int;
CMPEQC R9,10,R0;
BEQ R0,failedReg,R3;

ORC R31,11,R10;
DISPC "\nR10 11=";
DISP R10,int;
CMPEQC R10,11,R0;
BEQ R0,failedReg,R3;

ORC R31,12,R11;
DISPC "\nR11 12=";
DISP R11,int;
CMPEQC R11,12,R0;
BEQ R0,failedReg,R3;

ORC R31,13,R12;
DISPC "\nR12 13=";
DISP R12,int;
CMPEQC R12,13,R0;
BEQ R0,failedReg,R3;

ORC R31,14,R13;
DISPC "\nR13 14=";
DISP R13,int;
CMPEQC R13,14,R0;
BEQ R0,failedReg,R3;

ORC R31,15,R14;
DISPC "\nR14 15=";
DISP R14,int;
CMPEQC R14,15,R0;
BEQ R0,failedReg,R3;

ORC R31,16,R15;
DISPC "\nR15 16=";
DISP R15,int;
CMPEQC R15,16,R0;
BEQ R0,failedReg,R3;

ORC R31,17,R16;
DISPC "\nR16 17=";
DISP R16,int;
CMPEQC R16,17,R0;
BEQ R0,failedReg,R3;

ORC R31,18,R17;
DISPC "\nR17 18=";
DISP R17,int;
CMPEQC R17,18,R0;
BEQ R0,failedReg,R3;

ORC R31,19,R18;
DISPC "\nR18 19=";
DISP R18,int;
CMPEQC R18,19,R0;
BEQ R0,failedReg,R3;

ORC R31,20,R19;
DISPC "\nR19 20=";
DISP R19,int;
CMPEQC R19,20,R0;
BEQ R0,failedReg,R3;

ORC R31,21,R20;
DISPC "\nR20 21=";
DISP R20,int;
CMPEQC R20,21,R0;
BEQ R0,failedReg,R3;

ORC R31,22,R21;
DISPC "\nR21 22=";
DISP R21,int;
CMPEQC R21,22,R0;
BEQ R0,failedReg,R3;

ORC R31,23,R22;
DISPC "\nR22 23=";
DISP R22,int;
CMPEQC R22,23,R0;
BEQ R0,failedReg,R3;

ORC R31,24,R23;
DISPC "\nR23 24=";
DISP R23,int;
CMPEQC R23,24,R0;
BEQ R0,failedReg,R3;

ORC R31,25,R24;
DISPC "\nR24 25=";
DISP R24,int;
CMPEQC R24,25,R0;
BEQ R0,failedReg,R3;

ORC R31,26,R25;
DISPC "\nR25 26=";
DISP R25,int;
CMPEQC R25,26,R0;
BEQ R0,failedReg,R3;

ORC R31,27,R26;
DISPC "\nR26 27=";
DISP R26,int;
CMPEQC R26,27,R0;
BEQ R0,failedReg,R3;

ORC R31,28,R27;
DISPC "\nR27 28=";
DISP R27,int;
CMPEQC R27,28,R0;
BEQ R0,failedReg,R3;

ORC R31,29,R28;
DISPC "\nR28 29=";
DISP R28,int;
CMPEQC R28,29,R0;
BEQ R0,failedReg,R3;

ORC R31,30,R29;
DISPC "\nR29 30=";
DISP R29,int;
CMPEQC R29,30,R0;
BEQ R0,failedReg,R3;

ORC R31,31,R30;
DISPC "\nR30 31=";
DISP R30,int;
CMPEQC R30,31,R0;
BEQ R0,failedReg,R3;

ORC R31,32,R31;
DISPC "\nR31 0=";
DISP R31,int;
BNE R31,failedReg,R3;

; Test BEQ/BNE

BEQ R31,continue_beq,R3;
dispc "\nFailed BEQ";
trap;

continue_beq:
dispc "\nPassed BEQ branch";
BEQ R0,failedBEQ,R3;
dispc "\nPassed BEQ non branch";
BNE R0,continue_bne,R3;
dispc "\nFailed BNE";
trap;

continue_bne:
dispc "\nPassed BNE branch";
BNE R31,failedBNE,R3;
dispc "\nPassed BNE non branch";

; Test storing/loading a word into memory

DISPC "\nST -15=";
ST R0,4000,R31;
LD R31,4000,R1;
DISP R1,int;
CMPEQ R0,R1,R4;
BEQ R4,failedST,R3;
dispc "\nPassed LD/ST";

; Test all math operations
=======
dispc "ADD";
>>>>>>> dfcfdc1b7f77541e55c19ddee11bd7e39b7c2f6b
LDR label_a,R0;
LDR label_b,R1;
ADD R0,R1,R2;
disp R2;
dispc " ";

dispc "SUB";
LDR label_a,R0;
LDR label_b,R1;
SUB R0,R1,R2;
disp R2;
dispc " ";

////////////////////// stopped here //////////////////

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
<<<<<<< HEAD
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

;Test all constant math operations

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

; Test JMP

LDR label_1,R1;
JMP R31,R0;

trap;

failedReg: DISPC "\nFailed Register\n";
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
failedBNE: DISPC "\nFailed BNE\n";
trap;
failedBEQ: DISPC "\nFailed BEQ\n";
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
label_str: DB "\nDisplay string passed"
=======
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

label_a: db 12;
label_b: db 10;
>>>>>>> dfcfdc1b7f77541e55c19ddee11bd7e39b7c2f6b
