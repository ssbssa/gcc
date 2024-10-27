//===-- sanitizer_common_interface.inc ------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
// Sanitizer Common interface list.
//===----------------------------------------------------------------------===//
INTERFACE_FUNCTION(__sanitizer_acquire_crash_state)
INTERFACE_FUNCTION(__sanitizer_set_death_callback)
INTERFACE_FUNCTION(__sanitizer_set_report_path)
INTERFACE_FUNCTION(__sanitizer_set_report_fd)
INTERFACE_FUNCTION(__sanitizer_get_report_path)
INTERFACE_WEAK_FUNCTION(__sanitizer_on_print)
INTERFACE_WEAK_FUNCTION(__sanitizer_report_error_summary)
INTERFACE_WEAK_FUNCTION(__sanitizer_sandbox_on_notify)
// Stacktrace interface.
INTERFACE_FUNCTION(__sanitizer_get_module_and_offset_for_pc)
INTERFACE_FUNCTION(__sanitizer_symbolize_global)
INTERFACE_FUNCTION(__sanitizer_symbolize_pc)
// Allocator interface.
INTERFACE_FUNCTION(__sanitizer_install_malloc_and_free_hooks)
INTERFACE_WEAK_FUNCTION(__sanitizer_free_hook)
INTERFACE_WEAK_FUNCTION(__sanitizer_malloc_hook)
// Memintrinsic functions.
INTERFACE_FUNCTION(__sanitizer_internal_memcpy)
INTERFACE_FUNCTION(__sanitizer_internal_memmove)
INTERFACE_FUNCTION(__sanitizer_internal_memset)
