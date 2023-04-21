#include "modloader/shared/modloader.hpp"

static ModInfo modInfo {
    MOD_ID,
    VERSION
};

extern "C" void setModInfo(ModInfo &info) {
    info = modInfo;
}

// setup
extern "C" void onModInit() {

}

// load
extern "C" void onModLateInit() {

}