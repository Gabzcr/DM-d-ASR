#!/usr/bin/env python

# This program assembles source assembly code into a bit string.
# The bit string includes spaces and newlines for readability,
# these should be ignored by the simulator when it reads the corresponding file.

import os
import sys
import re
import string
import argparse
from numpy import binary_repr

line=0 # global variable to make error reporting easier
current_address=0 # idem
labels={} # global because shared between the two passes
jumps = [] #contiendra pour chaque element [label, type du saut (jump, jumpif ou call), adresse_courante de la ligne du saut, taille de la constante addr, inconnus]
jump_number = 0 #pour savoir ou on en est dans les sauts quand on appelle asm_addr_signed sur un label
opcode = "" #just to make this global
iteration = 1 #just to make this global too

def error(e):
    raise BaseException("Error at line " + str(line) + " : " + e)

def taille(val):
    if val>=-128 and val<= 127:
        return 9
    elif val>=-32768 and val<= 32767:
        return 18
    elif val>=-(1<<31) and val<= (1<<31)-1:
        return 35
    else:
        return 67

def ajout(saut):
    if saut[1] == "jump":
        return 4
    elif saut[1] == "jumpif":
        return (4+3)
    else: #opcode = "call"
        return 6


# All the asm_xxxx functions are helper functions that parse an operand and convert it into its binary encoding.
# Many are still missing

def asm_reg(s):
    "converts the string s into its encoding"
    if s[0]!='r':
        error("invalid register: " + s)
    try:
        val = int(s[1:]) # this removes the "r".
    except Exception:
	    raise error("invalid address for a register: " + s[1:])
    if val<0 or val>7:
        error("invalid register: " + s)
    else:
        return binary_repr(val,3) + ' '  # thanks stack overflow. The 3 is the number of bits



def asm_addr_signed(s):
    global jump_number
    "converts the string s into its encoding"
    # Is it a label or a constant?
    if (s[0]>='0' and s[0]<='9') or s[0]=='-' or s[0]=='+':
        try:
            if (s[0]>='0' and s[0]<='9'):
                val=int(s,0) #specifying the second argument catches hexa
            elif s[0] == '+':
                val = int(s[1:])
            elif s[0] == '-':
                val = -int(s[1:])
        except Exception:
	        raise error("invalid signed addr constant: " + s)
        # The following is not very elegant but easy to trust
        if val>=-128 and val<= 127:
            return '0 ' + binary_repr(val, 8)
        elif val>=-32768 and val<= 32767:
            return '10 ' +  binary_repr(val, 16)
        elif val>=-(1<<31) and val<= (1<<31)-1:
            return '110 ' + binary_repr(val, 32)
        else:
            return '111 ' +  binary_repr(val, 64)
    else:
        if iteration == 1:
            jumps.append([s, opcode, current_address, None]) #None is for addr_size that is currently unknown
            return ""
        else: #iteration = 2
            #TODO for debug:
            #print("adresse de la ligne du jump: ", jumps[jump_number][2], "\nadresse de la ligne du label", labels[jumps[jump_number][0]])
            jump_size = abs(jumps[jump_number][2] - labels[jumps[jump_number][0]])
            saut_apres = (jumps[jump_number][2] > labels[jumps[jump_number][0]])
            if saut_apres: #le jump est apres le label, il faut donc sauter aussi l'instruction jump elle-meme!
                jump_size += ajout(jumps[jump_number])
            label_croises = jumps[jump_number][4]
            for jmp in label_croises:
                jump_size += jumps[jmp][3]
            jump_number += 1
            #print(jump_size)
            if saut_apres:
                return asm_addr_signed(str(-(jump_size + 1))) #+1 car le pc est incremente
            else:
                return asm_addr_signed(str(jump_size + 1))

def asm_const_unsigned(s):
    "converts the string s into its encoding"
    if (s[0]>='0' and s[0]<='9'): #la condition s[0:2] == '0x' etait inutile, dans ce cas s[0] = 0
        try:
            val = int(s,0)
        except Exception:
	        raise error("invalid unsigned const: " + s)
        # The following is not very elegant but easy to trust
        if val==0 or val==1:
            return '0 ' + str(val)
        elif val< 256:
            return '10 ' + binary_repr(val, 8)
        elif  val< (1<<32):
            return '110 ' + binary_repr(val, 32)
        else:
            return '111 ' +  binary_repr(val, 64)
    else:
        error("Expecting a constant, got " + s)



def asm_const_signed(s):
    "converts the string s into its encoding"
    if (s[0]>='0' and s[0]<='9') or s[0]=='-' or s[0]=='+': #begin sabote was here
        try:
            if (s[0]>='0' and s[0]<='9'):
                val=int(s,0)
            elif s[0] == '+':
                val = int(s[1:],0)
            elif s[0] == '-':
                val = -int(s[1:],0)
        except Exception:
	        raise error("invalid unsigned const: " + s)
        # The following is not very elegant but easy to trust
        if val==0 or val==1:
            return '0 ' + str(val)
        elif val>=-128 and val<= 127:
            return '10 ' + binary_repr(val, 8)
        elif val>=-(1<<31) and val<= (1<<31)-1:
            return '110 ' + binary_repr(val, 32)
        else:
            return '111 ' +  binary_repr(val, 64)
    else:
        error("Expecting a constant, got " + s) #end sabote was here



def asm_shiftval(s): #cette constante n'est pas signee puisque dir donne la direction du shift
    "converts the string s into its encoding"
    if (s[0]>='0' and s[0]<='9'): #begin sabote was here
        try:
            val = int(s,0)
        except Exception:
	        raise error("invalid unsigned const for shift: " + s)
        # The following is not very elegant but easy to trust
        if val==1:
            return '1'
        elif val< 64:
            return '0 ' + binary_repr(val, 6)
        else:
            error("shiftval must be inferior or equal to 63, it is: " + s)
    else:
        error("Expecting a constant, got " + s) #end sabote was here



def asm_condition(cond):
    """converts the string cond into its encoding in the condition code. """
    condlist = {"eq":"000", "z":"000",  "neq":"001",  "nz":"001",  "sgt":"010",  "slt":"011",  "gt":"100",  "ge":"101",  "nc":"101",  "lt":"110",  "c":"110",  "le":"111"}
    if cond in condlist:
        val = condlist[cond]
        return val + " "
    else:
        error("Invalid condition: " + cond)


def asm_counter(ctr):
    """converts the string ctr into its encoding. """
    codelist = {"pc":"00", "sp":"01",  "a0":"10",  "a1":"11",  "0":"00",  "1":"01",  "2":"10",  "3":"11"}
    if ctr in codelist:
        val = codelist[ctr]
        return val + " "
    else:
        error("Invalid counter: " + ctr) #ici c'etait ecrit cond au lieu de ctr?



def asm_size(s):
    """converts the string s into its encoding. """
    codelist = {"1":"00", "4":"01",  "8":"100",  "16":"101",  "32":"110",  "64":"111"}
    if s in codelist:
        val = codelist[s]
        return val + " "
    else:
        error("Invalid size: " + s) #ici c'etait ecrit size au lieu de s?


def asm_pass(s_file):
    global line
    global labels
    global current_address
    code =[] # array of strings, one entry per instruction
    print "\n PASS " + str(iteration)
    current_address = 0
    source = open(s_file)
    for source_line in source:
        instruction_encoding=""
        print "processing " + source_line[0:-1] # just to get rid of the final newline

        # if there is a comment, get rid of it
        index = source_line.find(';') #cette ligne a ete corrigee, str.find(";",source_line) ne marchait pas
        if index !=-1:
            source_line = source_line[:index]

        # split the non-comment part of the line into tokens (thanks Stack Overflow)
        tokens = re.findall('[\S]+', source_line) # \S means: any non-whitespace
        # print tokens # to debug

        # if there is a label, consume it
        if tokens:
            token=tokens[0]
            if token[-1] == ":": # last character
                label = token[0: -1] # all the characters except last one
                labels[label] = current_address
                tokens = tokens[1:]

        # now all that remains should be an instruction... or nothing
        if tokens:
            opcode = tokens[0]
            token_count = len(tokens)
            #code below was saboted (except add2, add2i and jump)
            if opcode == "add2" and token_count==3:
                instruction_encoding = "0000 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "add2i" and token_count==3:
                instruction_encoding = "0001 " + asm_reg(tokens[1]) + asm_const_unsigned(tokens[2])
            if opcode == "sub2" and token_count==3:
                instruction_encoding = "0010 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "sub2i" and token_count==3:
                instruction_encoding = "0011 " + asm_reg(tokens[1]) + asm_const_unsigned(tokens[2]) #constante non signee?
            if opcode == "cmp" and token_count==3:
                instruction_encoding = "0100 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "cmpi" and token_count==3:
                instruction_encoding = "0101 " + asm_reg(tokens[1]) + asm_const_signed(tokens[2]) #constante signee? Va-t-on avoir besoin de comparer les valeurs de registres avec des nombres negatifs? Souvent?
            if opcode == "let" and token_count==3:
                instruction_encoding = "0110 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "leti" and token_count==3:
                instruction_encoding = "0111 " + asm_reg(tokens[1]) + asm_const_signed(tokens[2]) #la je pense que c'est signee, on doit bien pouvoir mettre des valeurs negatives dans les registres
            if opcode == "shift" and token_count==4:
                if tokens[1] == "left":
                    instruction_encoding = "1000 " + "0 " + asm_reg(tokens[2]) + asm_shiftval(tokens[3])
                elif tokens[1] == "right":
                    instruction_encoding = "1000 " + "1 " + asm_reg(tokens[2]) + asm_shiftval(tokens[3])
            if opcode == "readze" and token_count==4:
                instruction_encoding = "10010 " + asm_counter(tokens[1]) + asm_size(tokens[2]) + asm_reg(tokens[3])
            if opcode == "readse" and token_count==4:
                instruction_encoding = "10011 " + asm_counter(tokens[1]) + asm_size(tokens[2]) + asm_reg(tokens[3])
            #Here, a lot of constructive copypaste, for instance
            if opcode == "jump" and token_count==2:
                instruction_encoding = "1010 " + asm_addr_signed(tokens[1])
            if opcode == "jumpif" and token_count==3:
                instruction_encoding = "1011 " + asm_condition(tokens[1]) + asm_addr_signed(tokens[2])
            if opcode == "or2" and token_count==3:
                instruction_encoding = "110000 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "or2i" and token_count==3:
                instruction_encoding = "110001 " + asm_reg(tokens[1]) + asm_const_unsigned(tokens[2]) #non signee?
            if opcode == "and2" and token_count==3:
                instruction_encoding = "110010 " + asm_reg(tokens[1]) + asm_reg(tokens[2])
            if opcode == "and2i" and token_count==3:
                instruction_encoding = "110011 " + asm_reg(tokens[1]) + asm_const_unsigned(tokens[2]) #non signee?
            if opcode == "write" and token_count==4:
                instruction_encoding = "110100 " + asm_counter(tokens[1]) + asm_size(tokens[2]) + asm_reg(tokens[3])
            if opcode == "call" and token_count==2:
                instruction_encoding = "110101 " + asm_addr_signed(tokens[1])
            if opcode == "setctr" and token_count==3:
                instruction_encoding = "110110 " + asm_counter(tokens[1]) + asm_reg(tokens[2])
            if opcode == "getctr" and token_count==3:
                instruction_encoding = "110111 " + asm_counter(tokens[1]) + asm_reg(tokens[2])
            if opcode == "push" and token_count==3: #ATTENTION : on a push size reg et non juste push reg.
                instruction_encoding = "1110000 " + asm_size(tokens[1]) +  asm_reg(tokens[2])
            if opcode == "return" and token_count==1:
                instruction_encoding = "1110001 "
            if opcode == "add3" and token_count==4:
                instruction_encoding = "1110010 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_reg(tokens[3])
            if opcode == "add3i" and token_count==4:
                instruction_encoding = "1110011 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_const_unsigned(tokens[3])
            if opcode == "sub3" and token_count==4:
                instruction_encoding = "1110100 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_reg(tokens[3])
            if opcode == "sub3i" and token_count==4:
                instruction_encoding = "1110101 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_const_unsigned(tokens[3])
            if opcode == "and3" and token_count==4:
                instruction_encoding = "1110110 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_reg(tokens[3])
            if opcode == "and3i" and token_count==4:
                instruction_encoding = "1110111 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_const_unsigned(tokens[3])
            if opcode == "or3" and token_count==4:
                instruction_encoding = "1111000 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_reg(tokens[3])
            if opcode == "or3i" and token_count==4:
                instruction_encoding = "1111001 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_const_unsigned(tokens[3])
            if opcode == "xor3" and token_count==4:
                instruction_encoding = "1111010 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_reg(tokens[3])
            if opcode == "xor3i" and token_count==4:
                instruction_encoding = "1111011 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_const_unsigned(tokens[3])
            if opcode == "asr3" and token_count==4:
                instruction_encoding = "1111100 " + asm_reg(tokens[1]) + asm_reg(tokens[2]) + asm_shiftval(tokens[3])
            # If the line wasn't assembled:
            if instruction_encoding=="":
                # debug stuff
                print tokens
                print "opcode : " + opcode
                print "token count : " + str(token_count)
                error("don't know what to do with: " + source_line)
            else:
                # get rid of spaces. Thanks Stack Overflow
                compact_encoding = ''.join(instruction_encoding.split())
                instr_size = len(compact_encoding)
                # Debug output
                print "... @" + str(current_address) + " " + binary_repr(current_address,16) + "  :  " + compact_encoding
                print  "                          "+  instruction_encoding+ "   size=" + str(instr_size)
                current_address += instr_size


        line += 1
        code.append(instruction_encoding)
    source.close()
    return code




#/* main */
if __name__ == '__main__':

    argparser = argparse.ArgumentParser(description='This is the assembler for the ASR2017 processor @ ENS-Lyon')
    argparser.add_argument('filename', help='name of the source file.  "python asm.py toto.s" assembles toto.s into toto.obj')

    options=argparser.parse_args()
    filename = options.filename
    basefilename, extension = os.path.splitext(filename)
    obj_file = basefilename+".obj"
    code = asm_pass(filename) # first pass essentially builds the labels

    #jumps = [[label, opcode, adresse de la ligne du saut, addr_size]], ou addr_size est a determiner pour chaque saut
    for i in range(len(jumps)): #on determine les sauts (de taille inconnue) entre chaque saut et son label
        saut = jumps[i]
        inf = min(saut[2], labels[saut[0]])
        sup = max(saut[2], labels[saut[0]])
        inconnus = []
        for j in range(len(jumps)):
            saut2 = jumps[j]
            if saut2 != saut and sup <= saut2[2] and saut2[2] <= inf:
                inconnus.append(j)
            elif saut2 == saut and saut[2] > labels[saut[0]]:
                inconnus.append(j)
        jumps[i].append(inconnus)

    #initialisation des addr_size des jumps avec les meilleurs cas (on les elargira ensuite):
    for i in range(len(jumps)):
        saut = jumps[i]
        jump_size = abs(saut[2] - labels[saut[0]])
        saut[3] = taille(jump_size)
    ok = False
    while not(ok): #on elargit les tailles des constantes sur lesquelles on a un conflit
        ok = True
        for i in range(len(jumps)):
            jump_size = abs(jumps[i][2] - labels[jumps[i][0]])
            if jumps[i][2] > labels[jumps[i][0]]: #le jump est apres le label, il faut donc sauter aussi l'instruction jump elle-meme!
                jump_size += ajout(jumps[i])
            label_croises = jumps[i][4]
            for jmp in label_croises:
                jump_size += jumps[jmp][3]
            if taille(jump_size) > jumps[i][3]:
                jumps[i][3] = taille(jump_size)
                ok = False

    iteration = 2
    code = asm_pass(filename) # second pass is for good

    # statistics
    print "Average instruction size is " + str(1.0*current_address/len(code))

    outfile = open(obj_file, "w")
    for instr in code:
        outfile.write(instr)
        outfile.write("\n")


    outfile.close()
