#include "processor.h"
#include <ctime>
using namespace std;

Processor::Processor(Memory* m): m(m) {
	pc=0;
	sp=MEMSIZE - 1;
	a0=0;
	a1=0;
	for (int i=0; i<7; i++)
		r[i]=0;
	for (int i =0; i<128;i++) statistiques[i] = 0;
}

Processor::~Processor()
{}

void Processor::affichage()
{
	int nb_total = 0, i;
	for (i=0; i<128; i++) nb_total += statistiques[i];
	for (i=0; i<128; i++) {
		switch(i) {
				case 0b0000: // add2
					printf("add2: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0x1: // add2i
					printf("add2i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0x2: // sub2
					printf("sub2: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0x3: // sub2i
					printf("sub2i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0x4: // cmp
					printf("cmp: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0x5: // cmpi
					printf("cmpi: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0x6: // let
					printf("let: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0x7: // leti
					printf("leti: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0x8: // shift
					printf("shift: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b10010: // readze
					printf("readze: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b10011: // readse
					printf("readse: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0xa: // jump
					printf("jump: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0xb: // jumpif
					printf("jumpif: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b110000: // or2
					printf("or2: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b110001: // or2i
					printf("or2i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b110010: // and2
					printf("and2: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b110011: // and2i
					printf("and2i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b110100: // write
					printf("write: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b110101: // call
					printf("call: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b110110: // setctr
					printf("setctr: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b110111: // getctr
					printf("getctr: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1110000: // push
					printf("push: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1110001: // return
					printf("return: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1110010: // add3
					printf("add3: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1110011: // add3i
					printf("add3i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1110100: // sub3
					printf("sub3: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1110101: // sub3i
					printf("sub3i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1110110: // and3
					printf("and3: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1110111: // and3i
				printf("and3i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1111000: // or3
					printf("or3: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1111001: // or3i
					printf("or3i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1111010: // xor3
					printf("xor3: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1111011: // xor3i
					printf("xor3i: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1111100: // asr3
					printf("asr3: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1111101: //random
					printf("random: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;

				case 0b1111110: //sleep
					printf("sleep: %f%%\n", (100*(double)statistiques[i]/nb_total));
					break;
		}
	}
}

void Processor::von_Neuman_step(bool debug, bool stats) {
	// numbers read from the binary code
	int opcode=0;
	int regnum1=0;
	int regnum2=0;
	int regnum3=0;
	int shiftval=0;
	int condcode=0;
	int counter=0;
	int size=0;
	uword offset;
	uint64_t constop=0;
	int dir=0;
	// each instruction will use some of the following variables:
	// all unsigned, to be cast to signed when required.
	uword uop1;
	uword uop2;
	uword ur=0;
	doubleword fullr;
	bool manage_flags=false; // used to factor out the flag management code
	int instr_pc = pc; // for the debug output

	// read 4 bits.
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);
	read_bit_from_pc(opcode);

	switch(opcode) {

		case 0b0000: // add2 reg reg
		{
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			uop1 = r[regnum1];
			uop2 = r[regnum2];
			fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
			ur = uop1 + uop2;
			r[regnum1] = ur;
			manage_flags = true;
			int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
			int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
			int signres = (ur >> (WORDSIZE-1)) & 1;
			vflag = ((sign1 == sign2) and (signres != sign1));
			//Pour l'addition, il y a overflow seulement si les deux termes sont de même signe et le resultat est de signe oppose
			statistiques[0]++;
			break;
		}

		case 0x1: // add2i
		{
			read_reg_from_pc(regnum1);
			read_const_from_pc(constop);
			uop1 = r[regnum1];
			uop2 = constop;
			fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
			ur = uop1 + uop2;
			r[regnum1] = ur;
			manage_flags=true;
			int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
			int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
			int signres = (ur >> (WORDSIZE-1)) & 1;
			vflag = ((sign1 == sign2) and (signres != sign1));
			statistiques[1]++;
			break;
		}

		case 0x2: // sub2
		{
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			uop1 = r[regnum1];
			uop2 = r[regnum2];
			fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
			ur = uop1 - uop2;
			r[regnum1] = ur;
			manage_flags=true;
			int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
			int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
			int signres = (ur >> (WORDSIZE-1)) & 1;
			vflag = ((sign1 != sign2) and (signres != sign1));
			// Pour la soustraction, il y a overflow seulement si les deux termes sont de signes opposés et le résultat est du signe du premier terme
			statistiques[2]++;
			break;
		}

		case 0x3: // sub2i
		{
			read_reg_from_pc(regnum1);
			read_const_from_pc(constop);
			uop1 = r[regnum1];
			uop2 = constop;
			fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
			ur = uop1 - uop2;
			r[regnum1] = ur;
			manage_flags=true;
			int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
			int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
			int signres = (ur >> (WORDSIZE-1)) & 1;
			vflag = ((sign1 != sign2) and (signres != sign1));
			statistiques[3]++;
			break;
		}

		case 0x4: // cmp
		{
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			uop1 = r[regnum1];
			uop2 = r[regnum2];
			fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
			ur = uop1 - uop2;
			manage_flags=true;
			int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
			int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
			int signres = (ur >> (WORDSIZE-1)) & 1;
			vflag = ((sign1 != sign2) and (signres != sign1));
			// c'est une soustraction...
			statistiques[4]++;
			break;
		}

		case 0x5: // cmpi
		{
			read_reg_from_pc(regnum1);
			read_signed_const_from_pc(constop);
			uop1 = r[regnum1];
			uop2 = constop;
			fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
			ur = uop1 - uop2;
			manage_flags=true;
			int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
			int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
			int signres = (ur >> (WORDSIZE-1)) & 1;
			vflag = ((sign1 == sign2) and (signres != sign1));
			statistiques[5]++;
			break;
		}

		case 0x6: // let
			read_reg_from_pc(regnum1);
			read_reg_from_pc(regnum2);
			uop1 = r[regnum1];
			uop2 = r[regnum2];
			fullr = (doubleword) uop2; // for flags
			ur = uop2; // ?
			r[regnum1] = uop2;
			manage_flags=false;
			statistiques[6]++;
			break;

		case 0x7: // leti
			read_reg_from_pc(regnum1);
			read_signed_const_from_pc(constop);
			uop1 = r[regnum1];
			uop2 = constop;
			fullr = (doubleword) uop2; // for flags
			ur = uop2; // ?
			r[regnum1] = uop2;
			manage_flags=false;
			statistiques[7]++;
			break;

		case 0x8: // shift
			read_bit_from_pc(dir);
			read_reg_from_pc(regnum1);
			read_shiftval_from_pc(shiftval);
			uop1 = r[regnum1];
			if(dir==1){ // right shift
				ur = uop1 >> shiftval;
				cflag = ( ((uop1 >> (shiftval-1))&1) == 1);
			}
			else{
				cflag = ( ((uop1 << (shiftval-1)) & (1L<<(WORDSIZE-1))) != 0);
				ur = uop1 << shiftval;
			}
			r[regnum1] = ur;
			zflag = (ur==0);
			// no change to nflag
			manage_flags=false;
			statistiques[8]++;
			break;

		case 0x9:
			//read one more bit
			read_bit_from_pc(opcode);
			switch(opcode) {

			case 0b10010: // readze
			{
				read_counter_from_pc(counter);
				read_size_from_pc(size);
				read_reg_from_pc(regnum1);
				int var = 0;
				int i;
				for (i=0; i<size; i++)
				{
					var = (var << 1) + m->read_bit(counter);
					switch (counter) {
						case PC:
							pc++;
							break;
						case SP:
							sp++;
							break;
						case A0:
							a0++;
							break;
						case A1:
							a1++;
							break;
					}
				}
				r[regnum1] = var;
				manage_flags=false;
				statistiques[0b10010]++;
				break;
			}

			case 0b10011: // readse
			{
				read_counter_from_pc(counter);
				read_size_from_pc(size);
				read_reg_from_pc(regnum1);
				int var = 0;
				int i;
				for (i=0; i<size; i++)
				{
					var = (var << 1) + m->read_bit(counter);
					switch (counter) {
						case PC:
							pc++;
							break;
						case SP:
							sp++;
							break;
						case A0:
							a0++;
							break;
						case A1:
							a1++;
							break;
					}
				}
				// sign extension
				int sign=(var >> (size-1)) & 1;
				for (int i=size; i<WORDSIZE; i++)
					var += sign << i;

				r[regnum1] = var;
				manage_flags=false;
				statistiques[0b10011]++;
				break;
			}
			}
			break;

		case 0xa: // jump
		{
			read_addr_from_pc(offset);
			if (offset == (uword) -13) {
				if (stats) affichage();
				exit(EXIT_SUCCESS);
			}
			pc += offset;
			m -> set_counter(PC, (uword)pc);
			manage_flags=false;
			statistiques[0xa]++;
			break;
		}

		case 0xb: // jumpif
			read_cond_from_pc(condcode);
			read_addr_from_pc(offset);
			if (cond_true(condcode)) {
				pc += offset;
				m -> set_counter(PC, (uword)pc);
			}
			manage_flags=false;
			statistiques[0xb]++;
			break;

		case 0xc:
		case 0xd:
			//read two more bits
			read_bit_from_pc(opcode);
			read_bit_from_pc(opcode);
			switch(opcode) {

			case 0b110000: // or2
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				uop1 = r[regnum1];
				uop2 = r[regnum2];
				fullr = ((doubleword) uop1) | ((doubleword) uop2); // for flags
				ur = uop1 | uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b110000]++;
				break;

			case 0b110001: // or2i
				read_reg_from_pc(regnum1);
				read_const_from_pc(constop);
				uop1 = r[regnum1];
				uop2 = constop;
				fullr = ((doubleword) uop1) | ((doubleword) uop2); // for flags
				ur = uop1 | uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b110001]++;
				break;

			case 0b110010: // and2
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				uop1 = r[regnum1];
				uop2 = r[regnum2];
				fullr = ((doubleword) uop1) & ((doubleword) uop2); // for flags
				ur = uop1 & uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b110010]++;
				break;

			case 0b110011: // and2i
				read_reg_from_pc(regnum1);
				read_const_from_pc(constop);
				uop1 = r[regnum1];
				uop2 = constop;
				fullr = ((doubleword) uop1) & ((doubleword) uop2); // for flags
				ur = uop1 & uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b110011]++;
				break;

			case 0b110100: // write
			  {
				read_counter_from_pc(counter);
				read_size_from_pc(size);
				read_reg_from_pc(regnum1);
				int var = r[regnum1]; //l'entier dont on doit ecrire les size derniers bits dans la memoire a ctr
				int bit;
				for (int i = (size-1); i>=0; i--) {
					bit = (var >> i) & 1;
					m->write_bit(counter,bit);
					switch (counter) {
						case PC:
							pc++;
							break;
						case SP:
							sp++;
							break;
						case A0:
							a0++;
							break;
						case A1:
							a1++;
							break;
					}
				}
				manage_flags = false;
				statistiques[0b110100]++;
				break;
			}

			case 0b110101: // call
				uword cible;
				read_addr_from_pc(cible);
				r[7] = pc;
				pc = cible;
				m->set_counter(PC,cible);
				manage_flags = false;
				statistiques[0b110101]++;
				break;

			case 0b110110: // setctr
				read_counter_from_pc(counter);
				read_reg_from_pc(regnum1);
				m->set_counter(counter,r[regnum1]);
				// mise a jour du compteur correspondant du processeur:
				switch (counter) {
					case 0b00:
						pc = m->counter[PC];
						break;
					case 0b01:
						sp = m->counter[SP];
						break;
					case 0b10:
						a0 = m->counter[A0];
						break;
					case 0b11:
						a1 = m->counter[A1];
					}
				manage_flags = false;
				statistiques[0b110110]++;
				break;

			case 0b110111: // getctr
				read_counter_from_pc(counter);
				read_reg_from_pc(regnum1);
				r[regnum1] = m->counter[counter];
				manage_flags = false;
				statistiques[0b110111]++;
				break;
			}
			break; // Do not forget this break!

		case 0xe:
		case 0xf:
			//read 3 more bits
			read_bit_from_pc(opcode);
			read_bit_from_pc(opcode);
			read_bit_from_pc(opcode);
			switch(opcode) {

			case 0b1110000: // push ATTENTION: on a push reg et non push size reg!!!
				{
				read_reg_from_pc(regnum1);
				sp -= WORDSIZE;
				m->set_counter(SP,sp);
				int var = r[regnum1];
				int bit;
				for (int i = WORDSIZE-1; i>=0; i--) {
					bit = (var >> i) & 1;
					m->write_bit(SP,bit);
				}
				m->set_counter(SP,sp);
				manage_flags = false;
				statistiques[0b1110000]++;
				break;
			  }

			case 0b1110001: // return
				pc = r[7];
				m->set_counter(PC,r[7]);
				manage_flags = false;
				statistiques[0b1110001]++;
				break;

			case 0b1110010: // add3
			{
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_reg_from_pc(regnum3);
				uop1 = r[regnum2];
				uop2 = r[regnum3];
				fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
				ur = uop1 + uop2;
				r[regnum1] = ur;
				manage_flags=true;
				int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
				int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
				int signres = (ur >> (WORDSIZE-1)) & 1;
				vflag = ((sign1 == sign2) and (signres != sign1));
				statistiques[0b1110010]++;
				break;
			}

			case 0b1110011: // add3i
			{
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_const_from_pc(constop);
				uop1 = r[regnum2];
				uop2 = constop;
				fullr = ((doubleword) uop1) + ((doubleword) uop2); // for flags
				ur = uop1 + uop2;
				r[regnum1] = ur;
				manage_flags=true;
				int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
				int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
				int signres = (ur >> (WORDSIZE-1)) & 1;
				vflag = ((sign1 == sign2) and (signres != sign1));
				statistiques[0b1110011]++;
				break;
			}

			case 0b1110100: // sub3
			{
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_reg_from_pc(regnum3);
				uop1 = r[regnum2];
				uop2 = r[regnum3];
				fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
				ur = uop1 - uop2;
				r[regnum1] = ur;
				manage_flags=true;
				int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
				int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
				int signres = (ur >> (WORDSIZE-1)) & 1;
				vflag = ((sign1 != sign2) and (signres != sign1));
				statistiques[0b1110100]++;
				break;
			}

			case 0b1110101: // sub3i
			{
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_const_from_pc(constop);
				uop1 = r[regnum2];
				uop2 = r[constop];
				fullr = ((doubleword) uop1) - ((doubleword) uop2); // for flags
				ur = uop1 - uop2;
				r[regnum1] = ur;
				manage_flags=true;
				int sign1 = (uop1 >> (WORDSIZE-1)) & 1;
				int sign2 = (uop2 >> (WORDSIZE-1)) & 1;
				int signres = (ur >> (WORDSIZE-1)) & 1;
				vflag = ((sign1 != sign2) and (signres != sign1));
				statistiques[0b1110101]++;
				break;
			}

			case 0b1110110: // and3
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_reg_from_pc(regnum3);
				uop1 = r[regnum2];
				uop2 = r[regnum3];
				fullr = ((doubleword) uop1) & ((doubleword) uop2); // for flags
				ur = uop1 & uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b1110110]++;
				break;

			case 0b1110111: // and3i
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_const_from_pc(constop);
				uop1 = r[regnum2];
				uop2 = constop;
				fullr = ((doubleword) uop1) & ((doubleword) uop2); // for flags
				ur = uop1 & uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b1110111]++;
				break;

			case 0b1111000: // or3
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_reg_from_pc(regnum3);
				uop1 = r[regnum2];
				uop2 = r[regnum3];
				fullr = ((doubleword) uop1) | ((doubleword) uop2); // for flags
				ur = uop1 | uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b1111000]++;
				break;

			case 0b1111001: // or3i
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_const_from_pc(constop);
				uop1 = r[regnum2];
				uop2 = r[constop];
				fullr = ((doubleword) uop1) | ((doubleword) uop2); // for flags
				ur = uop1 | uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b1111001]++;
				break;

			case 0b1111010: // xor3
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_reg_from_pc(regnum3);
				uop1 = r[regnum2];
				uop2 = r[regnum3];
				fullr = ((doubleword) uop1) ^ ((doubleword) uop2); // for flags
				ur = uop1 ^ uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b1111010]++;
				break;

			case 0b1111011: // xor3i
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_const_from_pc(constop);
				uop1 = r[regnum2];
				uop2 = r[constop];
				fullr = ((doubleword) uop1) ^ ((doubleword) uop2); // for flags
				ur = uop1 ^ uop2;
				r[regnum1] = ur;
				manage_flags=true;
				statistiques[0b1111011]++;
				break;

			case 0b1111100: // asr3
			{
				read_reg_from_pc(regnum1);
				read_reg_from_pc(regnum2);
				read_shiftval_from_pc(shiftval);
				uop1 = r[regnum2];
				int sign=(uop1 >> (WORDSIZE-1)) & 1;
				ur = uop1 >> shiftval;
				//sign-extension
				for (int i=0; i<shiftval; i++)
					ur += sign << (WORDSIZE - 1 - i);
				r[regnum1] = ur;
				zflag = (ur == 0);
				cflag = ( ((uop1 >> (shiftval-1))&1) == 1); //ici que faut-il faire pour le cflag?
				manage_flags = false;
				statistiques[0b1111100]++;
				break;
			}

			case 0b1111101: //random
				read_reg_from_pc(regnum1);
				read_const_from_pc(constop);
				ur = rand()%constop;
				r[regnum1] = ur;
				zflag = (ur == 0);
				manage_flags = false;
				statistiques[0b1111101]++;
				break;

			case 0b1111110: //sleep
				read_const_from_pc(constop);
				struct timespec tim, tim2;
   				tim.tv_sec = 0;
   				tim.tv_nsec = 1000000L*constop;
				nanosleep(&tim,&tim2);
				statistiques[0b1111110]++;
				break;

			}
			break;
		}


	// flag management
	if(manage_flags) {
		zflag = (ur==0);
		cflag = (fullr > ((doubleword) 1)<<WORDSIZE);
		nflag = (0 > (sword) ur);
	}

	if (debug) {
		cout << "after instr: " << opcode
				 << " at pc=" << hex << setw(8) << setfill('0') << instr_pc
				 << " (newpc=" << hex << setw(8) << setfill('0') << pc
				 << " mpc=" << hex << setw(8) << setfill('0') << m->counter[0]
				 << " msp=" << hex << setw(8) << setfill('0') << m->counter[1]
				 << " ma0=" << hex << setw(8) << setfill('0') << m->counter[2]
				 << " ma0=" << hex << setw(8) << setfill('0') << m->counter[3] << ") ";
			//				 << " newpc=" << hex << setw(9) << setfill('0') << pc;
		cout << " zcnv = " << (zflag?1:0) << (cflag?1:0) << (nflag?1:0) << (vflag?1:0);
		for (int i=0; i<8; i++)
			cout << " r"<< dec << i << "=" << hex << setw(8) << setfill('0') << r[i];
		cout << endl;
	}
}


// form now on, helper methods. Read and understand...

void Processor::read_bit_from_pc(int& var) {
	var = (var<<1) + m->read_bit(PC); // the read_bit updates the memory's PC
	pc++;                             // this updates the processor's PC (memory pc must be the same as processor's pc)
}

void Processor::read_reg_from_pc(int& var) {
	var=0;
	read_bit_from_pc(var);
	read_bit_from_pc(var);
	read_bit_from_pc(var);
}


//unsigned
void Processor::read_const_from_pc(uint64_t& var) {
	var=0;
	int header=0;
	int size;
	read_bit_from_pc(header);
	if(header==0)
		size=1;
	else  {
		read_bit_from_pc(header);
		if(header==2)
			size=8;
		else {
			read_bit_from_pc(header);
			if(header==6)
				size=32;
			else
				size=64;
		}
	}
	// Now we know the size and we can read all the bits of the constant.
	for(int i=0; i<size; i++) {
		var = (var<<1) + m->read_bit(PC);
		pc++;
	}
}

//signed
void Processor::read_signed_const_from_pc(uint64_t& var) {
	var=0;
	int header=0;
	int size;
	read_bit_from_pc(header);
	if(header==0)
		size=1;
	else  {
		read_bit_from_pc(header);
		if(header==2)
			size=8;
		else {
			read_bit_from_pc(header);
			if(header==6)
				size=32;
			else
				size=64;
		}
	}
	// Now we know the size and we can read all the bits of the constant.
	for(int i=0; i<size; i++) {
		var = (var<<1) + m->read_bit(PC);
		pc++;
	}
	//sign-extension
	if (size > 1) {
		int sign=(var >> (size-1)) & 1;
		for (int i=size; i<WORDSIZE; i++)
			var += sign << i;
	}
}


// Beware, this one is sign-extended
void Processor::read_addr_from_pc(uword& var) {
	var=0;
	int header=0;
	int size;
	read_bit_from_pc(header);
	if(header==0)
		size=8;
	else  {
		read_bit_from_pc(header);
		if(header==2)
			size=16;
		else {
			read_bit_from_pc(header);
			if(header==6)
				size=32;
			else
				size=64;
		}
	}
	// Now we know the size and we can read all the bits of the constant.
	for(int i=0; i<size; i++) {
		var = (var<<1) + m->read_bit(PC);
		pc++;
	}

	// cerr << "before signext " << var << endl;  ??????
	// sign extension
	int sign=(var >> (size-1)) & 1;
	for (int i=size; i<WORDSIZE; i++)
		var += sign << i;
	// cerr << "after signext " << var << " " << (int)var << endl; ?????
}




void Processor::read_shiftval_from_pc(int& var) {
	// begin sabote
	var=0;
	int header=0;
	read_bit_from_pc(header);
	if(header==0) {
		for(int i=0; i<6; i++) {
			var = (var<<1) + m->read_bit(PC);
			pc++;
		}
	}
	else var = 1;
	//end sabote
}

void Processor::read_cond_from_pc(int& var) {
	var =0;
	read_bit_from_pc(var);
	read_bit_from_pc(var);
	read_bit_from_pc(var);
}


bool Processor::cond_true(int cond) {
	switch(cond) {
	case 0 :
		return (zflag);
		break;
	case 1 :
		return (! zflag);
		break;
		//begin sabote
	case 0b010:
		return ((!zflag) && ((nflag && vflag)||((!nflag) && (!vflag))));
		break;
	case 0b011:
		return ((nflag && (!vflag)) || ((!nflag) && vflag));
		break;
	case 0b100:
		return ((!zflag) && (!cflag));
		break;
	case 0b101:
		return (!cflag);
		break;
	case 0b110:
		return (cflag);
		break;
	case 0b111:
		return(vflag);
		break;
		// end sabote
	}
	throw "Unexpected condition code";
}


void Processor::read_counter_from_pc(int& var) {
	// begin sabote
	read_bit_from_pc(var);
	read_bit_from_pc(var);
	// end sabote
}


void Processor::read_size_from_pc(int& size) {
	// begin sabote
	size=0;
	read_bit_from_pc(size);
	if(size==0) {
		read_bit_from_pc(size);
	}
	else  {
		read_bit_from_pc(size);
		read_bit_from_pc(size);
	}
	switch(size)
	{
		case 0b00:
			size = 1;
			break;
		case 0b01:
			size = 4;
			break;
		case 0b100:
			size = 8;
			break;
		case 0b101:
			size = 16;
			break;
		case 0b110:
			size = 32;
			break;
		case 0b111:
			size = 64;
			break;
	}
}
