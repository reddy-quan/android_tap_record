#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <fcntl.h>
#include <sys/ioctl.h>
//#include <linux/input.h> // this does not compile
#include <errno.h>

/*qj:
1. PLAYBACK_FILE defines the playback record file path, you can put it under external storage root dir
2. put this file under android source tree system\core\toolbox
3. modify system\core\toolbox\Android.mk add: playback to the TOOLS list
4. recompile toolbox, and push it to /system/bin, chmod to 755(you must use busybox to chmod, 
	cause at that point, no chmod command available, chmod belongs to toolbox too)
5. usage: toolbox playback /dev/input/event0
*/

// from <linux/input.h>

struct input_event {
	struct timeval time;
	__u16 type;
	__u16 code;
	__s32 value;
};

#define EVIOCGVERSION		_IOR('E', 0x01, int)			/* get driver version */
#define EVIOCGID		_IOR('E', 0x02, struct input_id)	/* get device ID */
#define EVIOCGKEYCODE		_IOR('E', 0x04, int[2])			/* get keycode */
#define EVIOCSKEYCODE		_IOW('E', 0x04, int[2])			/* set keycode */

#define EVIOCGNAME(len)		_IOC(_IOC_READ, 'E', 0x06, len)		/* get device name */
#define EVIOCGPHYS(len)		_IOC(_IOC_READ, 'E', 0x07, len)		/* get physical location */
#define EVIOCGUNIQ(len)		_IOC(_IOC_READ, 'E', 0x08, len)		/* get unique identifier */

#define EVIOCGKEY(len)		_IOC(_IOC_READ, 'E', 0x18, len)		/* get global keystate */
#define EVIOCGLED(len)		_IOC(_IOC_READ, 'E', 0x19, len)		/* get all LEDs */
#define EVIOCGSND(len)		_IOC(_IOC_READ, 'E', 0x1a, len)		/* get all sounds status */
#define EVIOCGSW(len)		_IOC(_IOC_READ, 'E', 0x1b, len)		/* get all switch states */

#define EVIOCGBIT(ev,len)	_IOC(_IOC_READ, 'E', 0x20 + ev, len)	/* get event bits */
#define EVIOCGABS(abs)		_IOR('E', 0x40 + abs, struct input_absinfo)		/* get abs value/limits */
#define EVIOCSABS(abs)		_IOW('E', 0xc0 + abs, struct input_absinfo)		/* set abs value/limits */

#define EVIOCSFF		_IOC(_IOC_WRITE, 'E', 0x80, sizeof(struct ff_effect))	/* send a force effect to a force feedback device */
#define EVIOCRMFF		_IOW('E', 0x81, int)			/* Erase a force effect */
#define EVIOCGEFFECTS		_IOR('E', 0x84, int)			/* Report number of effects playable at the same time */

#define EVIOCGRAB		_IOW('E', 0x90, int)			/* Grab/Release device */

// end <linux/input.h>

//qj add start
#define PLAYBACK_FILE "/mnt/sdcard/m.txt"

int playback_main(int argc, char *argv[])
{
    int i;
    int fd;
    int ret;
    int version;
    struct input_event event;

	//qj add start
	FILE* file; //playback fd
	char* chp;
	file = fopen(PLAYBACK_FILE, "r");
	if (! file) {
	    fprintf(stderr, "could not open %s, %s\n", PLAYBACK_FILE, strerror(errno));
	    return 1;
	}
	//qj end

    if(argc != 2) {
        fprintf(stderr, "use: %s device type code value\n", argv[0]);
        return 1;
    }

    fd = open(argv[1], O_RDWR);
    if(fd < 0) {
        fprintf(stderr, "could not open %s, %s\n", argv[optind], strerror(errno));
        return 1;
    }
    if (ioctl(fd, EVIOCGVERSION, &version)) {
        fprintf(stderr, "could not get driver version for %s, %s\n", argv[optind], strerror(errno));
        return 1;
    }
	//qj 
	char cmd[64] = {0};
	int last_second, last_millsecond, type, code, value;

	//qj: Process the first line, and record last_second and last_millsecond
	if ((chp = fgets(cmd, sizeof(cmd), file)) != NULL) {
		//qj: fprintf(stderr, "cmd is: %s\n", cmd);
		if (5!=sscanf(cmd, "[%d.%d] %x %x %x", &last_second, &last_millsecond, &type, &code, &value)) {
		    fprintf(stderr, "error scanf, %s\n", strerror(errno));
		    return 1;	
		}
		//qj: write to device node
		{
			memset(&event, 0, sizeof(event));
			event.type = type;//atoi(type);
			event.code = code;//atoi(code);
			event.value = value;//atoi(value);
			ret = write(fd, &event, sizeof(event));
			if(ret < sizeof(event)) {
				fprintf(stderr, "write event failed, %s\n", strerror(errno));
				return -1;
			}
		}
	} else {
	    fprintf(stderr, "error read from %s, %s\n", PLAYBACK_FILE, strerror(errno));
	    return 1;
	}
	memset(cmd, 0, sizeof(cmd));
	//qj: now process the follow-up lines
	int new_second, new_millsecond;
	int sleep_second, sleep_millsecond, sleep_total;
	while ((chp = fgets(cmd, sizeof(cmd), file)) != NULL) {
		if (5!=sscanf(cmd, "[%d.%d] %x %x %x", &new_second, &new_millsecond, &type, &code, &value)) {
		    fprintf(stderr, "error scanf in while\n");
		    return 1;	
		}
		sleep_second = new_second - last_second;
		sleep_millsecond = new_millsecond - last_millsecond;
		sleep_total = sleep_second*1000000+sleep_millsecond;
		if (sleep_total > 0)
			usleep(sleep_total);

		memset(&event, 0, sizeof(event));
		event.type = type;//atoi(type);
		event.code = code;//atoi(code);
		event.value = value;//atoi(value);
		ret = write(fd, &event, sizeof(event));
		if(ret < sizeof(event)) {
		    fprintf(stderr, "write event failed, %s\n", strerror(errno));
		    return -1;
		}
		memset(cmd, 0, sizeof(cmd));
		last_second = new_second;
		last_millsecond = new_millsecond;
	}
	
    return 0;
}
