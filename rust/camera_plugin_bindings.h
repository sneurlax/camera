#ifndef CAMERA_PLUGIN_BINDINGS_H
#define CAMERA_PLUGIN_BINDINGS_H

#include <stdarg.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>

bool initialize_camera(void);

bool capture_image(uint8_t *buffer, unsigned long *len);

const int8_t *get_last_error(void);

#endif /* CAMERA_PLUGIN_BINDINGS_H */
