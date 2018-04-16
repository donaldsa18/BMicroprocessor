start:
ST R0,5,R31;
LD R31,5,R1;
ADD R0,R1,R2;
beq R2,start,R1;