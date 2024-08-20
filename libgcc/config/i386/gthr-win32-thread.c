/* Implementation of threads compatibility routines for libgcc2.  */

/* Copyright (C) 1999-2024 Free Software Foundation, Inc.

This file is part of GCC.

GCC is free software; you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free
Software Foundation; either version 3, or (at your option) any later
version.

GCC is distributed in the hope that it will be useful, but WITHOUT ANY
WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
for more details.

Under Section 7 of GPL version 3, you are granted additional
permissions described in the GCC Runtime Library Exception, version
3.1, as published by the Free Software Foundation.

You should have received a copy of the GNU General Public License and
a copy of the GCC Runtime Library Exception along with this program;
see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see
<http://www.gnu.org/licenses/>.  */

/* This module is separate from the rest of the implementation because only
   one copy of it ought to be linked.  */

/* The implementation strategy for the c++0x thread support is as follows.

   A GNU thread is represented by a Win32 HANDLE that is obtained when the
   Win32 thread is created, except of course for the initial thread.  This
   Win32 HANDLE is stored in a descriptor keyed from TLS memory for every
   thread, so the self routine can return it instead of having to duplicate
   the pseudo-handle returned by GetCurrentThread each time it is invoked.
   For the initial thread, this Win32 HANDLE is created during the first
   call to the self routine using the aforementioned technique.

   Note that the equal routine compares the identifier of threads instead
   of their Win32 HANDLE, which will give the correct positive answer even
   in the case where distinct Win32 HANDLEs have been created for the same
   thread by multiple instances of libgcc included in the link.  */

#include "gthr-win32.h"

/* The thread descriptor keyed from TLS memory.  */
struct __gthr_win32_thr_desc
{
  void *(*func) (void*);
  void *args;
  HANDLE h;
};

/* The TLS key used by one instance of the library.  */
static __gthread_key_t __gthr_win32_tls = TLS_OUT_OF_INDEXES;

/* The initialization device for the TLS key.  */
static __gthread_once_t __gthr_win32_tls_once = __GTHREAD_ONCE_INIT;

/* Initialize the TLS key.  */

static void
__gthr_win32_tls_init (void)
{
  if (__gthread_key_create (&__gthr_win32_tls, free))
    abort ();
}

/* Wrapper routine around thread functions.  */

static DWORD
__gthr_win32_thread_wrapper (void *args)
{
  struct __gthr_win32_thr_desc *td = (struct __gthr_win32_thr_desc *) args;

  __gthread_setspecific (__gthr_win32_tls, td);

  DWORD exit_code = (DWORD) (ULONG_PTR) (*td->func) (td->args);

  ExitThread (exit_code);
  return exit_code;
}

/* Implement the __gthread_create routine.  */

int
__gthr_win32_create (__gthread_t *thr, void *(*func) (void*), void *args)
{
  struct __gthr_win32_thr_desc *td;

  __gthread_once (&__gthr_win32_tls_once, __gthr_win32_tls_init);

  td = malloc (sizeof (struct __gthr_win32_thr_desc));
  td->func = func;
  td->args = args;
  td->h = CreateThread (NULL, 0,
			(LPTHREAD_START_ROUTINE) __gthr_win32_thread_wrapper,
			(LPVOID) td, CREATE_SUSPENDED, NULL);
  if (td->h)
    {
      ResumeThread (td->h);
      *thr = (__gthread_t) td->h;
      return 0;
    }
  else
    {
      free (td);
      return (int) GetLastError ();
    }
}

/* Implement the __gthread_join routine.  */

int
__gthr_win32_join (__gthread_t thr, void **value_ptr)
{
  int status = 0;

  if (__gthr_win32_get_thread_id (thr) == GetCurrentThreadId ())
    return 1;

  if (WaitForSingleObject ((HANDLE) thr, INFINITE) == WAIT_OBJECT_0)
    {
      if (value_ptr)
	{
	  DWORD exit_code;
	  if (GetExitCodeThread ((HANDLE) thr, &exit_code))
	    *value_ptr = (void *) (ULONG_PTR) exit_code;
	  else
	    status = (int) GetLastError ();
	}
    }
  else
    status = (int) GetLastError ();

  CloseHandle ((HANDLE) thr);
  return status;
}

/* The initialization device for the GetThreadId replacement.  */
static __gthread_once_t __gthr_win32_GetThreadId_once = __GTHREAD_ONCE_INIT;

typedef LONG NTAPI __gthr_win32f_NtQueryInformationThread
(HANDLE, INT, PVOID, ULONG, PULONG);
static __gthr_win32f_NtQueryInformationThread *
__gthr_win32_NtQueryInformationThread;

typedef DWORD WINAPI __gthr_win32f_GetThreadId (HANDLE);
static __gthr_win32f_GetThreadId *__gthr_win32_GetThreadId;

static DWORD WINAPI
__gthr_win32_GetThreadId_dummy (HANDLE thr ATTRIBUTE_UNUSED)
{
  return 0;
}

static DWORD WINAPI
__gthr_win32_GetThreadId_replacement (HANDLE thr)
{
  struct __gthr_win32_THREAD_BASIC_INFORMATION
  {
    LONG ExitStatus;
    PVOID TebBaseAddress;
    DWORD_PTR UniqueProcess;
    DWORD_PTR UniqueThread;
    ULONG_PTR AffinityMask;
    DWORD Priority;
    DWORD BasePriority;
  } tbi;
  if (__gthr_win32_NtQueryInformationThread (thr, 0, &tbi,
					     sizeof (tbi), NULL) == 0)
    return tbi.UniqueThread;

  return 0;
}

static void
__gthr_win32_GetThreadId_init (void)
{
  HMODULE kernel32 = GetModuleHandle ("kernel32.dll");
  if (kernel32 != NULL)
    {
      __gthr_win32_GetThreadId = (__gthr_win32f_GetThreadId *)
	GetProcAddress (kernel32, "GetThreadId");
      if (__gthr_win32_GetThreadId != NULL)
	return;
    }

  __gthr_win32_GetThreadId = __gthr_win32_GetThreadId_dummy;

  HMODULE ntdll = GetModuleHandle ("ntdll.dll");
  if (ntdll == NULL)
    return;

  __gthr_win32_NtQueryInformationThread
    = (__gthr_win32f_NtQueryInformationThread *)
    GetProcAddress (ntdll, "NtQueryInformationThread");
  if (__gthr_win32_NtQueryInformationThread != NULL)
    __gthr_win32_GetThreadId = __gthr_win32_GetThreadId_replacement;
}

/* Implement the __gthr_win32_get_thread_id routine.  */

__gthr_win32_DWORD
__gthr_win32_get_thread_id (__gthread_t thr)
{
  __gthread_once (&__gthr_win32_GetThreadId_once,
		  __gthr_win32_GetThreadId_init);

  return __gthr_win32_GetThreadId ((HANDLE) thr);
}

/* Implement the __gthread_self routine.  */

__gthread_t
__gthr_win32_self (void)
{
  struct __gthr_win32_thr_desc *td;

  __gthread_once (&__gthr_win32_tls_once, __gthr_win32_tls_init);

  if (!(td = __gthread_getspecific (__gthr_win32_tls)))
    {
      HANDLE proc = GetCurrentProcess ();
      td = malloc (sizeof (struct __gthr_win32_thr_desc));
      td->func = NULL;
      td->args = NULL;
      if (!DuplicateHandle (proc, GetCurrentThread(), proc, &td->h, 0, FALSE,
			    DUPLICATE_SAME_ACCESS))
	abort ();
      __gthread_setspecific (__gthr_win32_tls, td);
    }

  return td->h;
}
