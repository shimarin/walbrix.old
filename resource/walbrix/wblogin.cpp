#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <security/pam_appl.h>
#include <security/pam_misc.h>

int main(int argc, char **argv)
{
  printf("Walbrixへようこそ! 【Enterキーで操作を開始】");
  while (getchar() != '\n');

  pam_handle_t *pamh;
  struct pam_conv conv = { misc_conv, NULL };
  pam_start("login", "root", &conv, &pamh);
  int rc;
  do {
    rc = pam_authenticate(pamh, 0);
  } while (rc != PAM_SUCCESS && rc != PAM_ABORT && rc != PAM_MAXTRIES);
  pam_end(pamh, rc);

  if (rc == PAM_ABORT || rc == PAM_MAXTRIES) exit(-1);

  pid_t pid = fork();
  int rst;
  switch (pid) {
    case 0:
      if (execl("/bin/wbmenu.sh", "/bin/wbmenu.sh", NULL) < 0) _exit(-1);
      break; // never reach here
    case -1:
      return -1;
    default:
      waitpid(pid, &rst, 0);
      break;
  }
  rst = WIFEXITED(rst)? WEXITSTATUS(rst) : -1;
  if (rst == 9) {
    execl("/bin/login", "/bin/login", "-p", "-f", "root", NULL);
  }
  //else
  return 0;
}
