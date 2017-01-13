 ##############################################################################
 #
 #  Copyright (C) 2014 Google, Inc.
 #
 #  Licensed under the Apache License, Version 2.0 (the "License");
 #  you may not use this file except in compliance with the License.
 #  You may obtain a copy of the License at:
 #
 #  http://www.apache.org/licenses/LICENSE-2.0
 #
 #  Unless required by applicable law or agreed to in writing, software
 #  distributed under the License is distributed on an "AS IS" BASIS,
 #  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 #  See the License for the specific language governing permissions and
 #  limitations under the License.
 #
 ##############################################################################

LOCAL_PATH := $(call my-dir)

# Common variables
# ========================================================

# TODO(mcchou): Remove socket_utils sources after platform specific
# dependencies are abstracted.
btosiCommonSrc := \
    ./src/alarm.cc \
    ./src/allocation_tracker.cc \
    ./src/allocator.cc \
    ./src/array.cc \
    ./src/buffer.cc \
    ./src/compat.cc \
    ./src/config.cc \
    ./src/data_dispatcher.cc \
    ./src/eager_reader.cc \
    ./src/fixed_queue.cc \
    ./src/future.cc \
    ./src/hash_map_utils.cc \
    ./src/list.cc \
    ./src/metrics.cc \
    ./src/mutex.cc \
    ./src/osi.cc \
    ./src/properties.cc \
    ./src/reactor.cc \
    ./src/ringbuffer.cc \
    ./src/semaphore.cc \
    ./src/socket.cc \
    ./src/socket_utils/socket_local_client.cc \
    ./src/socket_utils/socket_local_server.cc \
    ./src/thread.cc \
    ./src/time.cc \
    ./src/wakelock.cc

btosiCommonTestSrc := \
    ./test/AlarmTestHarness.cc \
    ./test/AllocationTestHarness.cc \
    ./test/alarm_test.cc \
    ./test/allocation_tracker_test.cc \
    ./test/allocator_test.cc \
    ./test/array_test.cc \
    ./test/config_test.cc \
    ./test/data_dispatcher_test.cc \
    ./test/eager_reader_test.cc \
    ./test/fixed_queue_test.cc \
    ./test/future_test.cc \
    ./test/hash_map_utils_test.cc \
    ./test/leaky_bonded_queue_test.cc \
    ./test/list_test.cc \
    ./test/metrics_test.cc \
    ./test/properties_test.cc \
    ./test/rand_test.cc \
    ./test/reactor_test.cc \
    ./test/ringbuffer_test.cc \
    ./test/semaphore_test.cc \
    ./test/thread_test.cc \
    ./test/time_test.cc \
    ./test/wakelock_test.cc

btosiCommonIncludes := \
    $(LOCAL_PATH)/.. \
    $(LOCAL_PATH)/../include \
    $(LOCAL_PATH)/../utils/include \
    $(LOCAL_PATH)/../stack/include \
    $(bluetooth_C_INCLUDES)

# Bluetooth Protobuf static library for target
# ========================================================
include $(CLEAR_VARS)
LOCAL_CPP_EXTENSION := .cc
LOCAL_MODULE := libbt-protos
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
generated_sources_dir := $(call local-generated-sources-dir)
LOCAL_EXPORT_C_INCLUDE_DIRS := \
    $(generated_sources_dir)/proto/system/bt
LOCAL_SRC_FILES := $(call all-proto-files-under,src/protos/)

LOCAL_CFLAGS += $(bluetooth_CFLAGS)
LOCAL_CONLYFLAGS += $(bluetooth_CONLYFLAGS)
LOCAL_CPPFLAGS += $(bluetooth_CPPFLAGS)

include $(BUILD_STATIC_LIBRARY)

# Bluetooth Protobuf static library for host
# ========================================================
include $(CLEAR_VARS)
LOCAL_CPP_EXTENSION := .cc
LOCAL_MODULE := libbt-protos
LOCAL_MODULE_CLASS := STATIC_LIBRARIES
LOCAL_IS_HOST_MODULE := true
generated_sources_dir := $(call local-generated-sources-dir)
LOCAL_EXPORT_C_INCLUDE_DIRS := \
    $(generated_sources_dir)/proto/system/bt
LOCAL_SRC_FILES := $(call all-proto-files-under,src/protos/)

LOCAL_CFLAGS += $(bluetooth_CFLAGS)
LOCAL_CONLYFLAGS += $(bluetooth_CONLYFLAGS)
LOCAL_CPPFLAGS += $(bluetooth_CPPFLAGS)

include $(BUILD_HOST_STATIC_LIBRARY)

# libosi static library for target
# ========================================================
include $(CLEAR_VARS)
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(btosiCommonIncludes)
LOCAL_SRC_FILES := $(btosiCommonSrc)
LOCAL_MODULE := libosi
LOCAL_MODULE_TAGS := optional
LOCAL_SHARED_LIBRARIES := libc liblog libchrome
LOCAL_STATIC_LIBRARIES := libbt-protos
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

LOCAL_CFLAGS += $(bluetooth_CFLAGS)
LOCAL_CONLYFLAGS += $(bluetooth_CONLYFLAGS)
LOCAL_CPPFLAGS += $(bluetooth_CPPFLAGS)

include $(BUILD_STATIC_LIBRARY)

# libosi static library for host
# ========================================================
ifeq ($(HOST_OS),linux)
include $(CLEAR_VARS)
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(btosiCommonIncludes)
LOCAL_SRC_FILES := $(btosiCommonSrc)
LOCAL_MODULE := libosi-host
LOCAL_MODULE_TAGS := optional
LOCAL_SHARED_LIBRARIES := liblog libchrome
LOCAL_STATIC_LIBRARIES := libbt-protos
LOCAL_MODULE_CLASS := STATIC_LIBRARIES

# TODO(armansito): Setting _GNU_SOURCE isn't very platform-independent but
# should be compatible for a Linux host OS. We should figure out what to do for
# a non-Linux host OS.
LOCAL_CFLAGS += $(bluetooth_CFLAGS) -D_GNU_SOURCE -DOS_GENERIC
LOCAL_CONLYFLAGS += $(bluetooth_CONLYFLAGS)
LOCAL_CPPFLAGS += $(bluetooth_CPPFLAGS)

include $(BUILD_HOST_STATIC_LIBRARY)
endif

#
# Note: It's good to get the tests compiled both for the host and the target so
# we get to test with both Bionic libc and glibc
#
# libosi unit tests for target
# ========================================================
include $(CLEAR_VARS)
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(btosiCommonIncludes)
LOCAL_SRC_FILES := $(btosiCommonTestSrc)
LOCAL_MODULE := net_test_osi
LOCAL_MODULE_TAGS := tests
LOCAL_SHARED_LIBRARIES := libc liblog libprotobuf-cpp-lite libchrome libcutils
LOCAL_STATIC_LIBRARIES := libosi libbt-protos libgmock

LOCAL_CFLAGS += $(bluetooth_CFLAGS)
LOCAL_CONLYFLAGS += $(bluetooth_CONLYFLAGS)
LOCAL_CPPFLAGS += $(bluetooth_CPPFLAGS)

include $(BUILD_NATIVE_TEST)

# libosi unit tests for host
# ========================================================
ifeq ($(HOST_OS),linux)
include $(CLEAR_VARS)
LOCAL_CPP_EXTENSION := .cc
LOCAL_C_INCLUDES := $(btosiCommonIncludes)
LOCAL_SRC_FILES := $(btosiCommonTestSrc)
LOCAL_LDLIBS := -lrt -lpthread
LOCAL_MODULE := net_test_osi
LOCAL_MODULE_TAGS := tests
LOCAL_SHARED_LIBRARIES := liblog libprotobuf-cpp-lite libchrome
LOCAL_STATIC_LIBRARIES := libosi-host libbt-protos libgmock

LOCAL_CFLAGS += $(bluetooth_CFLAGS) -DOS_GENERIC
LOCAL_CONLYFLAGS += $(bluetooth_CONLYFLAGS)
LOCAL_CPPFLAGS += $(bluetooth_CPPFLAGS)

include $(BUILD_HOST_NATIVE_TEST)
endif
