#define _WIN32_WINNT 0x0601
#include <windows.h>
#include <io.h>


// 检测 fd 是否连接终端; 返回 1 表示是终端, 0 表示不是
unsigned char is_fd_terminal(int fd)
{
	if (_isatty(fd)) {
		return 1;
	}

	return 0;
}

// 获取系统逻辑 CPU 核心数(支持 >64 核，兼容老系统)
DWORD get_logical_cpu_count(void)
{
	DWORD count = GetActiveProcessorCount(ALL_PROCESSOR_GROUPS);

	if (count == 0) {
		// 兼容老系统(Win2000/XP/2003)
		SYSTEM_INFO si;
		GetSystemInfo(&si);
		count = si.dwNumberOfProcessors;
	}

	return count;
}

/**
 * @brief Detect processor number and fd1/fd2 terminal status
 *
 * @return int
 * bit   7: fd1 isatty
 * bit   6: fd2 isatty
 * bit 5-0: processor_count - 1
 */
int main(void)
{
	unsigned char fd1 = is_fd_terminal(1);
	unsigned char fd2 = is_fd_terminal(2);
	DWORD count = get_logical_cpu_count();

	if (count >= 0x3F) {
		count = 0x3F;
	} else if (count > 0) {
		count--;
	} else {
		count = 0;
	}

	return (fd1 << 7) | (fd2 << 6) | count;
}
