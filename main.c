#include <stdio.h>
#include <allegro5/allegro5.h>
#include <allegro5/keyboard.h>
#include <allegro5/allegro_image.h>
#include <allegro5/allegro_font.h>

#define IMAGE_SIZE 100

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

    ALLEGRO_DISPLAY* disp = al_create_display(702, 728);
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

    ALLEGRO_FONT* font = al_create_builtin_font();

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

    ALLEGRO_BITMAP* lissajeous_bitmap = al_create_bitmap(IMAGE_SIZE, IMAGE_SIZE);
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
                    w2 = w2 - 0.1 ;
                    lissajeou_changed = true;
                    break;
                 case ALLEGRO_KEY_RIGHT:
                    w2 = w2 + 0.1;
                    lissajeou_changed = true;
                    break;
                 case ALLEGRO_KEY_W:
                    w1 = w1 + 1;
                    lissajeou_changed = true;
                    break;
                case ALLEGRO_KEY_S:
                    w1 = w1 - 1;
                    lissajeou_changed = true;
                    break;
                 case ALLEGRO_KEY_A:
                    w2 = w2 - 1 ;
                    lissajeou_changed = true;
                    break;
                 case ALLEGRO_KEY_D:
                    w2 = w2 + 1;
                    lissajeou_changed = true;
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
            if (lissajeou_changed)
            {   
                pixel_array_area = al_lock_bitmap(lissajeous_bitmap, ALLEGRO_PIXEL_FORMAT_RGBA_8888, ALLEGRO_LOCK_READWRITE);
                memset(pixel_array_area->data, 0x0, pixel_array_area->pitch*IMAGE_SIZE);
                lissajous_draw(pixel_array_area->data, pixel_array_area->pitch,  IMAGE_SIZE/2, w1, w2, 0);
                al_unlock_bitmap(lissajeous_bitmap);
                lissajeou_changed = false;
            }
            al_clear_to_color(black);
            al_draw_textf(font, white, 0, 710, 0, "W1: %f", w1);
            al_draw_textf(font, white, 0, 720, 0, "W2: %f", w2);
            al_draw_scaled_bitmap(lissajeous_bitmap, 0,0, IMAGE_SIZE, IMAGE_SIZE, 0, 0, 700, 700, 0);
            al_flip_display();
            redraw = false;
        }
    }

    al_destroy_display(disp);
    al_destroy_timer(timer);
    al_destroy_event_queue(queue);
    al_destroy_bitmap(lissajeous_bitmap);

    // al_destroy_path(path);

    return 0;
}