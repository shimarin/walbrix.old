#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <pwd.h>

#define USER "apache"
#define PHP "php"
#define SCRIPT "/var/www/localhost/htdocs/occ"
#define SERVER_NAME "localhost"

int main(int argc, char* argv[])
{
  struct passwd* pw;
  char** new_argv;
  int i;

  pw = getpwnam(USER);
  if (!pw) {
    fprintf(stderr, "User %s does not exist\n", USER);
    return 1;
  }
  setuid(pw->pw_uid);
  setgid(pw->pw_gid);
  setenv("SERVER_NAME", SERVER_NAME, 0);
  new_argv = malloc(sizeof(char*) * (argc + 2));
  if (!new_argv) {
    fprintf(stderr, "This error can't happen.\n");
    return 2;
  }

  new_argv[0] = PHP;
  new_argv[1] = SCRIPT;

  for (i = 1; i < argc; i++) {
    new_argv[i + 1] = argv[i];
  }

  new_argv[argc + 1] = NULL;
  
  if (execvp(PHP, new_argv) < 0) {
    perror(PHP);
    return 3;
  }
  return 0; // not coming here
}
