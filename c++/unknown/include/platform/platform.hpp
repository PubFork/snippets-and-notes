#pragma once

#include <string>

class Platform {
private:

public:
  Platform() {};
  ~Platform() {};

  int install(std::string soft);
};
