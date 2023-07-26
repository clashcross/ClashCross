package fclashgobridge

/*
#include "stdint.h"
#include "dart_api_dl/dart_api_dl.h"
#include "dart_api_dl/dart_api_dl.c"
#include "dart_api_dl/dart_native_api.h"
// Go does not allow calling C function pointers directly.
// we mock a function to call Dart_PostCObject_DL
bool GoDart_PostCObject(Dart_Port_DL port, Dart_CObject* obj) {
  return Dart_PostCObject_DL(port, obj);
}
*/
import "C"
import (
	"fmt"
	"unsafe"
)

func InitDartApi(api unsafe.Pointer) {
	if C.Dart_InitializeApiDL(api) != 0 {
		panic("failed to create fclash dart bridge")
	} else {
		fmt.Println("Dart Api DL is initialized")
	}
}

func SendToPort(port int64, msg string) {
	var obj C.Dart_CObject
	obj._type = C.Dart_CObject_kString
	msg_obj := C.CString(msg) // go string -> char*s
	// union type, we do a force convertion
	ptr := unsafe.Pointer(&obj.value[0])
	*(**C.char)(ptr) = msg_obj
	ret := C.GoDart_PostCObject(C.Dart_Port_DL(port), &obj)
	if !ret {
		fmt.Println("ERROR: post to port ", port, " failed", msg)
	}
}
