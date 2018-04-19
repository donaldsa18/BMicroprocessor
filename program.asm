start:
dispc 'H';
dispc 'e';
dispc 'l';
dispc 'l';
dispc 'o';
dispc ' ';
dispc 'w';
dispc 'o';
dispc 'r';
dispc 'l';
dispc 'd';
dispc '!';
dispc '\n';
ST R0,5,R31;
LD R31,5,R1;
ADD R0,R1,R2;
beq R2,start,R1;

failedadd:
dispc 'F';
dispc 'a';
dispc 'i';
dispc 'l';
dispc 'e';
dispc 'd';
dispc ' ';
dispc 'a';
dispc 'd';
dispc 'd';
dispc '\n';
trap;
failedsub:
dispc 'F';
dispc 'a';
dispc 'i';
dispc 'l';
dispc 'e';
dispc 'd';
dispc ' ';
dispc 's';
dispc 'u';
dispc 'b';
dispc '\n';
trap;