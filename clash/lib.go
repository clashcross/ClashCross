package main

/*
#include "stdint.h"
*/
import "C"
import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strconv"
	"time"
	"unsafe"

	"github.com/Dreamacro/clash/adapter"
	"github.com/Dreamacro/clash/adapter/outboundgroup"
	"github.com/Dreamacro/clash/common/observable"
	"github.com/Dreamacro/clash/component/profile/cachefile"
	"github.com/Dreamacro/clash/component/resolver"
	"github.com/Dreamacro/clash/config"
	"github.com/Dreamacro/clash/constant"
	"github.com/Dreamacro/clash/hub"
	"github.com/Dreamacro/clash/hub/executor"
	P "github.com/Dreamacro/clash/listener"
	"github.com/Dreamacro/clash/log"
	"github.com/Dreamacro/clash/tunnel"
	"github.com/Dreamacro/clash/tunnel/statistic"
	fclashgobridge "github.com/kingtous/fclash-go-bridge"
)

var (
	options        []hub.Option
	log_subscriber observable.Subscription
)

//export clash_init
func clash_init(home_dir *C.char) int {
	home := C.GoString(home_dir)
	// constant.
	err := config.Init(home)
	if err != nil {
		return -1
	}
	return 0
}

//export set_config
func set_config(config_path *C.char) int {
	file := C.GoString(config_path)
	if _, err := executor.ParseWithPath(file); err != nil {
		fmt.Println("config validate failed:", err)
		return -1
	}
	constant.SetConfig(file)
	return 0
}

//export set_home_dir
func set_home_dir(home *C.char) int {
	home_gostr := C.GoString(home)
	info, err := os.Stat(home_gostr)
	if err == nil && info.IsDir() {
		fmt.Println("GO: set home dir to", home_gostr)
		constant.SetHomeDir(home_gostr)
		return 0
	} else {
		if err != nil {
			fmt.Println("error:", err)
		}
	}
	return -1
}

//export get_config
func get_config() *C.char {
	return C.CString(constant.Path.Config())
}

//export set_ext_controller
func set_ext_controller(port uint64) int {
	url := "127.0.0.1:" + strconv.FormatUint(port, 10)
	options = append(options, hub.WithExternalController(url))
	return 0
}

//export clear_ext_options
func clear_ext_options() {
	options = options[:0]
}

//export is_config_valid
func is_config_valid(config_path *C.char) int {
	if _, err := executor.ParseWithPath(C.GoString(config_path)); err != nil {
		fmt.Println("error reading config:", err)
		return -1
	}
	return 0
}

//export get_all_connections
func get_all_connections() *C.char {
	snapshot := statistic.DefaultManager.Snapshot()
	data, err := json.Marshal(snapshot)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export close_all_connections
func close_all_connections() {
	for _, connection := range statistic.DefaultManager.Snapshot().Connections {
		err := connection.Close()
		if err != nil {
			fmt.Println("warning:", err)
		}
	}
}

//export close_connection
func close_connection(id *C.char) bool {
	connection_id := C.GoString(id)
	for _, connection := range statistic.DefaultManager.Snapshot().Connections {
		if connection.ID() == connection_id {
			err := connection.Close()
			if err != nil {
				fmt.Println("warning:", err)
			}
			return true
		}
	}
	return false
}

//export parse_options
func parse_options() bool {
	err := hub.Parse(options...)
	if err != nil {
		return true
	}
	return false
}

//export get_traffic
func get_traffic() *C.char {
	up, down := statistic.DefaultManager.Now()
	traffic := map[string]int64{
		"Up":   up,
		"Down": down,
	}
	data, err := json.Marshal(traffic)
	if err != nil {
		fmt.Println("Error:", err)
		return C.CString("")
	}
	return C.CString(string(data))
}

//export init_native_api_bridge
func init_native_api_bridge(api unsafe.Pointer) {
	fclashgobridge.InitDartApi(api)
}

//export start_log
func start_log(port C.longlong) {
	if log_subscriber != nil {
		log.UnSubscribe(log_subscriber)
		log_subscriber = nil
	}
	log_subscriber = log.Subscribe()
	go func() {
		for elem := range log_subscriber {
			lg := elem
			data, err := json.Marshal(lg)
			if err != nil {
				fmt.Println("Error:", err)
			}
			ret_str := string(data)
			fclashgobridge.SendToPort(int64(port), ret_str)
		}
	}()
	fmt.Println("[GO] subscribe logger on dart bridge port", int64(port))
}

//export stop_log
func stop_log() {
	if log_subscriber != nil {
		log.UnSubscribe(log_subscriber)
		fmt.Println("Logger stopped")
		log_subscriber = nil
	}
}

//export change_proxy
func change_proxy(selector_name *C.char, proxy_name *C.char) C.long {
	proxies := tunnel.Proxies()
	proxy := proxies[C.GoString(selector_name)]
	if proxy == nil {
		return C.long(-1)
	}
	adapter_proxy := proxy.(*adapter.Proxy)
	selector, ok := adapter_proxy.ProxyAdapter.(*outboundgroup.Selector)
	if !ok {
		// not selector
		return C.long(-1)
	}
	if err := selector.Set(C.GoString(proxy_name)); err != nil {
		fmt.Println("", err)
		return C.long(-1)
	}
	cachefile.Cache().SetSelected(string(C.GoString(selector_name)), string(C.GoString(proxy_name)))
	return C.long(0)
}

type configSchema struct {
	Port        *int               `json:"port"`
	SocksPort   *int               `json:"socks-port"`
	RedirPort   *int               `json:"redir-port"`
	TProxyPort  *int               `json:"tproxy-port"`
	MixedPort   *int               `json:"mixed-port"`
	AllowLan    *bool              `json:"allow-lan"`
	BindAddress *string            `json:"bind-address"`
	Mode        *tunnel.TunnelMode `json:"mode"`
	LogLevel    *log.LogLevel      `json:"log-level"`
	IPv6        *bool              `json:"ipv6"`
}

func pointerOrDefault(p *int, def int) int {
	if p != nil {
		return *p
	}

	return def
}

//export change_config_field
func change_config_field(s *C.char) C.long {
	// todo
	general := &configSchema{}
	json_str := C.GoString(s)
	if err := json.Unmarshal([]byte(json_str), general); err != nil {
		fmt.Println(err)
		return C.long(-1)
	}
	// copy from clash source code
	if general.AllowLan != nil {
		P.SetAllowLan(*general.AllowLan)
	}

	if general.BindAddress != nil {
		P.SetBindAddress(*general.BindAddress)
	}

	ports := P.GetPorts()

	tcpIn := tunnel.TCPIn()
	udpIn := tunnel.UDPIn()
	// natTable := tunnel.NatTable()

	P.ReCreateHTTP(pointerOrDefault(general.Port, ports.Port), tcpIn)
	P.ReCreateSocks(pointerOrDefault(general.SocksPort, ports.SocksPort), tcpIn, udpIn)
	P.ReCreateRedir(pointerOrDefault(general.RedirPort, ports.RedirPort), tcpIn, udpIn)
	P.ReCreateTProxy(pointerOrDefault(general.TProxyPort, ports.TProxyPort), tcpIn, udpIn)
	P.ReCreateMixed(pointerOrDefault(general.MixedPort, ports.MixedPort), tcpIn, udpIn)

	if general.Mode != nil {
		tunnel.SetMode(*general.Mode)
	}

	if general.LogLevel != nil {
		log.SetLevel(*general.LogLevel)
	}

	if general.IPv6 != nil {
		resolver.DisableIPv6 = !*general.IPv6
	}
	return C.long(0)
}

//export async_test_delay
func async_test_delay(proxy_name *C.char, url *C.char, timeout C.long, port C.longlong) {
	go func() {
		ctx, cancel := context.WithTimeout(context.Background(), time.Millisecond*time.Duration(int64(timeout)))
		defer cancel()
		proxies := tunnel.Proxies()
		proxy := proxies[C.GoString(proxy_name)]
		if proxy == nil {
			data, err := json.Marshal(map[string]int64{
				"delay": -1,
			})
			if err != nil {
				return
			}
			fclashgobridge.SendToPort(int64(port), string(data))
			return
		}
		delay, _, err := proxy.URLTest(ctx, C.GoString(url))
		if err != nil || delay == 0 {
			data, err := json.Marshal(map[string]int64{
				"delay": -1,
			})
			if err != nil {
				return
			}
			fclashgobridge.SendToPort(int64(port), string(data))
			return
		}
		data, err := json.Marshal(map[string]uint16{
			"delay": delay,
		})
		if err != nil {
			fmt.Println("err: ", err)
		}
		fclashgobridge.SendToPort(int64(port), string(data))
	}()
}

//export get_proxies
func get_proxies() *C.char {
	proxies := tunnel.Proxies()
	for _, provider := range tunnel.Providers() {
		for _, proxy := range provider.Proxies() {
			proxies[proxy.Name()] = proxy
		}
	}
	data, err := json.Marshal(map[string]map[string]constant.Proxy{
		"proxies": proxies,
	})
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(data))
}

//export get_configs
func get_configs() *C.char {
	general := executor.GetGeneral()
	data, err := json.Marshal(general)
	if err != nil {
		return C.CString("")
	}
	return C.CString(string(data))
}

func main() {
	fmt.Println("hello clash")
}
