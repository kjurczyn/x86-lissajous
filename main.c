#include <stdio.h>
#include <malloc.h>
#include <allegro5/allegro5.h>
#include <allegro5/allegro_font.h>
#include <allegro5/keyboard.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_memfile.h>
#include <math.h>

#define HEADER_SIZE 54 //using 14 byte file header + 40 byte BITMAPINFOHEADER
#define COLOR_PALETTE_SIZE 8 //2 colors
#define BPP 1 //only black and white needed
//RCX, RDX, R8, R9, stack
extern void lissajous_draw(unsigned char* pixel_array, const unsigned int width, const unsigned int height, const unsigned int a, const unsigned int b); 

unsigned char* makeBitmapBuffer(int width, int height, int* size)
{
    int pixel_array_size = (ceil((BPP*width)/32)*4)*height;
    *size = pixel_array_size+ HEADER_SIZE + COLOR_PALETTE_SIZE;

    unsigned char* bmp_start = malloc(*size);
    //preparing file header
    unsigned char* bmp_ptr = bmp_start;
    *bmp_ptr = 0x42; // B
    bmp_ptr++;
    *bmp_ptr = 0x4D; //M
    bmp_ptr = bmp_start + 2;
    *(int*)bmp_ptr = *size;
    bmp_ptr = bmp_start  + 6;
    *(int*)bmp_ptr = 0;
    bmp_ptr = bmp_start + 10;
    *(int*)bmp_ptr = HEADER_SIZE+COLOR_PALETTE_SIZE;
    //preparing bitmap info header
    bmp_ptr = bmp_start + 14;
    *(int*)bmp_ptr = 40;
    bmp_ptr = bmp_start + 18;
    *(int*)bmp_ptr = width;
    bmp_ptr = bmp_start + 22;
    *(int*)bmp_ptr = height;
    bmp_ptr = bmp_start + 26;
    *(short int*)bmp_ptr = 1;
    bmp_ptr = bmp_start + 28;
    *(short int*)bmp_ptr = BPP;
    bmp_ptr = bmp_start + 30;
    *(int*)bmp_ptr = 0;
    bmp_ptr = bmp_start + 34;
    *(int*)bmp_ptr = width*height;
    bmp_ptr = bmp_start + 38;
    *(int*)bmp_ptr = 1;
    bmp_ptr = bmp_start + 42;
    *(int*)bmp_ptr = 1;
    bmp_ptr = bmp_start + 46;
    *(int*)bmp_ptr = 2;
    bmp_ptr = bmp_start + 50;
    *(int*)bmp_ptr = 0;
    //preparing color table
    bmp_ptr = bmp_start + 54;
    *(unsigned char*)bmp_ptr = 255;
    bmp_ptr++;
    *(unsigned char*)bmp_ptr = 255;
    bmp_ptr++;
    *(unsigned char*)bmp_ptr = 255;
    bmp_ptr++;
    *(unsigned char*)bmp_ptr = 0;
    bmp_ptr = bmp_start + 58;
    *(unsigned char*)bmp_ptr = 0;
    bmp_ptr++;
    *(unsigned char*)bmp_ptr = 0;
    bmp_ptr++;
    *(unsigned char*)bmp_ptr = 0;
    bmp_ptr++;
    *(unsigned char*)bmp_ptr = 0;
    bmp_ptr++;
    
    //filling pixel array with 0
    bmp_ptr = bmp_start + HEADER_SIZE + COLOR_PALETTE_SIZE;
    memset(bmp_ptr, 0xFF, pixel_array_size);

    FILE* image_file = fopen("image.bmp", "wb");
    fwrite(bmp_start, 1, *size, image_file);
    fclose(image_file);
    return bmp_start;
}



int main()
{
    if(!al_init())
    {
        printf("couldn't initialize allegro\n");
        return 1;
    }

    if(!al_install_keyboard())
    {
        printf("couldn't initialize keyboard\n");
        return 1;
    }

    ALLEGRO_TIMER* timer = al_create_timer(1.0 / 30.0);
    if(!timer)
    {
        printf("couldn't initialize timer\n");
        return 1;
    }

    ALLEGRO_EVENT_QUEUE* queue = al_create_event_queue();
    if(!queue)
    {
        printf("couldn't initialize queue\n");
        return 1;
    }

    ALLEGRO_DISPLAY* disp = al_create_display(1024, 768);
    if(!disp)
    {
        printf("couldn't initialize display\n");
        return 1;
    }

    if(! al_init_font_addon() || !al_init_ttf_addon())
    {
        printf("couldn't initialize font addon\n");
        return 1;
    }

    ALLEGRO_FONT* font = al_load_ttf_font("data/Roboto-Regular.ttf", 20, 0);

    if(!font)
    {   
        printf("couldn't initialize font\n");
        return 1;
    }

    if(!al_init_image_addon())
    {
        printf("couldn't initialize image addon\n");
        return 1;
    }

    ALLEGRO_BITMAP* edomae_elf = al_load_bitmap("data/edomae_elf.png");
    if(!edomae_elf)
    {
        printf("couldn't load elf :(\n");
        return 1;
    }


    if(!al_init_primitives_addon())
    {
        printf("couldn't initialize primitives addon\n");
        return 1;
    }

    ALLEGRO_COLOR white = al_map_rgb(255, 255, 255);
    ALLEGRO_COLOR black = al_map_rgb(0, 0, 0);
    ALLEGRO_COLOR red = al_map_rgb(255, 0, 0);


    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_display_event_source(disp));
    al_register_event_source(queue, al_get_timer_event_source(timer));

    bool done = false;
    bool redraw = true;
    bool elf = false;
    bool lissajeou_changed = false;
    
    int a = 1;
    int b = 1;

    int size = 0;
    unsigned char* buffer_ptr = makeBitmapBuffer(707, 707, &size);
    
    ALLEGRO_FILE* buffer = al_open_memfile(buffer_ptr, size, "r");
    ALLEGRO_BITMAP* lissajeou_shape = al_load_bitmap_f(buffer, ".bmp");
    
    ALLEGRO_EVENT event;

    al_start_timer(timer);
    while(1)
    {
        al_wait_for_event(queue, &event);

        switch(event.type)
        {
            case ALLEGRO_EVENT_TIMER:
                // game logic goes here.
                redraw = true;
                break;

            case ALLEGRO_EVENT_KEY_DOWN:
                if (event.keyboard.keycode == ALLEGRO_KEY_ESCAPE) { done = true; }
                else if (event.keyboard.keycode == ALLEGRO_KEY_E) { elf = !elf; }
                else { done = false; }
                break;
            case ALLEGRO_EVENT_DISPLAY_CLOSE:
                done = true;
                break;
        }

        if(done)
            break;

        if(redraw && al_is_event_queue_empty(queue))
        {
            al_clear_to_color(black);
            
            al_draw_text(font, white, 0, 0, 0, "Press ESC to exit, E for elf");
            al_draw_text(font, white, 0, 20, 0, "Use UP/DOWN key to control wave frequency");
            
            if (lissajeou_changed)
            {   
                al_destroy_bitmap(lissajeou_shape);
                buffer = al_open_memfile(buffer_ptr, size, "r");
                lissajeou_shape = al_load_bitmap_f(buffer, ".bmp");
                al_fclose(buffer);
            }            
            al_draw_bitmap(lissajeou_shape, 158, 59, 0);

            al_draw_rectangle(158,60,865,767, red, 2);

            if (elf) {  al_draw_bitmap(edomae_elf, 100, 100, 0);    }
            al_flip_display();
            redraw = false;
        }
    }

    al_destroy_font(font);
    al_destroy_display(disp);
    al_destroy_timer(timer);
    al_destroy_event_queue(queue);
    al_destroy_bitmap(edomae_elf);
    al_destroy_bitmap(lissajeou_shape);
   
    // al_destroy_path(path);

    return 0;
}