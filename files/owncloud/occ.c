#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>
#include <pwd.h>

#define PHP "php"
#define SCRIPT "/var/www/localhost/htdocs/occ"
#define SERVER_NAME "localhost"

int main(int argc, char* argv[])
{
  struct stat st;
  char** new_argv;
  int i;

  if (getuid() != 0) {
    fprintf(stderr, "You must be a root user\n");
    return 1;
  }

  if (stat(SCRIPT, &st) < 0) {
    perror(SCRIPT);
    return 2;
  }
  
  if (setgid(st.st_gid) < 0) { // setgid must be done before setuid
    perror("setgid");
    return 3;
  }

  if (setuid(st.st_uid) < 0) {
    perror("setuid");
    return 4;
  }

  setenv("SERVER_NAME", SERVER_NAME, 0);

  new_argv = malloc(sizeof(char*) * (argc + 2));
  if (!new_argv) {
    fprintf(stderr, "This error can't happen.\n");
    return 5;
  }

  new_argv[0] = PHP;
  new_argv[1] = SCRIPT;

  for (i = 1; i < argc; i++) {
    new_argv[i + 1] = argv[i];
  }

  new_argv[argc + 1] = NULL;
  
  if (execvp(PHP, new_argv) < 0) {
    perror(PHP);
    return 6;
  }
  return 0; // not coming here
}
