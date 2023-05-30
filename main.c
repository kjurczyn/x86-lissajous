#include <stdio.h>
#include <allegro5/allegro5.h>
#include <allegro5/allegro_font.h>
#include <allegro5/keyboard.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_primitives.h>

#define HEADER_SIZE 54 //using 14 byte file header + 40 byte BITMAPINFOHEADER
#define COLOR_PALETTE_SIZE 8 //2 colors
#define BPP 1 //only black and white needed
//RCX, RDX, R8, R9, stack
extern void lissajous_draw(const float a, const float b, const float x, const float y, const float w1, const float w2, const float d); 
//x and y are the center of the image, a and b are multiplied by the width and height of the image

ALLEGRO_COLOR white;
ALLEGRO_COLOR black;
ALLEGRO_COLOR red;

void custom_draw_spline(float* array_pointer)
{
    al_draw_spline(array_pointer, white, 5);
};

void custom_printf(int i)
{
    printf("Worked%d", i);
};

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

    white = al_map_rgb(255, 255, 255);
    black = al_map_rgb(0, 0, 0);
    red = al_map_rgb(255, 0, 0);

    al_register_event_source(queue, al_get_keyboard_event_source());
    al_register_event_source(queue, al_get_display_event_source(disp));
    al_register_event_source(queue, al_get_timer_event_source(timer));

    bool done = false;
    bool redraw = true;
    bool elf = false;
    bool draw_curve = false;

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
                else if (event.keyboard.keycode == ALLEGRO_KEY_E) { elf = !elf;}
                else if (event.keyboard.keycode == ALLEGRO_KEY_F) {draw_curve = !draw_curve;}
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
            
            // if (lissajeou_changed)
            // {   
            //     al_destroy_bitmap(lissajeou_shape);
            //     buffer = al_open_memfile(buffer_ptr, size, "r");
            //     lissajeou_shape = al_load_bitmap_f(buffer, ".bmp");
            //     al_fclose(buffer);
            // }            
            // al_draw_bitmap(lissajeou_shape, 158, 59, 0);

            al_draw_rectangle(158,60,865,767, red, 2);
            if (draw_curve) {lissajous_draw(100, 100, 511, 413, 7, 6, 0.5);}

            if (elf) {  al_draw_bitmap(edomae_elf, 100, 100, 0);    }
            // al_draw_line()
            al_flip_display();
            redraw = false;
        }
    }

    al_destroy_font(font);
    al_destroy_display(disp);
    al_destroy_timer(timer);
    al_destroy_event_queue(queue);
    al_destroy_bitmap(edomae_elf);
    // al_destroy_bitmap(lissajeou_shape);
   
    // al_destroy_path(path);

    return 0;
}