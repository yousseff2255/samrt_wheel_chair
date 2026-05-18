#ifndef MAX30102_PRIVATE_H
#define MAX30102_PRIVATE_H

#include <stdint.h>

#define MAX30102_I2C_ADDRESS        0x57u
#define MAX30102_EXPECTED_PART_ID   0x15u  /* 0x15 is for MAX30102! */
/* Register Map */
#define MAX30102_REG_INT_STATUS1    0x00u
#define MAX30102_REG_FIFO_WR_PTR   0x04u
#define MAX30102_REG_FIFO_RD_PTR   0x06u
#define MAX30102_REG_FIFO_DATA      0x07u
#define MAX30102_REG_FIFO_CONFIG    0x08u
#define MAX30102_REG_MODE_CONFIG    0x09u
#define MAX30102_REG_SPO2_CONFIG    0x0Au
#define MAX30102_REG_LED1_PA        0x0Cu
#define MAX30102_REG_LED2_PA        0x0Du

/* DC filter: high alpha = slow DC tracking = good AC extraction */
#define DC_FILTER_ALPHA             0.95f

/* Mean-filter window for noise smoothing */
#define MA_WINDOW                   4u

/* Beat detection */
#define BEAT_THRESHOLD              50        /* tune after testing */
#define BEAT_MIN_DELTA_MS           333u       /* 180 BPM ceiling    */
#define BEAT_MAX_DELTA_MS           1500u      /* 40  BPM floor      */

/* BPM rolling average depth */
#define BPM_BUFFER_SIZE             4u

/* DC filter: alpha = 19/20 = 0.95, stored scaled by 1024 */
typedef struct {
    int32_t prevDC_scaled;   /* prevDC * 1024 — no float needed */
} DC_Filter_t;

typedef struct {
    int16_t  buf[MA_WINDOW];
    uint8_t  idx;
} MA_Filter_t;

#endif