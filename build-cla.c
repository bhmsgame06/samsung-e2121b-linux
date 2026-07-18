#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#define CONTAINER_SIZE		0x40000

int main(int argc, char *argv[]) {

	/* checking args */

	if(argc <= 3) {
		fprintf(stderr, "Usage: %s <bootloader> <dtb> <kernel>\n", argv[0]);
		return 1;
	}

	/* opening files */

	/* bootloader */
	FILE *spl_fd = fopen(argv[1], "rb");
	if(!spl_fd) {
		perror("fopen");
		goto err;
	}
	fseek(spl_fd, 0, SEEK_END);
	uint32_t spl_size = ftell(spl_fd);
	fseek(spl_fd, 0, SEEK_SET);

	/* device tree */
	FILE *dtb_fd = fopen(argv[2], "rb");
	if(!dtb_fd) {
		perror("fopen");
		goto err;
	}
	fseek(dtb_fd, 0, SEEK_END);
	uint32_t dtb_size = ftell(dtb_fd);
	fseek(dtb_fd, 0, SEEK_SET);

	/* kernel image */
	FILE *kernel_fd = fopen(argv[3], "rb");
	if(!kernel_fd) {
		perror("fopen");
		goto err;
	}
	fseek(kernel_fd, 0, SEEK_END);
	uint32_t kernel_size = ftell(kernel_fd);
	fseek(kernel_fd, 0, SEEK_SET);

	/* writing .cla to stdout */

	uint8_t *cont_buf = malloc(CONTAINER_SIZE);
	if(!cont_buf) {
		perror("malloc");
		goto err;
	}

	/* bootloader */
	memset(cont_buf, 0xff, CONTAINER_SIZE);
	fread(cont_buf, 1, spl_size, spl_fd);
	fclose(spl_fd);
	fwrite(cont_buf, 1, CONTAINER_SIZE, stdout);

	/* device tree */
	memset(cont_buf, 0xff, CONTAINER_SIZE);
	fread(cont_buf, 1, dtb_size, dtb_fd);
	fclose(dtb_fd);
	fwrite(cont_buf, 1, CONTAINER_SIZE, stdout);

	/* kernel image */
	uint8_t c;
	for(uint32_t i = 0; i < kernel_size; i += CONTAINER_SIZE) {
		uint32_t n = fread(cont_buf, 1, CONTAINER_SIZE, kernel_fd);
		fwrite(cont_buf, 1, n, stdout);
	}
	fclose(kernel_fd);

	free(cont_buf);

	return 0;

err:
	if(cont_buf) free(cont_buf);
	if(spl_fd) fclose(spl_fd);
	if(dtb_fd) fclose(dtb_fd);
	if(kernel_fd) fclose(kernel_fd);

	return 1;
}
