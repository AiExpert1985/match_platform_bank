#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>

#include "flutter_window.h"
#include "utils.h"

std::wstring GetExecutableDirectory() {
  wchar_t buffer[MAX_PATH];
  if (GetModuleFileNameW(nullptr, buffer, MAX_PATH) == 0) {
    return std::wstring();
  }
  std::wstring path(buffer);
  size_t last_slash = path.find_last_of(L"\\/");
  if (last_slash != std::wstring::npos) {
    return path.substr(0, last_slash);
  }
  return std::wstring();
}

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
                      _In_ wchar_t *command_line, _In_ int show_command) {
  // Attach to console when present (e.g., 'flutter run') or create a
  // new console when running with a debugger.
  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  // Initialize COM, so that it is available for use in the library and/or
  // plugins.
  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  std::wstring base_directory = GetExecutableDirectory();
  std::wstring data_directory = base_directory.empty() ? L"data" : base_directory + L"\\data";
  flutter::DartProject project(data_directory);

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();

  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"match_platform_bank", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::ShowWindow(window.GetHandle(), show_command);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
