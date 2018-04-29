import sys
import os
import re
import binascii
import codecs
import ctypes
import math


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
        val = val + (1 << bits)  # compute negative value
    return val  # return positive value as is


def is_int(val):
    try:
        int(val)
        return True
    except ValueError:
        return False


def is_float(val):
    try:
        float(val)
        return True
    except ValueError:
        return False


def str_to_int_arr(val):
    # print("Parsing '{}'".format(val))
    if val is None:
        return [0]
    parsed = codecs.getdecoder("unicode_escape")(val[1:-1])[0]
    code_list = [int(ord(c)) for c in parsed]
    code_list.append(0)
    return code_list


class BCompiler:
    def __init__(self):
        self.re_line = re.compile(
            r'^([^:]+:\s+)?(?P<instr>[A-Za-z]{2,6})\s+(?P<argc>[^,]+)?(,\s*(?P<arga>[^,]+))?(,(?P<argb>[^,;]+))?')
        self.re_label = re.compile(r'^(?P<label>[^:]+):')
        self.re_char = re.compile(r"'(?P<escape>\\)?(?P<char>[^'\\])'")
        self.re_disp_str = re.compile(r'^([^:]+:\s+)?(?P<instr>[A-Za-z]{2,6})\s+(?P<arg>\"(?:[^\"]|\\\")*\")')
        self.instructions = {
            "LD": 0b011000,
            "ST": 0b011001,
            "DISP": 0b011110,
            "JMP": 0b011011,
            "BEQ": 0b011100,
            "BNE": 0b011101,
            "DISPC": 0b011010,
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
            "SRAC": 0b111110,
            "TRAP": 0b000001,
            "DB": None
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

        self.types = {
            "INT": 1,
            "INTEGER": 1,
            "FLOAT": 2,
            "DOUBLE": 2,
            "STR": 3,
            "STRING": 3
        }

    def char_to_int(self, char):
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
        filepath = None
        if len(sys.argv) < 2:
            filepath = "program.asm"
        else:
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
                        print("Line {}: Found label {}".format(linecount, m.group('label')))
                    m = self.re_line.match(line)
                    if m is not None:
                        arga = self.char_to_int(m.group('arga'))
                        argb = self.char_to_int(m.group('argb'))
                        argc = self.char_to_int(m.group('argc'))
                        # Have to count the size of a dispc instruction since it has data after it
                        if m.group('instr').upper() == "DISPC":
                            mstr = self.re_disp_str.match(line)
                            if is_int(argc):
                                sourcelines.append(
                                    SourceLine(linecount, icount, line, m.group('instr'), int(argc), None, None))
                                icount += 2
                                print("Line {}: Found int {}".format(linecount, int(argc)))
                            elif is_float(argc):
                                sourcelines.append(
                                    SourceLine(linecount, icount, line, m.group('instr'), float(argc), None, None))
                                icount += 2
                                print("Line {}: Found float {}".format(linecount, float(argc)))
                            elif mstr is not None:
                                str_data = str_to_int_arr(mstr.group('arg'))
                                sourcelines.append(
                                    SourceLine(linecount, icount, line, m.group('instr'), str_data, None, None))
                                icount += 1 + int(len(str_data) / 4)
                                print("Line {}: Found string {}".format(linecount, mstr.group('arg')))
                            else:
                                print(
                                "Line {}: DB is not a string, int, or float, it is a {}".format(linecount, type(argc)))
                        elif m.group('instr').upper() == "DB":
                            mstr = self.re_disp_str.match(line)
                            if is_int(argc):
                                sourcelines.append(
                                    SourceLine(linecount, icount, line, m.group('instr'), int(argc), None, None))
                                icount += 1
                                print("Line {}: Found int {}".format(linecount, int(argc)))
                            elif is_float(argc):
                                sourcelines.append(
                                    SourceLine(linecount, icount, line, m.group('instr'), float(argc), None, None))
                                icount += 1
                                print("Line {}: Found float {}".format(linecount, float(argc)))
                            elif mstr is not None:
                                str_data = str_to_int_arr(mstr.group('arg'))
                                sourcelines.append(
                                    SourceLine(linecount, icount, line, m.group('instr'), str_data, None, None))
                                icount += math.ceil(len(str_data) / 4.0)
                                print("Line {}: Found string {}".format(linecount, mstr.group('arg')))
                            else:
                                print(
                                    "Line {}: DB is not a string, int, or float, it is a {}".format(linecount,
                                                                                                    type(argc)))
                        else:
                            sourcelines.append(SourceLine(linecount, icount, line, m.group('instr'), argc, arga, argb))
                            print(
                            "Line {}: Found instruction {}({},{},{})".format(linecount, m.group('instr'), argc, arga,
                                                                             argb))
                            icount += 1
                    elif "TRAP" == line.upper():
                        sourcelines.append(SourceLine(linecount, icount, line, "trap", None, None, None))
                        print("Line {}: Found instruction trap".format(linecount))
                        icount += 1
            # Pass 2
            for line in sourcelines:
                if line.opcode.upper() in self.instructions:
                    upper_opcode = line.opcode.upper()
                    inst = ""
                    if upper_opcode == "DB":
                        if type(line.arg1) is int:
                            print("Line {}: processing db {}".format(line.line_num, line.arg1))
                            inst += "{:032b}".format(twos_comp(line.arg1, 32))
                        elif type(line.arg1) is float:
                            inst += "{:032b}".format(bin(ctypes.c_uint.from_buffer(ctypes.c_float(line.arg1)).value))
                        elif type(line.arg1) is list:
                            num_bits = 0
                            for i in range(0, len(line.arg1)):
                                if (i + 1) % 4 == 0:
                                    inst += "{:07b}".format(line.arg1[i])
                                    num_bits += 7
                                    # Pad string ending
                                    if num_bits < 32:
                                        inst += "_" + ("0" * (32 - num_bits))
                                    if i == 3:
                                        inst += " //START: " + line.line

                                    # Don't print new line if this is the last character
                                    if i != len(line.arg1):
                                        inst += "\n"
                                    num_bits = 0
                                else:
                                    inst += "{:07b}_".format(line.arg1[i])
                                    num_bits += 7
                            # Pad the last bits
                            if 0 < num_bits < 32:
                                inst += ("0" * (32 - num_bits))
                        else:
                            print("Line {}: Invalid db {}".format(line.line_num, type(line.arg1)))
                    else:
                        opcode = self.instructions[upper_opcode]
                        inst += "{:06b}_".format(opcode)
                        args_stripped = [str(line.arg1).replace("$", "").upper(),
                                         str(line.arg2).replace("$", "").upper(),
                                         str(line.arg3).replace("$", "").upper()]
                        # print(args_stripped)
                        opcode_cat = opcode >> 3
                        # Special instruction
                        if upper_opcode == "TRAP":
                            inst += "00000_00000_0000000000000000"
                        elif opcode_cat == 0b011:
                            if upper_opcode == "DISP":
                                if args_stripped[1] in args_stripped[1]:
                                    if args_stripped[1] in ["STR", "STRING"]:
                                        inst += "{:05b}_{:05b}_{:016b}".format(self.types[args_stripped[1]], 0,
                                                                               labels[line.arg1] - line.inum - 2)
                                    else:
                                        inst += "{:05b}_{:05b}_{:016b}".format(self.types[args_stripped[1]],
                                                                               self.regs[args_stripped[0]], 0)
                                else:
                                    print(
                                    "Error: this shouldn't happen. DISP type is a {}, not an int, float, or str".format(
                                        type(line.arg2)))
                            elif upper_opcode == "LD":
                                if args_stripped[2] in self.regs:
                                    if args_stripped[0] in self.regs:
                                        inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[2]],
                                                                               self.regs[args_stripped[0]],
                                                                               twos_comp(int(line.arg2), 16))
                                    else:
                                        print("Line {}: {} is not a register".format(line.line_num, args_stripped[0]))
                                else:
                                    print("Line {}: {} is not a register".format(line.line_num, args_stripped[2]))
                            elif upper_opcode == "ST":
                                if args_stripped[2] in self.regs:
                                    if args_stripped[0] in self.regs:
                                        inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[0]],
                                                                               self.regs[args_stripped[2]],
                                                                               twos_comp(int(line.arg2), 16))
                                    else:
                                        print("Line {}: {} is not a register".format(line.line_num, args_stripped[0]))
                                else:
                                    print("Line {}: {} is not a register".format(line.line_num, args_stripped[2]))
                            elif upper_opcode == "JMP":
                                if args_stripped[1] in self.regs:
                                    if args_stripped[0] in self.regs:
                                        inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[1]],
                                                                               self.regs[args_stripped[0]], 0)
                                    else:
                                        print("Line {}: {} is not a register".format(line.line_num, args_stripped[0]))
                                else:
                                    print("Line {}: {} is not a register".format(line.line_num, args_stripped[1]))
                            elif upper_opcode in ["BEQ", "BNE"]:
                                if args_stripped[2] in self.regs:
                                    if args_stripped[0] in self.regs:
                                        inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[2]],
                                                                               self.regs[args_stripped[0]],
                                                                               twos_comp(labels[line.arg2] - line.inum - 2, 16))
                                    else:
                                        print("Line {}: {} is not a register".format(line.line_num, args_stripped[0]))
                                else:
                                    print("Line {}: {} is not a register".format(line.line_num, args_stripped[2]))
                            elif upper_opcode == "LDR":
                                inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[1]], 0,
                                                                       twos_comp(labels[line.arg1] - line.inum - 2, 16))
                            elif upper_opcode == "DISPC":
                                if type(line.arg1) is int:
                                    inst += "{:05b}_{:05b}_{:016b}\n{:031b}".format(1, 0, 0, twos_comp(line.arg1, 32))
                                elif type(line.arg1) is float:
                                    inst += "{:05b}_{:05b}_{:016b}\n{:031b}".format(2, 0, 0, bin(
                                        ctypes.c_uint.from_buffer(ctypes.c_float(line.arg1)).value))
                                elif type(line.arg1) is list:
                                    inst += "{:02b}_".format(3)
                                    num_bits = 0
                                    for i in range(0, 3):
                                        if len(line.arg1) > i == 2:
                                            inst += "{:07b}_000 //START: {}\n".format(line.arg1[i], line.line)
                                        elif len(line.arg1) > i:
                                            inst += "{:07b}_".format(line.arg1[i])
                                        else:
                                            inst += "{:07b}".format(0)
                                    if len(line.arg1) > 3:
                                        for i in range(3, len(line.arg1)):
                                            if (i - 2) % 4 == 0:
                                                inst += "{:07b}".format(line.arg1[i])
                                                num_bits += 7
                                                # Pad string ending
                                                if num_bits < 32:
                                                    inst += "_" + ("0" * (32 - num_bits))

                                                # Don't print new line if this is the last character
                                                if i != len(line.arg1):
                                                    inst += "\n"
                                                num_bits = 0
                                            else:
                                                # print("charcode={}".format(line.arg1[i]))
                                                inst += "{:07b}_".format(line.arg1[i])
                                                num_bits += 7
                                    # Pad the last bits
                                    if 0 < num_bits < 32:
                                        inst += "_" + ("0" * (32 - num_bits))
                                else:
                                    print("Error: this shouldn't happen. DISPC arg is a {}".format(type(line.arg1)))
                            else:
                                print("Error: this shouldn't happen. Opcode='{}'".format(upper_opcode))
                        # Check if constant math operation
                        elif opcode_cat in [0b110, 0b111]:
                            if args_stripped[0] in self.regs:
                                if args_stripped[2] in self.regs:
                                    if line.arg2.isdigit():
                                        inst += "{:05b}_{:05b}_{:016b}".format(self.regs[args_stripped[2]],
                                                                               self.regs[args_stripped[0]],
                                                                               twos_comp(int(line.arg2), 16))
                                    else:
                                        print("Line {}: Literal {} is not a number".format(line.line_num, line.arg3))
                                else:
                                    print("Line {}: {} is not a register (const) opcode={}".format(line.line_num,
                                                                                                   args_stripped[2],
                                                                                                   opcode))
                            else:
                                print("Line {}: {} is not a register (const) opcode={}".format(line.line_num,
                                                                                               args_stripped[0],
                                                                                               opcode))

                        # Check if math operation
                        elif opcode_cat in [0b100, 0b101]:
                            error = False
                            for arg in args_stripped:
                                if arg not in self.regs:
                                    print("Line {}: {} is not a register (math)".format(line.line_num, arg))
                                    error = True
                            if not error:
                                inst += "{:05b}_{:05b}_{:05b}_{:011}".format(self.regs[args_stripped[2]],
                                                                             self.regs[args_stripped[0]],
                                                                             self.regs[args_stripped[1]], 0)
                    if inst[-1] == '\n':
                        inst = inst[:-1]
                    if '\n' in inst:
                        fout.write('{} //END: {}\n'.format(inst, line.line))
                    else:
                        fout.write('{} //{} line: {}\n'.format(inst, line.line, line.inum))

                else:
                    print("Line %d: invalid instruction %s".format(line.line_num, line.opcode))
        print("Done!")


if __name__ == '__main__':
    bc = BCompiler()
    bc.compile()
