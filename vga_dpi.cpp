// vga_dpi.cpp --- ---!!!

#include <stdio.h>

#include <SDL/SDL.h>

#include "svdpi.h"

#include "Vtop__Dpi.h"

static SDL_Surface *screen;
static int rows, cols;
static unsigned int row_sink, col_sink;

void vga_dpi_init(int h, int v)
{
	int flags;

	cols = h;
	rows = v;

	printf("Initialize display %dx%d\n", cols, rows);

	flags = SDL_INIT_VIDEO | SDL_INIT_NOPARACHUTE;

	if (SDL_Init(flags)) {
		printf("SDL initialization failed\n");
		return;
	}

	flags = SDL_HWSURFACE|SDL_ASYNCBLIT|SDL_HWACCEL;

	screen = SDL_SetVideoMode(cols, rows, 8, flags);

	if (!screen) {
		printf("Could not open SDL display\n");
		return;
	}

	SDL_WM_SetCaption("Image", "Image");

	row_sink = col_sink = 0;
}

static int eol;
static int eof;

void vga_dpi_display(int vsync, int hsync, int pixel)
{
	unsigned char *ps;
	int offset;

	if (screen == NULL) {
		printf("Error: display not initialized\n");
		return;
	}

	if (vsync == 0) {
		if (eof) {
			eof = 0;
			printf("Frame Complete\n");
		}
		row_sink = col_sink = 0;
		eol = 0;
		return;
	}

	if (hsync == 0) {
		if (eol == 1){
			row_sink++;
		}
		eol = 0;
		col_sink = 0;
		return;
	}

	ps = (unsigned char *)screen->pixels;
	offset = (row_sink * cols) + col_sink;

	if (ps[offset] != (unsigned char)pixel) {
		ps[offset] = (unsigned char)pixel;
		SDL_UpdateRect(screen, col_sink, row_sink, 1, 1);
	}

	col_sink++;
	eol = 1;
	eof = 1;
}
