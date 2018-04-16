import sys
import os
import re
import binascii


class SourceLine:

    def __init__(self, line_num, inum, line, opcode, arg1, arg2, arg3):
        self.line_num = line_num
        self.inum = inum
        self.line = line
        self.opcode = opcode
        self.arg1 = arg1
        self.arg2 = arg2
        self.arg3 = arg3


def main():
    filepath = sys.argv[1]
    re_line = re.compile(
        r'^([A-Za-z0-9]+:\s+)?(?P<instr>[A-Za-z]{2,6})\s(?P<argc>[^,]+),\s*(?P<arga>[^,]+),(?P<argb>[^,;]+)?')
    re_label = re.compile(r'^(?P<label>[A-Za-z0-9]+):')
    instructions = {
        "LD": 0b011000,
        "ST": 0b011001,
        "JMP": 0b011011,
        "BEQ": 0b011100,
        "BNE": 0b011101,
        "LDR": 0b011111,
        "ADD": 0b100000,
        "SUB": 0b100001,
        "MUL": 0b100010,
        "DIV": 0b100011,
        "CMPEQ": 0b100100,
        "CMPLT": 0b100101,
        "CMPLE": 0b100110,
        "AND": 0b101000,
        "OR": 0b101001,
        "XOR": 0b101010,
        "XNOR": 0b101011,
        "SHL": 0b101100,
        "SHR": 0b101101,
        "SRA": 0b101110,
        "ADDC": 0b101000,
        "SUBC": 0b110001,
        "MULC": 0b110010,
        "DIVC": 0b110011,
        "CMPEQC": 0b110100,
        "CMPLTC": 0b110101,
        "CMPLEC": 0b110110,
        "ANDC": 0b111000,
        "ORC": 0b111001,
        "XORC": 0b111010,
        "XNORC": 0b111011,
        "SHLC": 0b111100,
        "SHRC": 0b111101,
        "SRAC": 0b111110
    }
    registers = {
        "R0": 0,
        "R1": 1,
        "R2": 2,
        "R3": 3,
        "R4": 4,
        "R5": 5,
        "R6": 6,
        "R7": 7,
        "R8": 8,
        "R9": 9,
        "R10": 10,
        "R11": 11,
        "R12": 12,
        "R13": 13,
        "R14": 14,
        "R15": 15,
        "R16": 16,
        "R17": 17,
        "R18": 18,
        "R19": 19,
        "R20": 20,
        "R21": 21,
        "R22": 22,
        "R23": 23,
        "R24": 24,
        "R25": 25,
        "R26": 26,
        "R27": 27,
        "R28": 28,
        "R29": 29,
        "R30": 30,
        "R31": 31,
        "XP": 30,
        "SP": 29,
        "LP": 28,
        "BP": 27
    }
    if not os.path.isfile(filepath):
        print("File path {} does not exist. Exiting...".format(filepath))
        sys.exit()

    labels = {}
    icount = 0
    sourcelines = []
    with open("program.hex", "w") as fout:
        with open(filepath) as fin:
            linecount = 0
            for line in fin:
                linecount += 1
                line = line.strip().split(';')[0]
                m = re_label.match(line)
                if m is not none:
                    labels[m.group('label')] = icount + 1
                m = re_line.match(line)
                if m is not None:
                    sourcelines.append((linecount, icount, line, m.group('instr'), m.group('argc'), m.group('arga'), m.group('argb')))
                    icount += 1
        hexlines = []
        for line in sourcelines:
            if upper(line.opcode) in instructions:
                upper_opcode = upper(line.opcode)
                opcode = instructions[upper_opcode]
                inst = opcode << 26
                args_stripped = [line.arg1.replace("$", ""), line.arg2.replace("$", ""), line.arg3.replace("$", "")]
                # Check if math operation
                if 0b100000 & opcode:
                    for arg in args_stripped:
                        if upper(arg) not in registers:
                            print("Line {}: {} is not a register".format(line.line_num, arg1stripped))
                            sys.exit()

                    inst += registers[args_stripped[0]] << 21 + registers[args_stripped[1]] << 16 + registers[args_stripped[2]] << 11
                    hexlines.append(inst)
                # Check if constant math operation
                elif 0b110000 & opcode:
                    args_stripped = args_stripped[-1]
                    for arg in args_stripped:
                        if upper(arg) not in registers:
                            print("Line {}: {} is not a register".format(line.line_num, arg1stripped))
                            sys.exit()
                    if not line.arg3.isdigit():
                        print("Line {}: Literal {} is not a number".format(line.line_num, line.arg3))
                        sys.exit()
                    inst += registers[args_stripped[0]] << 21 + registers[args_stripped[1]] << 16 + int(line.arg3)
                # Special instruction
                elif 0b011000 & opcode:
                    if upper_opcode is "LD":
                        inst += registers[args_stripped[2]] << 21 + registers[args_stripped[0]] << 16 + int(line.arg2)
                    elif upper_opcode is "ST":
                        inst += registers[args_stripped[0]] << 21 + registers[args_stripped[2]] << 16 + int(line.arg2)
                    elif upper_opcode is "JMP":
                        inst += registers[args_stripped[1]] << 21 + registers[args_stripped[0]] << 16 + labels[line.arg2]
                    elif upper_opcode in ["BEQ", "BNE"]:
                        inst += registers[args_stripped[2]] << 21 + registers[args_stripped[0]] << 16 + labels[line.arg2]
                    elif upper_opcode is "LDR":
                        inst += registers[args_stripped[1]] << 21
                fout.write('{:04x} //%s'.format(inst, line.line))
            else:
                print("Line %d: invalid instruction %s" % (line.line_num, line.opcode))


if __name__ == '__main__':
    main()
