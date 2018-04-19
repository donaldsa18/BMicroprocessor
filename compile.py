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


def twos_comp(val, bits):
    """compute the 2's complement of int value val"""
    if (val & (1 << (bits - 1))) != 0:  # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)  # compute negative value
    return val  # return positive value as is


class BCompiler:
    def __init__(self):
        self.re_line = re.compile(
            r'^([A-Za-z0-9]+:\s+)?(?P<instr>[A-Za-z]{2,6})\s+(?P<argc>[^,]+)(,\s*(?P<arga>[^,]+))?(,(?P<argb>[^,;]+))?')
        self.re_label = re.compile(r'^(?P<label>[A-Za-z0-9]+):')
        self.re_char = re.compile(r"'(?P<escape>\\)?(?P<char>[^'\\])'")
        self.instructions = {
            "LD": 0b011000,
            "ST": 0b011001,
            "DISP": 0b010010,
            "JMP": 0b011011,
            "BEQ": 0b011100,
            "BNE": 0b011101,
            "DISPC": 0b011110,
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
            "ADDC": 0b110000,
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
        self.regs = {
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

    def charToInt(self, char):
        if char is None:
            return 0

        m = self.re_char.match(char)

        # Not a character, so return
        if m is None:
            return char

        esc = m.group('escape')
        c = m.group('char')

        # Not an escape character, so return ascii code
        if esc != '\\':
            return ord(c)

        # Can't craft these, so handle each escape character
        if c == 'a':
            return ord('\a')
        elif c == 'b':
            return ord('\b')
        elif c == 'f':
            return ord('\f')
        elif c == 'n':
            return ord('\n')
        elif c == 'r':
            return ord('\r')
        elif c == 't':
            return ord('\t')
        elif c == 'v':
            return ord('\v')
        elif len(c) > 1:
            if c[0] == 'x':
                return int(c[1:], 16)
            elif c[0] == 'o':
                return int(c[1:], 8)
        else:
            return ord(c)

    def compile(self):
        filepath = sys.argv[1]

        if not os.path.isfile(filepath):
            print("File path {} does not exist. Exiting...".format(filepath))
            sys.exit()

        labels = {}
        icount = 0
        sourcelines = []
        with open("program.bin", "w") as fout:
            # Pass 1
            with open(filepath) as fin:
                linecount = 0
                for line in fin:
                    linecount += 1
                    line = line.strip().split(';')[0]
                    m = self.re_label.match(line)
                    if m is not None:
                        labels[m.group('label')] = icount + 1
                    m = self.re_line.match(line)
                    if m is not None:
                        arga = self.charToInt(m.group('arga'))
                        argb = self.charToInt(m.group('argb'))
                        argc = self.charToInt(m.group('argc'))
                        sourcelines.append(SourceLine(linecount, icount, line, m.group('instr'), argc, arga, argb))
                        print("Line {}: Found instruction {}({},{},{})".format(linecount, m.group('instr'), argc, arga, argb))
                        icount += 1
            # Pass 2
            for line in sourcelines:
                if line.opcode.upper() in self.instructions:
                    upper_opcode = line.opcode.upper()
                    opcode = self.instructions[upper_opcode]
                    inst = "{:06b}_".format(opcode)
                    args_stripped = [str(line.arg1).replace("$", "").upper(), str(line.arg2).replace("$", "").upper(),
                                     str(line.arg3).replace("$", "").upper()]
                    # print(args_stripped)
                    opcode_cat = opcode >> 3
                    # Special instruction
                    if opcode_cat == 0b011:
                        if upper_opcode == "LD":
                            inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[2]],
                                                                   self.regs[args_stripped[0]],
                                                                   twos_comp(int(line.arg2), 16))
                        elif upper_opcode == "ST":
                            inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[0]],
                                                                   self.regs[args_stripped[2]],
                                                                   twos_comp(int(line.arg2), 16))
                        elif upper_opcode == "JMP":
                            inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[1]],
                                                                   self.regs[args_stripped[0]], 0)
                        elif upper_opcode in ["BEQ", "BNE"]:
                            inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[2]],
                                                                   self.regs[args_stripped[0]],
                                                                   twos_comp((line.inum + 1 - labels[line.arg2]), 16))
                        elif upper_opcode == "LDR":
                            inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[1]], 0,
                                                                   twos_comp((line.inum + 1 - labels[line.arg2]), 16))
                        elif upper_opcode == "DISP":
                            inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[0]], 0, 0)
                        elif upper_opcode == "DISPC":
                            inst += "{:05b}_{:05b}_{:016b}".format(0, 0, int(line.arg1))
                        else:
                            print("Error: this shouldn't happen. Opcode='{}'".format(upper_opcode))
                    # Check if constant math operation
                    elif opcode_cat == 0b110:
                        args_stripped = args_stripped[-1]
                        for arg in args_stripped:
                            if arg not in self.regs:
                                print(
                                    "Line {}: {} is not a register (const) opcode={}".format(line.line_num, arg,
                                                                                             opcode))
                                sys.exit()
                        if not line.arg3.isdigit():
                            print("Line {}: Literal {} is not a number".format(line.line_num, line.arg3))
                            sys.exit()
                        inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[2]],
                                                               self.regs[args_stripped[0]],
                                                               twos_comp(int(line.arg2), 16))
                    # Check if math operation
                    elif opcode_cat == 0b100:
                        for arg in args_stripped:
                            if arg not in self.regs:
                                print("Line {}: {} is not a register (math)".format(line.line_num, arg))
                                sys.exit()
                        inst += "{:05b}_{:05b}_{:05b}_{:011}".format(self.regs[args_stripped[2]],
                                                                     self.regs[args_stripped[0]],
                                                                     self.regs[args_stripped[1]], 0)
                    fout.write('{} //{}\n'.format(inst, line.line))

                else:
                    print("Line %d: invalid instruction %s".format(line.line_num, line.opcode))
        print("Done!")


if __name__ == '__main__':
    bc = BCompiler()
    bc.compile()
