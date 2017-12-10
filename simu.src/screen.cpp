#include "screen.h"


int renverserPixels(int pixel)
{
	int rv_px = 0;
	int i;
	for (i=0; i < 16; i++)
		rv_px = (rv_px << 1) + ((pixel >> i)&1);
	return rv_px;
}


void simulate_screen(Memory* m,  bool* refresh) {
	/*initialise sdl and create the screen*/
	SDL_Init(SDL_INIT_VIDEO);
	SDL_Window *window = SDL_CreateWindow("Asm", SDL_WINDOWPOS_UNDEFINED, SDL_WINDOWPOS_UNDEFINED, WIDTH*4, HEIGHT*4, 0);
	SDL_Renderer *renderer = SDL_CreateRenderer(window, -1, 0);
	SDL_Texture *texture = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STATIC, WIDTH, HEIGHT);
	SDL_Event e;
	Uint32 last_time = SDL_GetTicks();
	SDL_RenderSetScale(renderer, 2, 2);
	bool escape = false;
	bool is_up = false, is_down = false, is_right = false, is_left = false;
	/*temp buffer*/
	uint32_t tempscreen[WIDTH * HEIGHT];

	while (!escape) {

		/*deal with events*/
		while (SDL_PollEvent(&e) != 0) {
			if (e.type == SDL_QUIT) {
				escape = true;
			}
			else if (e.type == SDL_KEYDOWN) {
				switch (e.key.keysym.sym)
				{
					case SDLK_ESCAPE:
						escape = true;
						break;
					case SDLK_UP:
						is_up = true; /* met à 1 le bit qui repère la touche arrow_up */
						break;
					case SDLK_DOWN:
						is_down = true;
						break;
					case SDLK_LEFT:
						is_left = true;
						break;
					case SDLK_RIGHT:
						is_right = true;
						break;
				}
			}
			else if (e.type == SDL_KEYUP) {
				switch (e.key.keysym.sym)
				{
					case SDLK_UP:// pour éviter que la commande soit exécutée plusieurs fois.
						is_up = false;
						break;
					case SDLK_DOWN:
						is_down = false;
						break;
					case SDLK_LEFT:
						is_left = false;
						break;
					case SDLK_RIGHT:
						is_right = false;
						break;
				}
			}

		}
		m->write_bit_addr(409600,(int) is_up);
    m->write_bit_addr(409601,(int) is_down);
    m->write_bit_addr(409602,(int) is_left);
    m->write_bit_addr(409603,(int) is_right);



		/* if we need to refresh the screen*/
		if (true) {
			/* convert the colors */
			// i is a counter of 16-bit words
			for (unsigned int i=0; i < HEIGHT*WIDTH; i++) {
				uint64_t mword = m->m[ (MEM_SCREEN_BEGIN >>6) + (i>>2)];
				uint16_t pixel = (mword >> ((i&3)<<4)) & 0xffff;
				pixel = renverserPixels(pixel);

				uint32_t blue = pixel & ((1<<5)-1);
				uint32_t green = (pixel>>5) & ((1<<5)-1);
				uint32_t red = (pixel>>10) ;
				tempscreen[i] = (red << (3+16)) + (green << (3+8)) + (blue << 3);  // error in the original code here : (red << (2+16)) instead of (red << (3+16))
			}
			/* update the screen */
			SDL_UpdateTexture(texture, NULL, tempscreen, WIDTH * sizeof(uint32_t));
			SDL_RenderClear(renderer);
			SDL_RenderCopy(renderer, texture, NULL, NULL);
			SDL_RenderPresent(renderer);
			/* wait */
			Uint32 current = SDL_GetTicks();
			if (current - last_time < (1000.f * 1.f/60.f)) {
				SDL_Delay((1000.f * 1.f / 60.f) - last_time + current);
			}
			//refresh = false;
			last_time = current;
		}
	}
	/* close the screen properly */
	//refr = false;
	SDL_DestroyTexture(texture);
	SDL_DestroyRenderer(renderer);
	SDL_DestroyWindow(window);
	SDL_Quit();
}
