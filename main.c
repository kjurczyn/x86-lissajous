#include <stdio.h>
#include <allegro5/allegro5.h>
#include <allegro5/allegro_font.h>
#include <allegro5/keyboard.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_ttf.h>
#include <allegro5/allegro_primitives.h>
#include <allegro5/allegro_memfile.h>

//RCX, RDX, R8, R9, stack
extern void lissajous_draw(void* pixel_array, const unsigned int pitch, const unsigned int half_length, const double w1, const double w2, const double d); 


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

    ALLEGRO_DISPLAY* disp = al_create_display(700, 700);
    if(!disp)
    {
        printf("couldn't initialize display\n");
        return 1;
    }

    if(!al_init_image_addon())
    {
        printf("couldn't initialize image addon\n");
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
    bool lissajeou_changed = true;
    
    double w1 = 1;
    double w2 = 4;

    al_set_new_bitmap_flags(ALLEGRO_MEMORY_BITMAP);
    al_set_new_bitmap_format(ALLEGRO_PIXEL_FORMAT_RGBA_8888);

    ALLEGRO_BITMAP* lissajeous_bitmap = al_create_bitmap(100, 100);
    al_set_target_bitmap(lissajeous_bitmap);
    al_clear_to_color(white);
    al_set_target_bitmap(al_get_backbuffer(disp));

    ALLEGRO_BITMAP* bitmap_scaled = al_create_bitmap(700, 700);
    
    ALLEGRO_LOCKED_REGION* pixel_array_area = NULL;

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
                switch (event.keyboard.keycode)
                {
                case ALLEGRO_KEY_ESCAPE:
                    done = true;
                    break;
                case ALLEGRO_KEY_UP:
                    w1 = w1 + 0.1;
                    lissajeou_changed = true;
                    break;
                case ALLEGRO_KEY_DOWN:
                    w1 = w1 - 0.1;
                    lissajeou_changed = true;
                    break;
                 case ALLEGRO_KEY_LEFT:
                    w2 = (w2-0.1 > 0) ? w2 - 0.1 : w2 ;
                    lissajeou_changed = true;
                    break;
                 case ALLEGRO_KEY_RIGHT:
                    w2 = w2 + 0.1;
                    lissajeou_changed = true;
                    break;
                default:
                    done = false;
                    break;
                }
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
            
            if (lissajeou_changed)
            {   
                pixel_array_area = al_lock_bitmap(lissajeous_bitmap, ALLEGRO_PIXEL_FORMAT_RGBA_8888, ALLEGRO_LOCK_READWRITE);
                lissajous_draw(pixel_array_area->data, pixel_array_area->pitch,  50, w1, w2, 0);
                al_unlock_bitmap(lissajeous_bitmap);
                lissajeou_changed = false;
            }

            al_draw_scaled_bitmap(lissajeous_bitmap, 0,0, 100, 100, 0, 0, 700, 700, 0);
            //al_draw_rectangle(165,67,865,767, red, 2);
            al_flip_display();
            redraw = false;
        }
    }

    al_destroy_display(disp);
    al_destroy_timer(timer);
    al_destroy_event_queue(queue);
    al_destroy_bitmap(lissajeous_bitmap);
    al_destroy_bitmap(bitmap_scaled);
   
    // al_destroy_path(path);

    return 0;
}