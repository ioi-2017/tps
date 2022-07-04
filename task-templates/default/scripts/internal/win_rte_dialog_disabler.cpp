/**
 * This file links with the C++ solutions in windows
 *   in order to disable showing the runtime error dialog box.
 * This dialog box appears when some runtime errors (e.g. dereferencing a NULL pointer) happen.
 */
#include <windows.h>

static void disable_runtime_error_dialog() __attribute__ ((constructor));
static void disable_runtime_error_dialog() {
	DWORD dwMode = SetErrorMode(SEM_NOGPFAULTERRORBOX);
	SetErrorMode(dwMode | SEM_NOGPFAULTERRORBOX);
}
