set_project("FluidSynth")
set_version("2.3.3")
set_defaultmode("releasedbg")

if is_plat("linux") then
    option("alsa", {description = "Compile support for sound file output", default = true, type = "boolean"})
end
option("aufile", {description = "Compile support for sound file output", default = true, type = "boolean"})
option("dbus", {description = "Compile DBUS support", default = not is_plat("windows"), type = "boolean"})
option("jack", {description = "Compile JACK support", default = false, type = "boolean"})
option("libsndfile", {description = "Compile libsndfile support", default = true, type = "boolean"})
option("opensles", {description = "compile OpenSLES support", default = false, type = "boolean"})
option("network", {description = "Enable network support (requires BSD or WIN sockets)", default = false, type = "boolean"})
option("sdl2", {description = "Compile SDL2 audio support ", default = false, type = "boolean"})
-- option("pulseaudio", {description = "Compile PulseAudio support", default = false, type = "boolean"})
option("readline", {description = "Compile support for sound file output", default = false, type = "boolean"})
option("threads", {description = "Enable multi-threading support (such as parallel voice synthesis)", default = true, type = "boolean"})
option("openmp", {description = "Enable OpenMP support (parallelization of soundfont decoding, vectorization of voice mixing, etc.)", default = false, type = "boolean"})

add_requires("glib >=2.26.0")
if has_config("alsa") then
    add_requires("alsa-lib >=0.9.1")
    set_configvar("ALSA_SUPPORT", 1)
end
if has_config("libsndfile") then
    add_requires("libsndfile >=1.0.0")
    set_configvar("LIBSNDFILE_SUPPORT", 1)
    set_configvar("LIBSNDFILE_HASVORBIS", 1)
end
if has_config("pulseaudio") then
    -- todo
    set_configvar("LIBSNDFILE_SUPPORT", 1)
    set_configvar("LIBSNDFILE_HASVORBIS", 1)
end



set_languages("c90", "cxx98")

includes("check_cincludes.lua")
configvar_check_cincludes("HAVE_ARPA_INET_H", "arpa/inet.h")
configvar_check_cincludes("HAVE_ERRNO_H", "errno.h")
configvar_check_cincludes("HAVE_FCNTL_H", "fcntl.h")
configvar_check_cincludes("HAVE_GETOPT_H", "getopt.h")
configvar_check_cincludes("HAVE_INTTYPES_H", "inttypes.h")
configvar_check_cincludes("HAVE_LIMITS_H", "limits.h")
configvar_check_cincludes("HAVE_MATH_H", "math.h")
configvar_check_cincludes("HAVE_MEMORY_H", "memory.h")
configvar_check_cincludes("HAVE_NETINET_IN_H", "netinet/in.h")
configvar_check_cincludes("HAVE_NETINET_TCP_H", "netinet/tcp.h")
configvar_check_cincludes("HAVE_PTHREAD_H", "pthread.h")
configvar_check_cincludes("HAVE_SIGNAL_H", "signal.h")
configvar_check_cincludes("HAVE_STDARG_H", "stdarg.h")
configvar_check_cincludes("HAVE_STDINT_H", "stdint.h")
configvar_check_cincludes("HAVE_STDIO_H", "stdio.h")
configvar_check_cincludes("HAVE_STDLIB_H", "stdlib.h")
configvar_check_cincludes("HAVE_STRINGS_H", "strings.h")
configvar_check_cincludes("HAVE_STRING_H", "string.h")
configvar_check_cincludes("HAVE_SYS_MMAN_H", "sys/mman.h")
configvar_check_cincludes("HAVE_SYS_STAT_H", "sys/stat.h")
configvar_check_cincludes("HAVE_SYS_SOCKET_H", "sys/socket.h")
configvar_check_cincludes("HAVE_SYS_TIME_H", "sys/time.h")
configvar_check_cincludes("HAVE_SYS_TYPES_H", "sys/types.h")
configvar_check_cincludes("HAVE_UNISTD_H", "unistd.h")

-- todo winver and wdk support

if is_plat("windows", "mingw") then
    configvar_check_cincludes("HAVE_DSOUND_H", "dsound.h", {includes = "windows.h"})
    configvar_check_cincludes("HAVE_IO_H", "io.h")
    configvar_check_cincludes("HAVE_MMSYSTEM_H", "mmsystem.h", {includes = "windows.h"})
    configvar_check_cincludes("HAVE_OBJBASE_H", "objbase.h")
    configvar_check_cincludes("HAVE_WINDOWS_H", "windows.h")
    configvar_check_cincludes("HAVE_WASAPI_HEADERS", {"mmdeviceapi.h", "audioclient"})

  if ( enable-dsound AND HAVE_DSOUND_H )
    set ( WINDOWS_LIBS "${WINDOWS_LIBS};dsound;ksuser" )
    set ( DSOUND_SUPPORT 1 )
  endif ()

  if ( enable-winmidi AND HAVE_MMSYSTEM_H )
    set ( WINDOWS_LIBS "${WINDOWS_LIBS};winmm" )
    set ( WINMIDI_SUPPORT 1 )
  endif ()

  if ( enable-waveout AND HAVE_MMSYSTEM_H )
    set ( WINDOWS_LIBS "${WINDOWS_LIBS};winmm;ksuser" )
    set ( WAVEOUT_SUPPORT 1 )
  endif ()

  if ( enable-wasapi AND HAVE_WASAPI_HEADERS AND HAVE_OBJBASE_H)
    set ( WINDOWS_LIBS "${WINDOWS_LIBS};ole32" )
    set ( WASAPI_SUPPORT 1 )
  endif ()
end

if is_plat(("mingw")) then
    set_configvar("MINGW32", 1)
    add_cflags("-mms-bitfields")
    add_cxxflags("-mms-bitfields")
    if ( HAVE_SYS_MMAN_H )
      set ( WINDOWS_LIBS "${WINDOWS_LIBS};mman" )
    endif ()
end

if has_config("network") then
    set_configvar("NETWORK_SUPPORT", 1)
end

option("libm", {links = "m", showmenu = false})
option("pthread", {links = "pthread", showmenu = false})

local sources = {
    "src/**.c",
    "src/**.h",
}
target("libfluidsynth")
    set_version("3.2.1")
    if is_plat("windows", "mingw") then
        if has_config("network") then
            add_syslinks("ws2_32")
        end
        add_defines("FLUIDSYNTH_DLL_EXPORTS")
    end
    if has_config("libm") then
        add_links("m")
    end
    if has_config("pthread") then
        add_links("pthread")
    end

target("fluidsynth")
    if is_plat("windows", "mingw") then
        if has_config("network") then
            add_syslinks("ws2_32")
        end
        add_defines("FLUIDSYNTH_NOT_A_DLL")
    end